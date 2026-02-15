# CSI Ratios Summary Card on Executive Dashboard

**Date:** 2026-01-19
**Commit:** 4759d688
**Type:** Enhancement
**Status:** Completed

## Summary

Added CSI (Cost Structure Index) Ratios Summary card to the Executive Dashboard, bringing back this important financial metric for executive audiences.

## Background

CSI ratios had dropped off the executive dashboard but are important metrics for understanding business unit financial health. The user specifically requested these be brought back and implemented for an executive audience.

## Changes Made

### File: `src/components/burc/BURCExecutiveDashboard.tsx`

1. **Added CSIRatioSummary Interface** (lines 115-135):
   ```typescript
   interface CSIRatioSummary {
     ratios: { ps, sales, salesApac, maintenance, rd, ga }
     statuses: { ps, sales, salesApac, maintenance, rd, ga } // green/amber/red
     healthScore: number
     period: string
   }
   ```

2. **Added State** (lines 272-274):
   - `csiSummary`: Stores the current CSI ratio data
   - `csiExpanded`: Controls expanded/collapsed view

3. **Added Fetch Logic** (lines 488-506):
   - Fetches from `/api/analytics/burc/csi-ratios` API
   - Extracts current period ratios, statuses, and health score
   - Handles API errors gracefully

4. **Added CSI Summary Card UI** (lines 1534-1640):
   - Position: Executive Quick Glance Widgets Row 2 (alongside Cash/AR and Recent Activity)
   - Purple themed to differentiate from other cards
   - Features:
     - Header with Target icon, "CSI Ratios" title, and period label
     - Expandable/collapsible with chevron
     - Overall health score (colour-coded: green ≥80%, amber ≥60%, red <60%)
     - Quick status indicators for PS, Sales, and Maintenance ratios
     - Colour-coded badges (green/amber/red based on targets)
     - Expanded view shows all 5 ratios with status dots
     - Link to full CSI analysis page (/financials)

## CSI Ratio Targets

| Ratio | Target | Description |
|-------|--------|-------------|
| PS (Professional Services) | ≥2.0 | Net PS Rev ÷ PS OPEX |
| Sales & Marketing (APAC) | ≥1.0 | 70% × (Lic + 11% Maint) ÷ S&M OPEX |
| Maintenance | ≥4.0 | 85% Net Maint Rev ÷ Maint OPEX |
| R&D | ≥1.0 | 30% Lic + 15% Maint ÷ R&D OPEX |
| G&A | ≤20% | G&A OPEX ÷ Total Net Rev |

## Visual Design

- **Collapsed View**: Shows health score and 3 key ratios (PS, Sales, Maint) as compact badges
- **Expanded View**: Shows all 5 ratios with status indicators and targets
- **Status Colours**:
  - Green: Meeting/exceeding target
  - Amber: Within 80% of target (or 120% for G&A)
  - Red: Below 80% of target (or above 120% for G&A)

## Data Source

- **API Endpoint**: `/api/analytics/burc/csi-ratios`
- **Database**: `burc_csi_opex_monthly` table
- **Source Files**: BURC Performance Excel files

## Bug Fix: API Response Parsing

**Issue:** CSI Ratios card was not displaying initially because the fetch logic expected `csiData.current` but the API returns data at the top level.

**Original Code (incorrect):**
```typescript
if (csiData.current) {
  setCSISummary({
    ratios: csiData.current.ratios,
    statuses: csiData.current.statuses,
    healthScore: csiData.current.healthScore || 0,
    ...
  })
}
```

**Fixed Code:**
```typescript
if (csiData.ratios) {
  setCSISummary({
    ratios: {
      ps: csiData.ratios.ps?.value || 0,
      sales: csiData.ratios.sales?.value || 0,
      // ... extract values from nested structure
    },
    statuses: {
      ps: csiData.ratios.ps?.status || 'red',
      // ... extract statuses from nested structure
    },
    healthScore: csiData.healthScore?.current || 0,
    period: csiData.period?.monthName ? `${csiData.period.monthName} ${csiData.period.year}` : 'Current',
  })
}
```

**Root Cause:** The API returns ratios as objects with `value` and `status` properties (e.g., `{ ps: { value: 2.1, status: 'green', target: 2, ... } }`), but the dashboard expected simple numbers.

## Testing

- Build passes without TypeScript errors
- Pushed to main branch, triggers Netlify deployment
- Card displays when CSI data is available
- Expand/collapse functionality works correctly
- Verified in browser: Health score, collapsed view with 3 ratios, expanded view with all 5 ratios

## Related Files

- `src/app/api/analytics/burc/csi-ratios/route.ts` - API endpoint
- `src/components/csi/CSIOverviewPanel.tsx` - Full CSI analysis component
- `src/types/csi-insights.ts` - CSI type definitions
