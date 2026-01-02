# Bug Report: Timeline Quick Action Buttons Click Propagation

**Date:** 2026-01-02
**Severity:** Medium
**Status:** Fixed

## Summary

Clicking the Edit or Delete quick action buttons on timeline cards in the client profile page caused both the slideover panel AND the edit modal to open simultaneously. The edit modal would be hidden behind the slideover, requiring users to click Edit again from the slideover to dismiss it and reveal the edit modal.

## Symptoms

- Clicking Edit button on a timeline card opened the ActivityDetailSlideOver panel
- The EditActionModal or EditMeetingModal opened in the background (hidden behind the slideover)
- Users had to close the slideover manually to access the edit modal
- Same issue affected the Delete button, though less visible since delete is a quick operation

## Root Cause

The quick action buttons in the timeline card's action bar did not stop event propagation. When clicked:

1. The button's `onClick` handler was triggered (opening the edit modal)
2. The click event bubbled up to the parent card's `onClick` handler (opening the slideover)

Both modals opened, but the slideover was rendered on top of the edit modal due to z-index layering.

```typescript
// Before - no stopPropagation
<button onClick={() => handleEdit(item)} ...>
  <Edit3 />
</button>
```

## Fix Applied

Added `e.stopPropagation()` to both the Edit and Delete button click handlers to prevent the event from bubbling up to the parent card:

```typescript
// After - with stopPropagation
<button
  onClick={e => {
    e.stopPropagation()
    handleEdit(item)
  }}
  ...
>
  <Edit3 />
</button>

<button
  onClick={e => {
    e.stopPropagation()
    handleDelete(item.id, item.type)
  }}
  ...
>
  <Trash2 />
</button>
```

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/clients/[clientId]/components/v2/CenterColumn.tsx` | Added `e.stopPropagation()` to Edit and Delete quick action buttons |

## UX Improvement

Before:
1. User clicks Edit on card
2. Slideover opens (covering screen)
3. Edit modal opens behind slideover (invisible)
4. User must close slideover
5. Edit modal finally visible

After:
1. User clicks Edit on card
2. Edit modal opens directly
3. User can immediately edit the action/meeting

## Prevention

- All action buttons nested within clickable parent elements should include `e.stopPropagation()` to prevent unintended event bubbling
- Consider using a utility function for buttons that need to stop propagation:
  ```typescript
  const withStopPropagation = (handler: () => void) => (e: React.MouseEvent) => {
    e.stopPropagation()
    handler()
  }
  ```
- Review other clickable card components for similar issues

## Related

- The dropdown menu's toggle button already had `e.stopPropagation()` at line 640
- The slideover's Edit button correctly closes the slideover before opening the modal via the `onEdit` callback
