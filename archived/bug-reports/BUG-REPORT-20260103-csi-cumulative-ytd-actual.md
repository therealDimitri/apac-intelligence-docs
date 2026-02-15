# Bug Report: CSI Actual Value Should Be Cumulative YTD Average

**Date:** 3 January 2026
**Status:** Fixed
**Priority:** Medium

## Summary

The CSI Operating Ratios dashboard was showing only the single latest month's actual value instead of a cumulative year-to-date (YTD) running average as each month's data is populated in the BURC.

## Root Cause

In `src/lib/csi-analytics.ts`, the `analyseRatio()` function was using only the latest single month's actual value:

```typescript
// Before: Shows only last month's value
const latestActual = actualData[actualData.length - 1]
const latestActualValue = latestActual?.[ratio] || 0
```

This meant when 2026 actuals are populated month by month, users would only see the most recent month's ratio, not the cumulative YTD performance.

## Expected Behaviour

As each month's actual data is populated in the BURC:
- **Jan 2026 closes:** Actual = Jan's ratio
- **Feb 2026 closes:** Actual = (Jan + Feb) / 2
- **Mar 2026 closes:** Actual = (Jan + Feb + Mar) / 3
- etc.

This cumulative running calculation gives a better view of YTD performance against targets.

## Changes Made

### 1. Updated `src/lib/csi-analytics.ts`

Added logic to calculate cumulative YTD average for focus year (2026) actuals:

```typescript
// Check for focus year actuals (2026) - these are completed months in the current focus year
const focusYearActuals = actualData.filter(d => d.year === BURC_FOCUS_YEAR)

// Calculate cumulative YTD average for focus year actuals
let latestActualValue: number
let latestActualPeriod: string

if (focusYearActuals.length > 0) {
  // Focus year has actual data - show cumulative YTD average
  latestActualValue = ss.mean(focusYearActuals.map(d => d[ratio]))
  if (focusYearActuals.length === 1) {
    // Single month - show just that month
    latestActualPeriod = `${MONTH_NAMES[month.month - 1]} ${BURC_FOCUS_YEAR}`
  } else {
    // Multiple months - show YTD range
    latestActualPeriod = `${MONTH_NAMES[firstMonth.month - 1]}-${MONTH_NAMES[lastMonth.month - 1]} ${BURC_FOCUS_YEAR} YTD`
  }
} else {
  // No focus year actuals yet - fall back to latest prior year actual
  latestActualValue = priorActual?.[ratio] || 0
  latestActualPeriod = `${MONTH_NAMES[priorActual.month - 1]} ${priorActual.year}`
}
```

### 2. Updated `src/components/csi/CSIOverviewPanel.tsx`

Added handling for the new YTD period format in the label logic:

```tsx
// Check if this is a YTD cumulative format (e.g., "Jan-Mar 2026 YTD")
if (period.includes('YTD')) {
  return 'Actual YTD'
}
```

## Display Behaviour

| Scenario | Label | Period | Value |
|----------|-------|--------|-------|
| No 2026 actuals yet | "Actual" | "Dec 2025" | Dec 2025's ratio |
| Only Jan 2026 closed | "Actual" | "Jan 2026" | Jan 2026's ratio |
| Jan-Mar 2026 closed | "Actual YTD" | "Jan-Mar 2026 YTD" | (Jan + Feb + Mar) / 3 |
| All of 2026 closed | "Actual YTD" | "Jan-Dec 2026 YTD" | Average of all 12 months |

## Files Modified

- `src/lib/csi-analytics.ts` - Added cumulative YTD average calculation
- `src/components/csi/CSIOverviewPanel.tsx` - Added YTD label format handling

## Testing

TypeScript compilation passes without errors.

Since we're currently at January 3rd, 2026, no 2026 actuals exist yet (January is not complete). The dashboard will:
1. Currently show: "Actual - Dec 2025" (last completed month)
2. After Jan 2026 closes: "Actual - Jan 2026" (first 2026 actual)
3. After Feb 2026 closes: "Actual YTD - Jan-Feb 2026 YTD" (cumulative average)

## Related

- Previous fix: `BUG-REPORT-20260103-csi-ratios-source-file-fix.md` (CSI ratios source file and targets)
