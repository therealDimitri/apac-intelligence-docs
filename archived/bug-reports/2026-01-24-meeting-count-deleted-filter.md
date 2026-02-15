# Bug Report: Meeting Count Including Deleted Records

**Date**: 2026-01-24
**Status**: RESOLVED
**Severity**: Medium
**Component**: BURCExecutiveDashboard / Meeting Stats

---

## Issue Summary

The "Meetings Held" count on the Executive Dashboard was including soft-deleted meetings in its count, showing 7 instead of the correct 5 meetings in the last 30 days.

## Root Cause

The Supabase queries for meeting counts in `BURCExecutiveDashboard.tsx` did not filter out deleted meetings:

```typescript
// Before - no deleted filter
const { count: meetingsLast30d } = await supabase
  .from('unified_meetings')
  .select('*', { count: 'exact', head: true })
  .gte('meeting_date', thirtyDaysAgo.toISOString().split('T')[0])
  .eq('status', 'completed')
```

## Solution

Added `.eq('deleted', false)` filter to all meeting count queries:

```typescript
// After - excludes deleted meetings
const { count: meetingsLast30d } = await supabase
  .from('unified_meetings')
  .select('*', { count: 'exact', head: true })
  .gte('meeting_date', thirtyDaysAgo.toISOString().split('T')[0])
  .eq('status', 'completed')
  .eq('deleted', false)
```

## Files Modified

- `src/components/burc/BURCExecutiveDashboard.tsx`
  - Line 369: Added deleted filter to last 30 days query
  - Line 378: Added deleted filter to prior 30 days query
  - Line 385: Added deleted filter to QBR count query

## Testing

- Verified completed meetings last 30 days: 5 (was showing 7)
- Verified prior period: 25 (was showing 40)
- Build passes with no TypeScript errors

## Related

- Part of data audit: `docs/audits/2026-01-23-data-audit-report.md`
- Task #4: Fix Meetings Held showing 0 on dashboard
