# Bug Report: Mention Selection Not Inserting Properly

**Date:** 2026-01-25
**Status:** Fixed
**Severity:** High
**Component:** Comments / Rich Text Editor / Mentions

## Issue Summary

When clicking on a person in the @mention dropdown, the mention was not being inserted into the editor. The dropdown would close but the mention would not appear - instead, the user's typed text (e.g., "@laura") remained as plain text.

## Root Cause

The click handler was using `onClick` which fires on mouse release. Between `mousedown` and `mouseup`:
1. The editor could potentially lose focus
2. React state changes could occur
3. The `command` function reference could become stale

The Tiptap suggestion plugin's lifecycle:
1. User clicks dropdown item
2. `mousedown` event fires (editor might blur)
3. If editor blurs, `onExit()` is called, destroying the popup
4. `mouseup` fires, triggering `onClick`
5. By the time `onClick` runs, the command function may no longer be valid

## Fix Applied

Changed the selection from `onClick` to `onMouseDown`:

```typescript
// Before (broken)
onMouseDown={e => {
  e.preventDefault() // Prevent editor blur
  e.stopPropagation()
}}
onClick={e => {
  e.preventDefault()
  e.stopPropagation()
  selectItem(index)
}}

// After (fixed)
onMouseDown={e => {
  e.preventDefault() // Prevent editor blur
  e.stopPropagation() // Stop event bubbling
  // Execute selection immediately on mousedown, not onClick
  // This ensures the command runs before any state changes
  selectItem(index)
}}
```

By executing the selection on `mousedown`:
- The command runs immediately when the user presses down
- `preventDefault()` keeps the editor focused
- The mention node is inserted before any cleanup occurs

## Expected Behaviour After Fix

1. User types `@` followed by characters (e.g., `@lau`)
2. Dropdown appears with matching team members
3. User clicks on a person (e.g., "Laura Messing")
4. Mention is inserted as a styled badge: `@Laura Messing`
   - Purple background gradient
   - Rounded pill shape
   - Full name displayed (not the search text)
5. Cursor is positioned after the mention for continued typing

## HTML Output

When a mention is properly inserted, the HTML should be:
```html
<span class="mention bg-purple-100 text-purple-700 rounded px-1 font-medium"
      data-email="laura.messing@company.com">
  @Laura Messing
</span>
```

This is styled by both:
- Inline Tailwind classes
- Global CSS in `globals.css` for `.mention` and `.prose .mention`

## Files Modified

- `src/components/comments/MentionSuggestion.tsx`
  - Moved `selectItem(index)` from `onClick` to `onMouseDown`
  - Removed redundant `onClick` handler

## Related Issues

This is part of a series of mention functionality fixes:
- [2026-01-25-mention-dropdown-invisible.md](./2026-01-25-mention-dropdown-invisible.md) - Initial dropdown visibility issue

## Verification

After deploying, to verify the fix works:
1. Open any page with comments (e.g., APAC dashboard)
2. Click the floating comments button (purple message icon)
3. Click "Add Comment"
4. Type `@` followed by a name (e.g., `@lau`)
5. Dropdown should appear with matching team members
6. Click on a person
7. **Expected**: Mention badge is inserted with full name and styling
8. **Broken behaviour**: Plain text "@lau" remains, no badge inserted

## Lessons Learned

1. **Always execute dropdown selections on mousedown** - For any contenteditable editor, using `onClick` for dropdown selections can cause race conditions
2. **Understand the event timeline** - mousedown → potential blur/state changes → mouseup → click
3. **Test the actual insertion, not just UI** - The dropdown appearing wasn't sufficient verification
