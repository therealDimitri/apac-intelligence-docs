# Bug Report: Mention Dropdown Not Appearing

**Date:** 2026-01-25
**Status:** Fixed
**Severity:** Medium
**Component:** Comments / Rich Text Editor

## Issue Summary

When typing `@` followed by characters in the rich text editor (e.g., `@lau`), the mention suggestion dropdown was not appearing. The dropdown should show matching team members similar to Microsoft Teams, Slack, etc.

## Root Cause

The tippy.js CSS was not imported. The mention system uses tippy.js for positioning and displaying the suggestion popup. Without the CSS:
- The popup element was being created in the DOM
- But it was invisible/hidden due to missing base styles
- The tippy.js library requires `tippy.js/dist/tippy.css` for proper rendering

## Fix Applied

Added the required CSS import to `MentionSuggestion.tsx`:

```typescript
import 'tippy.js/dist/tippy.css' // Required for tippy popup visibility
```

## Files Modified

- `src/components/comments/MentionSuggestion.tsx` - Added tippy.js CSS import

## Technical Details

The mention system components:
1. **MentionSuggestion.tsx** - Tippy.js extension with `MentionList` component
2. **RichTextEditor.tsx** - Tiptap editor with Mention extension configured
3. **/api/cse-profiles** - API endpoint fetching team members for suggestions

The tippy.js library creates a popup positioned relative to the cursor. Without its CSS:
- No `display` property is set (defaults to browser's inline/none)
- No positioning styles are applied
- No visibility/opacity transitions work

## Verification

After fix:
1. Open any comment section with rich text editor
2. Type `@` followed by a name (e.g., `@lau`)
3. Dropdown should appear with matching team members
4. Can navigate with arrow keys and select with Enter

## Lessons Learned

1. **Always import required CSS for third-party libraries** - Even if you're using custom styling for the content, the container/positioning CSS is still needed
2. **Test UI components in isolation** - The mention functionality was likely never tested visually during initial development
3. **Check browser DevTools** - The popup element would have been visible in the DOM inspector but with no rendered size/visibility
