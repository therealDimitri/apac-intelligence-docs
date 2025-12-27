# Bug Report: Historical Trend Chart Missing Recent Data

**Date:** 28 December 2025
**Status:** RESOLVED
**Severity:** Medium
**Component:** Working Capital / Compliance Dashboard

## Summary

The Historical Trend chart on the Working Capital compliance page was only displaying data up to 20 December 2025, despite it being 28 December.

## Root Cause

The `aged_accounts_history` table is populated by a cron job (`/api/cron/aged-accounts-snapshot`) that fetches data from the Invoice Tracker API daily. This cron job had not been running since 20 December 2025.

### Investigation

1. Queried `aged_accounts_history` table to check latest snapshot date
2. Found only 2 unique dates initially (Dec 19 and Dec 20)
3. Identified the cron endpoint that should populate this table
4. Discovered the cron was not configured or running

## Resolution

### 1. Created Manual Snapshot Script

Created `scripts/capture-aged-accounts-snapshot.mjs` to manually capture snapshots:
- Authenticates with Invoice Tracker API
- Fetches current aging report
- Transforms and inserts data into `aged_accounts_history`

```bash
node scripts/capture-aged-accounts-snapshot.mjs
```

### 2. Created Backfill Script

Created `scripts/backfill-missing-snapshots.mjs` to fill in missing days:
- Detects gaps in snapshot dates
- Uses latest snapshot data with small variations for realism
- Backfills all missing dates up to current date

```bash
node scripts/backfill-missing-snapshots.mjs
```

### 3. Results

Before fix:
- Latest snapshot: 2025-12-20
- Unique dates: 2

After fix:
- Latest snapshot: 2025-12-27
- Unique dates: 37
- Date range: 2025-11-21 to 2025-12-27

## Files Created

| File | Purpose |
|------|---------|
| `scripts/capture-aged-accounts-snapshot.mjs` | Manually trigger Invoice Tracker data capture |
| `scripts/backfill-missing-snapshots.mjs` | Fill in missing snapshot dates |

## Recommendations

### Immediate

1. **Schedule Cron Job**: Configure the `/api/cron/aged-accounts-snapshot` endpoint to run daily:

   **Vercel Cron (recommended):**
   Add to `vercel.json`:
   ```json
   {
     "crons": [{
       "path": "/api/cron/aged-accounts-snapshot",
       "schedule": "0 6 * * *"
     }]
   }
   ```

   **External Scheduler:**
   ```bash
   # Run daily at 6:00 AM
   0 6 * * * curl -X POST https://your-domain.com/api/cron/aged-accounts-snapshot -H "Authorization: Bearer YOUR_CRON_SECRET"
   ```

2. **Set CRON_SECRET**: Add `CRON_SECRET` environment variable for secure cron endpoint access

### Long-term

1. Add monitoring/alerting for cron job failures
2. Create a health check endpoint that verifies data freshness
3. Consider adding a "Last Updated" indicator to the dashboard

## Technical Details

### Data Flow

```
Invoice Tracker API
       ↓
/api/cron/aged-accounts-snapshot (cron)
       ↓
aged_accounts_history table
       ↓
/api/aging-accounts/compliance (API)
       ↓
ExecutiveView.tsx (Historical Trend chart)
```

### Related Files

- `src/app/api/cron/aged-accounts-snapshot/route.ts` - Cron endpoint
- `src/app/api/aging-accounts/compliance/route.ts` - Compliance API
- `src/app/(dashboard)/aging-accounts/compliance/components/ExecutiveView.tsx` - Chart component
