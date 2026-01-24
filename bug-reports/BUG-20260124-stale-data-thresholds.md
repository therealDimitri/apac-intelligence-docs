# Bug Report: Stale Data Source Thresholds

**Date:** 2026-01-24
**Status:** Resolved
**Severity:** Low
**Component:** Data Quality Monitor

## Summary

The Data Quality Monitor was incorrectly flagging data sources as "stale" because it used uniform thresholds (24h warning, 7 days critical) for all data sources, regardless of their natural update cadence.

## Root Cause

The `getStaleSeverity()` function in `/src/app/api/admin/data-quality/route.ts` applied the same staleness thresholds to all data sources:
- Warning: > 24 hours
- Critical: > 7 days

This did not account for different data sources having different expected update frequencies:
- **Actions** - Updated ad-hoc by users (not daily)
- **NPS Responses** - Imported quarterly (every ~90 days)
- **Health Snapshots** - Daily automated snapshots
- **Meetings** - Regular sync from calendar systems
- **Aged Accounts** - Regular sync from Invoice Tracker

## Symptoms

- Data Quality Monitor showed 3 "Stale Data Sources" even when data was current
- Actions showing as "5 days ago" was flagged as warning (yellow)
- NPS Responses showing as "69 days ago" was flagged as critical (red)
- Both were actually normal for their respective update cadences

## Resolution

### 1. Implemented source-specific thresholds

Added a `stalenessThresholds` configuration object with appropriate thresholds per source:

```typescript
const stalenessThresholds: Record<string, { warning: number; critical: number }> = {
  client_health_history: { warning: 48, critical: 168 },   // 2 days / 7 days
  actions: { warning: 336, critical: 720 },                // 14 days / 30 days
  unified_meetings: { warning: 48, critical: 168 },        // 2 days / 7 days
  aging_accounts: { warning: 48, critical: 168 },          // 2 days / 7 days
  nps_responses: { warning: 2160, critical: 4320 },        // 90 days / 180 days
}
```

### 2. Updated `getStaleSeverity()` function

Modified to accept an optional `source` parameter and use source-specific thresholds:

```typescript
function getStaleSeverity(hours: number | null, source?: string): 'critical' | 'warning' | 'ok'
```

### 3. Excluded non-client entities from aged accounts

Added Adelaide Milk Services, Cirka, and FLOC to the excluded clients list in `sync-aged-accounts.ts` and deleted existing records from the database.

## Files Changed

- `src/app/api/admin/data-quality/route.ts` - Added source-specific thresholds
- `scripts/sync-aged-accounts.ts` - Added non-client exclusions

## Verification

After the fix:
- Stale Data Sources: 0 (was 3)
- Name Mismatches: 0 (was 3)
- All data freshness indicators show green checkmarks
- Actions (5 days) now shows OK status
- NPS Responses (69 days) now shows OK status

## Lessons Learned

- Data quality metrics should account for the natural cadence of different data sources
- Uniform thresholds can create false positives when data sources have different update frequencies
- Consider the business context when setting alerting thresholds
