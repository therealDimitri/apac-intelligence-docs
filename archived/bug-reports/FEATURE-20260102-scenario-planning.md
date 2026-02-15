# Feature: Scenario Planning for CSI Ratios

**Date**: 2 January 2026
**Status**: Implemented
**Priority**: Medium
**Component**: BURC Performance > CSI Ratios > Analysis > Scenario Planning

## Overview

Implemented scenario planning to replace single-point forecasts with three scenario projections (Best Case, Most Likely, Worst Case) for better decision-making under uncertainty.

## User Request

> "Consider scenario planning rather than single-point forecasts"

## Implementation

### New Files Created

1. **`src/lib/scenario-planning.ts`** - Utility functions for scenario generation
   - `createScenariosFromInterval()` - Creates 3 scenarios from prediction intervals
   - `generateScenarioRecommendation()` - Generates actionable recommendations
   - `createRatioScenarios()` - Creates comprehensive scenario analysis for a ratio
   - `summarisePortfolioRisk()` - Summarises overall portfolio risk

2. **`src/components/csi/ScenarioPlanning.tsx`** - UI component
   - Collapsible ratio rows with scenario cards
   - Portfolio risk summary badge (Low/Medium/High)
   - Actionable recommendations for each ratio
   - Legend explaining probability bounds

### Modified Files

1. **`src/components/csi/TrendAnalysisPanel.tsx`**
   - Added import for `ScenarioPlanning` component
   - Added `useMemo` hook to prepare scenario data from advancedML
   - Integrated `ScenarioPlanning` component between ML Insights and ratio cards

## How It Works

### Scenario Generation

The system uses existing **80% prediction intervals** to generate three scenarios:

| Scenario | Source | Probability |
|----------|--------|-------------|
| Best Case | upper80 (or lower80 for G&A) | ~10% chance of exceeding |
| Most Likely | point forecast | Most probable outcome |
| Worst Case | lower80 (or upper80 for G&A) | ~10% chance of falling below |

Note: G&A ratio is inverted (lower is better), so best/worst cases are swapped.

### Portfolio Risk Assessment

The system evaluates overall portfolio risk based on how many ratios meet targets across scenarios:

- **Low Risk**: All base cases meet targets with good downside protection
- **Medium Risk**: Mixed outlook, some ratios at risk
- **High Risk**: 3+ ratios projected below target

### Recommendations

Each ratio gets a contextual recommendation based on scenario analysis:

- All scenarios meet target → "Focus on maintaining current performance"
- No scenarios meet target → "Action required: improvement plan needed"
- Base meets, pessimistic doesn't → "Monitor closely, have contingency plans"
- Base fails, optimistic meets → "Focus on drivers to push toward best case"

## UI Features

1. **Portfolio Summary Header**
   - Risk level badge (colour-coded)
   - Summary message explaining the outlook

2. **Collapsible Ratio Rows**
   - Quick summary badges showing each scenario value
   - Click to expand for detailed view

3. **Scenario Cards** (when expanded)
   - Colour-coded: green (best), blue (base), amber (worst)
   - Shows value, probability, % vs target
   - Checkmark/warning icon for target status

4. **Recommendation Box**
   - Purple highlight with lightbulb icon
   - Actionable guidance based on scenario analysis

5. **Legend**
   - Explains the three scenario types and probabilities

## Data Flow

```
API: /api/analytics/burc/csi-ratios?includeAdvancedML=true
  ↓
performComprehensiveMLAnalysis()
  ↓
generateForecastReport() → enhancedAnalysis.ratioAnalyses[ratio].predictionIntervals
  ↓
TrendAnalysisPanel prepares scenarioData via useMemo
  ↓
ScenarioPlanning component renders scenarios
```

## Testing

1. Navigate to **BURC Performance > CSI Ratios > Analysis** tab
2. Verify "Scenario Planning" section appears below "Advanced ML Insights"
3. Check portfolio risk badge shows appropriate level
4. Expand a ratio row and verify:
   - Three scenario cards display (Best Case, Most Likely, Worst Case)
   - Values come from prediction intervals
   - Target status icons display correctly
   - Recommendation text is contextual
5. Verify G&A ratio scenarios are inverted (lower values are better)

## Dependencies

- Requires `includeAdvancedML=true` query parameter
- Needs at least 12 months of historical data for prediction intervals
- Uses existing `PredictionInterval` type from `forecasting-engine.ts`

## Future Enhancements

- Add sensitivity analysis ("what if" sliders)
- Allow custom scenario definitions
- Export scenario comparison to PDF/Excel
- Integrate with goal setting and budget planning
