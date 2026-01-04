# Bug Report: Health Score Mismatch Between Client Profiles and Detail Pages

**Date**: 2026-01-04
**Status**: Partially Fixed
**Priority**: Medium

## Issue Description

Health scores displayed on the Client Profiles page (`/client-profiles`) do not match the scores shown on individual client detail pages (`/clients/[id]/v2`).

## Root Cause Analysis

### Data Sources
1. **Client Profiles page** uses `client.health_score` from the `client_health_summary` materialized view
2. **Client Detail page** calculates health score dynamically using:
   - Latest quarter NPS (from `useNPSTrend` hook)
   - Compliance percentage (from database)
   - Working Capital percentage (from database)
   - Actions completion rate (from `useActions` hook)

### Key Differences
1. **NPS Calculation**: Client Detail uses latest quarter NPS, while materialized view may use all-time average
2. **Actions Component**: The database view includes `completion_rate` but requires refresh to capture current action status
3. **Staleness**: Materialized views don't auto-update - they require manual or scheduled refresh

## Fixes Applied

### 1. HealthBreakdown.tsx (Completed)
Changed the total display from using `client.health_score` (database) to using the sum of calculated components:

```tsx
// Before (showing database value)
{client.health_score !== null ? client.health_score : '--'}/100

// After (showing calculated value)
{healthComponents.reduce((sum, c) => sum + c.value, 0)}/100
```

### 2. Materialized View Status (Needs Attention)
The `client_health_summary` view includes the Actions component (`completion_rate`) but:
- Shows `completion_rate = 0` for all clients (needs refresh)
- No automatic refresh mechanism in place

## Recommended Actions

### Immediate: Refresh Materialized View
Run in Supabase SQL Editor:
```sql
REFRESH MATERIALIZED VIEW client_health_summary;
```

### Long-term: Add Scheduled Refresh
Create a Supabase Edge Function or cron job to refresh the view:

Option 1: Create a function and call from cron:
```sql
CREATE OR REPLACE FUNCTION refresh_client_health_summary()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW client_health_summary;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

Option 2: Use pg_cron extension (if enabled):
```sql
SELECT cron.schedule('refresh-health-summary', '0 */4 * * *',
  'REFRESH MATERIALIZED VIEW client_health_summary;');
```

## Technical Details

### Health Score Formula (v4.0)
- **NPS Score**: 20 points (normalise -100 to +100 → 0-20)
- **Segmentation Compliance**: 60 points (percentage × 0.6)
- **Working Capital**: 10 points (% under 90 days × 0.1)
- **Actions**: 10 points (completion rate × 0.1)

### Files Modified
- `src/app/(dashboard)/clients/[clientId]/components/HealthBreakdown.tsx`

### Related Files
- `src/lib/health-score-config.ts` - Single source of truth for formula
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` - Client detail calculation
- `docs/migrations/20260102_add_actions_to_health_score.sql` - Database view definition

## Verification Steps
1. Navigate to `/client-profiles`
2. Click on a client (e.g., Epworth Healthcare)
3. Expand "Health Score Breakdown" section
4. Verify the displayed total matches the sum of the 4 components
5. Compare with the badge on the Client Profiles list

## Notes
- The discrepancy will persist on the Client Profiles *list* until the materialized view is refreshed
- Individual client pages will show accurate calculated scores
- Consider implementing real-time health score calculation on the profiles page for consistency
