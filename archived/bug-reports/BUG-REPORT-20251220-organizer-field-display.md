# Bug Report: Imported Meetings - Wrong Organizer Displayed

**Date:** 2025-12-20
**Status:** Fixed
**Priority:** Medium
**Category:** Data Mapping Bug

---

## Summary

Imported Outlook meetings were displaying the user who synced them as the organiser instead of the actual meeting organiser from Outlook.

---

## Problem

### Observed Behaviour

All imported meetings showed the CSE who performed the import as the organiser:

```
Meeting: "APAC Weekly Sync"
Organiser: Jimmy Leimonitis  ← User who imported
```

### Expected Behaviour

Meetings should display the actual organiser from Outlook:

```
Meeting: "APAC Weekly Sync"
Organiser: Sarah Chen  ← Actual meeting organiser
```

---

## Root Cause

Three issues were identified in `src/hooks/useMeetings.ts`:

1. **Interface Missing Field**: The `UnifiedMeetingRow` interface did not include the `organizer` field
2. **Query Missing Field**: The Supabase select query did not fetch the `organizer` column
3. **Wrong Field Mapped**: Line 348 mapped `organizer: meeting.cse_name` instead of using the actual organizer

The database was correctly storing the organiser from Outlook, but the frontend was not fetching or using it.

---

## Fix Applied

**File:** `src/hooks/useMeetings.ts`

### 1. Added organizer to interface

```diff
interface UnifiedMeetingRow {
  // ... other fields
  cse_name?: string | null // User who synced/created the meeting
+ organizer?: string | null // Actual meeting organizer from Outlook
  // ...
}
```

### 2. Added organizer to Supabase select query

```diff
.select(`
  meeting_id,
  id,
  title,
  // ... other fields
  cse_name,
+ organizer,
  status,
  // ...
`)
```

### 3. Fixed field mapping

```diff
- organizer: meeting.cse_name || null,
+ organizer: meeting.organizer || null,
```

---

## Commits

- `17e29de` - fix: display actual meeting organizer instead of CSE name
- `bc4af75` - feat: add Organiser field to meeting detail panel

---

## Additional Fix: Organiser Field in UI

The meeting detail panel was not displaying the Organiser field at all. Added a dedicated "Organiser" row to the Overview tab in `src/components/MeetingDetailTabs.tsx` between Department and Attendees.

---

## Testing

- [x] Imported meetings display actual Outlook organiser
- [x] Meetings organised by others show correct organiser name
- [x] Meetings organised by importing user still show correctly
- [x] CSE name field still available for tracking who synced the meeting
- [x] Organiser field visible in meeting detail panel Overview tab
- [x] No TypeScript errors
- [x] Build succeeds

---

## Notes

- The `cse_name` field represents the user who synced/created the meeting in the system
- The `organizer` field represents the actual meeting organiser from Outlook
- Both fields are now correctly available and used for their intended purposes
