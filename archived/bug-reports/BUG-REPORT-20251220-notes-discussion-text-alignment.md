# Bug Report: Notes & Discussion Header Text Alignment

**Date:** 20 December 2025
**Status:** Resolved
**Component:** UnifiedComments
**File:** `src/components/comments/UnifiedComments.tsx`

## Issue Description

The "Notes & Discussion" header in the client profile right panel had messy text alignment. The title text was wrapping awkwardly and initially being truncated to "Notes & Di..." when alignment fixes were attempted.

## Root Cause

The header layout was using `flex items-center` which caused alignment issues when the title text needed to wrap. The original CSS didn't account for the narrow panel width, and an initial fix using `truncate` was too aggressive.

## Solution

Updated the header layout in `UnifiedComments.tsx` to:

1. Changed from `items-center` to `items-start` - allows vertical alignment at top when text wraps
2. Removed `truncate` class - allows full text to display
3. Added `text-sm leading-tight` to the title - makes text smaller and more compact
4. Aligned icon to top with `mt-0.5` when text wraps to multiple lines
5. Simplified button styling to a plain text link (removed padding/background)
6. Reduced gap between elements for tighter spacing

## Code Changes

**Before:**

```jsx
<div className="flex items-center justify-between px-4 py-3 border-b border-gray-100">
  <div className="flex items-center gap-2">
    <MessageSquare className="h-4 w-4 text-gray-500" />
    <h3 className="font-medium text-gray-900">
      {title}
      ...
    </h3>
  </div>
  <button className="px-3 py-1.5 text-sm text-blue-600 hover:bg-blue-50 rounded-md transition-colors">
    Add Comment
  </button>
</div>
```

**After:**

```jsx
<div className="flex items-start justify-between gap-2 px-4 py-3 border-b border-gray-100">
  <div className="flex items-start gap-2">
    <MessageSquare className="h-4 w-4 text-gray-500 flex-shrink-0 mt-0.5" />
    <h3 className="font-medium text-gray-900 text-sm leading-tight">
      {title}
      ...
    </h3>
  </div>
  <button className="text-sm text-blue-600 hover:text-blue-700 whitespace-nowrap flex-shrink-0">
    Add Comment
  </button>
</div>
```

## Testing

- Build passes successfully
- Visual verification confirmed text displays fully without truncation
- Header alignment is clean and professional

## Files Modified

- `src/components/comments/UnifiedComments.tsx`
