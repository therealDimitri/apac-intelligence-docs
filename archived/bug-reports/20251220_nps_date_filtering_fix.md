# Bug Report: NPS Analytics Date Filtering

**Date:** 2025-12-20
**Status:** Fixed
**Commit:** 3d31446

## Issue Description

NPS data was missing from the Analytics dashboard, showing "No data available" for NPS metrics and 0% on the NPS Breakdown chart.

## Root Cause

The NPS analytics APIs (`/api/analytics/dashboard` and `/api/analytics/ai-summary`) were filtering NPS responses by `response_date` within the selected timeframe (e.g., last 30 days). However, NPS surveys are only conducted twice yearly (Q2 and Q4), meaning:

1. Most timeframes would return 0 NPS responses
2. The fallback logic was unreliable
3. Grouping by `response_date` didn't align with actual survey periods

## Solution

### Changes Made

1. **`src/app/api/analytics/dashboard/route.ts`**
   - Removed date filtering from `fetchNPSAnalytics`
   - Always fetch all NPS data regardless of timeframe
   - Changed grouping from `response_date` to `period` field
   - Updated sorting to handle both "2023" (yearly) and "Q2 24" (quarterly) formats

2. **`src/app/api/analytics/ai-summary/route.ts`**
   - Removed date filtering (was using `response_date` >= startDate)
   - Removed fallback logic that fetched all data only when timeframe returned empty
   - Now always fetches all NPS data directly

### Database Context

The `nps_responses` table uses a `period` field with values like:
- `"2023"` - Full year format (historical data)
- `"Q2 24"` - Quarterly format (Q2 2024)
- `"Q4 24"` - Quarterly format (Q4 2024)
- `"Q2 25"` - Quarterly format (Q2 2025)
- `"Q4 25"` - Quarterly format (Q4 2025)

### Period Sorting Logic

```typescript
const parsePeriod = (p: string): number => {
  // Handle "Q2 24" format (quarterly)
  const quarterMatch = p.match(/Q(\d)\s+(\d{2})/)
  if (quarterMatch) {
    const year = 2000 + parseInt(quarterMatch[2])
    const quarter = parseInt(quarterMatch[1])
    return year * 10 + quarter
  }
  // Handle "2023" format (yearly - treat as Q0)
  const yearMatch = p.match(/^(\d{4})$/)
  if (yearMatch) {
    return parseInt(yearMatch[1]) * 10
  }
  return 0 // Unknown format
}
```

This ensures chronological ordering: 2023 -> Q2 24 -> Q4 24 -> Q2 25 -> Q4 25

## Testing

- Build passes successfully
- NPS data now displays correctly regardless of timeframe selection
- Historical trend chart shows data grouped by survey period

## Lessons Learned

1. Periodic/seasonal data (like NPS surveys) should not use timeframe filtering
2. Use domain-specific grouping fields (`period`) rather than generic date fields
3. Document survey schedules to inform data retrieval logic
