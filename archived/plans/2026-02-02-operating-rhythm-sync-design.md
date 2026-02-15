# Operating Rhythm Activity Sync Design

**Date:** 2 February 2026
**Status:** Approved
**Author:** Claude (Brainstorming Session)

## Problem Statement

The Operating Rhythm page auto-completes client activities based on dates instead of actual completion status. The `AnnualOrbitView` component generates mock data when `activityCompletions` prop is not passed (which it never is), causing past months to show 70-100% completion regardless of reality.

### Root Cause
```typescript
// AnnualOrbitView.tsx lines 126-177
const completionsByMonth = useMemo(() => {
  if (activityCompletions) {
    // Use provided completion data ← THIS PATH IS NEVER TAKEN
  }
  // Generate deterministic mock data ← THIS ALWAYS RUNS
  if (monthData.month < currentMonth) {
    // Past months: 70-100% completion ← AUTO-COMPLETING!
  }
})
```

## Solution Overview

1. **New database table** for activity requirements by segment tier
2. **Real-time Excel sync** with daily fallback for CSEs using Excel
3. **Deduplication logic** merging Excel + Dashboard events to single records
4. **Data transformation** from compliance view to monthly orbit format
5. **UI updates** showing all 12 activities with recommended vs actual

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Excel sync frequency | Real-time with daily fallback | Balance responsiveness with reliability |
| Deduplication | Merge to single record | Client + event_type + date = unique key |
| Activity requirements | Database table | Nothing hardcoded, configurable per year |
| Data source | Multiple (Excel + Dashboard) | CSEs use different workflows |

---

## 1. Database Schema

### 1.1 New Table: `segment_activity_requirements`

Stores expected activity frequency by segment tier. Replaces hardcoded values in `segment-activities.ts`.

```sql
CREATE TABLE segment_activity_requirements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  year INTEGER NOT NULL,
  segment TEXT NOT NULL,  -- Giant, Sleeping Giant, Collaboration, Leverage, Maintain, Nurture
  event_type_id UUID NOT NULL REFERENCES segmentation_event_types(id),
  expected_count INTEGER NOT NULL,  -- Total per year (12=monthly, 4=quarterly, 2=semi-annual, 1=annual)
  frequency TEXT NOT NULL,  -- Monthly, Quarterly, Semi-Annual, Annual
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(year, segment, event_type_id)
);

-- Enable RLS
ALTER TABLE segment_activity_requirements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated read" ON segment_activity_requirements
  FOR SELECT TO authenticated USING (true);

-- Index for common queries
CREATE INDEX idx_segment_activity_requirements_year_segment
  ON segment_activity_requirements(year, segment);
```

### 1.2 Seed Data (2026)

Based on Excel "Activities" sheet:

| Activity | Giant | Sleeping Giant | Collaboration | Leverage | Maintain | Nurture |
|----------|-------|----------------|---------------|----------|----------|---------|
| President/Group Leader Engagement | 4 | 2 | 2 | 1 | 1 | 0 |
| EVP Engagement | 4 | 2 | 2 | 1 | 0 | 0 |
| Strategic Ops Plan Meeting | 2 | 2 | 1 | 1 | 0 | 0 |
| Satisfaction Action Plan | 1 | 1 | 1 | 1 | 1 | 1 |
| SLA/Service Review Meeting | 4 | 2 | 2 | 2 | 1 | 0 |
| CE On-Site Attendance | 2 | 1 | 1 | 0 | 0 | 0 |
| Insight Touch Point | 12 | 12 | 12 | 4 | 4 | 4 |
| Health Check (Opal) | 4 | 4 | 4 | 4 | 4 | 4 |
| Upcoming Release Planning | 4 | 4 | 4 | 4 | 2 | 2 |
| Whitespace Demos (Sunrise) | 4 | 2 | 2 | 2 | 1 | 0 |
| APAC Client Forum / User Group | 2 | 2 | 2 | 2 | 2 | 2 |
| Updating Client 360 | 4 | 4 | 4 | 4 | 4 | 4 |

### 1.3 New Column: `segmentation_events.source`

Track where each completion originated:

```sql
ALTER TABLE segmentation_events
  ADD COLUMN source TEXT DEFAULT 'dashboard'
  CHECK (source IN ('dashboard', 'excel'));

-- Update existing records
UPDATE segmentation_events SET source = 'dashboard' WHERE source IS NULL;
```

---

## 2. Excel Sync Implementation

### 2.1 Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Excel File (OneDrive)                        │
│  /APAC Clients - Client Success/.../Activity Register 2026.xlsx │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    File Watcher (chokidar)                       │
│  - Watches for file changes                                      │
│  - Triggers sync on modification                                 │
│  - Daily fallback via cron job                                   │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Excel Parser (xlsx)                           │
│  - Reads each client sheet                                       │
│  - Extracts: Client, Activity, Date, Completed                   │
│  - Maps to segmentation_event_types                              │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   Deduplication Logic                            │
│  - Key: client_name + event_type_id + event_date                 │
│  - If exists: Update (prefer dashboard source if conflict)       │
│  - If new: Insert with source='excel'                            │
└───────────────────────────┬─────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                   segmentation_events table                      │
│  - Single source of truth                                        │
│  - Refreshes event_compliance_summary view                       │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Excel Parser Logic

```typescript
// src/lib/excel-sync/activity-register-parser.ts

interface ExcelActivity {
  clientName: string
  activityName: string
  month: number  // 1-12
  year: number
  completed: boolean
  completedDate: Date | null
}

function parseActivityRegister(filePath: string): ExcelActivity[] {
  const workbook = XLSX.readFile(filePath)
  const activities: ExcelActivity[] = []

  // Skip non-client sheets
  const skipSheets = ['Client Segments', 'Activities', 'Summary']

  for (const sheetName of workbook.SheetNames) {
    if (skipSheets.includes(sheetName)) continue

    const sheet = workbook.Sheets[sheetName]
    const clientName = sheetName  // Sheet name = client name

    // Parse rows: Activity | Jan Completed | Jan Date | Feb Completed | Feb Date | ...
    // Row structure from Excel analysis
    for (let row = 2; row <= 13; row++) {  // 12 activities
      const activityName = sheet[`A${row}`]?.v

      for (let month = 1; month <= 12; month++) {
        const completedCol = getCompletedColumn(month)  // B, D, F, H, J, L, N, P, R, T, V, X
        const dateCol = getDateColumn(month)            // C, E, G, I, K, M, O, Q, S, U, W, Y

        const completed = sheet[`${completedCol}${row}`]?.v === true
        const dateValue = sheet[`${dateCol}${row}`]?.v

        if (completed) {
          activities.push({
            clientName,
            activityName,
            month,
            year: 2026,
            completed: true,
            completedDate: dateValue ? excelDateToJS(dateValue) : null
          })
        }
      }
    }
  }

  return activities
}
```

### 2.3 Sync Service

```typescript
// src/lib/excel-sync/activity-sync-service.ts

export class ActivitySyncService {
  private watcher: FSWatcher | null = null
  private syncInProgress = false

  // Real-time sync via file watcher
  startWatching(filePath: string) {
    this.watcher = chokidar.watch(filePath, {
      persistent: true,
      awaitWriteFinish: { stabilityThreshold: 2000 }
    })

    this.watcher.on('change', async () => {
      if (!this.syncInProgress) {
        await this.syncFromExcel(filePath)
      }
    })
  }

  // Daily fallback sync (called by cron)
  async dailySync(filePath: string) {
    await this.syncFromExcel(filePath)
  }

  private async syncFromExcel(filePath: string) {
    this.syncInProgress = true
    try {
      const activities = parseActivityRegister(filePath)
      await this.upsertActivities(activities)
    } finally {
      this.syncInProgress = false
    }
  }

  private async upsertActivities(activities: ExcelActivity[]) {
    for (const activity of activities) {
      // Find event type
      const eventType = await this.findEventType(activity.activityName)
      if (!eventType) continue

      // Find client
      const client = await this.findClient(activity.clientName)
      if (!client) continue

      // Upsert with deduplication
      await supabase.rpc('upsert_segmentation_event', {
        p_client_id: client.id,
        p_event_type_id: eventType.id,
        p_event_date: activity.completedDate || new Date(activity.year, activity.month - 1, 15),
        p_completed: activity.completed,
        p_source: 'excel'
      })
    }
  }
}
```

### 2.4 Deduplication RPC

```sql
CREATE OR REPLACE FUNCTION upsert_segmentation_event(
  p_client_id UUID,
  p_event_type_id UUID,
  p_event_date DATE,
  p_completed BOOLEAN,
  p_source TEXT
) RETURNS UUID AS $$
DECLARE
  v_existing_id UUID;
  v_result_id UUID;
BEGIN
  -- Check for existing record (same client + event type + date)
  SELECT id INTO v_existing_id
  FROM segmentation_events
  WHERE client_id = p_client_id
    AND event_type_id = p_event_type_id
    AND DATE_TRUNC('day', event_date) = DATE_TRUNC('day', p_event_date);

  IF v_existing_id IS NOT NULL THEN
    -- Update existing, but preserve dashboard source (higher priority)
    UPDATE segmentation_events
    SET
      completed = COALESCE(p_completed, completed),
      source = CASE
        WHEN source = 'dashboard' THEN 'dashboard'  -- Dashboard wins
        ELSE p_source
      END,
      updated_at = now()
    WHERE id = v_existing_id
    RETURNING id INTO v_result_id;
  ELSE
    -- Insert new record
    INSERT INTO segmentation_events (client_id, event_type_id, event_date, completed, source)
    VALUES (p_client_id, p_event_type_id, p_event_date, p_completed, p_source)
    RETURNING id INTO v_result_id;
  END IF;

  RETURN v_result_id;
END;
$$ LANGUAGE plpgsql;
```

---

## 3. Data Transformation

### 3.1 Hook: `useOperatingRhythmData`

New hook that combines requirements + actuals for the orbit view:

```typescript
// src/hooks/useOperatingRhythmData.ts

interface MonthlyActivityData {
  month: number
  activities: {
    typeId: string
    typeName: string
    expected: number  // From requirements table
    completed: number  // From segmentation_events
    clients: {
      clientId: string
      clientName: string
      completed: boolean
      completedDate: Date | null
    }[]
  }[]
}

export function useOperatingRhythmData(year: number) {
  // 1. Fetch activity requirements by segment
  const { data: requirements } = useQuery(
    ['activity-requirements', year],
    () => fetchActivityRequirements(year)
  )

  // 2. Fetch all client completions
  const { data: completions } = useAllClientsCompliance(year)

  // 3. Fetch client segments
  const { data: clientSegments } = useQuery(
    ['client-segments', year],
    () => fetchClientSegments(year)
  )

  // 4. Transform to monthly view
  const monthlyData = useMemo(() => {
    if (!requirements || !completions || !clientSegments) return null

    return transformToMonthlyView(requirements, completions, clientSegments)
  }, [requirements, completions, clientSegments])

  return { data: monthlyData, isLoading: !monthlyData }
}
```

### 3.2 Transformation Logic

```typescript
function transformToMonthlyView(
  requirements: SegmentActivityRequirement[],
  completions: ClientCompliance[],
  clientSegments: ClientSegment[]
): MonthlyActivityData[] {
  const months: MonthlyActivityData[] = []

  for (let month = 1; month <= 12; month++) {
    const monthData: MonthlyActivityData = { month, activities: [] }

    // Group by activity type
    const activityTypes = new Set(requirements.map(r => r.event_type_id))

    for (const typeId of activityTypes) {
      const typeName = requirements.find(r => r.event_type_id === typeId)?.event_type_name

      // Calculate expected for this month (distribute yearly count across months)
      let totalExpected = 0
      const clientDetails: MonthlyActivityData['activities'][0]['clients'] = []

      for (const client of clientSegments) {
        const requirement = requirements.find(
          r => r.segment === client.segment && r.event_type_id === typeId
        )

        if (requirement) {
          const monthlyExpected = getExpectedForMonth(requirement, month)
          totalExpected += monthlyExpected

          // Check if completed
          const clientCompletion = completions.find(c => c.client_id === client.id)
          const eventCompletion = clientCompletion?.event_compliance.find(
            e => e.event_type_id === typeId && getMonth(e.event_date) === month
          )

          clientDetails.push({
            clientId: client.id,
            clientName: client.name,
            completed: !!eventCompletion?.completed,
            completedDate: eventCompletion?.event_date || null
          })
        }
      }

      monthData.activities.push({
        typeId,
        typeName,
        expected: totalExpected,
        completed: clientDetails.filter(c => c.completed).length,
        clients: clientDetails
      })
    }

    months.push(monthData)
  }

  return months
}
```

---

## 4. UI Updates

### 4.1 AnnualOrbitView Changes

```typescript
// src/components/operating-rhythm/AnnualOrbitView.tsx

// Update props interface
interface AnnualOrbitViewProps {
  // ... existing props
  activityData?: MonthlyActivityData[]  // New: structured data
}

// Replace mock data generation with real data
const completionsByMonth = useMemo(() => {
  if (!activityData) return generateEmptyMonths()  // Empty, not mock

  return activityData.map(monthData => ({
    month: monthData.month,
    activities: monthData.activities.map(a => ({
      ...a,
      completionRate: a.expected > 0 ? (a.completed / a.expected) * 100 : 0
    }))
  }))
}, [activityData])
```

### 4.2 Operating Rhythm Page Integration

```typescript
// src/app/(dashboard)/operating-rhythm/page.tsx

export default function OperatingRhythmPage() {
  const currentYear = new Date().getFullYear()
  const { data: activityData, isLoading } = useOperatingRhythmData(currentYear)

  return (
    <AnnualOrbitView
      activityData={activityData}
      // ... other props
    />
  )
}
```

### 4.3 Visual Design: Recommended vs Actual

The orbit view will show:
- **Ring segments** = Expected activities (plan)
- **Filled portions** = Completed activities (actual)
- **Colour coding**:
  - Green: On track (≥80% of expected)
  - Yellow: At risk (50-79% of expected)
  - Red: Behind (<50% of expected)

---

## 5. Implementation Sequence

### Phase 1: Database (Day 1)
1. Create `segment_activity_requirements` table
2. Seed 2026 data from Excel
3. Add `source` column to `segmentation_events`
4. Create `upsert_segmentation_event` RPC

### Phase 2: Excel Sync (Day 2)
1. Create Excel parser module
2. Implement sync service with file watcher
3. Add daily cron fallback
4. Test deduplication logic

### Phase 3: Data Layer (Day 3)
1. Create `useOperatingRhythmData` hook
2. Implement transformation logic
3. Add API route for requirements
4. Test data flow end-to-end

### Phase 4: UI Integration (Day 4)
1. Update `AnnualOrbitView` props and rendering
2. Integrate hook in Operating Rhythm page
3. Add visual indicators for recommended vs actual
4. Test all 12 activity types display

### Phase 5: Testing & Docs (Day 5)
1. End-to-end testing
2. Edge cases (new clients, segment changes)
3. Create bug report documenting the fix
4. Update CLAUDE.md with new patterns

---

## 6. Testing Plan

### Unit Tests
- Excel parser correctly extracts all 12 activities
- Deduplication prefers dashboard over Excel
- Monthly distribution calculation for different frequencies

### Integration Tests
- File watcher triggers sync on Excel change
- Data flows from Excel → DB → Hook → UI
- Materialized view refreshes correctly

### Manual Testing
- Verify all 12 activities show in orbit
- Complete activity via Dashboard, verify shows
- Complete activity via Excel, verify shows
- Complete same activity both ways, verify dedupes

---

## 7. Rollback Plan

If issues arise:
1. Revert to mock data by not passing `activityData` prop
2. Disable file watcher (no impact on existing data)
3. Materialized view can be rebuilt from source tables

---

## Appendix: Excel Column Mapping

| Column | Content |
|--------|---------|
| A | Activity name |
| B | Jan Completed (True/False) |
| C | Jan Date |
| D | Feb Completed |
| E | Feb Date |
| ... | ... |
| X | Dec Completed |
| Y | Dec Date |

Sheets to parse: All except "Client Segments", "Activities", "Summary"
