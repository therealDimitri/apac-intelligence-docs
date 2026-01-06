# Enhancement: Revenue Performance Tab - 2026 Forecasts

**Date:** 2026-01-06
**Status:** Completed
**Type:** Enhancement
**Component:** BURC Performance > Revenue Performance Tab

## Summary

Added FY2026 forecast data to all applicable Revenue Performance charts and verified data accuracy across all components.

## Changes Made

### 1. Revenue Trend Chart (`BURCRevenueTrendChart.tsx`)

- Added 2026 forecast from `burc_annual_financials` table
- Forecast revenue breakdown estimated from prior year (FY2025) percentages
- Visual indicators for forecast years:
  - Purple colour for axis labels
  - Bold, italic styling
  - Asterisk (*) suffix
  - "(Forecast)" label in tooltip
- Footer note explaining forecast methodology

### 2. Revenue Retention (NRR) Chart (`BURCNRRTrendChart.tsx`)

- Added FY2026 pre-computed NRR/GRR forecast based on 3-year average trends
- Conservative adjustments applied:
  - NRR: 95% (3-year avg: 108.1%)
  - GRR: 78% (3-year avg: 80.8%)
- Visual forecast indicators (same styling as Revenue Trend)
- Footer note explaining forecast methodology

### 3. Revenue Concentration Risk (`BURCConcentrationRisk.tsx`)

- Added 2026 concentration projection based on recent trends
- Dampened growth assumptions (50% of recent change)
- Risk level automatically calculated from projected HHI
- Visual forecast indicators added to chart

### 4. Revenue Mix Evolution (`BURCRevenueMixChart.tsx`)

- Added 2026 mix forecast with trend-based projections
- Percentages normalised to 100%
- Visual forecast indicators added to chart

### 5. Client Lifetime Value (`BURCClientLifetimeTable.tsx`)

- Clarified subtitle to indicate historical data (FY2019-2025)
- No forecast added (requires individual client-level predictions)

### 6. Supplier Analysis (`BURCCriticalSuppliersPanel.tsx`)

- Verified implementation is complete
- Current snapshot data (forecasting not applicable)

## Technical Changes

### API Updates (`/api/analytics/burc/historical/route.ts`)

1. **Revenue Trend View**: Added FY2026 forecast logic from `burc_annual_financials`
2. **Revenue Mix View**: Added FY2026 mix projection with trend analysis
3. **Concentration View**: Added FY2026 concentration projection with dampened trends
4. **NRR View**: Added FY2026 to pre-computed metrics array

### TypeScript Interfaces Updated (`useBURCHistorical.ts`)

- `RevenueMixYear`: Added `isForecast?: boolean`
- `ConcentrationYear`: Added `isForecast?: boolean`
- `NRRMetric`: Added `isForecast?: boolean`

## Forecast Methodology

| Chart | Method | Source |
|-------|--------|--------|
| Revenue Trend | Direct from annual financials | `burc_annual_financials.gross_revenue` |
| NRR/GRR | 3-year average with conservative adjustment | Pre-computed from historical data |
| Concentration | 50% dampened trend from prior 2 years | Calculated from `burc_historical_revenue_detail` |
| Revenue Mix | 50% dampened trend, normalised to 100% | Calculated from historical percentages |

## Visual Styling for Forecast Data

All charts now use consistent styling for forecast years:

- **X-Axis**: Purple (#9333EA), bold (600), italic
- **Label**: Suffixed with asterisk (*)
- **Tooltip**: Shows "(Forecast)" indicator
- **Footer**: Explanatory note about forecast methodology

## Files Modified

- `src/app/api/analytics/burc/historical/route.ts`
- `src/components/burc/BURCRevenueTrendChart.tsx`
- `src/components/burc/BURCNRRTrendChart.tsx`
- `src/components/burc/BURCConcentrationRisk.tsx`
- `src/components/burc/BURCRevenueMixChart.tsx`
- `src/components/burc/BURCClientLifetimeTable.tsx`
- `src/hooks/useBURCHistorical.ts`

## Testing

- TypeScript compilation: Passed (no errors)
- All interface updates verified

## Related

- Pipeline duplicates review (confirmed FALSE POSITIVE - APAC entries are distinct regional items)
- Bug report: `BUG-REPORT-20260106-pipeline-duplicate-entries.md`
