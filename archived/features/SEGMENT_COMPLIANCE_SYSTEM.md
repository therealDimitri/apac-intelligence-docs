# Segment-Based Compliance System Documentation

**Last Updated:** December 3, 2025
**System Version:** v2.0 (Time-Aware Compliance)

---

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Data Flow](#data-flow)
4. [Excel File Structure](#excel-file-structure)
5. [Database Schema](#database-schema)
6. [Compliance Calculation Logic](#compliance-calculation-logic)
7. [Segment Changes](#segment-changes)
8. [Repeatable Processes](#repeatable-processes)
9. [Troubleshooting](#troubleshooting)
10. [Code References](#code-references)

---

## Overview

### Purpose

The Segment-Based Compliance System tracks client engagement requirements based on their **segmentation tier** (Maintain, Leverage, Nurture, Collaboration, Sleeping Giant, Giant). Each tier has different event frequency requirements throughout the year.

### Key Principle: "Option A - Latest Segment Only"

**The dashboard displays compliance requirements for the client's CURRENT/LATEST segment**, matching the Excel client sheets.

**Example:** If MinDef changed from Maintain → Leverage in September:

- ✅ **Display**: Leverage tier requirements (current segment)
- ❌ **NOT Display**: Maintain tier requirements (historical segment)

This means:

- **EVP Engagement** (required for Leverage): SHOW as required
- **Satisfaction Action Plan** (required for Maintain): HIDE (excluded from Leverage)

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Excel Source File                             │
│  "APAC Client Segmentation Activity Register 2025.xlsx"         │
└──────────────────┬──────────────────────────────────────────────┘
                   │
                   ├─► Activities Sheet
                   │   (Tier requirements: frequency per event per tier)
                   │
                   └─► Client Sheets (e.g., "MINDEF-NCS")
                       (Individual client tracking with greyed-out events)

                   ↓ Scripts parse Excel

┌─────────────────────────────────────────────────────────────────┐
│                    Database Tables                               │
├─────────────────────────────────────────────────────────────────┤
│  1. segmentation_tiers                                          │
│     (tier_id, tier_name: Maintain, Leverage, etc.)              │
│                                                                  │
│  2. segmentation_event_types                                    │
│     (event_type_id, event_name: EVP Engagement, etc.)           │
│                                                                  │
│  3. tier_event_requirements ⭐ NEW                              │
│     (tier_id, event_type_id, frequency)                         │
│     Maps: Which events are required for each tier               │
│                                                                  │
│  4. client_segmentation                                         │
│     (client_name, tier_id, effective_from)                      │
│     Tracks: Segment changes over time                           │
│                                                                  │
│  5. segmentation_events                                         │
│     (client_name, event_type_id, event_date, completed)         │
│     Tracks: Actual completed events                             │
└─────────────────────────────────────────────────────────────────┘

                   ↓ Materialized View

┌─────────────────────────────────────────────────────────────────┐
│         event_compliance_summary (Materialized View)            │
│                                                                  │
│  Calculates:                                                     │
│  - Which events are required (based on LATEST segment)          │
│  - How many completed vs expected                               │
│  - Compliance % per event                                       │
│  - Overall compliance score                                     │
└─────────────────────────────────────────────────────────────────┘

                   ↓ Application reads view

┌─────────────────────────────────────────────────────────────────┐
│              Dashboard UI (Next.js/React)                        │
│  - Monthly overview with purple stars for segment changes       │
│  - Event compliance cards showing required vs completed          │
│  - Deadline extensions for mid-year segment changes             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Data Flow

### 1. **Excel → Database (Tier Requirements)**

**File:** `scripts/parse-tier-requirements.mjs`

**Input:** Activities sheet in Excel
**Output:** Rows in `tier_event_requirements` table

**Process:**

1. Read Activities sheet (rows 5-16, columns E-J)
2. For each event × tier combination:
   - Extract frequency (0-12 times per year)
   - Map tier name to tier_id
   - Map event name to event_type_id
   - Insert if frequency > 0 (skip events not required for that tier)

**Example Data:**

```sql
-- EVP Engagement requirements
tier: Maintain,     frequency: 0  (NOT inserted - not required)
tier: Leverage,     frequency: 1  (inserted)
tier: Nurture,      frequency: 1  (inserted)
tier: Collaboration, frequency: 1  (inserted)
tier: Sleeping Giant, frequency: 4  (inserted)
tier: Giant,        frequency: 4  (inserted)
```

### 2. **Excel → Database (Segment Changes)**

**File:** `scripts/update-segment-dates-to-september.mjs`

**Input:** "Client Segments - Sept" sheet
**Output:** Rows in `client_segmentation` table

**Process:**

1. All segment changes in 2025 are effective **September 1, 2025**
2. Initial segments (Jan 1) remain unchanged
3. Update any segment change records to 2025-09-01

**Example:**

```sql
-- MinDef segment history
2025-01-01: Maintain
2025-09-01: Leverage  ← Updated to Sept 1
```

### 3. **Database → Materialized View (Compliance Calculation)**

**File:** `docs/migrations/20251203_compliance_view_latest_segment_only.sql`

**Logic:** Option A - Latest Segment Only

**Steps:**

#### Step 1: Get Latest Segment

```sql
SELECT DISTINCT ON (client_name)
  client_name,
  tier_id,
  segment,
  effective_from
FROM client_segmentation
WHERE effective_from >= '2025-01-01'
  AND effective_from < '2026-01-01'
ORDER BY client_name, effective_from DESC  -- Latest first
```

#### Step 2: Get Requirements for Latest Segment

```sql
SELECT
  client_name,
  segment,
  event_type_id,
  event_name,
  frequency as required_count
FROM latest_segment
JOIN tier_event_requirements ON tier_id = tier_id
WHERE frequency > 0  -- Only required events
```

#### Step 3: Count Completed Events

```sql
SELECT
  client_name,
  event_type_id,
  COUNT(*) FILTER (WHERE completed = true) as actual_count
FROM segmentation_events
WHERE event_year = 2025
GROUP BY client_name, event_type_id
```

#### Step 4: Calculate Compliance

```sql
SELECT
  required_count as expected_count,
  COALESCE(actual_count, 0) as actual_count,
  ROUND((actual_count / required_count) * 100) as compliance_percentage
```

#### Step 5: Aggregate to Client-Year Level

```sql
SELECT
  client_name,
  segment,
  year,
  json_agg(event_compliance) as event_compliance,
  COUNT(*) as total_event_types_count,
  COUNT(*) FILTER (WHERE compliance >= 100) as compliant_count,
  ROUND((compliant_count / total_count) * 100) as overall_score
FROM event_compliance
GROUP BY client_name, year  -- ONE row per client-year
```

---

## Excel File Structure

### File Location

```
/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/
APAC Clients - Client Success/Client Segmentation/
APAC Client Segmentation Activity Register 2025.xlsx
```

### Sheet: "Activities"

**Purpose:** Master list of event requirements per tier

**Structure:**

```
Row 1: (Unused)
Row 2: Headers
Row 3: (Unused)
Row 4: Activity | Frequency | Team | Maintain | Leverage | Nurture | Collaboration | Sleeping Giants | Giants
Row 5: President/Group Leader... | Per Year | P/GL | 0 | 0 | 0 | 0 | 1 | 1
Row 6: EVP Engagement | Per Year | EVP | 0 | 1 | 1 | 1 | 4 | 4
Row 7: Strategic Ops Plan... | Per Year | CE/VP/AVP | 1 | 2 | 2 | 2 | 2 | 2
...
```

**Column Mapping:**

- Column A (index 0): Activity name (NOT used - use column B)
- Column B (index 1): Event name
- Column C (index 2): Frequency description
- Column D (index 3): Team responsible
- Column E (index 4): **Maintain** tier frequency
- Column F (index 5): **Leverage** tier frequency
- Column G (index 6): **Nurture** tier frequency
- Column H (index 7): **Collaboration** tier frequency
- Column I (index 8): **Sleeping Giants** tier frequency (DB uses "Sleeping Giant")
- Column J (index 9): **Giants** tier frequency (DB uses "Giant")

**Important Notes:**

- Frequencies are **per year** (0-12)
- 0 = Event is NOT required for that tier
- Database tier names use singular: "Sleeping Giant" and "Giant"

### Sheet: "Client Segments - Sept"

**Purpose:** Shows which segment each client is in as of September 2025

**Structure:**

```
Row 1: Maintain | Leverage | Nurture | Collaboration | Sleeping Giant | Giant
Row 2: Barwon Health | Albury Wodonga | Dept of Health, Victoria | Waikato | Singapore Health | SA Health (Sunrise)
Row 3: RVEEH | Grampians Health | SA Health (iQemo) | SA Health (iPro) | WA Health |
Row 4: Western Health | Gippsland HA | | | |
Row 5: SLMC | Mount Alvernia | | | |
Row 6: GRMC | NCS/MinDef Singapore | | | |
Row 7: Epworth Healthcare | | | | |
```

**Client Name Mapping:**

```javascript
const CLIENT_NAME_MAPPING = {
  'NCS/MinDef Singapore': 'Ministry of Defence, Singapore',
  'Albury Wodonga': 'Albury Wodonga Health',
  GHA: 'Gippsland Health Alliance',
  // ... (see scripts/parse-tier-requirements.mjs for full mapping)
}
```

### Client Sheets (e.g., "MINDEF-NCS")

**Purpose:** Track individual client's event completion with greyed-out rows for non-applicable events

**Structure:**

```
Row 1-4: Headers
Row 5: Event | Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec
Row 6: President/Group Leader... | | | | | | | | | | | |
Row 7: EVP Engagement | | | | | | | ✓ | | | | |
Row 8: Satisfaction Action Plan | ████ (GREYED OUT - not required for current segment)
```

**Grey Background Meaning:**

- Event is NOT required for the client's **current segment**
- Example: MinDef is on Leverage tier, which doesn't require "Satisfaction Action Plan"
- Grey detection: `fgColor.theme === 2 || rgb includes 'E8E8E8'`

---

## Database Schema

### Table: `tier_event_requirements`

**Purpose:** Maps which events are required for each tier and how frequently

**Columns:**

```sql
id UUID PRIMARY KEY
tier_id UUID REFERENCES segmentation_tiers(id)
event_type_id UUID REFERENCES segmentation_event_types(id)
frequency INTEGER NOT NULL DEFAULT 0  -- Times per year (0-12)
created_at TIMESTAMPTZ
updated_at TIMESTAMPTZ

UNIQUE(tier_id, event_type_id)  -- One requirement per tier-event combo
```

**Example Data:**

```sql
-- EVP Engagement
tier: Maintain (id: xxx),     event: EVP Engagement,  frequency: 0
tier: Leverage (id: yyy),     event: EVP Engagement,  frequency: 1
tier: Nurture (id: zzz),      event: EVP Engagement,  frequency: 1

-- Satisfaction Action Plan
tier: Maintain (id: xxx),     event: Satisfaction..., frequency: 1
tier: Leverage (id: yyy),     event: Satisfaction..., frequency: 0  -- NOT REQUIRED
```

**Query Example:**

```sql
-- Get all required events for Leverage tier
SELECT
  et.event_name,
  ter.frequency
FROM tier_event_requirements ter
JOIN segmentation_event_types et ON et.id = ter.event_type_id
JOIN segmentation_tiers t ON t.id = ter.tier_id
WHERE t.tier_name = 'Leverage'
  AND ter.frequency > 0
ORDER BY et.event_name;
```

### Table: `client_segmentation`

**Purpose:** Tracks segment changes over time for each client

**Columns:**

```sql
id UUID PRIMARY KEY
client_name TEXT NOT NULL
tier_id UUID REFERENCES segmentation_tiers(id)
effective_from DATE NOT NULL
created_at TIMESTAMPTZ
updated_at TIMESTAMPTZ
```

**Example Data:**

```sql
-- MinDef segment history
client: Ministry of Defence, Singapore,  tier: Maintain,  effective_from: 2025-01-01
client: Ministry of Defence, Singapore,  tier: Leverage,  effective_from: 2025-09-01

-- SA Health (iPro) segment history
client: SA Health (iPro),  tier: Nurture,       effective_from: 2025-01-01
client: SA Health (iPro),  tier: Collaboration, effective_from: 2025-09-01
```

**Important:** All 2025 segment changes are effective **September 1, 2025**

### Materialized View: `event_compliance_summary`

**Purpose:** Pre-calculated compliance data for fast dashboard queries

**Columns:**

```sql
client_name TEXT
segment TEXT  -- Latest segment name
cse TEXT  -- Client Success Executive
year INTEGER
event_compliance JSON  -- Array of event compliance objects
overall_compliance_score INTEGER  -- 0-100%
overall_status TEXT  -- 'critical' | 'at-risk' | 'compliant'
compliant_event_types_count INTEGER
total_event_types_count INTEGER
last_updated TIMESTAMPTZ
```

**Event Compliance JSON Structure:**

```json
[
  {
    "event_type_id": "uuid",
    "event_type_name": "EVP Engagement",
    "event_code": "EVP",
    "expected_count": 1,
    "actual_count": 0,
    "compliance_percentage": 0,
    "status": "critical",
    "priority_level": "medium",
    "events": []
  },
  ...
]
```

**Refresh Command:**

```sql
REFRESH MATERIALIZED VIEW event_compliance_summary;
```

---

## Compliance Calculation Logic

### Option A: Latest Segment Only (CURRENT IMPLEMENTATION)

**Rationale:** Matches Excel client sheets which show current segment requirements

**Logic:**

1. Find the client's **latest segment** in 2025 (by effective_from DESC)
2. Get tier requirements for that segment ONLY
3. Count completed events for the FULL YEAR (regardless of which segment period)
4. Calculate compliance percentage: `(actual / expected) * 100`

**Example: MinDef**

**Segment History:**

- Jan 1 - Aug 31: Maintain tier
- Sept 1 - Dec 31: Leverage tier

**Requirements (Latest Segment = Leverage):**

```
✅ EVP Engagement: 1/year (required for Leverage)
❌ Satisfaction Action Plan: EXCLUDED (not required for Leverage, even though it was required for Maintain)
✅ Strategic Ops Plan: 2/year (required for Leverage)
... (7 more events)

Total: 9 events
```

**Event Counting (Full Year):**

- EVP Engagement completed in March → Counts: 1
- Satisfaction Action Plan completed in July → Does NOT count (event excluded from requirements)

**Result:**

- Dashboard shows **9 events** (not 10)
- "Satisfaction Action Plan" is NOT displayed
- "EVP Engagement" shows as 1/1 (100% compliant)

### Alternative: Option B (MAX Aggregation - NOT USED)

**For reference only - this was considered but rejected**

Would show requirements needed at ANY point during 2025:

- EVP Engagement: MAX(Maintain=0, Leverage=1) = 1
- Satisfaction Action Plan: MAX(Maintain=1, Leverage=0) = 1

This would show 10 events total, holding clients accountable for all requirements throughout the year.

---

## Segment Changes

### Detection Logic

**File:** `src/hooks/useSegmentChange.ts`

**Query:**

```typescript
const { data: history } = await supabase
  .from('client_segmentation')
  .select('effective_from, segmentation_tiers(tier_name)')
  .eq('client_name', clientName)
  .order('effective_from', { ascending: true })

// Check for changes within the year
for (let i = 1; i < history.length; i++) {
  const changeDate = new Date(history[i].effective_from)
  if (changeDate >= yearStart && changeDate <= yearEnd) {
    return {
      hasChanged: true,
      changeMonth: changeDate.getMonth() + 1, // 9 for September
      changeYear: changeDate.getFullYear(),
      previousSegment: history[i - 1].segmentation_tiers.tier_name,
      currentSegment: history[i].segmentation_tiers.tier_name,
    }
  }
}
```

### UI Indicators

**Purple Star Badge:**

- Appears on the month of segment change
- For 2025: All segment changes → September (month 9)
- Component: `RightColumn.tsx` lines 1000-1002

**Deadline Extension:**

- Normal deadline: December 31, 2025
- Segment change deadline: June 20, 2026 (+6 months)
- Shown in header: "Extended to Jun 20, 2026"
- Component: `RightColumn.tsx` lines 50-52

**Legend:**

- Purple circle: "Segment Changed"
- Component: `RightColumn.tsx` lines 1050-1055

---

## Repeatable Processes

### Process 1: Parse Tier Requirements from Excel

**When to run:**

- Excel Activities sheet is updated with new event requirements
- New tiers are added
- Event frequencies change

**Steps:**

1. **Verify Excel file exists:**

   ```bash
   ls -la "/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Clients - Client Success/Client Segmentation/APAC Client Segmentation Activity Register 2025.xlsx"
   ```

2. **Run the parser:**

   ```bash
   node scripts/parse-tier-requirements.mjs
   ```

3. **Verify output:**

   ```
   Expected output:
   ✅ Inserted: 60
   ✅ Skipped (frequency 0): 12

   Should see requirements for all 6 tiers × 12 events
   ```

4. **Check database:**

   ```bash
   node -e "
   import { createClient } from '@supabase/supabase-js';
   import dotenv from 'dotenv';

   dotenv.config({ path: '.env.local' });

   const supabase = createClient(
     process.env.NEXT_PUBLIC_SUPABASE_URL,
     process.env.SUPABASE_SERVICE_ROLE_KEY
   );

   async function check() {
     const { count } = await supabase
       .from('tier_event_requirements')
       .select('*', { count: 'exact' });

     console.log(\`Total requirements: \${count}\`);
   }

   check();
   "
   ```

5. **Refresh materialized view:**
   ```bash
   node scripts/apply-latest-segment-only.mjs
   ```

### Process 2: Update Segment Changes

**When to run:**

- Excel "Client Segments - Sept" sheet is updated
- New clients are added
- Clients change segments

**Steps:**

1. **Verify segment change date:**
   - All 2025 segment changes should be **September 1, 2025**
   - Initial segments (Jan 1) remain unchanged

2. **Update database:**

   ```bash
   node scripts/update-segment-dates-to-september.mjs
   ```

3. **Verify MinDef (or any client):**

   ```
   Expected output:
   2025-01-01: Maintain
   2025-09-01: Leverage
   ```

4. **Refresh materialized view:**

   ```bash
   node scripts/apply-latest-segment-only.mjs
   ```

5. **Verify compliance:**

   ```bash
   node -e "
   import { createClient } from '@supabase/supabase-js';
   import dotenv from 'dotenv';

   dotenv.config({ path: '.env.local' });

   const supabase = createClient(
     process.env.NEXT_PUBLIC_SUPABASE_URL,
     process.env.SUPABASE_SERVICE_ROLE_KEY
   );

   async function check() {
     const { data } = await supabase
       .from('event_compliance_summary')
       .select('segment, total_event_types_count')
       .eq('client_name', 'Ministry of Defence, Singapore')
       .eq('year', 2025)
       .single();

     console.log(\`MinDef: \${data.segment} tier, \${data.total_event_types_count} events\`);
   }

   check();
   "
   ```

### Process 3: Refresh Compliance View

**When to run:**

- Event data is updated (new events completed)
- Tier requirements change
- Segment changes are updated
- Daily/weekly maintenance

**Steps:**

1. **Manual refresh:**

   ```bash
   node -e "
   import { createClient } from '@supabase/supabase-js';
   import dotenv from 'dotenv';

   dotenv.config({ path: '.env.local' });

   const supabase = createClient(
     process.env.NEXT_PUBLIC_SUPABASE_URL,
     process.env.SUPABASE_SERVICE_ROLE_KEY
   );

   async function refresh() {
     await supabase.rpc('exec_sql', {
       sql_query: 'REFRESH MATERIALIZED VIEW event_compliance_summary'
     });
     console.log('✅ View refreshed');
   }

   refresh();
   "
   ```

2. **Or use the full apply script:**
   ```bash
   node scripts/apply-latest-segment-only.mjs
   ```

### Process 4: Add New Client

**When to run:**

- New client is onboarded
- Client needs to be tracked in the dashboard

**Steps:**

1. **Add to Excel:**
   - Add client to appropriate tier column in "Client Segments - Sept" sheet
   - Create new client sheet with their name
   - Mark greyed-out events based on their tier

2. **Add to database:**

   ```sql
   -- Add initial segment
   INSERT INTO client_segmentation (client_name, tier_id, effective_from)
   VALUES (
     'New Client Name',
     (SELECT id FROM segmentation_tiers WHERE tier_name = 'Leverage'),
     '2025-01-01'
   );

   -- If they changed segments in September
   INSERT INTO client_segmentation (client_name, tier_id, effective_from)
   VALUES (
     'New Client Name',
     (SELECT id FROM segmentation_tiers WHERE tier_name = 'Collaboration'),
     '2025-09-01'
   );
   ```

3. **Refresh view:**

   ```bash
   node scripts/apply-latest-segment-only.mjs
   ```

4. **Verify:**
   - Check dashboard for new client
   - Verify event count matches expected tier requirements

### Process 5: Add New Event Type

**When to run:**

- New engagement type is introduced company-wide
- New requirement is added to all tiers

**Steps:**

1. **Add to database:**

   ```sql
   -- Add event type
   INSERT INTO segmentation_event_types (event_name, event_code)
   VALUES ('New Event Name', 'NEW');
   ```

2. **Update Excel Activities sheet:**
   - Add new row with event name
   - Set frequency for each tier (0-12)

3. **Re-parse tier requirements:**

   ```bash
   node scripts/parse-tier-requirements.mjs
   ```

4. **Refresh view:**
   ```bash
   node scripts/apply-latest-segment-only.mjs
   ```

---

## Troubleshooting

### Issue: Client shows wrong number of events

**Symptoms:**

- Client should have 9 events but shows 10
- Events that should be excluded are appearing

**Diagnosis:**

1. Check client's latest segment:

   ```sql
   SELECT cs.effective_from, t.tier_name
   FROM client_segmentation cs
   JOIN segmentation_tiers t ON t.id = cs.tier_id
   WHERE cs.client_name = 'Client Name'
   ORDER BY cs.effective_from DESC
   LIMIT 1;
   ```

2. Check tier requirements:

   ```sql
   SELECT et.event_name, ter.frequency
   FROM tier_event_requirements ter
   JOIN segmentation_event_types et ON et.id = ter.event_type_id
   WHERE ter.tier_id = (
     SELECT tier_id FROM client_segmentation
     WHERE client_name = 'Client Name'
     ORDER BY effective_from DESC
     LIMIT 1
   )
   AND ter.frequency > 0;
   ```

3. Check compliance view:
   ```sql
   SELECT segment, total_event_types_count, event_compliance
   FROM event_compliance_summary
   WHERE client_name = 'Client Name' AND year = 2025;
   ```

**Solution:**

- Refresh materialized view: `node scripts/apply-latest-segment-only.mjs`
- If still wrong, check if Excel Activities sheet matches database

### Issue: Purple star appears on wrong month

**Symptoms:**

- Star shows on July but should be September
- Star missing entirely

**Diagnosis:**

1. Check segment change date:

   ```sql
   SELECT effective_from, segmentation_tiers.tier_name
   FROM client_segmentation
   JOIN segmentation_tiers ON tier_id = segmentation_tiers.id
   WHERE client_name = 'Client Name'
   ORDER BY effective_from;
   ```

2. Expected for 2025:
   - First row: 2025-01-01 (initial segment)
   - Second row: 2025-09-01 (segment change)

**Solution:**

- Update segment change dates: `node scripts/update-segment-dates-to-september.mjs`

### Issue: Materialized view is stale

**Symptoms:**

- Dashboard shows old data
- Changes to events don't appear
- Compliance percentages are outdated

**Diagnosis:**

```sql
SELECT last_updated FROM event_compliance_summary LIMIT 1;
```

**Solution:**

```bash
node scripts/apply-latest-segment-only.mjs
```

### Issue: Multiple rows per client in compliance view

**Symptoms:**

- Query with .single() fails
- Client appears twice in dashboard

**Diagnosis:**

```sql
SELECT client_name, COUNT(*) as row_count
FROM event_compliance_summary
WHERE year = 2025
GROUP BY client_name
HAVING COUNT(*) > 1;
```

**Root Cause:**

- Materialized view is grouping by segment instead of just client_name

**Solution:**

- Re-apply latest segment only migration:
  ```bash
  node scripts/apply-latest-segment-only.mjs
  ```

### Issue: Tier requirements not parsing

**Symptoms:**

- Parser shows "Inserted: 0"
- Database has no requirements

**Diagnosis:**

1. Check Excel file path exists
2. Check Activities sheet exists
3. Check column indices match:
   - E (index 4) = Maintain
   - F (index 5) = Leverage
   - etc.

**Solution:**

- Update column indices in `scripts/parse-tier-requirements.mjs`
- Verify tier names match database (singular: "Sleeping Giant", not "Sleeping Giants")

---

## Code References

### Key Files

**Database Migrations:**

- `docs/migrations/20251202_tier_event_requirements.sql` - Creates tier requirements table
- `docs/migrations/20251203_compliance_view_latest_segment_only.sql` - Creates materialized view (Option A)

**Scripts:**

- `scripts/parse-tier-requirements.mjs` - Parses Excel Activities sheet → tier_event_requirements table
- `scripts/update-segment-dates-to-september.mjs` - Updates all 2025 segment changes to Sept 1
- `scripts/apply-latest-segment-only.mjs` - Refreshes materialized view and verifies MinDef

**React Components:**

- `src/hooks/useSegmentChange.ts` - Detects segment changes for purple star badge
- `src/hooks/useEventCompliance.ts` - Reads compliance data from materialized view
- `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx` - Monthly overview with badges
- `src/lib/segment-deadline-utils.ts` - Calculates deadline extensions

### Important Line References

**Purple Star Badge:**

```typescript
// src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx:1000-1002
{isSegmentChange && (
  <div className="h-5 w-5 bg-purple-600 rounded-full flex items-center justify-center shadow-lg"
       title="Segment Changed">
    <Star className="h-3 w-3 text-white" fill="currentColor" />
  </div>
)}
```

**Segment Change Detection:**

```typescript
// src/hooks/useSegmentChange.ts:68-75
for (let i = 1; i < history.length; i++) {
  const changeDate = new Date(history[i].effective_from);
  if (changeDate >= yearStart && changeDate <= yearEnd) {
    return {
      hasChanged: true,
      changeMonth: changeDate.getMonth() + 1,  // 9 for September
      ...
    };
  }
}
```

**Deadline Extension:**

```typescript
// src/lib/segment-deadline-utils.ts:120-125
if (segmentChangeInfo.hasChanged) {
  // Extend deadline by 6 months from segment change date
  const extensionDate = new Date(year, segmentChangeInfo.changeMonth - 1 + 6, 20)
  return extensionDate
}
// Normal deadline: Dec 31
return new Date(year, 11, 31)
```

---

## Version History

### v2.0 - December 3, 2025

- ✅ Implemented "Option A - Latest Segment Only" logic
- ✅ Created tier_event_requirements table
- ✅ Parsed Activities sheet for tier requirements
- ✅ Updated all 2025 segment changes to September 1
- ✅ Materialized view now uses latest segment (not MAX aggregation)
- ✅ Purple star badge appears on September for segment changes
- ✅ Deadline extensions: June 20, 2026 for mid-year changes

### v1.0 - December 2, 2025

- ❌ Used MAX aggregation across all segments (Option B - rejected)
- ❌ Segment changes had inconsistent dates (June, July, August, September)
- ⚠️ Multiple rows per client in materialized view

---

## Appendix A: Client Name Mapping

```javascript
const CLIENT_NAME_MAPPING = {
  'Albury-Wodonga (AWH)': 'Albury Wodonga Health',
  'Albury Wodonga': 'Albury Wodonga Health',
  GHA: 'Gippsland Health Alliance',
  'Gippsland Health Alliance (GHA)': 'Gippsland Health Alliance',
  Grampians: 'Grampians Health Alliance',
  'Grampians Health': 'Grampians Health Alliance',
  Epworth: 'Epworth Healthcare',
  GRMC: 'Guam Regional Medical City',
  'Guam Regional Medical City (GRMC)': 'Guam Regional Medical City',
  'MINDEF-NCS': 'Ministry of Defence, Singapore',
  'NCS/MinDef Singapore': 'Ministry of Defence, Singapore',
  RVEEH: 'Royal Victorian Eye and Ear Hospital',
  'Royal Victorian Eye and Ear Hospital (RVEEH)': 'Royal Victorian Eye and Ear Hospital',
  'SA Health iPro': 'SA Health (iPro)',
  'SA Health iQemo': 'SA Health (iQemo)',
  'SA Health Sunrise': 'SA Health (Sunrise)',
  SingHealth: 'Singapore Health Services Pte Ltd',
  'Singapore Health (SingHealth)': 'Singapore Health Services Pte Ltd',
  SLMC: "Saint Luke's Medical Centre",
  "Saint Luke's Medical Centre (SLMC)": "Saint Luke's Medical Centre",
  'Vic Health': 'Department of Health, Victoria',
  'Dept of Health, Victoria': 'Department of Health, Victoria',
  'Department of Health, Victoria': 'Department of Health, Victoria',
  Waikato: 'Te Whatu Ora Waikato',
  'WA Health': 'Western Australia Department Of Health',
  'Western Health': 'Western Health',
  'Barwon Health': 'Barwon Health',
}
```

---

## Appendix B: Quick Command Reference

```bash
# Parse tier requirements from Excel
node scripts/parse-tier-requirements.mjs

# Update segment change dates to September 1
node scripts/update-segment-dates-to-september.mjs

# Refresh compliance view
node scripts/apply-latest-segment-only.mjs

# Check MinDef compliance
node -e "
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config({ path: '.env.local' });

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function check() {
  const { data } = await supabase
    .from('event_compliance_summary')
    .select('*')
    .eq('client_name', 'Ministry of Defence, Singapore')
    .eq('year', 2025)
    .single();

  console.log(\`Segment: \${data.segment}\`);
  console.log(\`Events: \${data.total_event_types_count}\`);
  console.log(\`Score: \${data.overall_compliance_score}%\`);
}

check();
"

# Verify one row per client
node -e "
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config({ path: '.env.local' });

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function verify() {
  const { data } = await supabase
    .from('event_compliance_summary')
    .select('client_name, year')
    .eq('year', 2025);

  const counts = {};
  data.forEach(r => {
    counts[r.client_name] = (counts[r.client_name] || 0) + 1;
  });

  const multiples = Object.entries(counts).filter(([_, c]) => c > 1);
  console.log(\`Multiple rows: \${multiples.length}\`);
}

verify();
"
```

---

**End of Documentation**
