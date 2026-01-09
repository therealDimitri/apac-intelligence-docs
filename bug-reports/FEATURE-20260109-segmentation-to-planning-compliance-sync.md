# Feature: Segmentation-to-Planning Compliance Sync Job

**Date:** 2026-01-09
**Type:** Feature Implementation
**Status:** Implemented

## Summary

Created a new sync job script (`/scripts/sync-planning-compliance.mjs`) that synchronises compliance data from segmentation tables to the planning system tables.

## Problem Statement

The Planning Hub enhancement (v2) introduced new tables for tracking compliance at the account plan, territory, business unit, and APAC levels:
- `account_plan_event_requirements`
- `territory_compliance_summary`
- `business_unit_planning`
- `apac_planning_goals`

These tables need to be populated with compliance data calculated from the segmentation system tables:
- `segmentation_events`
- `segmentation_event_compliance`
- `tier_event_requirements`
- `client_segmentation`

## Solution

Created `/scripts/sync-planning-compliance.mjs` that:

### Data Flow

1. **Reads from Segmentation Tables:**
   - `account_plans` - identifies clients with planning requirements
   - `client_segmentation` - maps clients to tiers and CSEs
   - `tier_event_requirements` - defines required events per tier
   - `segmentation_event_types` - event type metadata
   - `segmentation_events` - completed/scheduled events
   - `segmentation_event_compliance` - existing compliance records
   - `segmentation_tiers` - tier names and levels

2. **Calculates Compliance:**
   - Per client: completed events vs required events per event type
   - Status determination based on thresholds:
     - `critical`: < 50%
     - `at_risk`: 50-79%
     - `compliant`: 80-99%
     - `exceeded`: >= 100%

3. **Writes to Planning Tables:**
   - `account_plan_event_requirements` - per-client, per-event-type compliance
   - `territory_compliance_summary` - aggregated per CSE territory
   - `business_unit_planning` - updates compliance fields
   - `apac_planning_goals` - updates APAC-wide compliance metrics

### Features

- **Dry-run mode:** `--dry-run` flag shows what would be changed without modifying data
- **Fiscal year support:** `--year 2026` flag allows targeting specific fiscal years
- **Detailed logging:** Timestamps, log levels, and progress tracking
- **Error handling:** Graceful handling of missing data and database errors

## Usage

```bash
# Dry run (no changes)
npm run planning:sync:compliance:dry-run

# Live sync for current year
npm run planning:sync:compliance

# Sync for specific fiscal year
node scripts/sync-planning-compliance.mjs --year 2026

# Dry run for specific year
node scripts/sync-planning-compliance.mjs --dry-run --year 2025
```

## Files Changed

| File | Change Type | Description |
|------|-------------|-------------|
| `/scripts/sync-planning-compliance.mjs` | Added | New sync job script |
| `/package.json` | Modified | Added npm scripts `planning:sync:compliance` and `planning:sync:compliance:dry-run` |

## Technical Details

### Source Tables (Read)
- `account_plans`
- `client_segmentation`
- `tier_event_requirements`
- `segmentation_event_types`
- `segmentation_events`
- `segmentation_event_compliance`
- `segmentation_tiers`
- `territory_strategies`
- `business_unit_planning`
- `apac_planning_goals`

### Target Tables (Write)
- `account_plan_event_requirements` (upsert)
- `territory_compliance_summary` (upsert)
- `business_unit_planning` (update compliance fields)
- `apac_planning_goals` (update compliance fields)

### Dependencies
- `@supabase/supabase-js` - Database client
- `dotenv` - Environment variable loading

### Environment Variables Required
- `NEXT_PUBLIC_SUPABASE_URL` - Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY` - Service role key for bypassing RLS

## Testing

1. Run dry-run first to verify data calculations:
   ```bash
   npm run planning:sync:compliance:dry-run
   ```

2. Verify output shows expected number of clients and compliance calculations

3. Run live sync:
   ```bash
   npm run planning:sync:compliance
   ```

4. Verify data in Supabase:
   - Check `account_plan_event_requirements` for per-client records
   - Check `territory_compliance_summary` for territory aggregations
   - Check `business_unit_planning.overall_compliance_percentage`
   - Check `apac_planning_goals.actual_compliance`

## Notes

- The script uses the service role key to bypass RLS policies
- Territory-to-BU mapping is currently hardcoded; may need to be moved to a configuration table
- The script can be run as a scheduled job (e.g., daily via cron) to keep compliance data in sync
