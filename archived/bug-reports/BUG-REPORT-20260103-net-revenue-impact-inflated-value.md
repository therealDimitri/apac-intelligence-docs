# Bug Report: Net Revenue Impact Showing Inflated Value

**Date:** 2026-01-03
**Status:** Fixed
**Severity:** Medium
**Component:** BURCExecutiveDashboard.tsx

## Issue Description

The Net Revenue Impact (NRI) card on the BURC Executive Dashboard was displaying an inflated dollar value that didn't match the original calculation.

## Root Cause

When moving the Net Revenue Impact bar from the financials page into the BURCExecutiveDashboard component, the wrong data source was used:

- **Incorrect:** `summary.total_pipeline` (~$54.9M) - The full unweighted pipeline value
- **Correct:** `summary.weighted_pipeline` (~$34.1M) - Probability-adjusted pipeline value

The original implementation on the financials page used an alert-based `totalOpportunity` calculation (~$14M) which summed the financial impacts from medium/low risk alerts. Using `total_pipeline` significantly inflated the NRI value.

## Solution

Changed the calculation to use `weighted_pipeline` instead of `total_pipeline`:

```typescript
// Before (incorrect)
const netImpact = (summary.total_pipeline || 0) - (summary.total_at_risk || 0)

// After (correct)
const opportunity = summary.weighted_pipeline || 0
const atRisk = summary.total_at_risk || 0
const netImpact = opportunity - atRisk
```

Also:
- Updated subtitle to "Weighted pipeline minus revenue at risk"
- Simplified calculation logic using an IIFE pattern for cleaner code
- Pre-calculated `coverageRatio` to avoid repeated calculations

## Files Changed

- `src/components/burc/BURCExecutiveDashboard.tsx`

## Commit

```
fix: use weighted_pipeline for Net Revenue Impact calculation
Commit: 4e88eaa
```

## Verification

The NRI value now shows the weighted pipeline (~$34.1M) minus revenue at risk, providing a more accurate representation of the probability-adjusted opportunity value.

## Lessons Learned

1. When consolidating components from different pages, ensure the same data sources are used
2. Different pipeline metrics exist: `total_pipeline` (unweighted), `weighted_pipeline` (probability-adjusted), and alert-based totals
3. Always verify calculated values match expectations when moving code between components
