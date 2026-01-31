# Bug Report: Recharts ResponsiveContainer Dimension Error

**Date:** 28 December 2025
**Severity:** Medium
**Status:** Fixed
**Commit:** 329f3ca

## Issue Summary

Console error: `The width(-1) and height(-1) of chart should be greater than 0`

This error occurs when Recharts' `ResponsiveContainer` component renders before its parent container has determined dimensions, resulting in negative width/height values.

## Root Cause

The `ResponsiveContainer` component from Recharts calculates its dimensions based on the parent container. When the parent has:
- `display: none`
- Zero width/height
- Flexbox with no explicit sizing

...the ResponsiveContainer can calculate `-1` for both dimensions, triggering the error.

## Solution

Added `minWidth={0}` prop to all `ResponsiveContainer` components. This ensures the component handles edge cases where the container width might be calculated as negative.

## Files Modified

| File | Changes |
|------|---------|
| `src/components/charts/HealthTrendChart.tsx` | Added `minWidth={0}` |
| `src/components/charts/NPSTrendChart.tsx` | Added `minWidth={0}`, fixed TypeScript types |
| `src/components/charts/SentimentPieChart.tsx` | Added `minWidth={0}`, fixed TypeScript types |
| `src/components/charts/PortfolioProgressChart.tsx` | Added `minWidth={0}`, fixed TypeScript types |
| `src/components/charts/InitiativeTimelineChart.tsx` | Added `minWidth={0}`, fixed TypeScript types |
| `src/components/EventTypeVisualization.tsx` | Added `minWidth={0}` (2 instances) |
| `src/app/(dashboard)/aging-accounts/compliance/components/ExecutiveView.tsx` | Added `minWidth={0}` (3 instances) |

## Additional Fixes

While addressing this issue, ESLint errors were also resolved:
- Removed unused imports (`LineChart`, `parse`)
- Replaced `any` types with proper TypeScript generics in `CustomTooltip` functions

## Example Fix

```tsx
// Before
<ResponsiveContainer width="100%" height={height}>

// After
<ResponsiveContainer width="100%" height={height} minWidth={0}>
```

## Testing

1. Navigate to any page with charts
2. Verify no console errors about negative dimensions
3. Charts should render correctly even when container initially has no dimensions

## Prevention

When using Recharts `ResponsiveContainer`, always include `minWidth={0}`:

```tsx
<ResponsiveContainer width="100%" height={250} minWidth={0}>
  <AreaChart data={data}>
    {/* chart content */}
  </AreaChart>
</ResponsiveContainer>
```
