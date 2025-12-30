# Bug Report: CSI Chart Forecast Display and Dynamic Year

**Date:** 30 December 2025
**Severity:** Medium
**Status:** Fixed
**Commit:** bf1ddc9

## Issues Summary

Two issues with the CSI Timeline Chart:

1. **Forecast lines not distinguished**: The chart legend showed "Actual" (solid) vs "Forecast" (dashed) but all data lines rendered the same
2. **Hardcoded focus year**: "Viewing 2026" always displayed regardless of actual data

## Root Causes

### Issue 1: Forecast Line Display
The Recharts `Line` component renders all data points with the same style. There was no differentiation between actual and forecast data points in the line rendering, despite the legend implying a distinction.

### Issue 2: Hardcoded Year
Both `CSIOverviewPanel.tsx` and `CSITabsContainer.tsx` had:
```typescript
const BURC_FOCUS_YEAR = 2026
```
This was a static constant that didn't respond to actual data.

## Solutions

### Issue 1: Split Data Into Segments
Modified `CSITimelineChart.tsx` to:
- Split data into `_actual` and `_forecast` data keys (e.g., `ps_actual`, `ps_forecast`)
- Include a "transition point" at the boundary so lines connect smoothly
- Render two `Line` components per ratio:
  - Actual: solid line (`strokeDasharray` omitted)
  - Forecast: dashed line (`strokeDasharray="5 5"`)
- Hide forecast lines from legend (`legendType="none"`)

### Issue 2: Dynamic Year Calculation
**CSIOverviewPanel.tsx:**
```typescript
function calculateFocusYear(statistics: FullStatisticalAnalysis): number {
  if (statistics.dataRange?.end) {
    const yearMatch = statistics.dataRange.end.match(/\d{4}/)
    if (yearMatch) return parseInt(yearMatch[0], 10)
  }
  return new Date().getFullYear() + 1
}

// Usage in component
const focusYear = useMemo(() => calculateFocusYear(statistics), [statistics])
```

**CSITabsContainer.tsx:**
```typescript
const focusYear = useMemo(() => {
  if (historicalData.length === 0) {
    return new Date().getFullYear() + 1
  }
  return Math.max(...historicalData.map(d => d.year))
}, [historicalData])
```

## Files Modified

| File | Changes |
|------|---------|
| `src/components/csi/CSITimelineChart.tsx` | Split data into actual/forecast segments, render separate lines |
| `src/components/csi/CSIOverviewPanel.tsx` | Calculate focusYear from statistics.dataRange.end |
| `src/components/csi/CSITabsContainer.tsx` | Calculate focusYear from max year in historical data |

## Visual Impact

**Before:**
- All lines rendered solid regardless of data type
- "Viewing: 2026" always displayed

**After:**
- Actual data: solid lines
- Forecast data: dashed lines (connected at transition point)
- Year display updates based on actual data range

## Testing

1. Navigate to BURC Financials > CSI Ratios tab
2. View the Timeline chart
3. Verify:
   - Historical data renders with solid lines
   - Forecast data renders with dashed lines
   - Lines connect smoothly at the actual/forecast boundary
   - "Viewing: [Year]" updates based on data

## Technical Notes

The transition point logic ensures visual continuity:
```typescript
const lastActualIndex = sorted.reduce(
  (lastIdx, d, idx) => (d.dataType === 'actual' ? idx : lastIdx),
  -1
)
const isTransitionPoint = idx === lastActualIndex
// Include transition point in BOTH actual and forecast segments
ps_actual: isActual || isTransitionPoint ? d.ratios.ps : null,
ps_forecast: !isActual || isTransitionPoint ? d.ratios.ps : null,
```
