# Bug Fix: Plan Coverage Table UI Improvements

**Date**: 2026-01-19
**Type**: Bug Fix / Enhancement
**Status**: RESOLVED

---

## Issues Fixed

### 1. Pipeline Badge Colour Not Showing
**Problem**: Pipeline badge in Forecast column was displaying as grey instead of purple.

**Root Cause**: The colour logic checked for 'best' and 'commit' but fell through to grey for 'pipeline'.

**Fix**: Updated forecast badge colour logic to include purple for Pipeline status.
```typescript
// Before: defaulted to gray
// After: Pipeline = Purple
if (statusLower.includes('pipeline')) {
  return { bg: 'bg-purple-100', text: 'text-purple-700' }
}
```

### 2. Column Alignment Issues
**Problem**: Forecast, Stage, ACV, Weighted, Close and Probability columns were not properly centred.

**Fix**: Changed all data cells from `text-right` to `text-center` alignment for consistent display.

### 3. Column Header Renaming
**Problem**: Column headers were abbreviated and unclear.

**Changes**:
- `ACV` → `Total ACV`
- `Weighted` → `Weighted ACV`
- `Close` → `Close Date`
- `Prob` → `Probability`

### 4. Missing Close Quarter Column
**Problem**: No way to see which calendar quarter a deal was expected to close.

**Fix**: Added new `Qtr` column showing Q1-Q4 based on close date month.
```typescript
// Calculate calendar quarter from close date
`Q${Math.ceil((new Date(opp.close_date).getMonth() + 1) / 3)}`
```

### 5. No Sort Functionality on Columns
**Problem**: Users couldn't sort the Plan Coverage table by any column.

**Fix**: Made all column headers clickable with sort indicators (ArrowUp/ArrowDown/ArrowUpDown icons). Supports:
- Opportunity name (alphabetical)
- Forecast status (alphabetical)
- Stage (alphabetical)
- Total ACV (numeric)
- Weighted ACV (numeric)
- Close Date (date)
- Close Quarter (numeric)
- Probability (numeric)

### 6. Stage Badge Colours Inconsistent
**Problem**: Stage badges in Opportunity Qualification section didn't match Plan Coverage colours.

**Root Cause**: Opportunity Qualification was using `getCategoryBadgeColors()` which was designed for forecast categories (Best Case, Commit, Pipeline), not sales stages (Engage, Discover, Prove, Agree).

**Fix**: Created separate helper functions:
- `getForecastBadgeColors()` - For forecast status badges
- `getStageBadgeColors()` - For sales stage badges

**Stage Colour Mapping**:
| Stage | Background | Text |
|-------|------------|------|
| Engage | bg-blue-100 | text-blue-700 |
| Discover | bg-amber-100 | text-amber-700 |
| Prove | bg-purple-100 | text-purple-700 |
| Agree | bg-emerald-100 | text-emerald-700 |
| Closed Won | bg-green-100 | text-green-700 |

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx` | All UI improvements (+199 lines, -56 lines) |

## CSE Financial Reconciliation

Reviewed Excel source file: `APAC 2026 Sales Budget 14Jan2026 v0.1.xlsx`

**CSE Summary Weighted ACV from Pipeline:**

| CSE | Weighted ACV | Total ACV |
|-----|--------------|-----------|
| Johnathan Salisbury | $1,269,624.80 | $928,122.80 |
| Laura Messing | $2,675,259.98 | $5,726,997.18 |
| New Asia CSE | $2,485,028.27 | $7,919,399.40 |
| Tracey Bland | $1,928,636.30 | $3,335,052.00 |
| **Grand Total** | **$8,358,549.35** | **$17,909,571.38** |

**Notes**:
- "CSE Summary Wgt ACV" values are pipeline forecasts (weighted by probability)
- The application loads CSE targets from `cse_cam_targets` Supabase table
- CSE name "New Asia CSE" maps to "Open Role" in the app
- "Johnathan Salisbury" maps to "John Salisbury" in the app

## Testing

- [x] Build passes (`npm run build`)
- [x] TypeScript compilation successful
- [x] ESLint passes
- [x] Pipeline badge now shows purple colour
- [x] All columns properly centred
- [x] Column headers correctly renamed
- [x] Close Quarter column displays Q1-Q4
- [x] Sort functionality works on all columns
- [x] Stage badges match between Plan Coverage and Opportunity Qualification

## Commit

- `d308c79e` - Improve Plan Coverage table UI and functionality
