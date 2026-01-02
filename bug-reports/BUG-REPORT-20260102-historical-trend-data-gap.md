# Bug Report: Historical Trend Charts Missing Data After Dec 27

**Date:** 2026-01-02
**Severity:** Medium
**Status:** Fixed (cron route) + Manually backfilled

## Summary

The Historical Trend charts for Working Capital and Health Score on Client Profiles only displayed data up until December 27, 2025. No new snapshots were being captured.

## Root Causes

### 1. Netlify Scheduled Functions Not Running

After the cron authentication fix was deployed on Dec 28 (commit `661d05e`), the Netlify scheduled functions appear to have stopped running. The `health-snapshot` function should run daily at 20:00 UTC but hasn't executed since Dec 27.

**Evidence:**
```
Latest snapshot dates in client_health_history:
- 2025-12-27 (last)
- Gap: Dec 28, 29, 30, 31, Jan 1
- 2026-01-02 (manually captured today)
```

### 2. Formula Mismatch Between Code and Database

The `health-snapshot` cron route was importing `calculateHealthScore` from `health-score-config.ts` which uses the **new 4-component formula**:
- NPS: 20 points (max)
- Compliance: 60 points (max)
- Working Capital: 10 points (max)
- Actions: 10 points (max)
- **Total: 100 points**

However, the `client_health_history` table has check constraints that only allow the **old 3-component formula**:
- NPS: 40 points (max)
- Compliance: 50 points (max)
- Working Capital: 10 points (max)
- **Total: 100 points**

When the cron tried to insert compliance_points > 50, the database constraint rejected it:
```
Error: new row for relation "client_health_history" violates check constraint "client_health_history_compliance_points_check"
```

## Fixes Applied

### 1. Updated Cron Route to Use Legacy Formula

Created a local `calculateHealthScoreLegacy()` function in the cron route that matches the database constraints:

```typescript
function calculateHealthScoreLegacy(
  npsScore: number | null,
  compliancePercentage: number | null,
  workingCapitalPercentage: number | null
): { total: number; breakdown: { nps: number; compliance: number; workingCapital: number } } {
  // NPS: ((nps + 100) / 200) * 40 -> max 40 points
  const nps = npsScore ?? 0
  const npsPoints = Math.round(((nps + 100) / 200) * 40)

  // Compliance: (compliance / 100) * 50 -> max 50 points
  const compliance = Math.min(100, compliancePercentage ?? 50)
  const compliancePoints = Math.round((compliance / 100) * 50)

  // Working Capital: (wc / 100) * 10 -> max 10 points
  let workingCapitalPoints: number
  if (workingCapitalPercentage === null || workingCapitalPercentage === undefined) {
    workingCapitalPoints = 10
  } else {
    const wcPercent = Math.min(100, workingCapitalPercentage)
    workingCapitalPoints = Math.round((wcPercent / 100) * 10)
  }

  return {
    total: npsPoints + compliancePoints + workingCapitalPoints,
    breakdown: { nps: npsPoints, compliance: compliancePoints, workingCapital: workingCapitalPoints },
  }
}
```

### 2. Manually Captured Today's Snapshot

Ran the snapshot capture script manually to add 2026-01-02 data for all 18 clients.

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/cron/health-snapshot/route.ts` | Added `calculateHealthScoreLegacy()` function, removed import of new formula |

## Outstanding Issues

### Netlify Function Monitoring Required

The scheduled functions need to be verified as running. Check Netlify function logs to confirm:
- `health-snapshot` runs daily at 20:00 UTC
- `aged-accounts-snapshot` runs daily at 19:00 UTC

If functions aren't running, consider:
1. Redeploying to Netlify
2. Checking `CRON_SECRET` is set in Netlify environment
3. Verifying function bundle size isn't exceeding limits

### Database Constraint Migration (Future)

If the new 4-component formula needs to be used in historical tracking, a migration would be required to:
1. Alter `client_health_history_compliance_points_check` to allow 0-60
2. Alter `client_health_history_nps_points_check` to allow 0-20
3. Add `actions_points` column with constraint 0-10
4. Backfill historical data with recalculated values

For now, the legacy formula maintains consistency with existing historical data.

## Prevention

- Add monitoring/alerting for Netlify scheduled function failures
- Ensure database constraints are updated in sync with formula changes
- Consider adding a health check endpoint that verifies recent snapshot existence
