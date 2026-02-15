# Bug Report: BURCReconciliation formatCurrency Crash

**Date:** 31 January 2026
**Severity:** High
**Status:** Fixed
**Commit:** d6b181e9

## Summary

The `BURCReconciliation` component crashed with a TypeError when rendering because the `formatCurrency` function received undefined values from the API.

## Error Message

```
TypeError: Cannot read properties of undefined (reading 'toFixed')
src/components/burc/BURCReconciliation.tsx (57:20) @ formatCurrency
```

## Root Cause

The `formatCurrency` function assumed it always received a valid number:

```typescript
const formatCurrency = (value: number, decimals = 1) => {
  const absValue = Math.abs(value)  // crashes if value is undefined
  if (absValue >= 1000000) return `$${(value / 1000000).toFixed(decimals)}M`
  if (absValue >= 1000) return `$${(value / 1000).toFixed(decimals)}K`
  return `$${value.toFixed(0)}`  // line 57 - crashes here
}
```

When the `burc_pipeline_detail` or `burc_waterfall` tables are empty (no data for the selected fiscal year), the reconciliation API returns undefined values for `totalPipeline`, `totalWaterfall`, and `totalVariance`. The function couldn't handle these undefined inputs.

## Fix Applied

Added null/undefined/NaN checking at the start of the function:

```typescript
const formatCurrency = (value: number | undefined | null, decimals = 1) => {
  if (value === undefined || value === null || isNaN(value)) return '$0'
  const absValue = Math.abs(value)
  if (absValue >= 1000000) return `$${(value / 1000000).toFixed(decimals)}M`
  if (absValue >= 1000) return `$${(value / 1000).toFixed(decimals)}K`
  return `$${value.toFixed(0)}`
}
```

## Files Changed

- `src/components/burc/BURCReconciliation.tsx` - Added defensive null checking

## Testing

1. Navigated to `/burc` page
2. Verified Pipeline Reconciliation section renders without errors
3. Confirmed it shows "$0" for empty data instead of crashing
4. Tested YoY toggle functionality - works correctly

## Prevention

This is a defensive programming issue. Currency formatting functions should always validate inputs before performing mathematical operations like `Math.abs()` or `.toFixed()`.

## Related

- Issue discovered while testing the new YoY comparison feature (Phase 2 of BURC implementation plan)
