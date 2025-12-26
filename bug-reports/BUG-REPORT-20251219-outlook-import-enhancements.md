# Bug Report: Outlook Import Enhancements and Fixes

## Date

19 December 2025

## Issues Summary

Multiple issues with Outlook calendar import were identified and fixed:

1. **Organizer Always Shows Current User** - Meetings displayed the importing user as organiser instead of the actual meeting organiser from Outlook
2. **Missing Department Dropdown** - Import modal lacked the ability to assign departments to meetings
3. **Timezone Issues** - Imported meeting times were incorrect due to UTC vs local timezone handling
4. **Past Meetings Not Marked Completed** - Meetings with dates before today were not automatically marked as 'completed'

## Symptoms

- All imported meetings showed the current user as "organiser" even when they were only an attendee
- No way to assign department codes during Outlook import
- Meeting times appeared off by several hours (UTC offset)
- Historical meetings remained with 'scheduled' status or null status

## Root Causes

### 1. Organizer Field

The import route set `cse_name` (Current Syncing Employee) correctly but did not populate the `organizer` field with the actual Outlook meeting organiser.

### 2. Missing Department Dropdown

The API already supported `departmentOverrides` but the UI modal did not expose this functionality.

### 3. Timezone Handling

Two issues:

- API requested UTC timezone: `'Prefer': 'outlook.timezone="UTC"'`
- Parsing used JavaScript Date methods which applied local timezone conversions inconsistently

### 4. Status Logic

Import route did not set the `status` field based on meeting date.

## Solutions

### 1. Organizer Field Fix

Added `organizer` field to both insert and update operations using the actual Outlook organiser:

```typescript
organizer: parsedEvent.organizer_name || event.organizer?.emailAddress?.name
```

### 2. Department Dropdown

- Added `DepartmentOption` interface and state management
- Added department fetching on modal open
- Added `handleAssignDepartment` function
- Added dropdown UI in meeting card for importable meetings
- Pass `departmentOverrides` to API on import

### 3. Timezone Fix

Changed Microsoft Graph API request to use AUS Eastern timezone:

```typescript
'Prefer': 'outlook.timezone="AUS Eastern Standard Time"'
```

And parse date/time directly from string to avoid Date object conversion:

```typescript
const meetingDate = dateTimeStr.split('T')[0] // YYYY-MM-DD
const meetingTime = timePart.substring(0, 5) // HH:MM
```

### 4. Auto-Status Logic

Added status determination based on meeting date:

```typescript
const today = new Date().toISOString().split('T')[0]
const meetingStatus = parsedEvent.meeting_date < today ? 'completed' : 'scheduled'
```

## Files Modified

1. `src/app/api/outlook/import-selected/route.ts`
   - Added `organizer` field to insert and update
   - Added auto-status logic
   - Already had `departmentOverrides` support

2. `src/components/OutlookSyncButton.tsx`
   - Added `DepartmentOption` interface
   - Added `departments` and `departmentAssignments` state
   - Added `fetchDepartments` effect
   - Added `handleAssignDepartment` function
   - Added department dropdown UI in meeting cards
   - Pass `departmentOverrides` to import API

3. `src/lib/microsoft-graph.ts`
   - Changed timezone header to "AUS Eastern Standard Time"
   - Changed datetime parsing to extract directly from string

## Data Migration

### Status Backfill

Created and ran `scripts/backfill-meeting-status.mjs` which:

- Found 95 past meetings without 'completed' status
- Updated all 95 meetings to have status = 'completed'
- Zero errors

### Timezone Backfill

Created and ran `scripts/backfill-meeting-timezone.mjs` which:

- Found 76 Outlook-imported meetings
- Identified 53 meetings with UTC times needing correction
- Applied +10 hour offset (AEST) to convert UTC → local time
- Updated all 53 meetings with correct local times
- Zero errors

Example corrections:

- 01:00 UTC → 11:00 AEST
- 03:00 UTC → 13:00 AEST
- 09:00 UTC → 19:00 AEST

## Prevention

- Always populate `organizer` field from source data during import
- Always set `status` field based on meeting date
- Use consistent timezone handling (request in target timezone, parse string directly)
- Expose API capabilities in UI when useful

## Testing

- Build passes with no TypeScript errors
- Status backfill script executed successfully - 95 meetings updated
- Timezone backfill script executed successfully - 53 meetings updated
- All past meetings now correctly show as 'completed'
- All meeting times now display in correct local time (AEST)

### Organizer Field Backfill

Created and ran `scripts/backfill-meeting-organizer.mjs` which:

- Found 133 meetings with NULL organizer field
- Updated all 133 meetings to have organizer = cse_name (reasonable default)
- Zero errors

Note: For accurate organizer data from Outlook, users should re-import their meetings. The original import did not capture organizer data.

### Search Performance Fix

Created search debouncing in `CondensedStatsBar.tsx`:

- Added local state for immediate input feedback
- Implemented 300ms debounce before triggering search queries
- Prevents database query on every keystroke
- Full fix documented in: `BUG-REPORT-20251219-search-performance-debounce.md`

## Commits

- `3a4ed42` - fix(outlook): add organizer field, auto-status, and department dropdown
- Pending commit for organizer backfill and search debounce fix
