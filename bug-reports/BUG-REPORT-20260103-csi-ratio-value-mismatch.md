# Bug Report: CSI Ratio Values Different Between Overview and Analysis Tabs

**Date:** 3 January 2026
**Severity:** Medium
**Status:** Resolved
**Affected Page:** Financials > CSI Ratios

## Issue Description

The PS Ratio (and other CSI ratios) showed different values between the Overview and Analysis tabs on the same page:

| Tab | Value Displayed | Source Field |
|-----|-----------------|--------------|
| **Overview** | 1.89 | `analysis.actualData.latestValue` |
| **Analysis** | 2.47 | `analysis.currentValue` |

Users expected both tabs to show the same "current" value.

## Root Cause Analysis

The discrepancy was caused by how `currentValue` was calculated in `analyseRatio()` function:

### Before (Bug)
```typescript
// src/lib/csi-analytics.ts line 477
const currentValue = data[data.length - 1]?.[ratio] || 0
```

This took the **last element** of the `data` array which includes both actual and forecast data. Since data is sorted by date ascending:
- `data[data.length - 1]` = December 2026 budget forecast = **2.47**

### Overview Tab (Correct)
```typescript
// Correctly filtered to actual data only
const actualData = data.filter(d => d.isActual)
const latestActual = actualData[actualData.length - 1]
const latestActualValue = latestActual?.[ratio] // = 1.89
```

The Overview tab was correctly showing the latest **actual** data (Jan 2026 = 1.89), while the Analysis tab was incorrectly showing December 2026 **budget forecast** (2.47) as the "current" value.

## Solution Implemented

Changed `analyseRatio()` to filter to actual data before getting currentValue:

```typescript
export function analyseRatio(
  data: CSIDataPoint[],
  ratio: CSIRatioName,
  target: number
): RatioAnalysis {
  // CRITICAL: Use actual data only for currentValue to avoid showing forecast as "current"
  // This ensures consistency with CSIOverviewPanel which shows actualData.latestValue
  const actualOnlyData = data.filter(d => d.isActual !== false)
  const currentValue = actualOnlyData[actualOnlyData.length - 1]?.[ratio] || 0
  // ...
}
```

## Files Changed

- `src/lib/csi-analytics.ts`
  - Modified `analyseRatio()` function to filter actual data before getting currentValue

## Verification Steps

1. Navigate to https://apac-cs-dashboards.com/financials
2. Click on "CSI Ratios" tab
3. On **Overview** sub-tab, note the PS Ratio "Actual" value
4. Click on **Analysis** sub-tab
5. Verify the PS Ratio "Current" value matches the Overview "Actual" value

## Related Commits

- `6ede2f2` - fix: use actual data for CSI ratio currentValue instead of forecast

## Lessons Learned

1. **Consistency is key**: When displaying the same metric in multiple places, ensure they use the same data source
2. **Actual vs Forecast**: Always be explicit about whether values represent actual historical data or forecasts
3. **Array ordering matters**: When data arrays contain mixed actual/forecast data sorted by date, the "last" element may be a future forecast, not the current actual value

---

## Author

Claude AI - Bug fix and documentation
