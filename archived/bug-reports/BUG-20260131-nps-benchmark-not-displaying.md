# Bug Report: NPS Benchmark Data Not Displaying

**Date:** 2026-01-31
**Severity:** Medium
**Status:** Fixed
**Component:** NPS Analytics / GlobalNPSBenchmark

## Summary

The NPS Analytics page was showing "No benchmark data available" despite the database containing 361 benchmark records for Q4 25.

## Symptoms

- "No benchmark data available" error displayed on NPS Analytics page
- Global Altera Benchmark section showed error state with warning icon
- Database contained valid data (verified: 361 global records, 43 APAC records)

## Root Cause

**API response envelope mismatch**

The API endpoint `/api/nps/global-benchmark` uses `createSuccessResponse()` which wraps the response:

```json
{
  "success": true,
  "data": {
    "period": "Q4 25",
    "global": {...},
    "apac": {...},
    "comparison": {...}
  }
}
```

But the `GlobalNPSBenchmark` component was expecting data at the top level:

```typescript
// BEFORE (broken)
const benchmarkData = await response.json()
setData(benchmarkData)  // Sets { success, data } instead of the actual data

// Later check fails because benchmarkData.comparison is undefined
if (error || !data || !data.comparison) {
  return <error state>
}
```

## Solution

Fixed the component to properly unwrap the API response envelope:

```typescript
// AFTER (fixed)
const result = await response.json()
if (!result.success) {
  throw new Error(result.error || 'Failed to fetch benchmark data')
}
setData(result.data)  // Now correctly sets the unwrapped data
```

## Files Modified

- `src/components/GlobalNPSBenchmark.tsx` - Fixed response parsing

## Verification

1. Visit NPS Analytics page
2. Global Altera Benchmark section should display:
   - APAC NPS: -19 (Q4 25)
   - Global ex. APAC NPS: -5
   - Difference: -13.3 points

## Related

- API endpoint: `src/app/api/nps/global-benchmark/route.ts`
- API utility: `src/lib/api-utils.ts` (`createSuccessResponse`)

## Prevention

When consuming API endpoints that use `createSuccessResponse`, always check for and unwrap the `{ success, data }` envelope structure.
