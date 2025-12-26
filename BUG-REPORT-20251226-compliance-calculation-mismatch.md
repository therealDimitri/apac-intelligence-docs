# Bug Report: Historical Compliance Chart Using Different Calculation Method

**Date:** 26 December 2025
**Severity:** Medium
**Status:** Fixed
**Commit:** 0a90779

## Summary

The Historical Trend chart in the Aging Accounts Compliance dashboard was displaying different compliance percentages (~70-75%) compared to the KPI cards (~48%), causing user confusion and distrust in the data.

## Root Cause

Two different calculation methods were being used:

1. **KPI Cards**: Dollar-weighted average
   - Formula: `Σ(compliance × AR) / Σ(AR)`
   - Gives more weight to clients with larger outstanding amounts
   - Result: ~48% compliance

2. **Historical Chart API** (before fix): Simple average
   - Formula: `Σ(compliance) / count`
   - Treats all clients equally regardless of AR size
   - Result: ~70-75% compliance

The discrepancy occurred because smaller clients often have better compliance ratios, which inflated the simple average.

## Symptoms

- Sparklines appeared "flat" and unrealistic
- Historical Trend chart showed ~70% while KPI showed ~48%
- Users reported the chart "looked fake"
- Data appeared disconnected from the live metrics

## Investigation Process

1. Verified database data integrity - data was accurate
2. Traced calculation path from database through API to frontend
3. Compared KPI card calculation vs API calculation
4. Identified the weighting difference as root cause

## Fix Applied

Updated `/api/aging-accounts/compliance/route.ts` to use dollar-weighted average:

```typescript
// Before: Simple average
const avg = sum / count

// After: Dollar-weighted average
dailyData.forEach(record => {
  const ar = record.total_outstanding || 0
  group.weightedUnder60Sum += (record.compliance_under_60 || 0) * ar
  group.totalAR += ar
})
const avg_under_60 = group.totalAR > 0 ? group.weightedUnder60Sum / group.totalAR : 0
```

## Files Changed

- `src/app/api/aging-accounts/compliance/route.ts`

## Testing

- TypeScript compilation: Passed
- ESLint: Passed
- Manual verification: Historical chart now matches KPI card percentages

## Additional Notes

- Historical data will remain at previous values until new snapshots are captured
- A Netlify scheduled function was deployed to capture daily snapshots at 6:00 AM Sydney time
- Last snapshot was 20 December 2025; new data will accumulate from next scheduled run

## Lessons Learned

1. Ensure consistency in calculation methods across all visualisations
2. When data appears "fake", investigate the underlying calculations first
3. Dollar-weighted averages are more meaningful for financial metrics
