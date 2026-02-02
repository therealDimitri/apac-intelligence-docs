# Bug Report: BURC YoY Comparison Showing Incorrect Values (OPEX + Revenue)

**Date:** 2 February 2026
**Status:** Fixed
**Severity:** High
**Affected Components:** Executive Dashboard, YoY Comparison Panel

## Summary

The OPEX and Revenue YoY comparisons in the Year-over-Year Comparison panel were showing incorrect values. Both issues stemmed from the API summing detailed breakdown tables instead of using authoritative values from `burc_annual_financials`.

## Incorrect Values (Before Fix)

| Metric | Displayed | Actual (Excel) | Variance |
|--------|-----------|----------------|----------|
| FY26 OPEX | $-22.0M | $22.0M | Sign error due to summing Variance category |
| FY25 OPEX | $88.5M | $20.0M | +$68.5M (342% error) |
| OPEX Change | -$110M (-124.9%) | +$2.0M (+10%) | Completely wrong |

## Root Cause

### 1. Category Pollution in burc_monthly_opex

The `burc_monthly_opex` table contains multiple category types per month:
- **Baseline** - Budgeted/planned OPEX
- **Actual** - Real OPEX spend
- **Variance** - Difference between Baseline and Actual

The API was summing ALL categories together, which produced incorrect totals:
- FY25: Baseline ($44.9M) + Actual ($38.7M) + Variance ($4.9M) = $88.5M (wrong)
- FY26: Similar issue with Variance category containing negative values

### 2. Incorrect API Logic

**src/app/api/analytics/burc/route.ts (lines 659, 687):**
```javascript
// OLD: Summed all categories
const currentTotal = Object.values(opexByCategory).reduce((a, b) => a + b, 0)
const compareTotal = Object.values(compareByCategory).reduce((a, b) => a + b, 0)
```

## Resolution

### Database Column Added

Added `total_opex` column to `burc_annual_financials` with authoritative values from Excel Row 34 "Total OPEX Excluding unallocated Business Case OPEX":

| Fiscal Year | total_opex |
|-------------|------------|
| FY2026 | $22,046,221.03 |
| FY2025 | $20,044,962.10 |

### API Fix

Updated `src/app/api/analytics/burc/route.ts` to query `burc_annual_financials.total_opex` for authoritative values:

```javascript
// NEW: Use authoritative total_opex from burc_annual_financials
const { data: opexFinancials } = await supabase
  .from('burc_annual_financials')
  .select('total_opex')
  .eq('fiscal_year', fiscalYear)
  .single()

const authoritativeOpexTotal = opexFinancials?.total_opex || summedTotal
```

## Correct Excel Data Sources

| Metric | Sheet | Row | Column | Value |
|--------|-------|-----|--------|-------|
| FY2026 Total OPEX | APAC BURC | 34 | U (Forecast) | $22,046,221.03 |
| FY2025 Total OPEX | APAC BURC | 34 | Historical | $20,044,962.10 |

## Verification

Dashboard YoY Comparison now displays:
- **OPEX Change: +$2.0M (+10.0%)** ✓
- FY26: $22.0M ✓
- FY25: $20.0M ✓

## Lessons Learned

1. **Multi-category tables require explicit category filtering** - When a table contains multiple category types (Baseline, Actual, Variance), never blindly sum all values
2. **Create authoritative columns for key metrics** - Store final calculated values in a single source of truth to avoid aggregation errors
3. **Variance categories can be negative** - Summing positive base values with negative variances produces unexpected results

## Related Files

- `src/app/api/analytics/burc/route.ts` - API route with OPEX comparison logic
- `scripts/sync-burc-data-supabase.mjs` - BURC data sync script
- Database table: `burc_annual_financials` (added `total_opex` column)
- Database table: `burc_monthly_opex` (contains category-level data)

## Revenue YoY Comparison Fix

### Incorrect Values (Before Fix)

| Metric | Displayed | Actual (Excel) | Variance |
|--------|-----------|----------------|----------|
| FY26 Revenue | $39.5M | $31.6M | +$7.9M (25% error) |
| FY25 Revenue | $25.4M | $26.6M | -$1.2M (5% error) |
| Revenue Change | +$14.1M (+55.7%) | +$5.0M (+18.7%) | Overstated by $9M |

### Root Cause

The `revenueStreamsComparison` was summing `burc_revenue_detail` by stream type (Maint, PS, SW, HW) which produced different totals than the authoritative `gross_revenue` in `burc_annual_financials`.

### Resolution

Updated API to use `burc_annual_financials.gross_revenue` for the total variance calculation:

```javascript
const { data: currentRevenueFinancials } = await supabase
  .from('burc_annual_financials')
  .select('gross_revenue')
  .eq('fiscal_year', fiscalYear)
  .single()

const authoritativeCurrentRevenue = currentRevenueFinancials?.gross_revenue || summedCurrentTotal
```

### Correct Excel Data Sources

| Metric | Sheet | Cell | Value |
|--------|-------|------|-------|
| FY2025 Gross Revenue | 26 vs 25 Q Comparison | P14 | $26,631,098.22 |
| FY2026 Gross Revenue (Forecast) | 26 vs 25 Q Comparison | I14 | $31,597,838.41 |
| FY2026 Gross Revenue Target | APAC BURC | W36 | $30,906,xxx |

## Related Bug Reports

- `docs/BUG-20260202-burc-financial-metrics-incorrect.md` - Related ARR/NRR/GRR fix from same session
