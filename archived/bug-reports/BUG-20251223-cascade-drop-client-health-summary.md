# Bug Report: CASCADE Drop Removed client_health_summary

**Date:** 2025-12-23
**Severity:** Critical
**Status:** ✅ RESOLVED

## Summary

When updating `event_compliance_summary` to add client_id support, using `DROP ... CASCADE` also removed the dependent `client_health_summary` materialized view, causing the application to fail with "Could not find the table 'public.client_health_summary' in the schema cache".

## Root Cause

The `event_compliance_summary` view was dropped with CASCADE to add client_id support:

```sql
DROP MATERIALIZED VIEW IF EXISTS event_compliance_summary CASCADE;
```

The `client_health_summary` view has a LATERAL JOIN dependency on `event_compliance_summary` for compliance metrics, so CASCADE removed it as well.

## Impact

- All client list pages failed to load
- Health scores were unavailable
- Users received error: "Failed to fetch clients from materialized view"

## Resolution

1. Recreated `client_health_summary` view with proper SQL
2. Created `safe_parse_date()` function to handle mixed date formats in `actions.Due_Date`:
   - ISO format (YYYY-MM-DD)
   - Australian format (DD/MM/YYYY)
   - Partial format (D/MM/YYYY)
   - Invalid text (returns NULL)

3. All indexes and permissions restored

## Verification

```
client_health_summary: 18 clients
event_compliance_summary: 18 records
```

## Prevention

When modifying materialized views with CASCADE:

1. Check for dependent views first
2. Document all dependent views that need recreation
3. Test in development environment first

## Files Modified

- `scripts/apply-event-compliance-client-id.mjs` - Should check for dependents
- Added `safe_parse_date()` function to database
