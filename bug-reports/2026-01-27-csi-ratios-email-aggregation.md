# Enhancement: CSI Operating Ratios Added to Email Data Aggregation

**Date**: 2026-01-27
**Type**: Enhancement
**Status**: Completed
**Component**: Email Data Aggregator (`src/lib/emails/data-aggregator.ts`)

## Summary

Added CSI (operating ratios) data to the email aggregation system for inclusion in team performance emails.

## Changes Made

### 1. New Interface: `CSIRatiosData`

Added a new TypeScript interface at line 611-633 defining the CSI ratios data structure:

```typescript
export interface CSIRatiosData {
  // PS Ratio: PS Revenue / PS OPEX (target >= 2.0)
  psRatio: number
  psTarget: number
  psStatus: 'green' | 'amber' | 'red'
  // Maintenance Ratio: (85% x Maintenance Revenue) / Maintenance OPEX (target >= 4.0)
  maintenanceRatio: number
  maintenanceTarget: number
  maintenanceStatus: 'green' | 'amber' | 'red'
  // Sales Ratio: (70% x Net Licence Revenue) / S&M OPEX (target >= 1.0)
  salesRatio: number
  salesTarget: number
  salesStatus: 'green' | 'amber' | 'red'
  // Period information
  period: {
    year: number
    month: number
    monthName: string
  }
  // Overall health based on ratios
  ratiosMeetingTarget: number
  totalRatios: number
}
```

### 2. Updated `TeamPerformanceData` Interface

Added `csiRatios: CSIRatiosData | null` field to the `TeamPerformanceData` interface.

### 3. CSI Data Fetching Logic

Added CSI ratios query logic in the `getTeamPerformanceData` function (~line 1580-1728):

1. **Primary Source**: Queries `burc_csi_ratios` table for pre-calculated ratios
2. **Fallback Source**: If no pre-calculated ratios exist, calculates from `burc_csi_opex` table using standard CSI formulas:
   - PS Ratio = PS Revenue / PS OPEX
   - Sales Ratio = (70% x Licence NR) / S&M OPEX
   - Maintenance Ratio = (85% x Maintenance Revenue) / Maintenance OPEX

3. **Status Calculation**: Uses threshold-based status:
   - Green: ratio >= target
   - Amber: ratio >= 80% of target
   - Red: ratio < 80% of target

4. **Error Handling**: If CSI data is unavailable, `csiRatios` returns `null` (graceful degradation)

## CSI Ratio Targets

| Ratio | Target | Formula |
|-------|--------|---------|
| PS Ratio | >= 2.0 | PS Revenue / PS OPEX |
| Sales Ratio | >= 1.0 | (70% x Licence NR) / S&M OPEX |
| Maintenance Ratio | >= 4.0 | (85% x Maintenance Revenue) / Maintenance OPEX |

## Database Tables Used

- `burc_csi_ratios` - Pre-calculated ratios (primary source)
- `burc_csi_opex` - Raw OPEX data (fallback for calculation)

## Testing

- TypeScript compilation: PASSED
- Full Next.js build: PASSED
- No breaking changes to existing functionality

## Files Modified

- `/src/lib/emails/data-aggregator.ts`
  - Added `CSIRatiosData` interface
  - Added `csiRatios` field to `TeamPerformanceData` interface
  - Added CSI data fetching and calculation logic
  - Added `csiRatios` to return object

## Usage

Email templates can now access CSI ratios via:

```typescript
const teamData = await getTeamPerformanceData(managerName, managerEmail)
if (teamData?.csiRatios) {
  // Display PS Ratio
  console.log(`PS Ratio: ${teamData.csiRatios.psRatio} (${teamData.csiRatios.psStatus})`)
  // Display Sales Ratio
  console.log(`Sales Ratio: ${teamData.csiRatios.salesRatio} (${teamData.csiRatios.salesStatus})`)
  // Display Maintenance Ratio
  console.log(`Maintenance Ratio: ${teamData.csiRatios.maintenanceRatio} (${teamData.csiRatios.maintenanceStatus})`)
}
```

## Related Files

- `/src/app/api/analytics/burc/csi-ratios/route.ts` - Reference implementation for ratio calculations
- `/src/app/api/analytics/burc/csi-insights/route.ts` - Reference implementation for ratio calculations
