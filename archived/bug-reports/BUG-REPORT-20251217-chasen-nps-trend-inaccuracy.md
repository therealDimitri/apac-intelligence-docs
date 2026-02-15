# Bug Report: ChaSen NPS Summary Incorrectly Reports "Stable" for Declining Trends

**Date:** 17 December 2025
**Severity:** Medium
**Status:** Fixed

## Summary

The ChaSen AI-generated NPS summaries were incorrectly reporting "stable" trends for clients with clearly declining NPS scores. The AI was not accurately reflecting the historical trend data.

## Example

**Western Health:**

- Historical NPS Scores: 0 → -67 → -100 (clearly declining)
- ChaSen Summary said: "NPS score is currently stable"
- Should say: "NPS score has progressively declined"

## Root Cause

The trend calculation in `src/app/api/chasen/nps-insights/route.ts` only compared current vs previous period scores:

```typescript
// BUG (lines 259-262):
const scoreChange = previousScore !== undefined ? currentScore - previousScore : null
const trendDirection =
  scoreChange !== null
    ? scoreChange > 5
      ? 'improving'
      : scoreChange < -5
        ? 'declining'
        : 'stable'
    : 'unknown'
```

Issues:

1. Only compared current vs previous period, ignoring full historical trend
2. Threshold of ±5 was too small for NPS scale (-100 to +100)
3. AI prompt didn't enforce using the calculated trend direction

## Fix

### 1. Improved Trend Calculation

Now analyses the full `trendData` array to determine trend direction:

```typescript
if (trendData && trendData.length >= 2) {
  const firstScore = trendData[0]
  const lastScore = trendData[trendData.length - 1]
  const totalChange = lastScore - firstScore

  // Calculate consecutive movements
  let consecutiveDeclines = 0
  let consecutiveIncreases = 0
  for (let i = 1; i < trendData.length; i++) {
    if (trendData[i] < trendData[i - 1]) consecutiveDeclines++
    else if (trendData[i] > trendData[i - 1]) consecutiveIncreases++
  }

  // Determine trend based on overall pattern
  if (totalChange <= -20 || consecutiveDeclines >= trendData.length - 1) {
    trendDirection = 'declining'
    trendAnalysis = `Score has dropped ${Math.abs(totalChange)} points...`
  }
  // ... etc
}
```

### 2. Enhanced AI Prompt

Added explicit instructions requiring the AI to use the calculated trend:

```
- **CALCULATED TREND DIRECTION: DECLINING** (You MUST use this value in your response)
```

Added guidelines:

```
- **TREND ACCURACY IS CRITICAL**: Your "trend" field MUST match the "CALCULATED TREND DIRECTION" provided above
- **SUMMARY MUST REFLECT ACTUAL TREND**: If the trend is "declining", your summary MUST acknowledge the decline
```

## Files Changed

- `src/app/api/chasen/nps-insights/route.ts` - Improved trend calculation and AI prompt

## Verification

After fix, Western Health's NPS insight should correctly identify:

- Trend: "declining" (not "stable")
- Summary acknowledges the progressive decline from 0 to -100
- Risk level reflects the severity of the decline

## Related

- NPS Analytics page displays ChaSen insights in the client detail modal
- Insights are regenerated on each request (no persistent cache)
