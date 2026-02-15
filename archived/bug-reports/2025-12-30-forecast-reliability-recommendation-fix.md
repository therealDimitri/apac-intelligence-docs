# Bug Report: Forecast Reliability Recommendation Misleading

**Date:** 30 December 2025
**Severity:** Medium (Misleading UX)
**Status:** Resolved

## Problem Description

The "Forecast reliability is low" insight in the Priority Matrix was displaying incorrect recommendations. When the ML forecasting confidence was low, it always suggested:

> "Extend historical data collection to 36+ months, validate data sources with finance team, and cross-reference with GL reports"

This recommendation was shown **regardless of how much data was available**, even when users had 48+ months of historical data.

## Root Cause

In `src/lib/csi-analytics.ts` (line 965-969), the low confidence recommendation was static text that didn't account for:

1. **Actual data quantity** - The `data.length` (number of months) was not checked
2. **True cause of low confidence** - Low confidence is caused by high MAPE (prediction error > 30%) due to data volatility, not insufficient data quantity

```typescript
// OLD CODE - Static text regardless of data quantity
if (overallConfidence === 'low') {
  recommendedActions.push(
    `Forecast reliability is low: Extend historical data collection to 36+ months...`
  )
}
```

## Solution

Updated the recommendation logic to be **data-aware**:

```typescript
if (overallConfidence === 'low') {
  const monthsOfData = data.length
  const mapeRounded = Math.round(avgMAPE)

  if (monthsOfData >= 36) {
    // Have sufficient data - issue is volatility, not data quantity
    recommendedActions.push(
      `Forecast reliability is low (MAPE: ${mapeRounded}%) despite ${monthsOfData} months of data: High variability in metrics reduces prediction accuracy. Consider segmenting analysis by business cycle, reviewing for one-off events affecting data, and using scenario-based planning instead of point forecasts`
    )
  } else if (monthsOfData >= 24) {
    // Moderate data - suggest validation focus
    recommendedActions.push(
      `Forecast reliability is low (MAPE: ${mapeRounded}%): Current ${monthsOfData} months of data shows high variability...`
    )
  } else {
    // Insufficient data
    recommendedActions.push(
      `Forecast reliability is low: Only ${monthsOfData} months of historical data available. Extend to 36+ months...`
    )
  }
}
```

## New Behaviour

| Data Available | New Recommendation |
|---------------|-------------------|
| **36+ months** | Explains it's due to high variability, suggests scenario planning and event review |
| **24-35 months** | Suggests validation + extending data |
| **< 24 months** | Original recommendation to extend data collection |

## Technical Details

- **MAPE** (Mean Absolute Percentage Error) is now shown in the message
- **Actual months count** is displayed so users understand their data situation
- Recommendations are now actionable based on the real cause of low confidence

## Files Modified

| File | Change |
|------|--------|
| `src/lib/csi-analytics.ts` | Lines 964-985 - Data-aware recommendation logic |

## Testing

1. With 48+ months data: Shows "despite X months of data" with volatility guidance
2. With 24-35 months: Shows current count with validation suggestions
3. With < 24 months: Shows original "extend data" recommendation
