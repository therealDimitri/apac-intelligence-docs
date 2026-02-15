# Bug Report: BURC Revenue Data Not Displaying (FY2025/2026 Zeros)

**Date:** 2026-01-08
**Status:** Resolved
**Priority:** High
**Component:** BURC Financial Analytics

---

## Issue Summary

The BURC dashboard and related APIs were showing $0 for FY2025 and FY2026 revenue data despite the data existing in the database. This caused:
- Revenue trend charts showing incomplete data
- Export files missing 2025/2026 values
- Drill-down analytics missing recent year data

---

## Root Cause

**Data source mismatch:**

Three different tables store revenue data with varying levels of completeness:

| Table | Row Count | FY2024 | FY2025 | FY2026 |
|-------|-----------|--------|--------|--------|
| `burc_historical_revenue` | 65 | $36.0M | **$0** | **$0** |
| `burc_historical_revenue_detail` | 295 | $33.04M | $26.19M | $29.86M |
| `burc_annual_financials` | 8 | $33.04M | $26.34M | $31.17M |

The APIs were querying `burc_historical_revenue` which uses a denormalised column structure (`year_2019`, `year_2020`, etc.) but the `year_2025` and `year_2026` columns were never populated.

The authoritative data exists in:
- `burc_annual_financials` - Correct yearly totals
- `burc_historical_revenue_detail` - Client-level breakdown by fiscal year

---

## Solution Implemented

Updated three API routes to use the correct data sources:

### 1. `/api/analytics/burc/route.ts` (Historical Revenue Section)

**Before:** Computed year totals from `burc_historical_revenue` (zeros for 2025/2026)

**After:** Fetches year totals from `burc_annual_financials` (authoritative) with fallback to client-level data

```typescript
// Fetch both client-level data and accurate annual totals in parallel
const [histResult, annualResult] = await Promise.all([
  supabase.from('burc_historical_revenue').select('*'),
  supabase.from('burc_annual_financials').select('fiscal_year, gross_revenue'),
])

// Use annual_financials as primary source, fall back to client data
const getAnnualTotal = (year: number) =>
  annualData.find(a => a.fiscal_year === year)?.gross_revenue || 0

const yearTotals = {
  fy25: getAnnualTotal(2025) || historical.reduce(...),
  fy26: getAnnualTotal(2026) || historical.reduce(...),
  // ...
}
```

### 2. `/api/analytics/burc/drill-down/route.ts`

**Before:** Queried `burc_historical_revenue` for revenue breakdown

**After:** Queries `burc_historical_revenue_detail` which has complete fiscal year data

```typescript
const { data: revenueData } = await supabase
  .from('burc_historical_revenue_detail')
  .select('client_name, revenue_type, fiscal_year, amount_usd')
  .in('fiscal_year', [2023, 2024, 2025])
```

### 3. `/api/analytics/burc/export/route.ts`

**Before:** Exported from `burc_historical_revenue` (missing 2025/2026 data)

**After:** Queries `burc_historical_revenue_detail` and transforms to expected format

```typescript
// Use burc_historical_revenue_detail which has complete data for all years
supabase.from('burc_historical_revenue_detail').select('*')

// Transform detail data into the format expected by the export
revenueDetail?.forEach(row => {
  if (row.fiscal_year === 2025) existing.year_2025 += amount
  else if (row.fiscal_year === 2026) existing.year_2026 += amount
})
```

---

## Files Modified

| File | Change |
|------|--------|
| `src/app/api/analytics/burc/route.ts` | Use `burc_annual_financials` for year totals |
| `src/app/api/analytics/burc/drill-down/route.ts` | Switch to `burc_historical_revenue_detail` |
| `src/app/api/analytics/burc/export/route.ts` | Switch to `burc_historical_revenue_detail` |

---

## Data Architecture Note

The BURC module has evolved to use multiple tables:

```
┌─────────────────────────────────┐
│   burc_annual_financials        │ ← Authoritative yearly totals
│   (fiscal_year, gross_revenue)  │   Use for: Year totals, KPIs
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ burc_historical_revenue_detail  │ ← Client-level breakdown
│ (client_name, fiscal_year,      │   Use for: Drill-downs, exports
│  revenue_type, amount_usd)      │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│   burc_historical_revenue       │ ← DEPRECATED (legacy format)
│   (customer_name, year_2024...) │   Only 2019-2024 populated
└─────────────────────────────────┘
```

**Recommendation:** Future development should use:
- `burc_annual_financials` for yearly totals
- `burc_historical_revenue_detail` for client-level analysis
- Avoid `burc_historical_revenue` as it requires manual column updates for new years

---

## Verification

After deployment, verify:
1. Revenue Trend chart shows data for FY2019-FY2026
2. BURC export includes 2025/2026 values
3. Drill-down by client shows recent year revenue

---

## Related Issues

- BUG-REPORT-20260107-historical-revenue-sync.md - Original sync of 2019-2024 data
- BUG-REPORT-20260107-burc-annual-financials-sync.md - Annual totals sync
