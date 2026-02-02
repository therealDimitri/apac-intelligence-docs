# Bug Report: BURC Financial Metrics Showing Incorrect Values

**Date:** 2 February 2026
**Status:** Fixed
**Severity:** Critical
**Affected Components:** Executive Dashboard, Financial KPIs

## Summary

The BURC financial metrics (Total ARR, NRR, GRR) displayed on the Executive Dashboard were significantly incorrect due to multiple data source issues.

## Incorrect Values (Before Fix)

| Metric | Displayed | Actual (Excel) | Variance |
|--------|-----------|----------------|----------|
| Total ARR | $29.9M | $15.9M | +$14M (88% error) |
| NRR | 90% | 99% | -9 percentage points |
| GRR | 98% | 96% | +2 percentage points |
| Churn | $675K | $578K | +$97K |

## Root Causes

### 1. Wrong ARR Source in View

The `burc_executive_summary` database view calculated `total_arr` by summing `burc_arr_tracking.arr_usd` (FY2025 client-level data totaling $29.9M) instead of using the authoritative `burc_annual_financials.ending_arr` value.

**View definition (incorrect):**
```sql
WITH total_arr AS (
  SELECT COALESCE(sum(burc_arr_tracking.arr_usd), 0) AS total_arr
  FROM burc_arr_tracking
  WHERE year = 2025  -- Wrong: summing client tracking, not authoritative ARR
)
```

### 2. Wrong Excel Cell Reference

The `ending_arr` value in `burc_annual_financials` was sourced from Cell U36 ("Gross Revenue" = $31.6M) instead of Row 60 ("Maintenance NR (ARR)" = $15.9M).

**Correct Excel source:**
- File: `2026 APAC Performance.xlsx`
- Sheet: `APAC BURC`
- Row 60: "Maintenance NR (ARR)"
- Column U: FY2026 Total = $15,875,052.79

### 3. Hardcoded Churn Fallback

The sync script used a hardcoded $675,000 churn value instead of reading from the Attrition sheet which shows $578,000 for FY2026.

### 4. Incorrect NRR/GRR Base Values

With the wrong ARR values, the NRR and GRR calculations produced incorrect percentages:
- Old calculation used $29.9M starting ARR
- Correct starting ARR is $15.99M (FY2025 Maintenance NR from 26 vs 25 Q Comparison sheet)

## Resolution

### Database View Fix

Updated `burc_executive_summary` view to use `ending_arr` from `burc_annual_financials`:

```sql
-- Changed from summing burc_arr_tracking to using authoritative source
COALESCE(lf.ending_arr, lf.gross_revenue)::numeric AS total_arr
```

### Data Corrections

Updated `burc_annual_financials` for FY2026:

| Field | Old Value | New Value |
|-------|-----------|-----------|
| starting_arr | $29,855,057.24 | $15,987,722.35 |
| ending_arr | $29,855,057.24 | $15,875,052.79 |
| churn | $675,000 | $578,000 |
| expansion | -$2,423,552.21 | $465,330.44 |
| nrr_percent | 90.96 | 99.30 |
| grr_percent | 98.03 | 96.38 |

### Script Fix

Updated `scripts/sync-burc-data-supabase.mjs` to properly handle hierarchical Excel structure in Maint Pivot sheet (parent client rows vs child detail rows).

## Correct Excel Data Sources

| Metric | Sheet | Row | Column | Value |
|--------|-------|-----|--------|-------|
| FY2026 Maintenance NR (ARR) | APAC BURC | 60 | U | $15,875,052.79 |
| FY2025 Maintenance NR | 26 vs 25 Q Comparison | 22 | P | $15,987,722.35 |
| FY2026 Churn | Attrition | 3 | 2026 | $578,000 |

## Formulas

**NRR (Net Revenue Retention):**
```
NRR = Ending ARR / Starting ARR × 100
NRR = $15,875,052.79 / $15,987,722.35 × 100 = 99.30%
```

**GRR (Gross Revenue Retention):**
```
GRR = (Starting ARR - Churn) / Starting ARR × 100
GRR = ($15,987,722.35 - $578,000) / $15,987,722.35 × 100 = 96.38%
```

**Net Expansion:**
```
Net Expansion = Ending ARR - Starting ARR + Churn
Net Expansion = $15,875,052.79 - $15,987,722.35 + $578,000 = $465,330.44
```

## Verification

Dashboard now displays:
- Total ARR: $15.9M ✓
- NRR: 99% ✓
- GRR: 96% ✓
- Rule of 40: 48 ✓

## Lessons Learned

1. **Always verify Excel cell references** - Document exact row/column sources, not just sheet names
2. **Database views can mask data issues** - Views that aggregate from multiple sources need careful review
3. **Avoid hardcoded fallback values** - They silently hide data sync failures
4. **Financial metrics require end-to-end tracing** - From Excel source → database → view → API → UI

## Related Files

- `scripts/sync-burc-data-supabase.mjs` - BURC data sync script
- `src/components/burc/BURCExecutiveDashboard.tsx` - Dashboard component
- Database view: `burc_executive_summary`
- Database table: `burc_annual_financials`
