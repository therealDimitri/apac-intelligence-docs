# Bug Report: CSI Sparkline Target Lines Not Positioned Correctly

**Date:** 31 December 2025
**Status:** Fixed
**Commit:** e911c94
**Component:** TrendAnalysisPanel (CSI Ratios)

## Issue Description

Target lines in the CSI sparkline charts were not positioned at logical locations relative to the data scale. Users reported that "current target lines don't make logical sense" - the dashed reference lines appeared at seemingly random positions rather than at the actual target values.

## Root Cause

The `react-sparklines` library's `SparklinesReferenceLine` component with `type="custom"` and `value` prop does not respect explicit `min` and `max` bounds passed to the parent `Sparklines` component. This caused the reference line to be positioned incorrectly relative to the chart's Y-axis scale.

## Example of the Problem

For **Sales Ratio**:
- Current value: 0.00
- Target: >1

The target line (at value 1) should appear near the top of the chart since the data is near 0. However, the `SparklinesReferenceLine` was rendering the line at an incorrect position that didn't match the data scale.

## Solution

Replaced `SparklinesReferenceLine` with a manual SVG overlay that calculates the correct Y position based on the actual Y-axis range:

### Key Changes in `src/components/csi/TrendAnalysisPanel.tsx`:

1. **Removed SparklinesReferenceLine import** (no longer needed)

2. **Calculate Y-axis bounds** including both data range and target value:
```typescript
const dataMin = Math.min(...sparklineData)
const dataMax = Math.max(...sparklineData)
const target = analysis.target
const yMin = Math.min(dataMin, target) * 0.9 // Add 10% padding below
const yMax = Math.max(dataMax, target) * 1.1 // Add 10% padding above
```

3. **Add manual SVG overlay** with calculated target line position:
```tsx
{/* Manual target line overlay - positioned based on target value within the Y-axis range */}
<svg
  className="absolute inset-0 pointer-events-none"
  viewBox="0 0 200 48"
  preserveAspectRatio="none"
>
  <line
    x1="5"
    y1={5 + ((yMax - target) / (yMax - yMin)) * 38}
    x2="195"
    y2={5 + ((yMax - target) / (yMax - yMin)) * 38}
    stroke="#9CA3AF"
    strokeWidth="1"
    strokeDasharray="4 2"
  />
</svg>
```

### Position Formula Explanation

`y1 = 5 + ((yMax - target) / (yMax - yMin)) * 38`

- `5` = top margin (matches Sparklines margin prop)
- `(yMax - target) / (yMax - yMin)` = normalised position (0 = top, 1 = bottom)
- `38` = usable chart height (48 total - 5 top margin - 5 bottom margin)

## Verification

After the fix, target lines now appear at logical positions:

| Ratio | Current | Target | Target Line Position |
|-------|---------|--------|---------------------|
| PS Ratio | 2.47 | >2 | Near bottom (data exceeds target) |
| Sales Ratio | 0.00 | >1 | Near top (target above data) |
| Maintenance Ratio | 5.19 | >4 | Lower portion (data exceeds target) |
| R&D Ratio | 0.15 | >1 | Near top (target above data) |
| G&A Ratio | 18.70% | <20% | Just above data line |

## Files Modified

- `src/components/csi/TrendAnalysisPanel.tsx`

## Lessons Learned

1. Third-party charting libraries may not handle all edge cases correctly - always verify reference line positioning with various data scales
2. When library features don't work as expected, manual SVG overlays can provide precise control
3. For charts with reference lines, ensure Y-axis bounds account for both data range AND reference values

## Related Issues

- Previous commit `7b6364a` fixed card alignment in the same session
