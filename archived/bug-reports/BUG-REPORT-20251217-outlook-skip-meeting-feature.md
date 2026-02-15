# Feature Report: Skip Meeting in Outlook Sync

**Date:** 17 December 2025
**Severity:** Enhancement
**Status:** RESOLVED

## Problem Summary

When syncing meetings from Outlook, users had no way to permanently skip meetings they didn't want to import. These unwanted meetings would appear on every sync, cluttering the preview list and requiring users to repeatedly deselect them.

## User Request

Add the ability to:

1. Permanently skip meeting import so it doesn't appear as "new" on future syncs
2. View all skipped meetings in a dedicated tab
3. Restore skipped meetings if needed later

## Solution

### Pre-existing Infrastructure (Already Built)

The foundation for this feature was already in place:

1. **Database Table:** `skipped_outlook_events`
   - `outlook_event_id` (TEXT)
   - `user_email` (TEXT)
   - `skipped_at` (TIMESTAMP)
   - `reason` (TEXT)
   - Unique constraint on (outlook_event_id, user_email)
   - Row Level Security (RLS) policies for user isolation

2. **API Endpoints:** `/api/outlook/skipped`
   - GET: List user's skipped events
   - POST: Add events to skip list
   - DELETE: Remove events from skip list

3. **Test Coverage:** `tests/unit/api/outlook/skipped.test.ts`

### New Implementation

#### 1. Updated `/api/outlook/preview` Route

**File:** `src/app/api/outlook/preview/route.ts`

Changes:

- Added query to fetch user's skipped events from `skipped_outlook_events` table
- Added new action type: `'permanently_skipped'`
- For each meeting, checks if `outlook_event_id` exists in skip list
- If skipped, sets `action = 'permanently_skipped'` with reason and timestamp
- Returns skipped meetings in response (not filtered out)

```typescript
interface PreviewMeeting {
  // ... existing fields
  action: 'new' | 'update' | 'skip' | 'permanently_skipped'
  skippedReason?: string
  skippedAt?: string
}
```

#### 2. Updated OutlookSyncButton Component

**File:** `src/components/OutlookSyncButton.tsx`

Changes:

**State Management:**

- Added `skipping` state to track in-progress skip operations
- Updated `activeTab` type to include `'permanently_skipped'`

**New Functions:**

- `handleSkipMeeting(eventId, reason)`: Skip a meeting permanently
- `handleUnskipMeeting(eventId)`: Restore a skipped meeting

**UI Updates:**

- Added fourth "Skipped" tab with orange badge showing count
- Skip button on new/update meeting cards
- Restore button on skipped meeting cards
- Visual indicators (orange styling, Ban icon) for skipped meetings
- Displays skip reason and date for skipped meetings

## UI Design

### Tab Bar (4 tabs)

```
[New (33)] [Updates (5)] [Up to Date (24)] [Skipped (12)]
```

### Meeting Card for New/Update:

```
[✓] Meeting Title          [NEW]    [Skip →]
    Client Name
    Date • Time (duration)
```

### Meeting Card for Skipped:

```
[⊘] Meeting Title          [SKIPPED]    [↩ Restore]
    Client Name
    Reason: User skipped • 17/12/2025
```

## Files Modified

| File                                   | Change                                                 |
| -------------------------------------- | ------------------------------------------------------ |
| `src/app/api/outlook/preview/route.ts` | Query skip list, add `permanently_skipped` action type |
| `src/components/OutlookSyncButton.tsx` | Add skip/unskip functions, Skipped tab, UI controls    |

## Testing Verification

1. ✅ Build completed successfully with no TypeScript errors
2. ✅ Skipped meetings categorised as `permanently_skipped` in preview
3. ✅ Skipped meetings appear in dedicated "Skipped" tab
4. ✅ Skip action moves meeting to Skipped tab immediately
5. ✅ Restore action moves meeting back to "New" tab
6. ✅ Different users have separate skip lists (RLS enforced)

## User Flow

1. User clicks "Sync Outlook" button
2. Preview modal shows meetings in tabs: New, Updates, Up to Date, Skipped
3. For any meeting in New/Updates tab, user can click "Skip" to permanently skip it
4. Skipped meetings move to "Skipped" tab with orange styling
5. On next sync, previously skipped meetings appear directly in "Skipped" tab
6. User can click "Restore" on any skipped meeting to bring it back to "New"

## Skip Reasons

Default reason is "User skipped". Future enhancement could add dropdown with common reasons:

- Not a client meeting
- Internal meeting
- Personal event
- Duplicate entry
- Other

## Related Documentation

- `docs/BUG-REPORT-20251217-modal-ics-popup-alignment.md` - Modal z-index fixes (same session)
- `docs/DATABASE_STANDARDS.md` - Database guidelines
