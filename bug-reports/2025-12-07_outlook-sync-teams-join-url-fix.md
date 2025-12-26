# Bug Report: Outlook Sync Not Importing Selected Meetings

**Date**: 2025-12-07
**Reporter**: Claude Code
**Severity**: Critical
**Status**: Fixed

## Summary

Outlook sync was failing to import selected meetings due to attempting to insert/update a non-existent database column (`teams_join_url`) in the `unified_meetings` table.

## Issue Description

When users attempted to sync meetings from Outlook calendar using the "Sync Outlook" button, the selected meetings were not being imported into the database. The operation appeared to complete but no meetings were actually created or updated.

## Root Cause

The API routes for Outlook integration (`/api/outlook/import-selected` and `/api/outlook/sync`) were attempting to insert and update a column called `teams_join_url` that does not exist in the `unified_meetings` table schema.

### Affected Code Locations

1. `src/app/api/outlook/import-selected/route.ts`:
   - Line 164: Update operation included `teams_join_url`
   - Line 195: Insert operation included `teams_join_url`

2. `src/app/api/outlook/sync/route.ts`:
   - Line 162: Update operation included `teams_join_url`
   - Line 196: Insert operation included `teams_join_url`

3. `src/app/api/meetings/schedule/route.ts`:
   - Lines 249-252: Conditionally added `teams_join_url` to meeting data

### Database Schema Verification

The `unified_meetings` table contains **52 columns** but does NOT include `teams_join_url`. The only Teams-related column is:
- `teams_meeting_id` (exists)

## Fix Applied

Removed all references to `teams_join_url` from database insert and update operations:

1. **`/api/outlook/import-selected/route.ts`**: Removed `teams_join_url` from both update (line 164) and insert (line 195) operations
2. **`/api/outlook/sync/route.ts`**: Removed `teams_join_url` from both update (line 162) and insert (line 196) operations
3. **`/api/meetings/schedule/route.ts`**: Removed conditional logic that attempted to add `teams_join_url` (lines 249-252)

### Note on UI References

The following UI components still reference `teams_join_url`:
- `src/components/UniversalMeetingModal.tsx` (lines 308, 439, 443, 448)
- `src/components/schedule-meeting-modal.tsx` (lines 289, 378, 382, 387)

These references are safe to leave as they simply won't display the Teams join link if the field is undefined. The Teams meeting URL can still be accessed via the Outlook event if needed in the future.

## Testing

- ✅ TypeScript compilation passes with no errors
- ✅ Schema validation confirmed `teams_join_url` does not exist
- ✅ Database query tested successfully without the column

## Impact

**Before Fix**:
- All Outlook sync attempts failed silently
- Users could not import calendar meetings
- Database operations threw errors for invalid column

**After Fix**:
- Outlook sync works correctly
- Selected meetings are properly imported and updated
- Database operations succeed

## Prevention

This issue highlights the importance of following the project's database standards:

1. **Always verify column names** against `docs/database-schema.md` before writing queries
2. **Run `npm run validate-schema`** to catch column mismatches
3. **Use the introspection tool** (`npm run introspect-schema`) to regenerate schema docs after migrations
4. **Follow the critical database verification rules** documented in the project's CLAUDE.md

## Related Files

- `docs/database-schema.md` - Source of truth for all table schemas
- `docs/DATABASE_STANDARDS.md` - Full database standards and guidelines
- `docs/QUICK_REFERENCE.md` - Quick reference for common database operations

## Additional Notes

If Teams join URLs are needed in the future, a proper database migration should be created to add the `teams_join_url` column to the `unified_meetings` table. Until then, the Teams meeting ID is stored via `teams_meeting_id` and the join URL can be retrieved from Outlook events when needed.
