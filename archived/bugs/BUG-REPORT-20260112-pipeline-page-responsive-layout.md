# Bug Report: Pipeline Page Not Optimised for 14-16" Displays

**Date:** 12 January 2026
**Status:** Fixed
**Severity:** Low
**Component:** 2026 Pipeline Page

## Issue Description

The 2026 Pipeline Overview page stats cards grid was displaying 8 columns on screens as small as 1024px (lg breakpoint), causing the cards to appear cramped and difficult to read on 14-16" laptop displays (typically 1280-1440px width).

## Steps to Reproduce

1. Navigate to /pipeline
2. View on a 14-16" display (1280-1440px viewport width)
3. Observe that 8 stats cards are displayed in a single row, appearing cramped

## Expected Behaviour

Stats cards should display in a readable layout appropriate for the screen size, with sufficient spacing and card width for readability.

## Root Cause

The grid responsive breakpoints were set to show 8 columns at the `lg` breakpoint (1024px), which was too aggressive:

```typescript
<div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-8 gap-3">
```

## Solution

Updated the responsive breakpoints to use `xl` (1280px) for 6 columns and `2xl` (1536px) for 8 columns:

```typescript
<div className="grid grid-cols-2 md:grid-cols-4 xl:grid-cols-6 2xl:grid-cols-8 gap-3">
```

### Breakpoint Behaviour After Fix

| Screen Width | Grid Columns | Typical Use |
|--------------|--------------|-------------|
| < 768px | 2 columns | Mobile |
| 768px - 1279px | 4 columns | Tablet / Small laptop |
| 1280px - 1535px | 6 columns | 14-16" displays |
| 1536px+ | 8 columns | External monitors / Large displays |

## Files Modified

- `src/app/(dashboard)/pipeline/page.tsx` - Line 588

## Verification

- Tested at 1440x900 viewport (simulating 14" display)
- Layout displays 6 columns in first row, 2 in second row
- Cards are readable with proper spacing
- Build passes with zero TypeScript errors

## Commit

```
fix: Optimise pipeline page layout for 14-16" displays
217ac567
```
