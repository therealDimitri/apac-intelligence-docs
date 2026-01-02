# Bug Report: Insights Panel Technical Jargon Removal

**Date**: 2 January 2026
**Status**: Resolved
**Priority**: Medium
**Component**: Unified Insights Panel, Forecast Metrics

## Issues Reported

### 1. Technical Jargon Throughout Insights
**Problem**: User-facing text contained statistical terms that non-technical users couldn't understand:
- "MAPE: 15.2%" (Mean Absolute Percentage Error)
- "RMSE: 2.1" (Root Mean Square Error)
- "deviation at index 5"
- "Volatile metrics detected (MAPE: 25%)"

Users needed to understand what the forecast reliability actually meant without needing a statistics background.

### 2. Duplicate Content in Insight Cards
**Problem**: The description and "Analysis" section showed identical text. For example:
- Description: "Review renewal rates, address customer churn drivers..."
- Analysis item 1: "Review renewal rates"
- Analysis item 2: "Address customer churn drivers"

This was redundant and made cards unnecessarily long.

### 3. Multiple Reasoning Items Per Insight
**Problem**: Anomaly insights showed 3-4 bullet points of generic advice instead of one clear action:
- "These values are significantly different from historical patterns"
- "This could indicate data entry errors, system issues, or genuine business changes"
- "We recommend verifying the data is accurate"
- "Consider whether any one-off events occurred"

## Fixes Applied

### 1. Plain Language for Forecast Metrics

**ForecastSection.tsx** - Changed metric labels:
| Before | After |
|--------|-------|
| MAPE: 15.2% | Accuracy: 85% |
| RMSE: 2.1 | Spread: ±2.1 |
| MAE: 1.5 | Avg Error: 1.5 |

**forecasting-engine.ts** - Changed descriptions:
| Before | After |
|--------|-------|
| "Highly accurate forecasts (MAPE: 8.5%, outperforms naive baseline)" | "Highly reliable forecasts (92% accuracy) based on consistent patterns" |
| "Good forecast accuracy (MAPE: 15%)" | "Good forecast reliability (85% accuracy)" |
| "Low forecast accuracy (MAPE: 55%). Data may be too volatile..." | "Lower forecast confidence. Data patterns are more volatile than expected." |

**csi-analytics.ts** - Changed confidence reasons:
| Before | After |
|--------|-------|
| "Excellent forecast accuracy (MAPE: 8%) with high model agreement" | "Forecasts are highly reliable with consistent historical patterns" |
| "High forecast uncertainty (MAPE: 35%). Data may be too volatile..." | "Forecasts have lower confidence than usual. Data patterns are more volatile than expected." |

**ml-forecast/route.ts** - Changed recommendations:
| Before | After |
|--------|-------|
| "High forecast uncertainty (MAPE: 32%) - data may be too volatile..." | "Forecasts have lower confidence than usual - data patterns are more volatile than expected" |
| "Excellent forecast accuracy (MAPE: 8%) - predictions are highly reliable" | "Forecasts are highly reliable - predictions are based on consistent historical patterns" |

### 2. Pipe-Separated Recommendation Format

Changed recommendation generation in `csi-analytics.ts` from:
```
Title (values): action1, action2, action3
```

To:
```
Title | Context description | Single clear action
```

Updated `parseRecommendation()` in `utils.ts` to:
- Parse the new pipe-separated format
- Keep context in description
- Show action separately (not duplicated)

### 3. Single Action Per Insight

Changed `InsightCard.tsx` from numbered "Analysis" list to single "Recommended Action" box:

**Before:**
```
Analysis:
1) Review renewal rates
2) Address customer churn drivers
3) Evaluate support ticket resolution times
```

**After:**
```
Recommended Action:
Review renewal rates and address churn drivers
```

### 4. Simplified Anomaly Insights

Changed anomaly reasoning from 4 generic items to 1 specific action:

**Before:**
```typescript
reasoning: [
  'These values are significantly different from historical patterns',
  'This could indicate data entry errors, system issues, or genuine business changes',
  'We recommend verifying the data is accurate',
  'Consider whether any one-off events occurred',
],
```

**After:**
```typescript
reasoning: ['Verify data accuracy and check for any recent business events'],
```

## Files Modified

1. **`src/app/api/analytics/ml-forecast/route.ts`** (lines 193-199)
   - Removed MAPE percentage from recommendation text
   - Used plain language descriptions

2. **`src/app/(dashboard)/clients/[clientId]/components/ForecastSection.tsx`** (lines 437-458)
   - Changed "MAPE" label to "Accuracy" (inverted: 100 - MAPE)
   - Changed "RMSE" label to "Spread" with ± prefix
   - Changed "MAE" label to "Avg Error"

3. **`src/lib/csi-analytics.ts`** (lines 900-905)
   - Removed MAPE percentages from confidence reasons
   - Used plain language explanations

4. **`src/lib/forecasting-engine.ts`** (lines 278-300)
   - Changed accuracy descriptions to use percentage format (100 - MAPE)
   - Removed technical terminology from descriptions

5. **`src/components/insights/utils.ts`**
   - Updated `parseRecommendation()` for pipe-separated format
   - Simplified anomaly insight reasoning arrays

6. **`src/components/insights/InsightCard.tsx`**
   - Changed from numbered "Analysis" list to "Recommended Action" box
   - Added condition to only show if action differs from description

## Testing Verification

1. TypeScript compilation passes with no errors
2. Navigate to BURC Performance > CSI Ratios > Analysis tab
3. Verify insights show clean, non-duplicate content
4. Verify "Recommended Action" appears instead of numbered list
5. Navigate to client page > Forecast section
6. Verify metrics show "Accuracy: 85%" instead of "MAPE: 15%"

## UI/UX Principles Applied

Based on research into modern dashboard design:

1. **Progressive Disclosure**: Show summary first, details on expand
2. **Plain Language**: Use "Accuracy: 85%" not "MAPE: 15%"
3. **Single Action Focus**: One clear next step, not multiple options
4. **No Duplication**: Context and action are separate, never repeated
5. **5-7 Rule**: Limit to ~5 insights to prevent cognitive overload

## Notes

- Internal calculation variables (mape, rmse, etc.) are unchanged - only user-facing text was updated
- The threshold logic remains the same (e.g., mape <= 10 = high confidence)
- Comments in code still reference MAPE for developer understanding
