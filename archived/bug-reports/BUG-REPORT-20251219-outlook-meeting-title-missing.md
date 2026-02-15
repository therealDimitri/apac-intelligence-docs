# Bug Report: Outlook Meeting Titles Not Displayed

## Date

19 December 2025

## Issue Summary

Meetings imported from Outlook were displaying generic titles like "General" or "Client Meeting" instead of their actual Outlook subject line.

## Symptoms

- Meetings in the Briefing Room list showed generic titles
- Meeting detail panel showed incorrect titles
- Only meetings imported via Outlook sync were affected
- Manually created meetings displayed correctly

## Root Cause

The `unified_meetings` table has two relevant columns:

1. `title` - The dedicated title/subject column
2. `meeting_notes` - For meeting notes/transcript content

The UI display logic in `useMeetings.ts` (line 341) uses:

```typescript
title: meeting.title || meeting.meeting_type || 'Client Meeting'
```

However, the Outlook import route (`/api/outlook/import-selected`) was only setting `meeting_notes` with the subject as a fallback - it never populated the `title` column:

```typescript
// BEFORE (bug)
const meetingData = {
  meeting_id: `OUTLOOK-${event.id}`,
  // title: NOT SET - this was the bug!
  meeting_notes: parsedEvent.meeting_notes || parsedEvent.subject,
  // ...
}
```

## Solution

Added the `title` field to both new meeting creation and existing meeting updates:

```typescript
// AFTER (fixed)
const meetingData = {
  meeting_id: `OUTLOOK-${event.id}`,
  title: parsedEvent.subject || event.subject || 'Untitled Meeting',
  meeting_notes: parsedEvent.meeting_notes || parsedEvent.subject,
  // ...
}
```

Also created a backfill script (`scripts/backfill-meeting-titles.mjs`) to fix existing meetings that were imported before the fix.

## Files Modified

1. `src/app/api/outlook/import-selected/route.ts` - Added `title` field to insert and update

## Data Migration

Ran `scripts/backfill-meeting-titles.mjs` which:

- Found 76 Outlook-synced meetings
- Updated 49 meetings with proper titles
- Skipped 27 meetings that already had titles
- Zero errors

## Prevention

The `title` column should always be populated when creating meetings from any source. Future code reviews should verify that all required display fields are being set during data import/creation.

## Testing

- Build passes with no TypeScript errors
- Code committed and pushed to main branch
- Backfill script executed successfully
- Refreshing the Briefing Room now shows correct meeting titles

## Commits

- `3ce0a40` - fix(outlook): populate title field from Outlook event subject
- `213e130` - chore: add meeting title backfill script
