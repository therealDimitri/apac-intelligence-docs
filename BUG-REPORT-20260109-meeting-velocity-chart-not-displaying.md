# Bug Report: Meeting Velocity Chart Not Displaying

**Date:** 9 January 2026
**Severity:** Medium
**Status:** Fixed
**Component:** Meeting Analytics Dashboard

## Issue Summary

The Meeting Velocity chart in the Briefing Room's Meeting Analytics section was not displaying any bars. The chart appeared as an empty container with only the labels and summary section visible.

## Root Cause

CSS percentage heights only work when the parent element has a defined height. In the bar chart implementation:

```tsx
<div className="flex items-end gap-1 h-20">  {/* Parent has h-20 (80px) */}
  {data.weeklyTrend.map((week, index) => (
    <div className="flex-1 group relative">  {/* Missing height! */}
      <div style={{ height: `${Math.max(height, 4)}%` }} />  {/* Percentage fails */}
    </div>
  ))}
</div>
```

The outer container had `h-20`, but the flex item children (`flex-1 group relative`) didn't inherit this height explicitly. The inner bar divs used percentage-based heights (`height: X%`), but without a parent with defined height, CSS cannot calculate what that percentage refers to - resulting in effectively 0px height bars.

## Solution

Added `h-full` to the flex item container to make it inherit the full height of the parent, allowing the percentage-based height calculation to work correctly.

```tsx
// Before
<div className="flex-1 group relative">

// After
<div className="flex-1 h-full group relative">
```

## Files Modified

| File | Changes |
|------|---------|
| `src/components/meeting-analytics/MeetingVelocityChart.tsx` | Added `h-full` class to bar container div (line 92) |

## Technical Details

### CSS Height Percentage Behaviour

When using percentage heights in CSS:
1. The browser needs to know the parent's height to calculate the percentage
2. `height: auto` or unspecified height on the parent means `height: 50%` on the child = 0
3. Flexbox's `flex-1` makes an element grow to fill available space horizontally, but doesn't set an explicit height
4. Adding `h-full` (height: 100%) on a flex child inherits the flex container's computed height

### Component Structure

```
.flex.items-end.h-20 (80px height container)
└── .flex-1.h-full.group.relative (now inherits full 80px)
    └── div[style="height: X%"] (can now calculate against 80px)
```

## Testing

1. Navigate to Briefing Room > Meeting Analytics
2. Verify the Meeting Velocity chart displays bar chart correctly
3. Hover over bars to verify tooltips show meeting counts
4. Test with different timeframe selections (30 days, 90 days, 1 year)

## Prevention

When creating bar charts with percentage heights:
- Ensure every ancestor in the height chain has a defined height
- Use `h-full` on flex children that need to pass height to their children
- Test charts with varying data to ensure bars render at all heights

## Related Components

Other charts in the codebase that use similar patterns should be audited:
- `MeetingMixChart.tsx` - Uses Recharts (different approach)
- `HealthTrendChart.tsx` - Uses ResponsiveContainer
- Custom bar charts elsewhere should follow this pattern
