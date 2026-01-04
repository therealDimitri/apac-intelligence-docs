# Bug Report: Health Score Trend Card Colour and Cron Job Issues

**Date:** 2026-01-04
**Status:** FIXED
**Severity:** Medium (UI/UX + Data)

## Problem Description

### Issue 1: Health Score Trend Card Using Wrong Colour Logic

The Health Score Trend card was using trend direction (improving/declining/stable) to determine header colour:
- Green = Improving (trend > 0)
- Red = Declining (trend < 0)
- **Purple = Stable (trend === 0)** ← Wrong

This didn't match the rest of the dashboard which uses health status-based colours.

**Example:** Western Health had a Critical health score (40) but the card showed a purple header because the trend was stable (0).

### Issue 2: Health Snapshot Cron Not Running

The health snapshot cron job hadn't run since 2026-01-02. Data gaps:
- Dec 21 → Dec 27 (6-day gap)
- Dec 27 → Jan 02 (6-day gap)
- Jan 02 → Jan 04 (missing)

### Issue 3: CRON_SECRET Not Set in Netlify

The `CRON_SECRET` environment variable was missing from Netlify, causing all scheduled functions to fail with:
```
CRON_SECRET not configured
```

## Root Cause

### Issue 1
The code in `LeftColumn.tsx` used `historicalTrend` for colour selection instead of `healthStatus`.

### Issues 2 & 3
The Netlify function `health-snapshot.mts` checks for `CRON_SECRET` before making API calls. Without it, the function returns a 500 error and never triggers the snapshot.

## Solution

### 1. Updated Health Score Trend Card Colours

Changed the gradient logic to use health status instead of trend direction:

**Before (wrong):**
```typescript
className={`px-4 py-2.5 bg-gradient-to-r ${
  historicalTrend > 0
    ? 'from-green-500 to-emerald-500'
    : historicalTrend < 0
      ? 'from-red-500 to-rose-500'
      : 'from-purple-500 to-purple-600'  // Purple for stable trend
}`}
```

**After (correct):**
```typescript
className={`px-4 py-2.5 bg-gradient-to-r ${
  healthStatus === 'healthy'
    ? 'from-green-500 to-emerald-500'
    : healthStatus === 'at-risk'
      ? 'from-amber-500 to-orange-500'
      : 'from-red-500 to-rose-500'  // Red for critical
}`}
```

Now the card header matches the dashboard colour scheme:
- **Green** = Healthy (score >= 70)
- **Amber/Orange** = At-Risk (score 60-69)
- **Red** = Critical (score < 60)

### 2. Ran Health Snapshot Manually

Triggered the cron endpoint to capture today's data:
```bash
curl "http://localhost:3002/api/cron/health-snapshot"
```

Result: 18 client snapshots captured for 2026-01-04.

### 3. Added CRON_SECRET to Netlify

Generated and set the environment variable:
```bash
CRON_SECRET=$(openssl rand -hex 32)
netlify env:set CRON_SECRET "$CRON_SECRET"
```

All scheduled functions will now authenticate correctly.

## Files Modified

1. `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
   - Changed Health Score Trend card header colour logic from trend-based to status-based

## Environment Changes

1. **Netlify Environment Variables**
   - Added `CRON_SECRET` for scheduled function authentication

## Verification

### Health Score Trend Card Colours
| Client | Health Score | Status | Card Header Colour |
|--------|--------------|--------|-------------------|
| Western Health | 40 | Critical | Red ✓ |
| Royal Victorian Eye and Ear Hospital | 60 | At-Risk | Amber ✓ |
| Te Whatu Ora Waikato | 90 | Healthy | Green ✓ |

### Snapshot Data
```
Latest snapshot date: 2026-01-04
Snapshots for 2026-01-04: 18
```

### RVEEH History (example)
| Date | Score | Status |
|------|-------|--------|
| 2026-01-04 | 75 | Healthy |
| 2026-01-02 | 68 | At-Risk |
| 2025-12-27 | 88 | Healthy |

## Related Issues

- BUG-REPORT-20260104-card-order-and-revenue-styling.md
- BUG-REPORT-20251228-cron-jobs-auth-blocked.md

## Recommendations

1. **Monitor Netlify function logs** after each scheduled run to verify success
2. **Set up alerting** for cron job failures (e.g., via webhook to Slack)
3. **Consider adding a health check endpoint** that returns the date of the last successful snapshot
