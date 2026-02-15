# Bug Report: CSI Ratio Card Display Fixes

**Date:** 30 December 2025
**Severity:** High (Incorrect Data Display)
**Status:** Resolved

## Issues Fixed

### Issue 1: Negative Forecast Accuracy Values

**Problem:** Forecast accuracy was showing impossible values like -147%, -47%, -365%

**Root Cause:** The formula `100 - MAPE` produces negative values when MAPE exceeds 100% (common with volatile data)

**Solution:** Clamp accuracy to 0-100% range:
```typescript
const accuracy = mape !== undefined
  ? Math.max(0, Math.min(100, Math.round(100 - mape)))
  : Math.round(analysis.trend.r2 * 100)
```

---

### Issue 2: G&A Progress Calculation Inverted

**Problem:** G&A ratio at 18.70% with target <20% showed 94% progress instead of 100%

**Root Cause:** Progress was calculated as `(currentValue / target) * 100` which works for "higher is better" ratios, but G&A is "lower is better"

| Ratio | Target Type | Calculation |
|-------|------------|-------------|
| PS, Sales, Maint, R&D | Higher is better (>X) | `current / target` |
| G&A | Lower is better (<X%) | Inverted: at/below target = 100% |

**Solution:** Added special handling for G&A in `csi-analytics.ts`:
```typescript
if (ratio === 'ga') {
  // G&A: target is ceiling (e.g., <20%), lower is better
  if (currentValue <= target) {
    percentageOfTarget = 100 // At or below target = success
  } else {
    // Above target - inverse scale
    percentageOfTarget = Math.round((target / currentValue) * 100)
  }
} else {
  // Other ratios: higher is better
  percentageOfTarget = Math.round((currentValue / target) * 100)
}
```

---

### Issue 3: Low Forecast Accuracy Due to Wrong Metric

**Problem:** Forecast accuracy was consistently low (44-51%) even with 48 months of data

**Root Cause:** MAPE was calculated from **in-sample** linear regression (fitting to existing data), not actual forecast accuracy. In-sample metrics are always optimistic.

**Solution:** Use **cross-validation MAPE** which tests actual out-of-sample forecast accuracy:
```typescript
// Time series cross-validation FIRST to get actual forecast accuracy
const crossValidation = timeSeriesCrossValidation(values, 24, 6, 3)
const cvMape = crossValidation.averageMAPE

// Use CV MAPE for the primary forecast metrics (out-of-sample)
const forecastMetrics: ForecastMetrics = {
  ...inSampleMetrics,
  mape: Math.round(cvMape * 100) / 100,
}
```

**Why this helps:**
- In-sample fitting can have 95%+ fit but poor forecasts
- Cross-validation actually tests predictions on held-out data
- Gives realistic accuracy expectations

## Files Modified

| File | Changes |
|------|---------|
| `src/components/csi/TrendAnalysisPanel.tsx` | Clamp accuracy 0-100%, colour coding fix |
| `src/lib/csi-analytics.ts` | G&A progress logic, CV MAPE for accuracy |

---

### Issue 4: Forecast Using Budget Data Instead of Actuals Only

**Problem:** Forecasting was including 2026 budget/forecast data in training and cross-validation

**Root Cause:** `performEnhancedAnalysis` was using ALL data passed to it, including 12 months of 2026 forecast data

**Data available:**
| Year | Type | Months |
|------|------|--------|
| 2023 | Actual | 12 |
| 2024 | Actual | 12 |
| 2025 | Actual | 12 |
| 2026 | Forecast/Budget | 12 |

**Total:** 36 months actual + 12 months forecast = 48 rows

**Solution:** Filter for actual data only in `performEnhancedAnalysis`:
```typescript
// CRITICAL: Only use actual data for forecasting/cross-validation
const actualData = data.filter(d => d.isActual !== false)
const values = actualData.map(d => d[ratio])
```

**Impact:** Now uses 36 months of actual data for cross-validation, giving more accurate MAPE calculations.

---

### Issue 5: generateForecast Using Budget Data

**Problem:** The `generateForecast` function was using all data including budget/forecast for trend calculations and confidence bands.

**Root Cause:** Function used `data.map((d, i) => ...)` without filtering for actual data.

**Solution:** Filter for actual data at start of function:
```typescript
// CRITICAL: Only use actual data for forecasting
const actualData = data.filter(d => d.isActual !== false)
const lastPoint = actualData[actualData.length - 1]

// Calculate trends for each ratio using actual data only
ratios.forEach(ratio => {
  const regressionData = actualData.map((d, i) => ({ x: i, y: d[ratio] }))
  trends[ratio] = calculateLinearRegression(regressionData)
})
```

---

### Issue 6: performComprehensiveMLAnalysis Using Budget Data

**Problem:** Advanced ML analysis (seasonal decomposition, anomaly detection, hierarchical forecasting) was using budget data mixed with actuals.

**Root Cause:** Three separate loops were mapping `data.map(d => d[ratio])` without filtering.

**Solution:** Add single filter at start and use `actualData` throughout:
```typescript
// CRITICAL: Only use actual data for ML analysis
const actualData = data.filter(d => d.isActual !== false)

// Seasonal decomposition - uses actualData
const values = actualData.map(d => d[ratio])

// Anomaly detection - uses actualData
const values = actualData.map(d => d[ratio])

// Hierarchical forecast - uses actualData
hierarchicalData[ratio] = actualData.map(d => d[ratio])
```

## Expected Results After Fix

| Card | Before | After |
|------|--------|-------|
| Sales Ratio | -147% | 0% (clamped) |
| R&D Ratio | -47% | 0% (clamped) |
| G&A Ratio | -365%, 94% progress | 0% (clamped), 100% progress |
| All ratios | 48 months (mixed actual+forecast) | 36 months (actual only) |
| Accuracy | Polluted by budget data | Based on actual historical data |
