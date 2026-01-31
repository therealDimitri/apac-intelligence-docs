# Bug Report: Priority Matrix Owner Display Clutter

**Date:** 31 December 2025
**Status:** Fixed
**Severity:** Medium (UX/Visual Clutter)
**Component:** Priority Matrix Cards

## Summary

Multi-owner cards in the Priority Matrix displayed redundant owner information in three separate locations, creating visual clutter and confusion.

## Issue Description

Cards with multiple CSE owners showed:

1. **Left side**: Purple "2C" badge (EnhancedAvatar initials from "2 CSEs" text) + "2 CSEs" text + department
2. **Right side**: Avatar photos overlapping + "2 CSEs" text

This resulted in the CSE count being displayed 3 times and unclear owner identification.

## Root Cause

The `item.metadata.owner` field was being set to "X CSEs" for multi-owner items (e.g., "2 CSEs"). This caused:

1. `EnhancedAvatar` to render initials from "2 CSEs" → displayed "2C" badge
2. Owner name text to display "2 CSEs"
3. `OwnerAvatarGroup` to display actual avatars + "X CSEs" text

The owner display logic didn't differentiate between single-owner (show avatar + name) and multi-owner (show avatar group only).

## Solution

Consolidated the owner display into a single location with conditional rendering:

### For Multi-Owner Items
- Show only `OwnerAvatarGroup` component (avatars + "X CSEs" label)
- Append department after a separator
- Result: `[avatar1][avatar2][+N] X CSEs · Department`

### For Single-Owner Items
- Show traditional avatar + name + department layout
- Unchanged from before

## Code Changes

### MatrixItem.tsx (Comfortable View)
```tsx
{/* Owner Section - consolidated display */}
{(() => {
  const owners = getOwnersFromClientAssignments(clientAssignments)
  const hasMultipleOwners = owners.length > 1

  // Multi-owner: show avatar group only
  if (hasMultipleOwners) {
    return (
      <div className="flex items-center gap-3 flex-1">
        <OwnerAvatarGroup owners={owners} maxVisible={3} size="sm" getPhotoURL={getPhotoURL} />
        {item.metadata?.department && (
          <>
            <span className="text-gray-400">·</span>
            <span className="text-xs text-gray-500">{item.metadata.department}</span>
          </>
        )}
      </div>
    )
  }

  // Single owner: show avatar + name + department
  if (item.metadata?.owner) {
    return (
      <div className="flex items-center gap-2 min-w-0 flex-1">
        <EnhancedAvatar name={item.metadata.owner} ... />
        <div className="min-w-0">
          <span className="text-sm font-medium text-gray-700 block truncate">
            {item.metadata.owner}
          </span>
          {item.metadata?.department && (
            <span className="text-xs text-gray-500 block truncate">
              {item.metadata.department}
            </span>
          )}
        </div>
      </div>
    )
  }

  return null
})()}
```

### MatrixItemCompact.tsx (Compact View)
Same logic applied with smaller sizes (`size="xs"`, `maxVisible={2}`).

## Files Modified

| File | Change |
|------|--------|
| `src/components/priority-matrix/MatrixItem.tsx` | Consolidated owner display logic |
| `src/components/priority-matrix/MatrixItemCompact.tsx` | Consolidated owner display logic |

## Before/After

### Before
```
[2C badge] 2 CSEs · Client Success         [avatar1][avatar2] 2 CSEs
```

### After
```
[avatar1][avatar2][avatar3] 3 CSEs · Client Success
```

## Testing

1. Verified multi-owner cards show single consolidated avatar group
2. Verified single-owner cards display normally (avatar + name + department)
3. Verified tooltips still work on hover over avatars
4. TypeScript and ESLint checks pass

## Deployment

- **Commit:** `cab9b72`
- **Message:** "fix: Consolidate multi-owner CSE display to single location"
- **Deployed to:** https://apac-cs-dashboards.com
