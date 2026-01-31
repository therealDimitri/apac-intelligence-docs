# Bug Report: CSI Ratio Tooltip Alignment Issue

**Date:** 30 December 2025
**Severity:** Low
**Status:** Fixed
**Commit:** 9fca422

## Issue Summary

The CSI Timeline Chart tooltip displayed "Maintenance Ratio" concatenated with its value (e.g., "Maintenance Ratio5.64") without proper spacing, while other shorter ratio names displayed correctly with proper alignment.

## Root Cause

Two issues combined to cause the display problem:

1. **Insufficient tooltip width**: The tooltip container had `min-w-[200px]` which was too narrow to accommodate the longest ratio name ("Maintenance Ratio")
2. **Missing whitespace control**: No `whitespace-nowrap` class on the ratio name span allowed text wrapping in edge cases

## Solution

Applied two fixes to the `CustomTooltip` component:

1. Increased tooltip minimum width from 200px to 260px
2. Added `whitespace-nowrap` to the ratio name span to prevent text wrapping

## Files Modified

| File | Changes |
|------|---------|
| `src/components/csi/CSITimelineChart.tsx` | Increased `min-w-[200px]` to `min-w-[260px]` on tooltip container |
| `src/components/csi/CSITimelineChart.tsx` | Added `whitespace-nowrap` to ratio name span |

## Code Changes

```tsx
// Before - Line 95
<div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg p-3 min-w-[200px]">

// After - Line 95
<div className="bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg p-3 min-w-[260px]">
```

```tsx
// Before - Line 122
<span className="text-gray-600 dark:text-gray-400">{config.name}</span>

// After - Line 122
<span className="text-gray-600 dark:text-gray-400 whitespace-nowrap">{config.name}</span>
```

## Testing

1. Navigate to BURC Financials > CSI Ratios tab
2. Hover over the CSI Timeline Chart
3. Verify all ratio names display with proper spacing from their values:
   - PS Ratio: [value]
   - Sales Ratio: [value]
   - Maintenance Ratio: [value] (previously concatenated)
   - R&D Ratio: [value]

## Prevention

When creating tooltips with variable-length labels:
- Set minimum width to accommodate the longest expected label
- Use `whitespace-nowrap` on labels to prevent unexpected wrapping
- Use flexbox with `justify-between` for label-value pairs
