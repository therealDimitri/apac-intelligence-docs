# Bug Report: Revenue Concentration and Mix Charts Including Aggregate Rows

**Date:** 2026-01-20
**Severity:** High
**Status:** Fixed
**Component:** BURC Performance - Revenue Charts

## Summary

The Revenue Concentration and Revenue Mix charts were showing incorrect data because they included aggregate rows (APAC Total, Total, Baseline, profit share entries) from the `burc_historical_revenue_detail` table, causing FY2025 to show $157.5M instead of the correct $26.03M and concentration metrics showing 100% (HHI 10000).

## Symptoms

- Revenue Concentration chart showed 100% Top 5 concentration
- HHI Index showed 10000 (indicating a single-client monopoly)
- FY2025 total revenue appeared as $157.5M instead of ~$26M
- Revenue Mix percentages were incorrect due to inflated totals
- Browser continued showing stale data even after API fix due to HTTP caching

## Root Cause

Two issues were identified:

### Issue 1: Aggregate Rows Not Filtered
The `getRevenueConcentration()` and `getRevenueMix()` functions in the historical API were aggregating all rows including:
- "APAC Total"
- "Total"
- "Baseline"
- "DBM to APAC profit share"
- "Hosting to APAC profit share"
- "MS to APAC profit share"
- "(blank)"

These aggregate rows should be excluded as they double-count actual client revenue.

### Issue 2: Browser HTTP Caching
The API returns `cache-control: public, max-age=3600` headers. The frontend hooks were not bypassing browser cache, causing stale data to persist for up to 1 hour after fixes.

**Before (broken):**
```typescript
// getRevenueConcentration() - no filtering
allData.forEach(row => {
  const year = row.fiscal_year
  const client = row.client_name  // Includes aggregate rows!

  yearlyClientRevenue[year][client] =
    (yearlyClientRevenue[year][client] || 0) + row.amount_usd
})

// useBURCConcentration hook - no cache bypass
const res = await fetch('/api/analytics/burc/historical?view=concentration')
```

## Fix Applied

### API Fix - Filter Aggregate Rows
Used the existing `getConsolidatedClientName()` function which returns `null` for rows marked with `__EXCLUDE__` in the `CLIENT_PARENT_MAP`:

**After (fixed):**
```typescript
allData.forEach(row => {
  const year = row.fiscal_year
  const rawClient = row.client_name
  if (!rawClient) return

  // Use consolidated name and filter out aggregate rows
  const client = getConsolidatedClientName(rawClient)
  if (!client) {
    excludedCount++
    excludedNames.add(rawClient)
    return // Skip aggregation rows (APAC Total, Total, Baseline, etc.)
  }

  if (!yearlyClientRevenue[year]) {
    yearlyClientRevenue[year] = {}
  }
  yearlyClientRevenue[year][client] =
    (yearlyClientRevenue[year][client] || 0) + (row.amount_usd || 0)
})
```

### Frontend Fix - Bypass Browser Cache
Added `cache: 'no-store'` to all BURC fetch calls:

```typescript
const res = await fetch('/api/analytics/burc/historical?view=concentration', {
  cache: 'no-store'
})
```

## Files Changed

| File | Change |
|------|--------|
| `src/app/api/analytics/burc/historical/route.ts` | Added aggregate row filtering to `getRevenueConcentration()` and `getRevenueMix()` |
| `src/hooks/useBURCHistorical.ts` | Added `cache: 'no-store'` to all fetch calls |

## Data Validation

**Before fix (FY2025):**
- Total Revenue: $157.50M (incorrect - includes aggregates)
- Clients: 1 (incorrect - aggregates treated as single client)
- Top 5 Concentration: 100%
- HHI: 10000

**After fix (FY2025):**
- Total Revenue: $26.03M (correct)
- Clients: 17 (correct - actual distinct clients)
- Top 5 Concentration: 83.8%
- HHI: 2197 (Medium concentration)

## Excluded Rows

The following client names are now correctly excluded:
- APAC Total
- Total
- Baseline
- (blank)
- DBM to APAC profit share
- Hosting to APAC profit share
- MS to APAC profit share

## Testing

1. Navigate to BURC Performance page
2. Click "Revenue Performance" tab
3. Verify Revenue Concentration Risk shows:
   - Top 5 Clients: ~80% (not 100%)
   - HHI Index: ~2300 (not 10000)
   - Status: "Medium Concentration" (not monopoly-level)
4. Verify Revenue Trend shows FY2025 total of ~$26M
5. Verify Revenue Mix percentages sum to 100% per year

## Prevention

- When aggregating from `burc_historical_revenue_detail`, always use `getConsolidatedClientName()` to filter aggregate rows
- The `CLIENT_PARENT_MAP` in the API defines which client names should be excluded using the `__EXCLUDE__` marker
- When making API fixes, ensure frontend hooks bypass browser cache using `cache: 'no-store'`

## Commit

```
fix: Revenue Concentration and Mix charts excluding aggregate rows

- Added filtering to getRevenueConcentration() to exclude aggregate rows
  (APAC Total, Total, Baseline, profit share entries) using __EXCLUDE__ marker
- Added same filtering to getRevenueMix() for consistent data
- Added cache: 'no-store' to all BURC hooks to bypass browser HTTP cache
  and ensure fresh data after API fixes

Before: FY2025 showed $157M with 100% concentration (HHI 10000)
After: FY2025 shows $26M with 80% top-5 concentration (HHI 2364)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```
