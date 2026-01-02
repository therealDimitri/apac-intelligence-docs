# Bug Report: Historical Analytics API Timeout

**Date:** 3 January 2026
**Severity:** Critical
**Status:** Resolved
**Affected Page:** Financials > Historical Analytics (2019-2025) tab

## Issue Description

The Historical Analytics tab on the Financials page was showing:
- "No revenue data available" for the Revenue Trend chart
- "Failed to load NRR data" for the NRR/GRR chart
- Revenue Concentration Risk chart was working (partial data loading)

## Root Cause Analysis

The `/api/analytics/burc/historical` endpoint was timing out on Netlify due to:

1. **Sequential Pagination**: The API was fetching 84,932 records using sequential pagination (1000 records per page, 85 pages)
2. **Execution Time**: Each page request took ~0.5 seconds, resulting in **44+ seconds** total execution time
3. **Netlify Timeout**: Netlify serverless functions have a 10-26 second timeout limit
4. **Partial Failure**: Some views worked (concentration) because they were cached or returned faster, but trend and NRR views consistently timed out

### Database Statistics
- **Total records**: 84,932 in `burc_historical_revenue_detail`
- **Revenue types**: Maintenance (49,506), Professional Services (25,680), License (9,270), Hardware (476)
- **Years covered**: 2019-2025 ($14M to $52M per year)

## Solution Implemented

Replaced sequential pagination with **parallel pagination**:

```typescript
async function fetchWithParallelPagination<T>(
  tableName: string,
  selectColumns: string,
  filters?: { gte?: { column: string; value: number }; lte?: { column: string; value: number } }
): Promise<T[]> {
  const pageSize = 10000 // Larger pages for fewer round trips

  // First, get the count to know how many pages we need
  const { count } = await countQuery
  const totalPages = Math.ceil((count || 0) / pageSize)

  // Fetch all pages in parallel using Promise.all
  const pagePromises = Array.from({ length: totalPages }, async (_, page) => {
    // ... fetch page
  })

  const results = await Promise.all(pagePromises)
  return results.flat() as T[]
}
```

### Performance Improvement
- **Before**: ~44 seconds (sequential, 85 requests)
- **After**: ~5 seconds (parallel, 9 requests)
- **Improvement**: 88% faster

## Files Changed

- `src/app/api/analytics/burc/historical/route.ts`
  - Added `fetchWithParallelPagination()` helper function
  - Updated all view functions to use parallel pagination:
    - `getRevenueTrend()`
    - `getRevenueMix()`
    - `getClientLifetimeValue()`
    - `getRevenueConcentration()`
    - `getHistoricalNRR()`

## Verification Steps

1. Navigate to Financials page
2. Click on "Historical (2019-2025)" tab
3. Verify Revenue Trend chart displays with data for all years
4. Verify NRR/GRR Trends chart displays with retention metrics
5. Verify Revenue Concentration Risk chart continues to work
6. Check browser Network tab - API requests should complete in <10 seconds

## Lessons Learned

1. **Always consider data volume**: APIs that work in development may fail in production with larger datasets
2. **Parallel fetching**: When pagination is required, use parallel requests where possible
3. **Monitor function timeouts**: Set up alerts for serverless function timeouts
4. **Caching is critical**: The in-memory cache (1-hour TTL) prevents repeated slow queries

## Related Commits

- `8074d46`: fix: optimize Historical Analytics API with parallel pagination
