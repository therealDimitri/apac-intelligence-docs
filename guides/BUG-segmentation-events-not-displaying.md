# Bug Report: Segmentation Events Not Displaying in Modal Calendar

**Date:** 2026-01-10
**Severity:** High
**Status:** Fixed

## Summary

Segmentation events were not displaying in the modal calendar tiles even though completed events existed in the database with tick boxes checked in the Excel import. The calendar showed "No Events Found" for months where events clearly existed.

## Root Cause

The `/api/segmentation-events/route.ts` API endpoint was attempting to query events by `client_uuid`, but:

1. The `resolve_client_id` RPC function referenced in the code did not exist
2. Events imported from Excel only had `client_name` populated - the `client_id` column was `NULL` for 749+ events
3. The API was not using the `client_aliases` table for client name resolution

**Important Rule:** Always use the `client_aliases` table for client name resolution. This table maps various client name formats/aliases to a canonical `client_id`.

## Fix Applied

Updated `/api/segmentation-events/route.ts` to:

1. First query the `client_aliases` table to get the `client_id` for the given client name
2. Build the query to fetch events by EITHER `client_id` OR `client_name`
3. This handles both new events (with `client_id`) and imported events (with `client_name` only)

### Code Change

**Before (broken):**
```typescript
// Tried to use non-existent RPC function
const { data: clientId } = await supabase.rpc('resolve_client_id', { p_name: clientName })

// Only queried by client_uuid which was NULL for imported events
query = query.eq('client_uuid', clientId)
```

**After (fixed):**
```typescript
// Use client_aliases table (ALWAYS use this for client resolution!)
const { data: aliasData } = await supabase
  .from('client_aliases')
  .select('client_id')
  .ilike('alias', clientName)
  .single()

const clientId = aliasData?.client_id

// Query by BOTH client_id OR client_name to catch all events
if (clientId) {
  query = query.or(`client_id.eq.${clientId},client_name.eq.${clientName}`)
} else {
  query = query.eq('client_name', clientName)
}
```

## Files Changed

1. `src/app/api/segmentation-events/route.ts`
   - Removed non-existent RPC call
   - Added query to `client_aliases` table
   - Changed event query to use OR condition for `client_id` and `client_name`
   - Added deduplication for events that might match both conditions

## Database Context

- `segmentation_events` table has both `client_id` and `client_name` columns
- Events imported from Excel have `client_name` populated but `client_id = NULL`
- The `completed` column is set based on the tick box in Excel (TRUE, 'true', 1, 'Y', etc.)
- Only events with `completed = true` are displayed in the calendar

## Testing

1. Verified GHA (Gippsland Health Alliance) modal:
   - **Before:** "No Events Found" for Sep '25 - Jan '26
   - **After:** Events correctly displayed:
     - Sep '25: 4 events ✅
     - Oct '25: 7 events ✅
     - Nov '25: 4 events ✅
     - Dec '25: 2 events ✅
   - Total: 17 events matching "17 of 26 Events Completed"

2. Console logs confirmed:
   - `[useSegmentationEvents] ✅ SUCCESS! Fetched 57 events` for GHA
   - Segment change correctly detected: `Collaboration → Leverage`

## Key Learnings

**CRITICAL:** Always use the `client_aliases` table for client name resolution. This is a standard pattern in this codebase and must be followed consistently.

## Related

- `docs/guides/BUG-segment-reassessment-false-positive.md` - Related segment change detection fix
- `scripts/check-gha-events.mjs` - Debug script created during investigation
- `scripts/check-missing-aliases.mjs` - Script to find clients missing aliases
