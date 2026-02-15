# Enhancement: Historical Revenue Tab in Command Centre

**Date:** 2026-01-19
**Commit:** 114ef89b
**Type:** Enhancement
**Status:** Completed

## Summary

Added a new "Historical Revenue" tab to the Command Centre, surfacing historical revenue analytics that were previously only accessible via the separate Financials page.

## Background

The BURC historical revenue components existed in the codebase but were not displayed in the Command Centre:
- `BURCRevenueTrendChart` - Revenue trend by type (2019-2026)
- `BURCRevenueMixChart` - Revenue mix breakdown
- `BURCNRRTrendChart` - Net Revenue Retention trends
- `BURCConcentrationRisk` - Client concentration risk analysis
- `BURCClientLifetimeTable` - Client lifetime revenue details

Users had to navigate to `/financials` to see this data, which was disconnected from the main Command Centre experience.

## Solution

### Changes Made

**File:** `src/components/ActionableIntelligenceDashboard.tsx`

1. Added imports for BURC historical components
2. Added `History` icon from lucide-react
3. Extended tab state type to include `'historical'`
4. Added new tab button in navigation
5. Added tab content with historical revenue dashboard layout

### Tab Layout

```
┌─────────────────────────────────────────────────────┐
│ Revenue Trend Chart (2019-2026)                     │
│ [Full width - SW/PS/Maint/HW breakdown]             │
├────────────────────────┬────────────────────────────┤
│ Revenue Mix Chart      │ NRR Trend Chart            │
│ [Half width]           │ [Half width]               │
├────────────────────────┴────────────────────────────┤
│ Concentration Risk Analysis                         │
│ [Full width]                                        │
├─────────────────────────────────────────────────────┤
│ Client Lifetime Revenue Table                       │
│ [Full width - sortable table]                       │
└─────────────────────────────────────────────────────┘
```

## Command Centre Tabs

The Command Centre now has three tabs:

| Tab | Description |
|-----|-------------|
| Executive Dashboard | KPIs, ARR, retention metrics |
| Priority Actions Matrix | Urgency/impact prioritisation |
| Historical Revenue | Revenue trends and analysis |

## Testing

- Build passes without TypeScript errors
- Tab navigation works correctly
- All components render with data from `burc_historical_revenue_detail` table

## Related Files

- `src/components/ActionableIntelligenceDashboard.tsx` - Main dashboard with tabs
- `src/components/burc/BURCRevenueTrendChart.tsx` - Revenue trend chart
- `src/components/burc/BURCRevenueMixChart.tsx` - Revenue mix chart
- `src/components/burc/BURCNRRTrendChart.tsx` - NRR trend chart
- `src/components/burc/BURCConcentrationRisk.tsx` - Concentration risk
- `src/components/burc/BURCClientLifetimeTable.tsx` - Lifetime revenue table
