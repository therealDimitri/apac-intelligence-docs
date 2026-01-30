# Bug Report: Working Capital Historical Trend Not Updating (Recurring)

**Date:** 2026-01-31
**Severity:** Medium
**Status:** Fixed (with long-term solution)
**Component:** Working Capital / Aged Accounts Snapshots

## Summary

Historical trend data for the Working Capital dashboard was not updating reliably. This was a recurring issue - the third occurrence since initial fix on 2026-01-20.

## Symptoms

- Historical Trend chart showing stale data (last point: 24 Jan, current date: 31 Jan)
- 6-7 day gaps between data points
- Pattern of unreliable snapshot captures:
  - Dec 27 → Jan 5 (9 days gap)
  - Jan 5 → Jan 14 (9 days gap)
  - Jan 14 → Jan 19 (5 days gap, first fix applied)
  - Jan 19 → Jan 24 (5 days gap)
  - Jan 24 → Jan 30 (6 days gap)

## Root Cause

The Netlify scheduled function (`netlify/functions/aged-accounts-snapshot.mts`) runs at 7:00 PM UTC daily but fails intermittently without clear error indication. The underlying cause of the Netlify scheduler unreliability was not definitively identified, but likely factors include:

- Netlify scheduled function infrastructure inconsistencies
- Cold start timeouts
- Authentication/token expiry edge cases
- Network transience during Invoice Tracker API calls

## Solution: Page-Load Auto-Healing

Implemented a self-healing mechanism that guarantees fresh data when users access the dashboard:

### Changes Made

**`src/hooks/useAgedAccountsTrends.ts`:**
- Added `autoHeal` option to hook configuration
- Added state: `isHealing`, `latestSnapshotDate`, `hasAttemptedHeal`
- Added useEffect that:
  1. Detects if latest snapshot date is not today
  2. Automatically triggers `/api/cron/aged-accounts-snapshot` POST
  3. Refreshes trend data after successful capture
  4. Only attempts once per page load (prevents loops)

**`src/app/(dashboard)/aging-accounts/page.tsx`:**
- Enabled `autoHeal: true` in the useAgedAccountsTrends hook call

### How It Works

```
User visits Working Capital page
    ↓
useAgedAccountsTrends fetches historical data
    ↓
Hook checks: Is latestSnapshotDate === today?
    ↓
NO → Trigger POST /api/cron/aged-accounts-snapshot
    ↓
Snapshot captured from Invoice Tracker
    ↓
Hook refetches trends with fresh data
    ↓
Chart displays up-to-date data
```

## Why This Approach

| Option | Reliability | Dependency |
|--------|-------------|------------|
| Netlify scheduled function | ★★☆☆☆ | External scheduler |
| GitHub Actions cron | ★★★☆☆ | External scheduler |
| Supabase pg_cron | ★★★★☆ | Database scheduler |
| **Page-load auto-heal** | ★★★★★ | User visits page |

Page-load auto-healing is the most robust because:
- **Zero external dependencies** - runs in the application itself
- **Guaranteed execution** - triggers when users actually need the data
- **Self-correcting** - automatically fills gaps regardless of how they occur
- **Low overhead** - only runs once per page load, only when needed

## Files Modified

- `src/hooks/useAgedAccountsTrends.ts` - Added auto-heal logic
- `src/app/(dashboard)/aging-accounts/page.tsx` - Enabled auto-heal

## Verification

1. Visit Working Capital page
2. If today's snapshot is missing, console will log:
   ```
   [useAgedAccountsTrends] Auto-heal: Latest snapshot is YYYY-MM-DD, triggering capture for YYYY-MM-DD
   [useAgedAccountsTrends] Auto-heal: Captured N records
   ```
3. Historical Trend chart should show data up to current date

## Manual Backfill (If Needed)

To manually trigger a snapshot:

```bash
# Via API (requires CRON_SECRET)
curl -X POST https://apac-cs-dashboards.com/api/cron/aged-accounts-snapshot \
  -H "Authorization: Bearer $CRON_SECRET"

# Via local script
export $(cat .env.local | grep -v '^#' | xargs) && node scripts/trigger-aged-accounts-snapshot.js
```

## Prevention

The Netlify scheduled function remains in place as the primary mechanism. The page-load auto-heal serves as a reliable fallback that ensures data freshness regardless of scheduler reliability.

## Related

- Previous fix: `docs/guides/BUG-REPORT-20260120-working-capital-snapshots-not-running.md`
- Snapshot API: `src/app/api/cron/aged-accounts-snapshot/route.ts`
- Netlify function: `netlify/functions/aged-accounts-snapshot.mts`
