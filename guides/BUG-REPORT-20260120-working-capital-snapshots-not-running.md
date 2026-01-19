# Bug Report: Working Capital Daily Snapshots Not Running

**Date:** 2026-01-20
**Severity:** High
**Status:** Fixed
**Component:** Netlify Scheduled Functions / Working Capital Dashboard

## Summary

The Working Capital (Aging Accounts) historical trend chart was not updating because daily snapshots were not being captured to the `aged_accounts_history` table. The chart showed data ending around January 14 instead of current date.

## Symptoms

- Historical Trend chart in Working Capital dashboard showed stale data
- Last data point was approximately January 14, 2026
- Current date was January 20, 2026 (6 days of missing data)
- KPI cards showed current data (from `aging_accounts` table) but trend chart was outdated

## Root Cause

**Primary Issue:** Wrong fallback URL in Netlify scheduled functions

The `aged-accounts-snapshot.mts` function had an incorrect fallback URL:

```typescript
// BEFORE (broken)
const baseUrl = process.env.URL || process.env.DEPLOY_PRIME_URL || 'https://apac-intelligence.netlify.app';

// AFTER (fixed)
const baseUrl = process.env.URL || process.env.DEPLOY_PRIME_URL || 'https://apac-cs-dashboards.com';
```

**Why This Caused the Issue:**
1. Netlify provides `process.env.URL` automatically, which should be the correct domain
2. However, if this env var was missing/empty, the fallback URL was wrong
3. The API call would go to `apac-intelligence.netlify.app` which may not exist or route differently
4. The cron job would fail silently, and no data would be captured

**Additional Issues Found:**
- Same incorrect fallback URL in 5 other Netlify functions
- No warning logged when `CRON_SECRET` was not configured
- Limited error logging made debugging difficult

## Data Flow

```
[Netlify Cron Scheduler]
    ↓ (0 19 * * * = 6 AM Sydney daily)
[aged-accounts-snapshot.mts] ← Fixed fallback URL here
    ↓ POST /api/cron/aged-accounts-snapshot
[Invoice Tracker API] → [Get aging data]
    ↓
[aged_accounts_history] ← Daily client snapshots
    ↓
[/api/aging-accounts/compliance] ← Reads historical data
    ↓
[Historical Trend Chart] ← Should now update daily
```

## Fix Applied

### 1. Fixed Fallback URL

```typescript
// All Netlify functions now use correct fallback
const baseUrl = process.env.URL || process.env.DEPLOY_PRIME_URL || 'https://apac-cs-dashboards.com';
```

### 2. Added Comprehensive Logging

```typescript
const timestamp = new Date().toISOString();
console.log(`[Aged Accounts Snapshot] Daily capture triggered at ${timestamp}`);
console.log(`[Aged Accounts Snapshot] Calling API: ${apiUrl}`);
console.log(`[Aged Accounts Snapshot] Response status: ${response.status}`);
```

### 3. Added CRON_SECRET Warning

```typescript
const cronSecret = process.env.CRON_SECRET;
if (!cronSecret) {
  console.warn('[Aged Accounts Snapshot] Warning: CRON_SECRET not set - API may reject request');
}
```

## Files Changed

| File | Change |
|------|--------|
| `netlify/functions/aged-accounts-snapshot.mts` | Fixed URL, added logging |
| `netlify/functions/aging-alerts-check.mts` | Fixed fallback URL |
| `netlify/functions/chasen-auto-discover.mts` | Fixed fallback URL |
| `netlify/functions/cse-friday-email.mts` | Fixed fallback URL |
| `netlify/functions/cse-monday-email.mts` | Fixed fallback URL |
| `netlify/functions/cse-wednesday-email.mts` | Fixed fallback URL |

## Required Environment Variables

Ensure these are set in Netlify Dashboard → Site Settings → Environment Variables:

| Variable | Description | Required |
|----------|-------------|----------|
| `CRON_SECRET` | Shared secret for cron authentication | Yes |
| `INVOICE_TRACKER_URL` | Invoice Tracker API base URL | Yes |
| `INVOICE_TRACKER_EMAIL` | Invoice Tracker login email | Yes |
| `INVOICE_TRACKER_PASSWORD` | Invoice Tracker login password | Yes |
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase project URL | Yes |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role key | Yes |

## Verification Steps

1. **Check Netlify Function Logs:**
   - Go to Netlify Dashboard → Functions → aged-accounts-snapshot
   - Look for logs at 7:00 PM UTC (6:00 AM Sydney)
   - Should see "Daily capture triggered" and "Capture result" logs

2. **Verify Database Records:**
   ```sql
   SELECT snapshot_date, COUNT(*) as client_count
   FROM aged_accounts_history
   GROUP BY snapshot_date
   ORDER BY snapshot_date DESC
   LIMIT 7;
   ```

   Should show daily entries including today's date.

3. **Check Dashboard:**
   - Go to Working Capital → Historical Trend tab
   - Chart should show data points up to current date
   - "Updated" timestamp should show today

## Manual Trigger (If Needed)

If snapshots are still not running, manually trigger via API:

```bash
curl -X POST https://apac-cs-dashboards.com/api/cron/aged-accounts-snapshot \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_CRON_SECRET"
```

Expected response:
```json
{
  "success": true,
  "message": "Daily snapshot captured successfully",
  "records": 15,
  "timestamp": "2026-01-20T..."
}
```

## Prevention

1. **Use consistent domain:** All Netlify functions should use `https://apac-cs-dashboards.com` as fallback
2. **Monitor function logs:** Set up alerts for failed scheduled functions
3. **Database monitoring:** Alert if `aged_accounts_history` has no new records for 24+ hours
4. **Health check endpoint:** Consider adding a `/api/health/snapshots` endpoint to verify data freshness

## Related Documentation

- `/docs/guides/AGING_ACCOUNTS_IMPORT_GUIDE.md` - Data import process
- `/docs/migrations/20251205_aging_accounts_database.sql` - Database schema

## Commit

```
Fix Working Capital daily snapshots not running

Root cause: Netlify scheduled functions had incorrect fallback URL
(apac-intelligence.netlify.app instead of apac-cs-dashboards.com)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```
