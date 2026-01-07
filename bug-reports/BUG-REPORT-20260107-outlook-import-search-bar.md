# Feature: Search Bar in Outlook Import Modal

**Date**: 7 January 2026
**Status**: Implemented
**Severity**: Enhancement
**Component**: Outlook Import Modal

## Feature Request

Add a search bar to the Outlook import modal to help users quickly find specific meetings in their calendar events.

## Implementation

Added a search input field at the top of the meetings list that filters by:
- Meeting subject
- Client name
- Location
- Attendees (email addresses/names)

### Features

1. **Real-time filtering**: Results update as user types
2. **Clear button**: X button appears when search has text
3. **Result count**: Shows "X of Y meetings" when filtered
4. **Case-insensitive**: Search is case-insensitive
5. **State reset**: Search clears when modal closes

## Code Changes

**File Modified**: `src/components/outlook-import-modal.tsx`

1. Added `Search` icon import from lucide-react
2. Added `searchQuery` state variable
3. Updated `displayedMeetings` filter to include search logic:
```typescript
// Search filter
if (searchQuery.trim()) {
  const query = searchQuery.toLowerCase()
  const matchesSubject = m.subject?.toLowerCase().includes(query)
  const matchesClient = m.client_name?.toLowerCase().includes(query)
  const matchesLocation = m.location?.toLowerCase().includes(query)
  const matchesAttendees = m.attendees?.some(a => a.toLowerCase().includes(query))
  return matchesSubject || matchesClient || matchesLocation || matchesAttendees
}
```

4. Added search input UI with clear button
5. Updated `handleClose` to reset search state

## UI Design

```
┌─────────────────────────────────────────────┐
│ 🔍 Search by subject, client, location...  │
├─────────────────────────────────────────────┤
│ Showing 5 of 20 meetings                    │
├─────────────────────────────────────────────┤
│ ☐ Select All                 5 of 5 selected│
├─────────────────────────────────────────────┤
│ Meeting 1...                                 │
│ Meeting 2...                                 │
└─────────────────────────────────────────────┘
```

## Testing

1. Open the Outlook import modal from Briefing Room
2. Wait for calendar events to load
3. Type in the search box
4. Verify meetings are filtered correctly
5. Click X to clear search
6. Close and reopen modal - search should be cleared
