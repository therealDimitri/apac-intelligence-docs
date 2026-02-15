# Bug Report: Replace R² with MAPE for Forecast Accuracy

**Date:** 30 December 2025
**Severity:** Medium (Misleading Metric)
**Status:** Resolved

## Problem Description

The CSI Trend Analysis panel was displaying **R² (R-squared)** as the primary accuracy metric for forecasting. While R² measures how well a regression line fits historical data, it's **not appropriate for evaluating forecast accuracy**.

### Why R² is Wrong for Forecasting

| Metric | What it Measures | Appropriate For |
|--------|------------------|-----------------|
| **R²** | Variance explained by the model | Regression fit quality |
| **MAPE** | Average percentage error of predictions | Forecast accuracy |

R² can be high (e.g., 95%) even when the model makes poor predictions. It only measures how well the line fits past data, not how accurate future predictions will be.

## Solution

Replaced R² display with **Forecast Accuracy** calculated from MAPE:

```
Forecast Accuracy = 100% - MAPE
```

### New Display Logic

| MAPE Value | Accuracy | Colour |
|------------|----------|--------|
| ≤10% | 90%+ | Green |
| 10-25% | 75-90% | Amber |
| >25% | <75% | Red |

### Before vs After

**Before:**
```
R-squared: 73%
```

**After:**
```
Forecast Accuracy: 78%  (calculated from MAPE of 22%)
```

## Technical Implementation

### File: `src/components/csi/TrendAnalysisPanel.tsx`

1. **Added type definition for enhanced analysis:**
```typescript
interface EnhancedRatioAnalysisData {
  forecastMetrics?: {
    mape: number
    mae: number
    rmse: number
    r2: number
  }
}
```

2. **Updated RatioCard component signature:**
```typescript
function RatioCard({
  ratio,
  analysis,
  mape,  // NEW: MAPE from enhanced analysis
}: {
  ratio: CSIRatioName
  analysis: RatioAnalysis
  mape?: number
})
```

3. **Updated stats grid display:**
```typescript
<span className="block text-gray-500 mb-1">Forecast Accuracy</span>
<span className={cn(
  'font-semibold',
  mape !== undefined && mape <= 10 && 'text-green-600',
  mape !== undefined && mape > 10 && mape <= 25 && 'text-amber-600',
  mape !== undefined && mape > 25 && 'text-red-600',
)}>
  {mape !== undefined ? `${Math.round(100 - mape)}%` : `${(analysis.trend.r2 * 100).toFixed(0)}%`}
</span>
```

4. **Updated RatioCard rendering to pass MAPE:**
```typescript
{ratioOrder.map(ratio => {
  const enhancedRatioAnalysis = advancedML?.enhancedAnalysis?.ratioAnalyses?.[ratio]
  const mapeValue = enhancedRatioAnalysis?.forecastMetrics?.mape

  return (
    <RatioCard
      key={ratio}
      ratio={ratio}
      analysis={ratios[ratio]}
      mape={mapeValue}
    />
  )
})}
```

## Data Source

MAPE is calculated in `src/lib/forecasting-engine.ts` using:

```typescript
// MAPE = (1/n) * Σ|actual - predicted| / actual * 100
const apes = actuals.map((actual, i) => {
  if (actual === 0) return 0
  return Math.abs((actual - predictions[i]) / actual) * 100
})
const mape = ss.mean(apes)
```

## Backwards Compatibility

- Falls back to R² display if MAPE is unavailable (when `advancedML` prop is not passed)
- No breaking changes to existing components

## Related Files

| File | Change |
|------|--------|
| `src/components/csi/TrendAnalysisPanel.tsx` | Display logic updated |
| `src/lib/forecasting-engine.ts` | MAPE already calculated here |
| `src/lib/csi-analytics.ts` | Enhanced analysis already includes MAPE |
