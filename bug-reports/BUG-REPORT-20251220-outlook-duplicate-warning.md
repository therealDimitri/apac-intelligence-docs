# Bug Report: Outlook Meeting Import - Duplicate Warning Feature

**Date:** 2025-12-20
**Status:** Implemented (Bug Fixed)
**Priority:** Medium
**Category:** Feature Enhancement / UX Improvement

---

## Bug Fixes (2025-12-20)

### Fix #1: URL Encoding for Event IDs

**Issue:** Duplicate detection was not working because Outlook event IDs contain special characters (base64 encoding with `=`, `+`, `/`) that were not being properly URL encoded/decoded.

**Root Cause:** The original implementation used `encodeURIComponent()` on the entire comma-separated string, which encoded the commas. The API then couldn't properly split and match the IDs.

**Fix Applied:**

- Encode each event ID individually before joining with comma
- Decode each event ID individually on the server side
- Added debug logging to track the duplicate detection flow

**Commits:**

- `a843ecd` - Initial implementation
- `c3fe0bb` - URL encoding fix

---

### Fix #2: Supabase Query Limits

**Issue:** Preview API wasn't detecting all duplicates for large numbers of events.

**Root Cause:** Supabase `.in()` clause has limits that can fail silently with 100+ items.

**Fix Applied:**

- Chunk event IDs into batches of 50 before querying
- Add `.eq('deleted', false)` filter to only find active meetings

**Commits:**

- `8a29ed9` - fix: improve duplicate detection in Outlook preview API

---

### Fix #3: Deleted Meetings Not Re-Importable

**Issue:** Meetings that were previously imported and then deleted could not be re-imported. They showed as "NEW" in the import modal but clicking import would fail silently.

**Root Cause:**

1. Preview API correctly filtered out deleted meetings (so they appeared as "NEW")
2. Import API also filtered out deleted meetings (so it tried to INSERT)
3. INSERT failed due to unique constraint on `outlook_event_id` (deleted record still exists)
4. Error was logged but meeting wasn't imported

**Fix Applied:**

Import logic now handles three cases:

```typescript
if (existingMeeting && !existingMeeting.deleted) {
  // CASE 1: Active meeting exists → UPDATE it
} else if (existingMeeting && existingMeeting.deleted) {
  // CASE 2: Deleted meeting exists → RESTORE it (set deleted=false) and UPDATE
} else {
  // CASE 3: No meeting exists → INSERT new record
}
```

**Commits:**

- `819a35b` - fix: treat deleted meetings as non-existing in import
- `8d90f5b` - fix: restore deleted meetings instead of failing to insert

---

## Summary

Added a proactive duplicate warning system to the Outlook Import Modal that warns users **before** they import meetings that already exist in the Briefing Room. This prevents accidental duplicate imports and gives users control over how duplicates are handled.

---

## Problem Statement

### Previous Behaviour

1. User opens Outlook Import Modal
2. User selects meetings to import
3. User clicks "Import"
4. API silently skips or updates duplicates
5. User only sees "Skipped (duplicates): X" **after** import completes

### Issues

- Users had **no visibility** into which meetings already existed before importing
- No way to distinguish new meetings from duplicates in the selection list
- No control over duplicate handling behaviour (skip vs update)
- Potential for confusion when imports showed unexpected "skipped" counts

---

## Solution Implemented

### New Components & Features

#### 1. Duplicate Check API Endpoint

**File:** `src/app/api/outlook/check-duplicates/route.ts`

```
GET /api/outlook/check-duplicates?eventIds=id1,id2,id3
```

Returns which Outlook events already exist in `unified_meetings` table:

```json
{
  "duplicates": {
    "outlook-event-123": {
      "exists": true,
      "meeting_id": "OUTLOOK-abc",
      "client_name": "Epworth",
      "meeting_date": "2025-12-15",
      "imported_at": "2025-12-10T09:00:00Z",
      "status": "completed"
    }
  },
  "duplicateCount": 5,
  "newCount": 10
}
```

#### 2. Visual Duplicate Indicators

**File:** `src/components/outlook-import-modal.tsx`

- **Amber "Exists" badge** on meetings that already exist in Briefing Room
- **Amber border highlight** on duplicate meeting cards
- **Tooltip** showing import date and client name
- **Sub-text** showing "Imported as: [Client] (status)"

#### 3. Duplicate Warning Banner

When duplicates are detected, an amber warning banner appears with:

- Count of meetings that already exist
- Radio buttons to choose handling:
  - **Skip duplicates** (default) — Only import new meetings
  - **Update existing** — Refresh data from Outlook for duplicates
- Summary of selected new vs duplicate meetings

#### 4. Smart Footer

Footer now displays:

- Warning when duplicates will be skipped
- Dynamic button text: "Import X New Meetings" when skipping duplicates
- Clear summary of what will happen on import

---

## Files Modified

| File                                            | Changes                                                            |
| ----------------------------------------------- | ------------------------------------------------------------------ |
| `src/app/api/outlook/check-duplicates/route.ts` | **NEW** - API to check for existing meetings                       |
| `src/components/outlook-import-modal.tsx`       | Added duplicate detection, visual indicators, and action selection |

---

## Technical Details

### Duplicate Detection Flow

1. Modal opens → Fetch Outlook events
2. After events load → Call `/api/outlook/check-duplicates` with all event IDs
3. API queries `unified_meetings` table for matching `outlook_event_id`
4. Returns map of duplicates with metadata
5. UI renders badges, borders, and warning banner

### Database Query

```sql
SELECT id, meeting_id, outlook_event_id, client_name, meeting_date,
       meeting_time, title, created_at, status
FROM unified_meetings
WHERE outlook_event_id IN (...)
AND deleted = false
```

### State Management

New state variables added:

```typescript
const [duplicates, setDuplicates] = useState<Record<string, DuplicateInfo>>({})
const [checkingDuplicates, setCheckingDuplicates] = useState(false)
const [duplicateAction, setDuplicateAction] = useState<DuplicateAction>('skip')
const [showDuplicateWarning, setShowDuplicateWarning] = useState(false)
```

---

## User Experience

### Before (Old Flow)

```
Open Modal → Select All → Import → "Skipped 5 duplicates" 🤔
```

### After (New Flow)

```
Open Modal → See 5 with "Exists" badge → Choose "Skip duplicates" →
Import 10 New Meetings → "Imported 10, Skipped 5" ✅
```

---

## Testing Checklist

- [ ] Open Outlook Import Modal with mix of new and existing meetings
- [ ] Verify "Exists" badges appear on duplicates
- [ ] Verify amber warning banner shows correct count
- [ ] Test "Skip duplicates" option - only new meetings import
- [ ] Test "Update existing" option - duplicates are updated
- [ ] Verify footer text updates dynamically
- [ ] Verify import results show correct counts
- [ ] Test with no duplicates - no warning banner should appear
- [ ] Test with all duplicates - appropriate message shown

---

## Performance Considerations

- Duplicate check uses single batch query with `IN` clause
- Runs asynchronously after events load
- Non-blocking - users can interact while checking
- Check runs once per modal open (not on every selection change)

---

## Related Files

- `src/app/api/outlook/events/route.ts` - Fetches Outlook events
- `src/app/api/outlook/import-selected/route.ts` - Handles the actual import
- `src/app/api/outlook/skipped/route.ts` - User skip list management
- `docs/database-schema.md` - Schema reference for `unified_meetings`

---

## Future Enhancements

1. **Auto-deselect duplicates** - Option to automatically deselect duplicates when warning appears
2. **Show differences** - Display what changed between Outlook and existing meeting
3. **Merge option** - Combine data from both sources
4. **Batch update confirmation** - Separate confirmation dialog for updates

---

## Rollback Instructions

If issues arise, revert these files:

1. `src/components/outlook-import-modal.tsx` - Restore from git
2. Delete `src/app/api/outlook/check-duplicates/route.ts`

The system will fall back to the previous silent duplicate handling.
