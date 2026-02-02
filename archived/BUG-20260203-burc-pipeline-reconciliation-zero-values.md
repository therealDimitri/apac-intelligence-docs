# Bug Report: BURC Pipeline Reconciliation Showing $0 Values

**Date:** 3 February 2026
**Status:** Fixed
**Severity:** Medium
**Affected Components:** BURC Executive Dashboard, burc_reconciliation_summary view

## Summary

The Pipeline Reconciliation card on the BURC Executive Dashboard was displaying $0 for all values (Pipeline Total, Waterfall Total, Variance) due to a view query bug and data format mismatch.

## Symptoms

- Pipeline Reconciliation card showed:
  - Pipeline Total: $0
  - Waterfall Total: $0
  - Variance: $0
  - Status: RECONCILED (incorrectly)

## Root Causes

### 1. View WHERE Clause Bug
The `burc_reconciliation_summary` view filtered `WHERE fiscal_year >= 2025`, but the `burc_waterfall` table has `fiscal_year = NULL` for all rows (indicating "current year" data).

```sql
-- Original (broken)
WHERE fiscal_year >= 2025  -- No rows matched when fiscal_year IS NULL

-- Fixed
WHERE fiscal_year >= 2025 OR fiscal_year IS NULL
```

### 2. Category Double-Counting
The original view was summing both `backlog_runrate` and `committed_gross_rev`, but `committed_gross_rev` already includes `backlog_runrate`. This caused incorrect totals.

### 3. API Response Format Mismatch
The view returns snake_case columns (`total_pipeline`, `total_waterfall`) but the component expected camelCase (`totalPipeline`, `totalWaterfall`).

## Resolution

### View Fix (applied via pg client)
```sql
CREATE VIEW burc_reconciliation_summary AS
WITH waterfall_totals AS (
  SELECT
    COALESCE(fiscal_year, 2026) as fiscal_year,  -- Treat NULL as FY2026
    SUM(CASE WHEN category = 'committed_gross_rev' THEN amount ELSE 0 END) AS committed_waterfall,
    SUM(CASE WHEN category IN ('best_case_ps', 'best_case_maint') THEN amount ELSE 0 END) AS best_case_waterfall,
    SUM(CASE WHEN category IN ('pipeline_sw', 'pipeline_ps') THEN amount ELSE 0 END) AS standard_waterfall,
    -- ... etc
  FROM burc_waterfall
  WHERE fiscal_year >= 2025 OR fiscal_year IS NULL  -- Fixed
  GROUP BY COALESCE(fiscal_year, 2026)
)
```

### API Fix (route.ts)
Added transformation to convert snake_case view data to camelCase for the component.

## Verification

After fix, reconciliation shows meaningful data:

| Category | Pipeline | Waterfall | Variance | Notes |
|----------|----------|-----------|----------|-------|
| Committed | $0.16M | $20.16M | -$20.00M | Run-rate maintenance not in deals |
| Best Case | $8.89M | $6.23M | +$2.66M | Deals not yet in forecast |
| Pipeline | $4.09M | $1.55M | +$2.54M | More speculative deals |
| Business Case | $6.29M | $0.00M | +$6.29M | Not in waterfall (speculative) |
| **TOTAL** | **$19.43M** | **$27.94M** | **-$8.52M** | Status: CRITICAL |

## Explanation of Variance

The $8.52M negative variance is expected and meaningful:

1. **Committed Gap (-$20M)**: The waterfall includes $20M of run-rate maintenance revenue that doesn't appear as individual deals in the pipeline tracker.

2. **Best Case/Pipeline Overage (+$5.2M)**: The deal pipeline has more deals than what's been included in the official waterfall forecast.

3. **Business Case (+$6.3M)**: These highly speculative deals aren't included in the waterfall forecast at all.

## Files Modified

- `src/app/api/analytics/burc/reconciliation/route.ts` - Added data transformation
- Database view `burc_reconciliation_summary` - Fixed WHERE clause and category mapping

## Lessons Learned

1. **NULL handling in fiscal_year**: When tables use NULL to mean "current year", views must explicitly handle this with `COALESCE` or `OR fiscal_year IS NULL`

2. **Understand data hierarchies**: Before summing categories, check if they're additive or hierarchical (e.g., `committed_gross_rev` includes `backlog_runrate`)

3. **API response formats**: When views return snake_case, APIs must transform to match client expectations
