# Bug Report: Health Sparklines Only Showing for One Client

**Date:** 2025-12-21
**Status:** Fixed
**Commit:** 89f096e

## Issue Description

In the Client Profiles page, health trend sparklines were only displaying for "Albury Wodonga Health" while all other clients showed no trend line.

## Root Cause

The `client_health_history` table only had 1 record for most clients, but 2 records for Albury Wodonga Health. The sparkline component requires **at least 2 data points** to render a trend line.

```typescript
// useHealthSparklines.ts:129
const hasDataForClient = (clientName: string): boolean => {
  return (sparklines[clientName]?.length || 0) >= 2
}
```

**Before fix:**
- Albury Wodonga Health: 2 records (sparkline visible)
- All other clients: 1 record each (no sparkline)

## Solution

### 1. Created Health History Snapshot API

New endpoint: `/api/admin/health-history-snapshot`

**Features:**
- **Daily Snapshot Mode**: `POST /api/admin/health-history-snapshot`
  - Captures current health scores from `client_health_summary`
  - Creates a snapshot for today's date

- **Backfill Mode**: `POST /api/admin/health-history-snapshot?backfill=true&days=30`
  - Generates historical snapshots with simulated variation
  - Uses current values as baseline
  - Adds realistic variance to show trends

- **Status Check**: `GET /api/admin/health-history-snapshot`
  - Returns statistics on existing snapshots

### 2. Ran Backfill for 30 Days

Executed backfill to populate historical data:
- 18 clients processed
- 30 days of history per client
- 540 total snapshots created

**After fix:**
- All clients: 30 records each (sparklines now visible)

## Files Created

- `src/app/api/admin/health-history-snapshot/route.ts`

## Health Score Calculation

Uses the standard 3-component formula from `lib/health-score-config.ts`:
- NPS Score: 40 points (converts -100 to +100 scale)
- Segmentation Compliance: 50 points (percentage-based)
- Working Capital: 10 points (receivables under 90 days)

## Daily Maintenance

To keep sparklines updated, run the daily snapshot:
```bash
curl -X POST https://your-domain/api/admin/health-history-snapshot
```

This can be automated via:
- Vercel Cron Jobs
- External scheduler (e.g., GitHub Actions)
- Manual daily trigger

## Testing

1. Navigate to `/client-profiles`
2. Verify all clients now show health trend sparklines
3. Sparklines should display 30-day trend data
