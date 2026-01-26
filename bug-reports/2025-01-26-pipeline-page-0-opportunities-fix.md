# Bug Report: Pipeline Page Showing 0 Opportunities

## Issue
The Pipeline page displayed "0/0 opps" with "$0 ACV" and "$0 Weighted" despite the API successfully returning 83 opportunities with valid data.

## Date
2025-01-26

## Symptoms
- Pipeline page shows "0/0 opps"
- ACV and Weighted ACV both show $0
- "No opportunities match your filters" message displayed
- API endpoint `/api/pipeline/2026` returns 200 OK with valid data
- Browser evaluate confirmed API returned 83 opportunities with $17.9M ACV

## Root Cause
**Same issue as the Outlook sync bug (2025-01-26-outlook-sync-0-meetings-fix.md)**

Mismatch between the standardized API response structure and how the frontend component accessed it.

### The Problem
The `createSuccessResponse()` utility in `api-utils.ts` wraps all response data in a `data` property:

```typescript
// API returns:
{
  success: true,
  data: {
    opportunities: [...],  // 83 opportunities here
    stats: {...},
    lastUpdated: "..."
  }
}
```

But `pipeline/page.tsx` was accessing:
```typescript
// OLD CODE (BUGGY):
setOpportunities(data.opportunities || [])
setStats(data.stats || null)
setLastUpdated(data.lastUpdated)
// data.opportunities is undefined → falls back to empty array
```

### The Fix
```typescript
// NEW CODE (CORRECT):
setOpportunities(data.data?.opportunities || [])
setStats(data.data?.stats || null)
setLastUpdated(data.data?.lastUpdated)
// data.data.opportunities correctly accesses the opportunities array
```

## Files Affected
- `src/app/(dashboard)/pipeline/page.tsx` - Pipeline page component (lines 311-314)

## Changes Made

### Data Access Pattern (lines 311-314)
```typescript
// Before:
const data = await response.json()
setOpportunities(data.opportunities || [])
setStats(data.stats || null)
setLastUpdated(data.lastUpdated)

// After:
const data = await response.json()
setOpportunities(data.data?.opportunities || [])
setStats(data.data?.stats || null)
setLastUpdated(data.data?.lastUpdated)
```

## Pipeline Data Now Displaying
- **Total Opportunities**: 83
- **Total ACV**: $17,906,609.80 (~$17.91M)
- **Total Weighted ACV**: $8,340,365.80 (~$8.34M)
- **2026 Pipeline Bookings Forecast**: $23.41M (81 opps with forecast)

## Testing
- Build passes with zero TypeScript errors
- Browser verification confirms:
  - 83/83 opportunities displayed
  - ACV: $17.91M
  - Weighted: $8.34M
  - All filters and table columns working correctly

## Related Issues
This is the **same root cause** as:
- `2025-01-26-outlook-sync-0-meetings-fix.md` - Outlook sync showing 0 meetings

## Prevention
When using standardized API response utilities (`createSuccessResponse`, `createErrorResponse`), always remember:
- Success: Access data via `response.data.yourProperty`
- Error: Access error info via `response.error.code`, `response.error.message`, `response.error.details`

## Status
RESOLVED
