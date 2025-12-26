# Bug Report: NPS Response Count Showing Current Period Only

**Date:** 17 December 2025
**Severity:** Low
**Status:** Fixed

## Summary

The NPS Analytics page was showing response counts for the current period (Q4 25) only, instead of the total number of responses across all survey periods.

## Symptoms

| Client                   | Displayed Count | Actual Total |
| ------------------------ | --------------- | ------------ |
| Epworth Healthcare       | 1               | 11           |
| St Luke's Medical Centre | 2               | 11           |

Users saw "1 responses" for clients that actually had 11+ responses across all surveys.

## Root Cause

In `src/hooks/useNPSData.ts`, line 428, the response count was set using `currentResponses.length`:

```typescript
// BUG (line 428):
return {
  name,
  score: currentNPS,
  trend,
  responses: currentResponses.length,  // Only counts current period!
  ...
}
```

The variable `currentResponses` only contains responses from the current period (Q4 25) or previous period, not all historical responses.

However, `clientResponses` (built earlier at line 387-389) contains ALL responses for that client across all periods.

## Fix

Changed line 428 to use `clientResponses.length` instead:

```typescript
// FIXED:
return {
  name,
  score: currentNPS,
  trend,
  responses: clientResponses.length, // Total responses across all periods
  ...
}
```

## Files Changed

- `src/hooks/useNPSData.ts` - Line 428: Changed from `currentResponses.length` to `clientResponses.length`

## Verification

After fix, clients now show correct total response counts:

- Epworth Healthcare: 11 responses
- St Luke's Medical Centre: 11 responses
- SA Health (iPro): 46 responses
- SingHealth: 20 responses

## Related

- The NPS score calculation still uses current period data (correct behaviour)
- Only the response count display was affected
