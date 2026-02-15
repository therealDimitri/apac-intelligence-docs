# Bug Report: Netlify Cron Jobs Blocked by Authentication

**Date:** 28 December 2025
**Status:** RESOLVED
**Severity:** High
**Component:** Netlify Scheduled Functions / Authentication Middleware

## Summary

Multiple Netlify scheduled functions were failing silently because the API endpoints they called were blocked by authentication middleware. The functions would run but receive redirect responses instead of executing their intended tasks.

## Root Cause

The `src/proxy.ts` middleware requires authentication for all paths except those explicitly listed in `publicPaths`. Cron endpoints called by Netlify scheduled functions have no session cookies and were being redirected to the signin page.

## Issues Found

### 1. `/api/cron/*` Endpoints Blocked

All endpoints under `/api/cron/` were blocked by auth middleware.

**Affected functions:**
- `cse-monday-email` → `/api/cron/cse-emails?type=monday`
- `cse-wednesday-email` → `/api/cron/cse-emails?type=wednesday`
- `cse-friday-email` → `/api/cron/cse-emails?type=friday`
- `aged-accounts-snapshot` → `/api/cron/aged-accounts-snapshot`
- `chasen-auto-discover` → `/api/cron/chasen-auto-discover`

**Fix:** Added `/api/cron` to `publicPaths` in `src/proxy.ts`

### 2. `/api/aging-alerts/check` Blocked

The `aging-alerts-check` function calls `/api/aging-alerts/check` which is not under `/api/cron/`.

**Fix:** Added `/api/aging-alerts/check` to `publicPaths`

### 3. Duplicate Health Snapshot Functions

Two health snapshot functions existed:
- `health-snapshot.ts` - Old `schedule()` wrapper pattern
- `health-snapshot-scheduled.mts` - New `export const config` pattern

**Fix:** Removed `health-snapshot.ts`, renamed `health-snapshot-scheduled.mts` to `health-snapshot.mts`, added to `netlify.toml`

## Resolution

### Code Changes

**`src/proxy.ts`** - Added cron paths to publicPaths:
```typescript
const publicPaths = [
  // ... existing paths ...
  '/api/cron', // Cron endpoints - secured via CRON_SECRET header instead
  '/api/aging-alerts/check', // Cron endpoint for threshold alerts
  // ... rest of paths ...
]
```

**`netlify.toml`** - Added health-snapshot configuration:
```toml
[functions."health-snapshot"]
  schedule = "0 20 * * *"
```

**`netlify/functions/`** - Consolidated health snapshot:
- Deleted `health-snapshot.ts`
- Renamed `health-snapshot-scheduled.mts` → `health-snapshot.mts`

## Final Cron Job Configuration

| Function | Schedule (UTC) | Schedule (Sydney) | API Endpoint | Auth |
|----------|----------------|-------------------|--------------|------|
| cse-monday-email | Sun 20:00 | Mon 7:00 AM | `/api/cron/cse-emails?type=monday` | CRON_SECRET |
| cse-wednesday-email | Wed 01:00 | Wed 12:00 PM | `/api/cron/cse-emails?type=wednesday` | CRON_SECRET |
| cse-friday-email | Fri 04:00 | Fri 3:00 PM | `/api/cron/cse-emails?type=friday` | CRON_SECRET |
| aged-accounts-snapshot | Daily 19:00 | Daily 6:00 AM | `/api/cron/aged-accounts-snapshot` | CRON_SECRET |
| aging-alerts-check | Daily 21:00 | Daily 8:00 AM | `/api/aging-alerts/check` | CRON_SECRET |
| compliance-snapshot | Sat 20:00 | Sun 6:00 AM | Self-contained (Supabase) | Service Key |
| segmentation-refresh | Daily 19:00 | Daily 6:00 AM | Self-contained (Supabase) | Service Key |
| health-snapshot | Daily 20:00 | Daily 7:00 AM | `/api/cron/health-snapshot` | CRON_SECRET |
| chasen-auto-discover | Daily 18:00 | Daily 5:00 AM | `/api/cron/chasen-auto-discover` | CRON_SECRET |

## Security

Cron endpoints are still secured via `CRON_SECRET` header verification:

```typescript
// In API route
if (CRON_SECRET) {
  const authHeader = request.headers.get('authorization')
  if (authHeader !== `Bearer ${CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }
}
```

```typescript
// In Netlify function
const response = await fetch(apiUrl, {
  headers: {
    'Authorization': `Bearer ${process.env.CRON_SECRET || ''}`,
  },
})
```

## Testing

All endpoints verified working:

```bash
# CSE Emails - sent 8 emails
curl -X GET "http://localhost:3002/api/cron/cse-emails?type=monday"

# Aged Accounts - captured 11 records
curl -X POST "http://localhost:3002/api/cron/aged-accounts-snapshot"

# Aging Alerts - checked 30 combinations
curl -X POST "http://localhost:3002/api/aging-alerts/check"

# Health Snapshot - created 18 snapshots
curl -X GET "http://localhost:3002/api/cron/health-snapshot"

# Segmentation Refresh - updated 15 records
curl -X GET "http://localhost:3002/api/cron/segmentation-refresh"

# ChaSen Auto-Discover - synced 17 row counts
curl -X GET "http://localhost:3002/api/cron/chasen-auto-discover"
```

## Commits

1. `661d05e` - fix: allow cron endpoints to bypass auth middleware
2. `c5cbbcc` - fix: add aging-alerts/check to publicPaths for cron access
3. `9f9d63f` - chore: consolidate duplicate health-snapshot functions

## Recommendations

1. **Set CRON_SECRET in Netlify:** Ensure `CRON_SECRET` environment variable is configured in Netlify dashboard
2. **Monitor Function Logs:** Check Netlify function logs after scheduled runs to verify success
3. **Add New Cron Paths:** When adding new cron endpoints, either:
   - Place under `/api/cron/` (already in publicPaths)
   - Or add the specific path to publicPaths in `src/proxy.ts`

## Related Files

- `src/proxy.ts` - Authentication middleware
- `netlify.toml` - Scheduled function configuration
- `netlify/functions/*.mts` - Netlify function implementations
- `src/app/api/cron/*/route.ts` - API endpoints called by cron functions
