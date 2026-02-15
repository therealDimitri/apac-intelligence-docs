# Bug Report: Health Snapshot Data Gap

**Date**: 2026-01-23
**Status**: RESOLVED
**Severity**: High
**Component**: Netlify Scheduled Function / Health Sparklines

---

## Issue Summary

Health history snapshots were stale (last: 2026-01-16, 7 days old) causing health sparkline trend charts to show outdated data.

## Root Cause

The Netlify scheduled function `health-snapshot.mts` had an incorrect fallback URL (`http://localhost:3000`) that was later fixed to `https://apac-cs-dashboards.com`. However, a data gap remained from when the function was failing.

## Resolution

1. **Code Fix** (already applied in previous commit `dfb39e61`):
   - Fallback URL corrected to `https://apac-cs-dashboards.com`
   - Added comprehensive logging for debugging

2. **Manual Data Backfill**:
   - Manually triggered `/api/cron/health-snapshot` endpoint
   - Created 19 client snapshots for 2026-01-23

## Verification

```bash
curl -s http://localhost:3001/api/cron/health-snapshot
```

Response:
```json
{
  "success": true,
  "date": "2026-01-23",
  "snapshotsCreated": 19,
  "clients": ["The Royal Victorian Eye and Ear Hospital", "Te Whatu Ora Waikato", ...]
}
```

## Prevention

- Monitor Netlify function logs daily
- Set up alerting if `client_health_history` has no new records for 24+ hours
- All Netlify functions now use consistent fallback URL pattern

## Related

- Previous similar issue: `docs/guides/BUG-REPORT-20260120-working-capital-snapshots-not-running.md`
- Part of data audit: `docs/audits/2026-01-23-data-audit-report.md` (Item #5)
