# Bug Report: Actions Page Professional UI/UX Standards

## Date

19 December 2025

## Issue Summary

The Actions page metadata display did not meet professional UI/UX standards. Multiple visual issues existed including warped elliptical badges on grouped rows, status text wrapping to two lines, and overlapping metadata columns.

## Symptoms

1. **Warped/Elliptical Badges**: Grouped action rows displayed client count badges with `rounded-full` which created elliptical shapes instead of professional pill-shaped badges
2. **Status Text Wrapping**: "In Progress" status badge text wrapped to two lines instead of displaying on a single line
3. **Overlapping Metadata**: Date and owner columns overlapped due to fixed container width without proper gap spacing
4. **Inconsistent Alignment**: Metadata columns did not align vertically across different row types

## Root Cause Analysis

### CollapsibleActionGroup (Grouped Rows)

1. **Missing `ml-auto`**: The metadata container lacked `ml-auto` to push content to the right edge, causing inconsistent positioning
2. **Wrong Border Radius**: Used `rounded-full` which creates elliptical shapes when content width varies. Professional UIs use `rounded-md` for pill-shaped badges

### ActionCard (Single Action Rows)

1. **Fixed Container Width**: Used `w-[440px]` fixed width container which didn't adapt well to varying content
2. **Fixed Width Status Badge**: Used `w-[90px]` fixed width on status badge which caused "In Progress" text to wrap
3. **Missing `whitespace-nowrap`**: Text elements could wrap unexpectedly
4. **Oversized Logos**: Used `w-6 h-6` logos which were disproportionate to the metadata text

## Solution

### Industry Best Practices Applied

Researched top tech company UIs (Linear, Notion, Asana) and implemented:

1. **Explicit Gap Spacing**: Use `gap-4` instead of fixed container widths for consistent spacing
2. **Padding-Based Badge Sizing**: Use `px-2.5 py-0.5` padding instead of fixed widths for status badges
3. **`whitespace-nowrap`**: Prevent all metadata text from wrapping
4. **`ml-auto`**: Push metadata to right edge for consistent vertical alignment
5. **`rounded-md`**: Use consistent pill-shaped borders (not elliptical)

### CollapsibleActionGroup Changes

```tsx
// Before
<div className="hidden sm:flex items-center gap-4 text-xs text-gray-500 flex-shrink-0">
  <span className="flex items-center gap-1 bg-purple-100 text-purple-700 px-2.5 py-0.5 rounded-full font-medium whitespace-nowrap">

// After
<div className="hidden sm:flex items-center gap-4 text-xs text-gray-500 flex-shrink-0 ml-auto">
  <span className="inline-flex items-center gap-1 bg-purple-100 text-purple-700 px-2.5 py-0.5 rounded-md font-medium whitespace-nowrap">
```

### ActionCard Changes

```tsx
// Before - fixed width container and status badge
<div className="hidden sm:flex items-center w-[440px] text-xs text-gray-500 flex-shrink-0 ml-auto">
  <div className="w-[90px] flex items-center justify-center px-2 py-1 text-xs rounded font-medium">

// After - gap-based spacing and padding-based badge
<div className="hidden sm:flex items-center gap-4 text-xs text-gray-500 flex-shrink-0 ml-auto">
  <span className="inline-flex items-center px-2.5 py-0.5 text-xs rounded-md font-medium whitespace-nowrap">
```

### Column Width Optimisation

| Column | Before       | After         |
| ------ | ------------ | ------------- |
| Client | 140px        | 120px         |
| Date   | 100px        | 90px          |
| Owner  | 80px         | 70px          |
| Status | 90px (fixed) | padding-based |
| Logo   | w-6 h-6      | w-5 h-5       |

## Files Modified

- `src/app/(dashboard)/actions/page.tsx`
  - Lines 800-831: CollapsibleActionGroup metadata section
  - Lines 949-1015: ActionCard metadata section

## Testing

- Build passes with no TypeScript errors
- All 56 unit tests pass
- Visual verification shows:
  - Vertical column alignment across all row types
  - Status badges display on single line
  - No text overlapping between columns
  - Pill-shaped badges (not warped/elliptical)

## Visual Comparison

### Before

```
┌────────────────────────────────────────────────────────────────────┐
│ ● Schedule engagement meetings  (●●●●●) 7 clients  👤 3   ✓ 2/7   │  ← elliptical badge
│ ● Health Check - SA Health   SA Health   12/31Dimitri   In       │  ← overlapping
│                                                         Progress  │  ← 2 lines
└────────────────────────────────────────────────────────────────────┘
```

### After

```
┌────────────────────────────────────────────────────────────────────┐
│ ● Schedule engagement meetings    [7 clients]   👤 3   ✓ 2/7      │  ← pill badge
│ ● Health Check - SA Health   SA Health   12/31   Dimitri   In Progress │  ← aligned
└────────────────────────────────────────────────────────────────────┘
```

## Prevention

1. **Use Gap Spacing**: Prefer `gap-X` over fixed container widths for flexible layouts
2. **Padding-Based Badges**: Never use fixed widths on badges/pills with variable text
3. **Always `whitespace-nowrap`**: Apply to all metadata text that should stay on one line
4. **`ml-auto` Pattern**: Use to push flex items to consistent right edge
5. **`rounded-md` for Pills**: Use `rounded-md` instead of `rounded-full` for badges with variable width content

## Related Bug Reports

- `BUG-REPORT-20251219-actions-alignment-fix.md` - Earlier alignment attempt
- `BUG-REPORT-20251219-actions-page-fixes.md` - Dropdown z-index and logo fixes
- `BUG-REPORT-20251219-collapsible-similar-actions.md` - Collapsible grouping feature
- `BUG-REPORT-20251219-actions-page-ux-redesign.md` - Compact view implementation

## Commits

- `da0e8f5` - fix: professional UI/UX alignment for Actions page metadata
