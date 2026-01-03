# Bug Report: CSI Ratios Using Wrong Source File

**Date:** 3 January 2026
**Status:** Fixed
**Priority:** High

## Summary

The BURC sync script was reading CSI Operating Ratios from the wrong source file, resulting in Sales Ratio = 0.00 for most months of 2026 when there was actually forecast data available.

## Root Cause

The sync script was configured to read from:
- **Wrong:** `/APAC Leadership Team - General/Performance/Financials/BURC/2026/2026 APAC Performance.xlsx`

This file only contained "Actual" data for licence revenue (which is $0 for most months since deals haven't closed yet).

The correct source file is:
- **Correct:** `/APAC Leadership Team - Performance/Financials/BURC/2026/Budget Planning/2026 APAC Performance.xlsx`

This file contains the **pre-calculated CSI ratios** in the "APAC BURC" sheet (rows 119-125), which represent the official BURC forecast values.

## Changes Made

### 1. Updated Source File Path (`scripts/sync-burc-monthly.mjs`)

```javascript
// Primary: Budget Planning file (has full forecast with pre-calculated CSI ratios)
const BUDGET_PLANNING_SOURCE = '/APAC Leadership Team - Performance/Financials/BURC/2026/Budget Planning/2026 APAC Performance.xlsx'
```

### 2. Updated Extraction Logic

The `extractCSIOpexData()` function now:
1. Reads from the "APAC BURC" sheet (not "APAC BURC - Monthly NR Comp")
2. Finds pre-calculated ratio rows by label:
   - `Customer Service (>4)` → Maintenance Ratio
   - `Sales & Marketing (>1)` → Sales Ratio
   - `R&D (>1)` → R&D Ratio
   - `Professional Services (>2)` → PS Ratio
   - `Administration <=20%` → G&A Ratio
3. Uses correct column offset: Column C (index 2) = January data

### 3. Added New Sync Function

Created `syncCSIRatios()` to write pre-calculated values directly to `burc_csi_ratios` table, overriding any calculated values.

## Data Verification

### Before Fix (Jan 2026)
| Ratio | Value | Status |
|-------|-------|--------|
| Sales | 0.00 | 🔴 Red |
| PS | 1.89 | 🟠 Amber |
| Maint | 4.58 | 🟢 Green |

### After Fix (Jan 2026)
| Ratio | Value | Status |
|-------|-------|--------|
| Sales | 3.84 | 🟢 Green |
| PS | 1.82 | 🟠 Amber |
| Maint | 5.32 | 🟢 Green |
| R&D | 1.04 | 🟢 Green |

### Full 2026 CSI Ratios (Forecast)

| Month | PS | Sales | Maint | R&D |
|-------|-----|-------|-------|-----|
| Jan | 1.82 | 3.84 | 5.32 | 1.04 |
| Feb | 2.26 | 0.00 | 5.66 | 0.28 |
| Mar | 2.31 | 0.05 | 5.86 | 0.29 |
| Apr | 2.12 | 0.00 | 5.45 | 0.26 |
| May | 2.08 | 0.00 | 5.59 | 0.27 |
| Jun | 2.27 | 0.23 | 5.71 | 0.31 |
| Jul | 2.43 | 0.14 | 5.46 | 0.28 |
| Aug | 2.29 | 1.37 | 8.13 | 0.61 |
| Sep | 2.40 | 0.00 | 5.73 | 0.28 |
| Oct | 2.65 | 0.31 | 5.32 | 0.30 |
| Nov | 2.83 | 0.00 | 6.32 | 0.31 |
| Dec | 2.71 | 0.00 | 6.72 | 0.19 |

### 4. Updated Analytics Library (`src/lib/csi-analytics.ts`)

Added calculation for current month's plan value:
```typescript
// Current month's plan value from BURC (for display as "Plan")
const currentDate = new Date()
const currentMonth = currentDate.getMonth() + 1 // 1-12
const currentMonthForecast = forecastData.find(d => d.month === currentMonth)
const forecastCurrentMonthValue = currentMonthForecast?.[ratio] || forecastYearAvg
const forecastCurrentMonthPeriod = `${MONTH_NAMES[currentMonth - 1]} ${BURC_FOCUS_YEAR}`
```

### 5. Updated Type Definition (`src/types/csi-insights.ts`)

Extended `forecastData` with new fields:
```typescript
forecastData: {
  currentMonthValue: number // Current month's plan value from BURC
  currentMonthPeriod: string // e.g., "Jan 2026"
  yearAverage: number // Average of 2026 budget forecast
  yearEndValue: number // December 2026 budget forecast
  focusYear: number // The BURC focus year (2026)
}
```

### 6. Updated UI Component (`src/components/csi/CSIOverviewPanel.tsx`)

Changed Plan display from yearly average to current month's value:
- Label now shows current month period (e.g., "Jan 2026") instead of "BURC 2026"
- Value now shows `currentMonthValue` instead of `yearAverage`

## Files Modified

- `scripts/sync-burc-monthly.mjs` - Updated source file path and extraction logic
- `src/app/api/analytics/burc/csi-ratios/route.ts` - Fixed actual vs forecast detection (month must be fully completed to be "actual")
- `src/lib/csi-analytics.ts` - Added current month's plan value calculation
- `src/types/csi-insights.ts` - Extended forecastData type, corrected targets (Sales=1, Maint=4, G&A=20%), updated formulas
- `src/components/csi/CSIOverviewPanel.tsx` - UI now shows "Plan" for current/future months, updated formula definitions

## Testing

1. Ran `--dry-run` to verify correct data extraction
2. Confirmed month alignment (Jan=3.84, not Feb=3.84)
3. Ran full sync to update database
4. Verified with `scripts/check-csi-ratios.mjs`

## Prevention

- Document the correct source file location for BURC data
- The sync script now prefers the Budget Planning file, then falls back to General folder
- Pre-calculated CSI ratios from BURC are now the source of truth

## Official CSI Ratio Targets (Harris)

The following targets should be achieved consistently every month and by year end:

| Ratio | Target | Formula |
|-------|--------|---------|
| **PS** | ≥2 | Net Professional Services Revenue ÷ PS OPEX |
| **Sales** | ≥1 | 70% Net Licence Revenue ÷ S&M OPEX |
| **Maintenance** | ≥4 | 85% Net Maintenance Revenue ÷ Maintenance OPEX |
| **R&D** | ≥1 | (30% Net Licence Rev + 15% Net Maint Rev) ÷ R&D OPEX |
| **G&A** | ≤20% | G&A OPEX ÷ Total Net Revenue |

**Note:** Core Profitability Ratio = EBITA ÷ Net Maint Rev (should be ≥50%)

### Previous Incorrect Targets (Fixed)

| Ratio | Was | Now |
|-------|-----|-----|
| Sales | 2.0 | 1.0 |
| Maintenance | 2.0 | 4.0 |
| G&A | 10.0 | 20.0 |

## Understanding the Three CSI Ratio Values

The CSI Operating Ratios UI displays three distinct values for each ratio:

| Value | Source | What It Represents |
|-------|--------|-------------------|
| **Actual** | Last completed month (e.g., Dec 2025) | The calculated ratio from real historical data |
| **Plan** | BURC Budget (current month, e.g., Jan 2026) | Official management target from the Budget Planning file |
| **Forecast** | Linear regression on historical actuals | Statistical trend projection - where the data is heading |

### Why Forecast May Differ Significantly from Plan

**Example: Sales Ratio (Jan 2026)**
- **Actual (Dec 2025):** 0.23
- **Plan (Jan 2026):** 3.84
- **Forecast:** 0.05 (2% confidence)

The **Forecast (0.05)** is low because it's based on historical actual data - and historically, licence revenue has been inconsistent/low relative to S&M OPEX. The linear regression extrapolates that trend forward.

The **Plan (3.84)** is much higher because that's what management is budgeting to achieve - the aspirational target from the BURC.

### Confidence Percentage

The confidence percentage shown next to Forecast (e.g., "2%") represents the R² (coefficient of determination) from the linear regression:
- **High confidence (>50%):** Historical data follows a clean linear trend, forecast is reliable
- **Low confidence (<20%):** Data is volatile/unpredictable, forecast should be interpreted cautiously

### Key Insight

The gap between **Plan** and **Forecast** highlights whether achieving the budget will require a significant deviation from historical performance:
- **Small gap:** Historical trends support achieving the plan
- **Large gap:** Achieving the plan requires breaking from historical patterns

## Related

- Previous report: `BUG-REPORT-20260103-csi-ratios-verification.md` (now superseded)
