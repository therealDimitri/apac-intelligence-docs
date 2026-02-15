# Feature: Support Health Page - Phase 1 Enhancements

**Date:** 8 January 2026
**Status:** Implemented
**Priority:** High

---

## Summary

Implemented Phase 1 of the Support Health page enhancements as per the recommendations document. This includes expandable row details, aging stacked bar visualisation, health score component breakdown, and database migrations for historical data support.

---

## Changes Implemented

### 1. Database Migration for Historical Data Support
**Files:**
- `docs/migrations/20260108_support_historical_data.sql`
- `scripts/apply-support-historical-migration.mjs`
- `scripts/execute-support-historical-migration.mjs`

**Changes:**
- Added composite unique constraint on `(client_name, period_end)` to enable monthly snapshots
- Added indexes for efficient trend queries:
  - `idx_support_metrics_client` - Filter by client
  - `idx_support_metrics_period` - Sort by period (DESC)
  - `idx_support_metrics_client_period` - Composite for trend queries
  - `idx_support_metrics_health_score` - For at-risk filtering

**Status:** ✅ Migration applied successfully via direct database connection.

### 2. Expandable Row Details
**Files:**
- `src/components/support/SupportOverviewTable.tsx`
- `src/components/support/ExpandableRowContent.tsx` (new)

**Changes:**
- Added `expandedRows` state to track which rows are expanded
- Added click-to-expand functionality on table rows
- Added expand/collapse chevron button with rotation animation
- Created `ExpandableRowContent` component showing:
  - **Case Priority Breakdown**: Critical, High, Moderate, Low counts with colour coding
  - **Age Distribution**: Visual stacked bar with 0-7d, 8-30d, 31-60d, 61-90d, 90d+ buckets
  - **SLA & Satisfaction**: Response SLA, Resolution SLA, CSAT Score, Survey Response Rate
  - **Health Score Breakdown**: Visual progress bars for each component (SLA 40%, CSAT 30%, Aging 20%, Critical 10%)

### 3. Aging Stacked Bar Visualisation
**Files:**
- `src/components/support/AgingStackedBar.tsx` (new)

**Features:**
- Horizontal stacked bar showing case age distribution
- Colour-coded segments:
  - 0-7 days: Green (#10B981)
  - 8-30 days: Blue (#3B82F6)
  - 31-60 days: Amber (#F59E0B)
  - 61-90 days: Orange (#F97316)
  - 90+ days: Red (#EF4444)
- Tooltip showing detailed breakdown with counts and percentages
- Configurable height and labels

### 4. Enhanced SupportMetrics Interface
**File:** `src/components/support/SupportOverviewTable.tsx`

**Added Fields:**
- `moderate_open`, `low_open` - Additional priority breakdowns
- `aging_0_7d`, `aging_8_30d`, `aging_31_60d`, `aging_61_90d`, `aging_90d_plus` - Detailed aging buckets
- `response_sla_percent` - Response SLA compliance
- `breach_count` - SLA breach count
- `availability_percent` - System availability
- `surveys_sent`, `surveys_completed` - Survey metrics

---

## UI/UX Design Decisions

### Expandable Rows
- Click anywhere on the row to expand/collapse
- Chevron icon rotates 90° when expanded
- Subtle background highlight on expanded rows
- Smooth animation using Framer Motion

### Colour Coding
Following industry standards from Zendesk/Freshdesk:
- **Green** (≥95%): Target met
- **Amber** (90-94%): Warning
- **Red** (<90%): Critical

### Health Score Breakdown
Visual representation of the 4 components:
1. SLA Compliance (40% weight) - Green bar
2. CSAT Score (30% weight) - Amber bar
3. Aging Penalty (20% weight) - Blue bar
4. Critical Cases (10% weight) - Red bar

---

## Testing Instructions

1. Navigate to Support Health page (`/support`)
2. Click on any client row to expand
3. Verify expandable content shows:
   - Priority breakdown (4 boxes)
   - Aging distribution (stacked bar + badges)
   - SLA & Satisfaction metrics (4 boxes)
   - Health score breakdown (4 progress bars)
4. Click again to collapse
5. Verify grouped view still works

---

## Database Migration

Run this SQL in Supabase SQL Editor:

```sql
ALTER TABLE support_sla_metrics
ADD CONSTRAINT support_sla_metrics_client_period_unique
UNIQUE (client_name, period_end);

CREATE INDEX IF NOT EXISTS idx_support_metrics_client
ON support_sla_metrics (client_name);

CREATE INDEX IF NOT EXISTS idx_support_metrics_period
ON support_sla_metrics (period_end DESC);

CREATE INDEX IF NOT EXISTS idx_support_metrics_client_period
ON support_sla_metrics (client_name, period_end DESC);
```

---

## Next Steps (Phase 2)

1. Add trend charts section (6-month historical view)
2. Implement sparklines in table rows
3. Create monthly snapshot sync job
4. Add period comparison indicators

---

## Related Documents

- `docs/SUPPORT-HEALTH-RECOMMENDATIONS.md` - Full recommendations
- `docs/migrations/20260108_support_historical_data.sql` - Migration SQL
