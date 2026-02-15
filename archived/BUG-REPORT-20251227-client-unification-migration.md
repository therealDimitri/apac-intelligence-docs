# Bug Report: Client Unification Migration - UUID Type Mismatch

**Date:** 2025-12-27
**Status:** Resolved
**Severity:** Critical
**Component:** Database Migration

## Summary

The client unification migration (Phase 3) failed due to a type mismatch between existing INTEGER `client_id` columns and the new UUID-returning `resolve_client_id()` function.

## Root Cause

Several legacy tables had `client_id` columns defined as INTEGER type:
- `unified_meetings.client_id` - INTEGER
- `actions.client_id` - INTEGER
- `aging_accounts.client_id` - INTEGER
- `nps_responses.client_id` - INTEGER
- `client_segmentation.client_id` - VARCHAR

The migration attempted to set these INTEGER columns with UUID values returned by `resolve_client_id()`, causing the error:
```
column "client_id" is of type integer but expression is of type uuid
```

## Solution Applied

Instead of altering the existing INTEGER columns (which would break existing queries), we added new `client_uuid` UUID columns to the affected tables:

1. **Added `client_uuid` UUID columns** to:
   - `unified_meetings`
   - `actions`
   - `aging_accounts`
   - `nps_responses`
   - `client_segmentation`

2. **Created indexes** on the new `client_uuid` columns for query performance

3. **Backfilled data** using `resolve_client_id()` to populate `client_uuid`

4. **Updated triggers** to use `auto_resolve_client_uuid()` for these tables

5. **Updated monitoring views** to track `client_uuid` instead of `client_id`

## Migration Results

| Table | Total Rows | With client_uuid | Coverage |
|-------|------------|------------------|----------|
| unified_meetings | 135 | 99 | 73% |
| actions | 90 | 79 | 88% |
| client_segmentation | 26 | 26 | 100% |
| aging_accounts | 20 | 20 | 100% |
| nps_responses | 199 | 199 | 100% |
| portfolio_initiatives | 6 | 6 | 100% |
| client_health_history | 540 | 540 | 100% |

**Note:** `unified_meetings` and `actions` have lower coverage due to internal/meta entries that don't represent client meetings (e.g., "Internal Meeting", "All Clients", "Team Management"). These are correctly NULL and have been marked as resolved in `client_unresolved_names`.

## Database Objects Created

### Tables
- `clients` - Master client table with 32 clients
- `client_aliases_unified` - Alias lookup table with 77 aliases
- `client_unresolved_names` - Log of names that couldn't be resolved

### Functions
- `resolve_client_id(TEXT)` - Resolves client name to UUID
- `get_canonical_client_name(UUID)` - Gets canonical name from UUID
- `add_client_alias(TEXT, TEXT, TEXT, TEXT)` - Adds new alias
- `auto_resolve_client_uuid()` - Trigger function for legacy tables
- `auto_resolve_client_id()` - Trigger function for new tables

### Views
- `clients_with_aliases` - Client details with all aliases
- `client_summary` - Dashboard summary with counts
- `client_id_backfill_status` - Migration status monitoring

### Triggers
- `trigger_auto_resolve_client_uuid` on: unified_meetings, actions, aging_accounts, nps_responses, client_segmentation
- `trigger_auto_resolve_client_id` on: portfolio_initiatives, client_health_history, health_status_alerts, chasen_folders, chasen_conversations

## Migration Files

Located in `docs/migrations/client-unification/`:
1. `01_create_master_clients_table.sql` - Creates schema
2. `02_populate_clients_data.sql` - Populates clients and aliases
3. `03_backfill_client_ids.sql` - Backfills client_uuid columns
4. `04_add_constraints_and_cleanup.sql` - Adds triggers and views

## Future Considerations

1. **Update Application Code**: Queries should be updated to use `client_uuid` instead of relying on string matching
2. **Consider Column Rename**: In a future migration, consider:
   - Dropping legacy INTEGER `client_id` columns
   - Renaming `client_uuid` to `client_id`
3. **Monitoring**: Use `client_id_backfill_status` view to monitor coverage

## Prevention

Before running migrations that add foreign keys:
1. Check existing column types using `\d table_name` in psql
2. Use `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` for idempotency
3. Consider backward compatibility with existing queries

## Lessons Learned

1. Legacy tables often have inconsistent column types
2. Adding new columns is safer than altering existing ones
3. Use `ON CONFLICT DO NOTHING` for idempotent alias inserts
4. Mark non-client entries as "resolved" to avoid false positives in reporting
