# Bug Report: Health Score Compliance Mismatch with UI

**Date:** 16 December 2024
**Severity:** High
**Status:** Fixed and Deployed

## Summary

The health score's compliance component used a different calculation AND different data source than what's displayed in the UI's "Segmentation Actions" section, causing misleading health scores.

## Symptoms

**Saint Luke's Medical Centre (SLMC) Example:**

| Location                | Compliance Shown          | Calculation Method                  |
| ----------------------- | ------------------------- | ----------------------------------- |
| Health Score Card       | **80%** (showing Healthy) | 100% compliance in formula          |
| UI Segmentation Actions | **50%** (4/8 On Target)   | Proportion of on-target event types |

The health score shows "Healthy" with 80% despite only 4 of 8 required event types being completed.

## Root Cause

Two separate issues caused the mismatch:

### Issue 1: Wrong Calculation Method

The `client_health_summary` materialized view used `AVG(compliance_percentage)` instead of the proportion of on-target event types:

```sql
-- BUG (line 129 of 20251215_simplified_health_score.sql):
SELECT AVG(compliance_percentage) as compliance_percentage
FROM segmentation_event_compliance

-- For SLMC, this averages: [600%, 200%, 0%, 0%, 50%, 0%, 0%, 0%, 0%, 400%, 150%, 100%]
-- Result: 125% → capped to 100% → contributes 60 points to health score
```

This allowed **over-servicing to mask under-servicing**:

- Client over-serves 5 event types (400-600% compliance each)
- Client under-serves 7 event types (0-50% compliance each)
- Average = 125% → appears as 100% compliance
- But only 5/12 = 41.7% of event types are actually on-target

### Issue 2: Different Data Sources

Even after fixing the calculation, health scores still didn't match the UI because they used different data sources:

| Data Source                     | Used By                 | Western Health Example           |
| ------------------------------- | ----------------------- | -------------------------------- |
| `segmentation_event_compliance` | Health Score (old)      | 12 records, 4 on target = 33%    |
| `event_compliance_summary`      | UI Segmentation Actions | 8 event types, 7 on target = 88% |

The two tables have different:

- Number of event type records
- Compliance percentages per event type
- Calculation logic (raw vs aggregated)

## Correct Calculation

The compliance should use the **proportion of on-target event types**, matching the UI:

```sql
-- FIXED:
SELECT
  ROUND((COUNT(*) FILTER (WHERE compliance_percentage >= 100)::DECIMAL / COUNT(*) * 100))
  as compliance_percentage
FROM segmentation_event_compliance

-- For SLMC: 5 on-target / 12 total = 41.7%
```

## Impact Analysis

9 clients affected by this bug:

| Client                             | Current Score | Corrected Score | Change   |
| ---------------------------------- | ------------- | --------------- | -------- |
| Saint Luke's Medical Centre (SLMC) | 80%           | 45%             | **-35%** |
| Epworth Healthcare                 | 65%           | 40%             | -25%     |
| Mount Alvernia Hospital            | 68%           | 43%             | -25%     |
| NCS/MinDef Singapore               | 68%           | 45%             | -23%     |
| Western Health                     | 48%           | 26%             | -22%     |
| Guam Regional Medical City (GRMC)  | 56%           | 35%             | -21%     |
| Gippsland Health Alliance (GHA)    | 80%           | 60%             | -20%     |
| Grampians Health                   | 87%           | 67%             | -20%     |
| WA Health                          | 44%           | 30%             | -14%     |

## Files Involved

### Source of Bug

- `docs/migrations/20251215_simplified_health_score.sql` - Line 129: `AVG(compliance_percentage)`

### UI (Correct Calculation)

- `src/hooks/useEventCompliance.ts` - Uses `event_compliance_summary` view
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` - Displays on-target/at-risk counts

### Data Sources

- `client_health_summary` - Materialized view used by health score (BUGGY)
- `event_compliance_summary` - Materialized view used by UI (CORRECT)
- `segmentation_event_compliance` - Raw compliance data

## Fix

### Migration File

`docs/migrations/20251216_fix_compliance_calculation_bug.sql`

### Solution

Changed the health score to use `event_compliance_summary` view (same as UI) instead of `segmentation_event_compliance` table:

```sql
-- FIXED Compliance Metrics
-- Now uses event_compliance_summary view (same source as UI)
LEFT JOIN LATERAL (
  SELECT
    COALESCE(ecs.overall_compliance_score, 50) as compliance_percentage,
    CASE
      WHEN ecs.overall_compliance_score IS NULL THEN 'unknown'
      WHEN ecs.overall_compliance_score >= 75 THEN 'compliant'
      WHEN ecs.overall_compliance_score >= 50 THEN 'warning'
      ELSE 'non-compliant'
    END as compliance_status
  FROM event_compliance_summary ecs
  WHERE ecs.client_name = c.client_name
    AND ecs.year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
) compliance_metrics ON true
```

### Additional Fixes

1. **Date parsing**: Added handling for mixed date formats (`YYYY-MM-DD` and `DD/MM/YYYY`) in the `Due_Date` column
2. **Invalid dates**: Added filter to skip non-date values like "Per Year"

### Previous Approach (Insufficient)

Initial fix attempted to calculate proportion from `segmentation_event_compliance`:

```sql
-- This didn't work because segmentation_event_compliance has different data than UI
LEFT JOIN LATERAL (
  SELECT
    ROUND((COUNT(*) FILTER (WHERE compliance_percentage >= 100)::DECIMAL / COUNT(*) * 100))
      ELSE 50  -- Default to 50% if no compliance data
    END as compliance_percentage,
    ...
  FROM segmentation_event_compliance ec
  WHERE ec.client_name = c.client_name
    AND ec.year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
) compliance_metrics ON true
```

## Deployment Steps

1. Open Supabase SQL Editor:
   https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/sql/new

2. Paste contents of `docs/migrations/20251216_fix_compliance_calculation_bug.sql`

3. Click "Run"

4. Verify fix by checking client health scores match UI

## Verification Results

### Saint Luke's Medical Centre (SLMC)

| Metric       | Before Fix | After Fix |
| ------------ | ---------- | --------- |
| Health Score | 80%        | **50%**   |
| Compliance   | 100%       | **50%**   |
| UI Shows     | 50% (4/8)  | 50% (4/8) |
| Match        | ❌         | ✅        |

### Western Health

| Metric       | Before Fix | After Fix |
| ------------ | ---------- | --------- |
| Health Score | 26%        | **59%**   |
| Compliance   | 33%        | **88%**   |
| UI Shows     | 88% (7/8)  | 88% (7/8) |
| Match        | ❌         | ✅        |

## Commits

1. `b736786` - Initial fix (used wrong data source)
2. `77f3ac0` - Final fix (uses `event_compliance_summary` same as UI)

## Related Files

- `docs/migrations/20251216_fix_compliance_calculation_bug.sql` - Migration file
- `scripts/check-health-score-inflation.mjs` - Verification script
- `scripts/apply-compliance-fix-migration.mjs` - Impact preview script
- `scripts/execute-compliance-fix.mjs` - Execution helper script
