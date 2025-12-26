# Bug Report: Health Score Threshold Inconsistency

**Date:** 2025-12-23
**Status:** Fixed
**Severity:** Medium (UX Confusion)

## Summary

Health score status labels and colours were inconsistent between the Client Profiles page and the Client Detail page (LeftColumn.tsx), causing confusion about whether a client was "Healthy" or "At Risk".

## Root Cause

Two different threshold configurations were being used:

| Page                                         | Healthy | At Risk | Critical |
| -------------------------------------------- | ------- | ------- | -------- |
| Client Profiles (`client-profiles/page.tsx`) | >= 75   | 50-74   | < 50     |
| Client Detail (`LeftColumn.tsx`)             | >= 70   | 60-69   | < 60     |

This meant a client with a health score of 72 would show:

- **"At-risk"** (yellow) on the Client Profiles page
- **"Healthy"** (green) on their Client Detail page

## Fix Applied

Aligned `LeftColumn.tsx` to use the same 75/50 thresholds as `client-profiles/page.tsx`:

### Files Modified

- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
  - Line 793-797: SVG progress circle colour thresholds (70/60 -> 75/50)
  - Line 805-809: Health score text colour thresholds (70/60 -> 75/50)
  - Line 820-824: Health status label colour thresholds (70/60 -> 75/50)
  - Line 827: Health status text thresholds (70/60 -> 75/50)

### Code Changes

```tsx
// BEFORE (inconsistent)
healthComponents.total >= 70
  ? 'text-green-600'
  : healthComponents.total >= 60
    ? 'text-yellow-600'
    : 'text-red-600'

// AFTER (consistent with client-profiles page)
healthComponents.total >= 75
  ? 'text-green-600'
  : healthComponents.total >= 50
    ? 'text-yellow-600'
    : 'text-red-600'
```

## Consistent Thresholds (After Fix)

| Health Score | Status   | Colour       | Icon          |
| ------------ | -------- | ------------ | ------------- |
| >= 75        | Healthy  | Green        | CheckCircle2  |
| 50-74        | At Risk  | Yellow/Amber | AlertTriangle |
| < 50         | Critical | Red          | AlertTriangle |

## Testing

1. Visited Client Profiles page - confirmed correct status labels
2. TypeScript compilation passed with no errors
3. Visual verification of health badges showing correct icons and colours

## Related Files

- `src/app/(dashboard)/client-profiles/page.tsx` - Source of truth for thresholds
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` - Fixed
- `docs/database-schema.md` - `client_health_summary` view definition

## Notes

- The compliance score thresholds (for segmentation events) remain at 70/60 as these are different metrics
- The `_healthStatus` variable on line 455 of LeftColumn.tsx remains unused (prefixed with underscore)
