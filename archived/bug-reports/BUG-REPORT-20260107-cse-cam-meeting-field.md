# Bug Report: Add CSE/CAM Owner Field to Meeting Forms

**Date**: 7 January 2026
**Status**: Fixed
**Severity**: Enhancement
**Component**: Meeting Scheduling - UniversalMeetingModal

## Issue

When creating or importing meetings, there was no field to specify the CSE/CAM owner responsible for the meeting. The system defaulted to using the logged-in user's name, which wasn't always the correct CSE/CAM assignment.

## Solution

Added a CSE/CAM Owner field to the UniversalMeetingModal using the existing `PeopleSearchInput` component (Microsoft Graph API-powered organisation search).

### Changes Made

**1. `src/components/UniversalMeetingModal.tsx`**
- Added `UserCircle` icon import
- Added `PeopleSearchInput` component import
- Added `cseName: string[]` to form state
- Added CSE/CAM Owner field UI after Client Name field
- Included `cse_name` in meeting data sent to API
- Added `cseName: []` to form reset

**2. `src/app/api/meetings/schedule/route.ts`**
- Added `cse_name` to `ScheduleMeetingRequest` interface
- Updated meeting creation logic to use passed `cse_name` if provided
- Falls back to logged-in user's name if not specified

## UI Design

The CSE/CAM field appears after the Client Name field:

```
Client Name *
[Select a client...     ▼]

CSE/CAM Owner
[Search for CSE or CAM...   ]
Assign the CSE or CAM responsible for this meeting
```

## Features

1. **Organisation Search**: Uses Microsoft Graph API to search for people in the organisation
2. **Multiple Selection**: Supports selecting multiple CSE/CAMs if needed
3. **Fallback**: If no CSE/CAM is specified, defaults to the logged-in user
4. **Manual Entry**: Users can type a name and press Enter if person not in search results

## Testing

1. Open Briefing Room and click "Schedule Meeting"
2. Fill in meeting subject and client
3. In the CSE/CAM Owner field, search for a person
4. Select the CSE/CAM from the dropdown
5. Complete and submit the meeting
6. Verify the meeting is saved with the selected CSE/CAM name

## Future Enhancements

1. **Auto-populate from Client**: When selecting a client, auto-fill CSE/CAM from the client's assigned CSE
2. **Add to EditMeetingModal**: Similar field should be added to the edit modal
3. **Add to Outlook Import**: Auto-suggest CSE based on matched client
