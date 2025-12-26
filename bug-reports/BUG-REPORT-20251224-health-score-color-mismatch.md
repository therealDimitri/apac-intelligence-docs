# Bug Report: Health Score Badge and Ring Colour Mismatch

**Date:** 2024-12-24
**Status:** Fixed
**Severity:** Visual/UX

## Problem

Client profile detail cards displayed inconsistent colours between the health status badge and the health score ring. For example, a client with health score 58 would show:

- Badge: "Critical" with red styling (correct)
- Ring: Amber colour (incorrect - should be red)

## Root Cause

Multiple files had hardcoded health score thresholds that didn't match the centralised configuration in `src/lib/health-score-config.ts`:

**Centralised Config (Correct):**

- Healthy: >= 70
- At-Risk: >= 60 and < 70
- Critical: < 60

**Hardcoded Values (Incorrect):**

- Healthy: >= 75
- At-Risk: >= 50 and < 75
- Critical: < 50

This meant a score of 58 would be:

- Badge (using `getHealthStatus()`): "Critical" → red
- Ring (using hardcoded 75/50): >= 50 → amber

## Affected Files

| File                                                                   | Issue                          |
| ---------------------------------------------------------------------- | ------------------------------ |
| `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`  | Health ring + modal thresholds |
| `src/app/(dashboard)/clients/page.tsx`                                 | Health bar colour              |
| `src/app/(dashboard)/segmentation/page.tsx`                            | Health bar colour              |
| `src/app/(dashboard)/clients/[clientId]/v2/page.tsx`                   | PDF export status values       |
| `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx` | Health component colour        |

## Solution

1. **Import centralised config** - Added `getHealthStatus` and `HEALTH_SCORE_CONFIG` imports to all affected files
2. **Replace hardcoded thresholds** - Changed all `>= 75` / `>= 50` checks to use `getHealthStatus(score) === 'healthy' / 'at-risk' / 'critical'`
3. **Updated tooltip text** - Changed modal tooltip to use dynamic threshold values from `HEALTH_SCORE_CONFIG.thresholds`

### Example Fix

Before:

```typescript
stroke={healthScore >= 75 ? '#10b981' : healthScore >= 50 ? '#f59e0b' : '#ef4444'}
```

After:

```typescript
stroke={healthStatus === 'healthy' ? '#10b981' : healthStatus === 'at-risk' ? '#f59e0b' : '#ef4444'}
```

## Prevention

- Always use the centralised `getHealthStatus()` function for health status determination
- Never hardcode threshold values (70, 60) - use `HEALTH_SCORE_CONFIG.thresholds`
- The tooltip in the modal now uses dynamic values to stay in sync automatically

## Testing

Verify on `/clients/[clientId]/v2` page:

1. Check a client with health score 58-69 (should be "At-Risk" amber)
2. Check a client with health score < 60 (should be "Critical" red)
3. Check a client with health score >= 70 (should be "Healthy" green)
4. Verify badge colour matches ring colour
5. Click the health card to open modal and verify colours match there too

## Files Modified

- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
- `src/app/(dashboard)/clients/page.tsx`
- `src/app/(dashboard)/segmentation/page.tsx`
- `src/app/(dashboard)/clients/[clientId]/v2/page.tsx`
- `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
