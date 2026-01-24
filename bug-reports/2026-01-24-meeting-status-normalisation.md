# Bug Report: Meeting Status Case Inconsistency

**Date**: 2026-01-24
**Status**: RESOLVED
**Severity**: Low
**Component**: unified_meetings table

---

## Issue Summary

Meeting status values had inconsistent casing: "Scheduled" (2 records) vs "scheduled" (17 records).

## Root Cause

Data imported from different sources used different casing conventions.

## Solution

Normalised all status values to lowercase:

```sql
UPDATE unified_meetings
SET status = 'scheduled'
WHERE status = 'Scheduled';
```

## Results

Before:
- `Scheduled`: 2 records
- `scheduled`: 17 records
- `completed`: 189 records
- `cancelled`: 2 records

After:
- `scheduled`: 19 records
- `completed`: 189 records
- `cancelled`: 2 records

## Files Modified

- `supabase/migrations/20260124_normalise_meeting_statuses.sql` (applied via API)

## Prevention

Consider adding a CHECK constraint or trigger to enforce lowercase status values.

## Related

- Part of data audit: `docs/audits/2026-01-23-data-audit-report.md`
