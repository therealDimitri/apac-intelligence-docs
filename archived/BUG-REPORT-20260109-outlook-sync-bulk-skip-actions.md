# Bug Report: Outlook Sync Modal Missing Bulk Skip Actions

**Date:** 9 January 2026
**Severity:** Low (Enhancement)
**Status:** Fixed
**Component:** Outlook Sync Modal (Meeting Import)

## Issue Summary

The Outlook Sync modal's meeting import interface only had individual "Skip" buttons per meeting. Users with many meetings (e.g., 190+ skipped meetings) had no way to efficiently skip or restore multiple meetings at once, leading to tedious repetitive clicking.

## Root Cause

The original implementation only supported single-meeting skip operations via the `handleSkipMeeting()` function. While the API (`/api/outlook/skipped`) already supported bulk operations with arrays of event IDs, the UI didn't expose this capability.

## Solution

Added bulk action buttons to the meeting import modal:

1. **Skip Selected** button - Appears when meetings are selected on actionable tabs (New, Updates, No Client)
2. **Restore All** button - Appears on the Skipped tab to restore all permanently skipped meetings

### Implementation Details

#### New State
```tsx
const [bulkSkipping, setBulkSkipping] = useState(false)
```

#### New Functions
```tsx
// Bulk skip all selected meetings
const handleBulkSkip = async () => {
  const eventIds = Array.from(selectedMeetings)
  await fetch('/api/outlook/skipped', {
    method: 'POST',
    body: JSON.stringify({ eventIds, reason: 'Bulk skipped by user' }),
  })
  // Update local state and clear selection
}

// Bulk restore all skipped meetings in current view
const handleBulkRestore = async () => {
  const eventIds = filteredMeetings.map(m => m.outlookEventId)
  await fetch('/api/outlook/skipped', {
    method: 'DELETE',
    body: JSON.stringify({ eventIds }),
  })
  // Update local state
}
```

#### UI Updates
- Added "Skip Selected (N)" button with orange styling - shows count of selected meetings
- Added "Restore All (N)" button with green styling - shows count of skipped meetings
- Both buttons show loading spinner during operation
- Buttons are conditionally rendered based on active tab and selection state

## Files Modified

| File | Changes |
|------|---------|
| `src/components/OutlookSyncButton.tsx` | Added `bulkSkipping` state, `handleBulkSkip()` and `handleBulkRestore()` functions, updated bulk actions bar UI |

## Button Visibility Logic

| Tab | Skip Selected | Restore All |
|-----|--------------|-------------|
| New | ✅ (when selected) | ❌ |
| Updates | ✅ (when selected) | ❌ |
| No Client | ✅ (when selected) | ❌ |
| Up to Date | ❌ | ❌ |
| Already Imported | ❌ | ❌ |
| Skipped | ❌ | ✅ |

## Testing

1. Navigate to Briefing Room > Click "Sync Outlook"
2. **Test Skip Selected:**
   - Go to "New" or "No Client" tab
   - Select multiple meetings using checkboxes
   - Verify "Skip Selected (N)" button appears
   - Click button and verify all selected meetings move to "Skipped" tab
3. **Test Restore All:**
   - Go to "Skipped" tab
   - Verify "Restore All (N)" button appears
   - Click button and verify all meetings are restored to "New" tab
4. Verify buttons show loading state during operation
5. Verify error handling displays appropriate messages on failure

## User Experience Improvements

- Users can now skip 50+ unwanted meetings in a single click instead of 50+ individual clicks
- Restore All provides a quick way to undo bulk skips if done by mistake
- Visual feedback with counts helps users understand the scope of bulk operations
- Loading states prevent double-clicks and indicate operation progress
