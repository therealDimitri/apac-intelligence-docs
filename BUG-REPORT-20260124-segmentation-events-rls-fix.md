# Bug Report: Segmentation Events RLS Policy Blocking INSERT

**Date:** 2026-01-24
**Severity:** High (Functionality Broken)
**Status:** Resolved

## Summary

After fixing the schema mismatch bug (non-existent columns), attempting to log segmentation events failed with an RLS (Row Level Security) policy violation error.

## Root Cause

The `useEvents` hook was using the client-side Supabase client (anon key) to perform INSERT/UPDATE/DELETE operations on the `segmentation_events` table. The RLS policies on this table block these operations for anonymous/client-side requests.

### Database Error
```
code: '42501'
message: "new row violates row-level security policy for table 'segmentation_events'"
```

## Solution

Created a new API route that uses the service role key to bypass RLS policies, following the existing pattern used by other protected operations in the codebase.

## Files Modified

### 1. `src/app/api/segmentation-events/route.ts` (CREATED)
New API route with all CRUD operations using service role:
- `GET` - Fetch events with optional filters (client_name, year, event_type_id)
- `POST` - Create new segmentation event
- `PATCH` - Update existing event by ID
- `DELETE` - Delete event by ID

### 2. `src/hooks/useEvents.ts` (MODIFIED)
Updated all CRUD functions to use the API route instead of direct Supabase client:
- `fetchFreshData()` - Now calls `GET /api/segmentation-events`
- `createEvent()` - Now calls `POST /api/segmentation-events`
- `updateEvent()` - Now calls `PATCH /api/segmentation-events?id=`
- `markEventComplete()` - Now calls `PATCH /api/segmentation-events?id=`
- `deleteEvent()` - Now calls `DELETE /api/segmentation-events?id=`

## Testing Performed

- [x] Build passes without TypeScript errors
- [x] Event logging via QuickEventCaptureModal works successfully
- [x] Toast notification confirms "1 event(s) logged successfully!"
- [x] No RLS errors in console

## Pattern Reference

This fix follows the same pattern used by:
- `/api/comments/route.ts` - Comment CRUD operations
- `/api/actions/[id]/route.ts` - Action updates
- Other protected routes using `getServiceSupabase()`

## Related Bug Reports

- `BUG-REPORT-20260124-segmentation-event-logging-fix.md` - Previous schema mismatch fix (prerequisite for this fix)
