# Bug Report: Meeting Import Duplicate Detection Enhancement

**Date:** 2026-01-09
**Type:** Feature Enhancement
**Status:** Resolved
**Priority:** Medium

## Problem Description

When users sync meetings from Outlook, they had no visibility into whether meetings had been imported by other team members. This could lead to:
- Confusion about why certain meetings appeared as "already imported"
- No ability to see WHO imported a meeting
- Lack of transparency in collaborative meeting management

## Root Cause

The meeting preview API was not returning the `cse_name` (importer) field for existing meetings, and the UI had no dedicated tab to show meetings imported by other users.

## Solution Implemented

### 1. API Changes

**File:** `src/app/api/outlook/check-duplicates/route.ts`
- Added `imported_by` field to `DuplicateInfo` interface
- Updated database query to select `cse_name` column
- Return importer information in duplicate check response

**File:** `src/app/api/outlook/preview/route.ts`
- Added `importedBy` and `importedAt` fields to `PreviewMeeting` interface
- Added new action type: `'imported_by_others'`
- Updated database query to select `cse_name` and `created_at` for existing meetings
- Added logic to determine if meeting was imported by current user or another user
- Meetings imported by current user show as "Up to Date"
- Meetings imported by others show as "Already Imported"

### 2. UI Changes

**File:** `src/components/OutlookSyncButton.tsx`
- Added new "Already Imported" tab between "Up to Date" and "Skipped"
- Added amber-coloured styling for meetings imported by others
- Displays "Already imported by [Name] on [Date]" with clear visual indicator
- Shows "View Only" badge instead of Skip button for these meetings
- Meetings imported by others cannot be selected (disabled checkbox shows Users icon)
- Updated modal header to show count of meetings imported by others

## Files Modified

1. `src/app/api/outlook/check-duplicates/route.ts` - Added importer info to duplicate response
2. `src/app/api/outlook/preview/route.ts` - Added importer tracking and new action type
3. `src/components/OutlookSyncButton.tsx` - Added "Already Imported" tab with full UI support

## Testing Recommendations

1. **Same User Import:** Import a meeting, then preview again - should appear in "Up to Date" tab
2. **Different User Import:** Have another user import a meeting, then preview - should appear in "Already Imported" tab with their name
3. **Visual Verification:** Confirm amber styling and "View Only" badge appear correctly
4. **Action Prevention:** Verify meetings in "Already Imported" tab cannot be selected or skipped

## Technical Notes

- User matching is case-insensitive and checks both full name and first name
- The `cse_name` field in `unified_meetings` table stores the importer's name
- No database schema changes were required - existing columns were used

## Related Components

- `/api/outlook/events` - Fetches Outlook calendar events
- `/api/outlook/import-selected` - Handles actual meeting import
- `OutlookImportModal` - Alternative import modal (uses different duplicate check)
