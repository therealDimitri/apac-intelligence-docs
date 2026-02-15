# Bug Report: Comment Dropdown Menu Cut Off

**Date:** 1 January 2026
**Status:** Fixed
**Severity:** Minor (UI/UX)
**Component:** CommentItem.tsx

## Issue Description

The dropdown menu (Edit/Delete options) in the Notes & Discussion section was being clipped by parent containers, showing only the "Edit" option while "Delete" was hidden below the visible area.

## Root Cause

The dropdown menu was positioned to open **downward** using `mt-1` (margin-top), but parent containers in the RightColumn had `overflow-hidden` CSS properties that clipped any content extending beyond their boundaries.

### Affected Component

`src/components/comments/CommentItem.tsx` (line 266)

### Container Hierarchy with Overflow Issues

```
RightColumn.tsx
└── div.overflow-hidden (multiple nested containers)
    └── UnifiedComments.tsx
        └── CommentThread.tsx
            └── CommentItem.tsx
                └── Dropdown menu (clipped)
```

## Solution

Changed the dropdown menu positioning from opening downward to opening **upward**:

### Before (line 266)
```tsx
<div className="absolute right-0 mt-1 w-32 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-20">
```

### After
```tsx
<div className="absolute right-0 bottom-full mb-1 w-32 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-20">
```

### Key Changes
- Removed `mt-1` (margin-top for downward opening)
- Added `bottom-full` (positions menu above the button)
- Added `mb-1` (margin-bottom for spacing from button)

## Testing

1. Navigate to any client profile page (e.g., `/clients/SingHealth/v2`)
2. Click on the "Notes" tab in the right column
3. Hover over a comment you authored to reveal the three-dots menu button
4. Click the menu button
5. **Expected:** Both "Edit" and "Delete" options are visible above the button
6. **Actual (after fix):** Both options now display correctly

## Screenshots

### Before Fix
- Only "Edit" visible
- "Delete" cut off below visible area

### After Fix
- Both "Edit" and "Delete" visible
- Menu opens upward, avoiding overflow clipping

## Files Modified

- `src/components/comments/CommentItem.tsx`

## Lessons Learned

When working with dropdown menus in containers that may have `overflow-hidden`:
1. Consider the available space above vs below the trigger element
2. Upward-opening menus (`bottom-full`) avoid clipping in scroll containers
3. Always test dropdown menus at various scroll positions and container depths
