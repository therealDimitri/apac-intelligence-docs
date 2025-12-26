# Bug Report: Notes Filter Not Showing Results

**Date**: 2025-12-19
**Status**: RESOLVED
**Severity**: Medium
**Component**: Client Profile - Activity Timeline Filter

---

## Issue Summary

The "Notes" filter in the client profile action bar showed a count of 1 note, but clicking the filter displayed no results. The meeting with the note was not visible when filtering by notes.

## Symptoms

- Action bar showed "Notes 1" indicating 1 note exists
- Clicking "Notes" filter showed empty timeline
- The note was visible when "All Activity" or "Meetings" filter was selected

## Root Causes

### Issue 1: Filter Logic Mismatch

**ClientActionBar.tsx (counting):**

```typescript
// Counts meetings that have a notes field with content
const clientNotes = clientMeetings.filter(
  meeting => meeting.notes && meeting.notes.trim().length > 0
)
```

**CenterColumn.tsx (filtering - BEFORE):**

```typescript
// Looked for items with type === 'note' which don't exist
const typeMap: { [key: string]: string } = {
  actions: 'action',
  meetings: 'meeting',
  notes: 'note', // <-- No timeline items have type 'note'!
}
return timeline.filter(item => item.type === targetType)
```

### Issue 2: Whitespace-Only Notes Not Handled

**useMeetings.ts (BEFORE):**

```typescript
// Whitespace-only strings are truthy, so " " would be used instead of actual content
notes: meeting.transcript || meeting.meeting_notes || null,
```

If `transcript` contained only whitespace, it would be used and fail the trim check.

## Solutions

### Fix 1: CenterColumn.tsx Filter Logic

```typescript
// Special handling for 'notes' filter - show meetings that have notes
if (activeFilter === 'notes') {
  return timeline.filter(item => {
    if (item.type === 'meeting' && item.data) {
      const meeting = item.data as Meeting
      return meeting.notes && meeting.notes.trim().length > 0
    }
    return false
  })
}
```

### Fix 2: useMeetings.ts Notes Assignment

```typescript
// Check for actual content (not just whitespace) before using a value
notes: (meeting.transcript?.trim() ? meeting.transcript : null) ||
       (meeting.meeting_notes?.trim() ? meeting.meeting_notes : null),
```

## Files Modified

1. `src/app/(dashboard)/clients/[clientId]/components/v2/CenterColumn.tsx`
2. `src/hooks/useMeetings.ts`

## Impact

- Notes filter now correctly shows meetings that have notes attached
- Filter count matches the displayed results
- Whitespace-only notes are properly handled
- Users can find meetings with notes by clicking the Notes filter

## Verification

After fix:

- "Notes 1" count in action bar
- Clicking "Notes" filter shows the 1 meeting that has notes attached
- The meeting displays with its notes content visible

---

## Lessons Learned

1. **Filter logic must match count logic** - Both should use the same criteria
2. **Notes are meeting metadata, not separate entities** - The data model has notes as a field on meetings, not as standalone items
3. **Handle whitespace strings** - Always trim and check for actual content
4. **Test filters with actual data** - Verify that clicking filters shows expected results
