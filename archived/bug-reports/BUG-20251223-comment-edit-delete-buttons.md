# Bug Report: Comment Edit/Delete Buttons Not Working in Client Profile Timeline

**Date:** 23 December 2025
**Status:** Fixed
**Severity:** Medium
**Component:** Client Profile > Timeline

---

## Problem Description

Edit and Delete icon buttons on comment cards in the Client Profile timeline did not work. Clicking them had no effect - the UI provided no feedback and no action was taken.

### Screenshot Reference

The issue affected comment cards displayed in the timeline (green chat bubble icon, title starting with "Comment on...").

---

## Root Cause Analysis

The `handleEdit` and `handleDelete` functions in `CenterColumn.tsx` only handled `action` and `meeting` item types. The `comment` type was silently ignored.

### Affected Code (Before Fix)

**handleEdit (lines 404-410):**

```tsx
const handleEdit = (item: TimelineItem) => {
  if (item.type === 'action' && item.data) {
    setEditingAction(item.data as Action)
  } else if (item.type === 'meeting' && item.data) {
    setEditingMeeting(item.data as Meeting)
  }
  // No handling for 'comment' type!
}
```

**handleDelete (lines 379-401):**

```tsx
if (itemType === 'action') {
  await updateAction(itemId, { status: 'cancelled' })
} else if (itemType === 'meeting') {
  await updateMeeting(itemId, { status: 'cancelled' })
}
// No handling for 'comment' type!
```

---

## Solution Implemented

### 1. Added `handleDeleteComment` function

- Calls `DELETE /api/comments/{id}` endpoint
- Uses existing soft-delete mechanism (sets `is_deleted: true`)
- Refreshes comment list after deletion
- Shows success/error toast notifications

### 2. Updated `handleDelete` to route comments

- Added check for `comment` type at the start
- Routes to `handleDeleteComment` function

### 3. Hidden edit button for comments

- Comments use inline rich text editing via `CommentItem.tsx`
- Edit button hidden in both Quick Actions bar and dropdown menu
- Users can edit comments from the entity view (action/meeting) where comment was made

---

## Files Changed

| File                                                                    | Changes                                                                                                  |
| ----------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `src/app/(dashboard)/clients/[clientId]/components/v2/CenterColumn.tsx` | Added `handleDeleteComment`, updated `handleDelete` routing, conditionally hid edit buttons for comments |

---

## Behaviour Summary

| Item Type | Edit                        | Delete                     |
| --------- | --------------------------- | -------------------------- |
| Action    | Opens EditActionModal       | Sets status to 'cancelled' |
| Meeting   | Opens EditMeetingModal      | Sets status to 'cancelled' |
| Comment   | **Hidden** (edit at source) | **Calls DELETE API**       |

---

## Testing Steps

1. Navigate to Client Profile
2. View timeline with comments (filter by "Comments" or "All")
3. Verify delete button works on comment cards
4. Verify edit button is not shown for comment cards
5. Verify edit/delete still works for actions and meetings

---

## Related Systems

- Comments API: `DELETE /api/comments/{id}` - soft delete endpoint
- `useComments` hook: `deleteComment` function
- `CommentItem.tsx`: Inline edit/delete for comments within UnifiedComments component
