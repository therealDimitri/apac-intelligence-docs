# Bug Fix: Duplicate 2026 in Revenue Concentration Chart

**Date**: 2026-01-19
**Type**: Bug Fix
**Component**: BURC Historical Revenue - Revenue Concentration Risk Chart
**Status**: Resolved

## Description

The Revenue Concentration Risk chart was displaying "2026*" twice on the x-axis. This caused visual confusion and incorrect data representation in the chart.

## Root Cause

The API endpoint `/api/analytics/burc/historical?view=concentration` was:
1. Fetching actual 2026 data from the database (which exists - 4 records for "APAC Total")
2. **Then also** adding a forecasted 2026 entry based on 2024/2025 trends

This resulted in two 2026 data points being returned and rendered on the chart.

### Original Code (Line 642-678)

The code added a forecast 2026 entry without checking if actual 2026 data already existed:

```tsx
// Add 2026 forecast based on recent trend
const fy2025 = concentration.find(c => c.year === 2025)
const fy2024 = concentration.find(c => c.year === 2024)

if (fy2025 && fy2024) {
  // ... projection logic
  concentration.push(projected2026)
}
```

## Solution

Added a check to verify if actual 2026 data already exists before adding the forecast:

### Fixed Code

```tsx
// Add 2026 forecast based on recent trend (only if we don't already have actual 2026 data)
const fy2026Exists = concentration.some(c => c.year === 2026)
const fy2025 = concentration.find(c => c.year === 2025)
const fy2024 = concentration.find(c => c.year === 2024)

if (!fy2026Exists && fy2025 && fy2024) {
  // ... projection logic
  concentration.push(projected2026)
  console.log(`[getRevenueConcentration] Added FY2026 forecast: HHI=${projected2026.hhi}`)
}
```

## Files Modified

1. `src/app/api/analytics/burc/historical/route.ts`
   - Added `fy2026Exists` check at line 643
   - Modified conditional at line 647 to include `!fy2026Exists`

## Testing

### Before Fix
- X-axis displayed: 2019, 2020, 2021, 2022, 2023, 2024, 2025, **2026\*, 2026\***
- Two data points for 2026 (actual + forecast)

### After Fix
- X-axis displays: 2019, 2020, 2021, 2022, 2023, 2024, 2025, **2026\***
- Single 2026 data point (actual data used when available)

## Additional Notes

- Required server restart to clear in-memory cache (1-hour TTL)
- The cache uses the key `concentration` and stores results for 1 hour
- After fix deployment, users may need to wait for cache expiry or force refresh

## Verification Steps

1. Navigate to `/` (Command Centre)
2. Click on "Historical Revenue" tab
3. Scroll to "Revenue Concentration Risk" chart
4. Verify x-axis shows only one 2026* entry

## Commit

`11813cb7` - fix: Prevent duplicate 2026 in Revenue Concentration chart when actual data exists
