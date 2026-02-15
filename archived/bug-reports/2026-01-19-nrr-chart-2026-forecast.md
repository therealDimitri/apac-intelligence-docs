# Bug Report: NRR Trend Chart Missing 2026 Forecast

**Date**: 2026-01-19
**Severity**: Medium
**Component**: Historical Revenue Dashboard
**Status**: Fixed

## Issue Description

The Revenue Retention Trends (NRR/GRR) chart on the Historical Revenue tab was not displaying the 2026 forecast data. The chart only showed data up to 2025, while the Revenue Trend chart correctly displayed 2026 forecast.

## Root Cause

The `BURCNRRTrendChart` component had default props of `startYear = 2020` and `endYear = 2025`. The component was being used in `ActionableIntelligenceDashboard.tsx` without any props:

```tsx
<BURCNRRTrendChart />
```

This meant the chart defaulted to only showing 2020-2025, missing the 2026 forecast data.

## Solution

Updated the component usage to explicitly pass the `endYear={2026}` prop:

```tsx
<BURCNRRTrendChart startYear={2020} endYear={2026} />
```

The component already had support for forecast data (styling for years >= 2026), it just wasn't being utilised.

## Files Modified

1. `src/components/ActionableIntelligenceDashboard.tsx` - Added `endYear={2026}` prop to `BURCNRRTrendChart`
2. `src/app/api/analytics/burc/historical/route.ts` - Updated 2026 forecast metrics from conservative estimates to actual projections

## Verification

After the fix, the Historical Revenue dashboard now displays:
- **Revenue Retention Trends (2020-2026)**: Shows 2020, 2022, 2024, and 2026* on x-axis
- **Latest NRR**: 111.4% (Healthy) - reflecting 2026 forecast
- **Latest GRR**: 90% (Healthy) - reflecting 2026 forecast
- **Insight**: "Strong expansion: NRR above 110% indicates healthy upsells"

## Related Context

The 2025 NRR/GRR values (71.9%/66.7%) correctly reflect the actual revenue decline from FY2024 ($34.55M) to FY2025 ($28.25M) - an 18% decline. This is expected behaviour based on the actual financial data.

The 2026 forecast shows improvement based on projected revenue growth from $28.25M to $31.47M (+11.4%).

## Commit

`86aeb364` - fix: Add 2026 forecast to NRR Trend chart and update metrics
