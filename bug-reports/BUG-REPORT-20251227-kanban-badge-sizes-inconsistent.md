# Bug Report: Kanban Board Status Count Badges Inconsistent Sizes

**Date:** 27 December 2025
**Status:** RESOLVED
**Severity:** Low
**Affected Pages:** Actions Page - Kanban Board View

## Summary

Status count badges in the Kanban board column headers displayed at inconsistent sizes. Single-digit numbers (e.g., "1") appeared narrower than double-digit numbers (e.g., "29", "49"), causing visual inconsistency across columns.

## Root Cause

The badge `<span>` elements in both collapsed and expanded column views were missing:
1. A minimum width constraint (`min-w-[28px]`)
2. Text centering (`text-center`)

This caused the badge width to be determined solely by the content (number of digits), resulting in visually misaligned badges.

## Solution

Added `min-w-[28px]` and `text-center` classes to both badge locations in `src/components/KanbanBoard.tsx`:

### Collapsed View Badge (line 200-204)
```tsx
<span
  className={`min-w-[28px] px-1.5 py-0.5 text-xs font-medium ${column.badgeBg} ${column.badgeText} rounded-full text-center`}
>
  {actions.length}
</span>
```

### Expanded View Badge (line 229-233)
```tsx
<span
  className={`min-w-[28px] px-2 py-0.5 text-xs font-medium ${column.badgeBg} ${column.badgeText} rounded-full text-center`}
>
  {actions.length}
</span>
```

## Verification

- TypeScript compilation passes without errors
- Both collapsed and expanded column headers now display consistent badge sizes
- Single-digit and double-digit counts appear with identical badge dimensions

## Files Modified

1. `src/components/KanbanBoard.tsx` - Added `min-w-[28px] text-center` to both badge spans

## Technical Details

The fix uses:
- `min-w-[28px]` - Ensures a minimum width of 28px (enough for 2 digits)
- `text-center` - Centers the number within the badge

This pattern is consistent with badge styling best practices where badges should maintain uniform sizing regardless of content length.

## Related Documentation

- `src/components/KanbanBoard.tsx` - Main Kanban board component
- `docs/bug-reports/BUG-REPORT-20251226-segment-header-logos-missing.md` - Previous UI fix
