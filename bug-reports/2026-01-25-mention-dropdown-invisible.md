# Bug Report: Mention Dropdown Not Working

**Date:** 2026-01-25
**Status:** Fixed
**Severity:** Medium
**Component:** Comments / Rich Text Editor

## Issue Summary

The @mention functionality in the rich text editor had two issues:
1. The dropdown was not appearing when typing `@` followed by characters
2. After fixing visibility, selecting a person did not insert the mention - it just closed the dropdown

## Root Causes

### Issue 1: Dropdown Not Appearing
The tippy.js CSS was not imported. The mention system uses tippy.js for positioning and displaying the suggestion popup. Without the CSS, the popup element was created but invisible.

### Issue 2: Selection Not Inserting Mention
When clicking a mention suggestion button, the standard `onClick` event was causing the editor to lose focus (blur) before the command could execute. This triggered:
1. Editor blur event
2. Suggestion plugin's `onExit` callback
3. Popup destruction before command could insert the mention

## Fixes Applied

### Fix 1: Import tippy.js CSS
```typescript
import 'tippy.js/dist/tippy.css' // Required for tippy popup visibility
```

### Fix 2: Prevent Editor Blur on Selection
Changed button from `onClick` to `onMouseDown` with `preventDefault()`:
```typescript
<button
  type="button"
  onMouseDown={(e) => {
    e.preventDefault() // Prevent editor blur
    selectItem(index)
  }}
>
```

### Fix 3: Explicit Configuration
Added explicit suggestion configuration:
```typescript
char: '@', // Trigger character
allowSpaces: false, // Stop suggestion on space
```

## Files Modified

- `src/components/comments/MentionSuggestion.tsx`
  - Added tippy.js CSS import
  - Changed onClick to onMouseDown with preventDefault
  - Added type="button" to prevent form submission
  - Added explicit char and allowSpaces configuration

## Technical Details

The mention system flow:
1. User types `@` → Tiptap suggestion plugin triggers
2. `items()` callback fetches matching team members
3. `render().onStart()` creates MentionList component with tippy popup
4. User selects item → `command(item)` should insert mention node
5. `onExit()` destroys popup

The selection issue occurred because:
- `onClick` fires on mouseup
- Between mousedown and mouseup, the editor loses focus
- Editor blur triggers suggestion plugin cleanup
- By the time `onClick` fires, the command function is no longer valid

Using `onMouseDown` with `preventDefault()`:
- Fires immediately on mouse press
- `preventDefault()` stops the default focus-changing behaviour
- Command executes while editor still has focus
- Mention node is properly inserted

## Verification

After fix:
1. Open any comment section with rich text editor
2. Type `@` followed by a name (e.g., `@lau`)
3. Dropdown appears with matching team members
4. Click or press Enter to select
5. Mention is inserted as styled badge: `@Laura Messing`
6. Can continue typing after mention

## Lessons Learned

1. **Import CSS for third-party libraries** - Even with custom content styling, the container/positioning CSS is needed
2. **Use onMouseDown for dropdown selections** - onClick can cause focus issues with contenteditable editors
3. **Always use preventDefault() when preventing blur** - This is a common pattern for dropdown menus in rich text editors
4. **Test the full user journey** - The dropdown appearing wasn't enough; selection also needed verification
