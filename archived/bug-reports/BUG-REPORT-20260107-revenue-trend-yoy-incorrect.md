# Bug Report: Revenue Trend YoY Growth Showing 786% Instead of 28%

**Date:** 2026-01-07
**Status:** Resolved
**Priority:** High
**Component:** BURC Performance - Revenue Trend API

---

## Issue Summary

The Revenue Trend chart on the Financials page was displaying an incorrect Year-over-Year (YoY) growth of **786.2%** for FY2026 instead of the correct value of **28.1%**.

---

## Root Cause

The `getRevenueTrend` function in the historical API was using `burc_historical_revenue_detail` as the primary data source for yearly revenue totals. However, this table contained almost no data:

| Fiscal Year | burc_historical_revenue_detail | burc_annual_financials |
|-------------|-------------------------------|------------------------|
| FY2019 | $0.00M | $13.55M |
| FY2020 | $0.00M | $17.06M |
| FY2021 | $0.00M | $9.64M |
| FY2022 | $0.00M | $12.29M |
| FY2023 | $2.52M | $15.88M |
| FY2024 | $1.85M | $29.35M |
| FY2025 | $0.00M | $26.34M |
| FY2026 | N/A | $33.74M |

The API only fell back to `burc_annual_financials` for FY2026 (forecast year), causing the YoY calculation to compare:
- FY2025: ~$0M (from sparse historical_revenue_detail)
- FY2026: $33.74M (from annual_financials)

Result: `((33.74 - 0) / 3.8) * 100 = 786.2%`

---

## Solution Implemented

Changed the API to use `burc_annual_financials` as the **primary source** for all yearly totals, with `burc_historical_revenue_detail` used only as a secondary source for revenue type breakdown when sufficient data exists.

### Changes Made

**File:** `src/app/api/analytics/burc/historical/route.ts`

**Before:**
```typescript
// Primary: burc_historical_revenue_detail (incomplete data)
const data = await fetchWithParallelPagination<RevenueRow>(
  'burc_historical_revenue_detail',
  'fiscal_year, revenue_type, amount_usd',
  { ... }
)

// Only fallback to annual_financials for FY2026
if (endYear >= 2026 && (!yearlyData[2026] || yearlyData[2026].total === 0)) {
  const { data: forecast } = await supabase
    .from('burc_annual_financials')
    .select('fiscal_year, gross_revenue')
    .eq('fiscal_year', 2026)
    .single()
  // ...
}
```

**After:**
```typescript
// Primary: burc_annual_financials (complete data for all years)
const { data: annualData } = await supabase
  .from('burc_annual_financials')
  .select('fiscal_year, gross_revenue')
  .gte('fiscal_year', startYear)
  .lte('fiscal_year', endYear)
  .order('fiscal_year')

// Initialise from annual financials with estimated breakdown
if (annualData) {
  for (const row of annualData) {
    const total = row.gross_revenue || 0
    yearlyData[row.fiscal_year] = {
      sw: total * 0.15,    // Software ~15%
      ps: total * 0.25,    // PS ~25%
      maint: total * 0.55, // Maintenance ~55%
      hw: total * 0.05,    // Hardware ~5%
      total: total,
    }
  }
}

// Secondary: Use detail breakdown if >50% coverage exists
// (scales detail percentages to match annual total)
```

---

## YoY Growth Comparison

| Fiscal Year | Before (Broken) | After (Fixed) |
|-------------|-----------------|---------------|
| FY2020 | 0% | 25.9% |
| FY2021 | 0% | -43.5% |
| FY2022 | 0% | 27.6% |
| FY2023 | 0% | 29.1% |
| FY2024 | 0% | 84.9% |
| FY2025 | 0% | -10.2% |
| FY2026 | **786.2%** | **28.1%** |

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/analytics/burc/historical/route.ts` | Changed `getRevenueTrend()` to use `burc_annual_financials` as primary source |

---

## Testing Verification

- [x] TypeScript compilation passes (`npx tsc --noEmit`)
- [x] API returns correct yearly totals from `burc_annual_financials`
- [x] YoY growth calculated correctly (28.1% for FY2026)
- [x] Revenue Trend chart displays correct values
- [x] Revenue type breakdown uses estimated percentages

---

## Related Tables

- `burc_annual_financials` - Complete yearly revenue totals (primary source)
- `burc_historical_revenue_detail` - Detailed transaction-level data (secondary, incomplete)

---

## Lessons Learned

1. **Primary data sources matter**: When multiple tables contain overlapping data, always verify which has complete coverage
2. **Fallback logic should apply to all years**: The original code only fell back for FY2026, missing the fact that all other years were also empty
3. **YoY calculations are sensitive**: Small denominator values cause dramatic percentage swings
