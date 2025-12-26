# Bug Report: Composite Indexes Migration - Wrong Table/Column Names

**Date**: 2025-12-02
**Severity**: Critical (Blocks Phase 1 Deployment)
**Status**: Fixed
**Commit**: `a715bfb`

---

## Summary

The composite indexes migration (`20251202_add_composite_indexes.sql`) contained incorrect table and column names, causing SQL execution errors when attempting to deploy to Supabase.

---

## Error Message

```
ERROR: 42703: column "status" does not exist
```

This error was misleading - the actual issue was that the migration referenced non-existent tables (`events`, `meetings`) instead of the correct table names (`segmentation_events`, `unified_meetings`).

---

## Root Cause

The migration was written with incorrect assumptions about table and column names:

1. **Wrong table name**: `events` instead of `segmentation_events`
2. **Wrong table name**: `meetings` instead of `unified_meetings`
3. **Wrong column name**: `meetings.client` instead of `unified_meetings.client_name`
4. **Wrong column reference**: `events.segment` (doesn't exist on segmentation_events table)

---

## Impact

- **Deployment Blocked**: Phase 1 composite indexes could not be deployed to production
- **Performance Degradation**: Without these indexes, filtered queries remain slow (1.2s+ vs target <0.3s)
- **Phase 2 Dependency**: Phase 2 materialized views depend on Phase 1 indexes for optimal performance

---

## Detailed Analysis

### Incorrect Code (Before Fix)

```sql
-- Index 4: WRONG TABLE NAME
CREATE INDEX IF NOT EXISTS idx_events_client_date
ON events(client_name, event_date);  -- ❌ Table "events" doesn't exist

-- Index 5: WRONG TABLE NAME + COLUMN
CREATE INDEX IF NOT EXISTS idx_events_segment_type
ON events(segment, event_type_id);  -- ❌ No "segment" column on segmentation_events

-- Index 6: WRONG TABLE NAME + COLUMN
CREATE INDEX IF NOT EXISTS idx_meetings_client_date
ON meetings(client, meeting_date);  -- ❌ Table "meetings" doesn't exist, should be "client_name"
```

### Correct Code (After Fix)

```sql
-- Index 4: CORRECT TABLE NAME
CREATE INDEX IF NOT EXISTS idx_events_client_date
ON segmentation_events(client_name, event_date);  -- ✅ Correct table

-- Index 5: CORRECT TABLE + BETTER COLUMN CHOICE
CREATE INDEX IF NOT EXISTS idx_events_client_type
ON segmentation_events(client_name, event_type_id);  -- ✅ Changed to client_name (more useful)

-- Index 6: CORRECT TABLE + COLUMN
CREATE INDEX IF NOT EXISTS idx_meetings_client_date
ON unified_meetings(client_name, meeting_date);  -- ✅ Correct table and column
```

---

## Investigation Steps

1. **Error Reported**: User reported "ERROR: 42703: column 'status' does not exist"
2. **Read Migration**: Examined `docs/migrations/20251202_add_composite_indexes.sql`
3. **Verified Table Names**:
   - Searched codebase for `from('segmentation_events')` - found in `src/hooks/useEvents.ts`
   - Searched for `from('unified_meetings')` - found in `src/app/api/meetings/`
4. **Checked Column Names**:
   - Read `src/hooks/useEvents.ts` - confirmed `client_name`, `event_date`, `event_type_id` columns
   - Read `src/hooks/useMeetings.ts` - confirmed `client_name` (not `client`), `meeting_date` columns
   - Read `src/hooks/useActions.ts` - confirmed `Status` column exists (capital S)
5. **Applied Fixes**: Updated migration with correct table/column names

---

## Fix Applied

### Changes Made

1. **Index 4 (Events - Client + Date)**:
   - `ON events(...)` → `ON segmentation_events(...)`

2. **Index 5 (Events - Client + Type)**:
   - `ON events(segment, event_type_id)` → `ON segmentation_events(client_name, event_type_id)`
   - Renamed index: `idx_events_segment_type` → `idx_events_client_type`
   - **Rationale**: `segment` column doesn't exist on `segmentation_events` table. Using `client_name` is more useful for compliance queries that filter by client and event type.

3. **Index 6 (Meetings - Client + Date)**:
   - `ON meetings(client, ...)` → `ON unified_meetings(client_name, ...)`

### Files Modified

- `docs/migrations/20251202_add_composite_indexes.sql`

---

## Verification

### Before Fix
```sql
-- Attempting to run migration
CREATE INDEX IF NOT EXISTS idx_events_client_date ON events(client_name, event_date);
-- ERROR: relation "events" does not exist
```

### After Fix
```sql
-- Migration should now execute successfully
CREATE INDEX IF NOT EXISTS idx_events_client_date ON segmentation_events(client_name, event_date);
-- ✅ Index created successfully
```

### Testing Plan

1. Deploy fixed migration to Supabase SQL Editor
2. Verify all 6 indexes created:
   ```sql
   SELECT indexname, tablename, indexdef
   FROM pg_indexes
   WHERE schemaname = 'public'
     AND indexname LIKE 'idx_%'
   ORDER BY tablename, indexname;
   ```
3. Expected output: 6 rows showing all composite indexes
4. Test query performance with indexes:
   ```sql
   EXPLAIN ANALYZE
   SELECT * FROM actions WHERE "Client" = 'SA Health' AND "Status" = 'open';
   -- Should use Index Scan on idx_actions_client_status
   ```

---

## Lessons Learned

1. **Verify Schema First**: Always check actual table/column names in codebase before writing migrations
2. **Use Case-Sensitive Names**: PostgreSQL is case-sensitive with quoted identifiers (e.g., `"Status"` vs `status`)
3. **Test Migrations Locally**: Should have tested migration in development Supabase instance first
4. **Better Error Messages**: PostgreSQL error "column 'status' does not exist" was misleading - actual issue was table name
5. **Documentation**: Should maintain schema documentation (e.g., `docs/SCHEMA.md`) with table/column reference

---

## Related Issues

- Phase 1 Task 1: Deploy composite indexes migration
- Phase 2 materialized views depend on these indexes for optimal performance
- Foreign key relationships (Phase 2) also reference these tables

---

## Prevention

To prevent similar issues in future:

1. **Schema Documentation**: Create `docs/SCHEMA.md` with authoritative table/column reference
2. **Migration Template**: Create template with verification queries to check table/column existence
3. **Pre-Deployment Checks**: Add script to validate migrations before deployment:
   ```sql
   -- Check if table exists
   SELECT EXISTS (
     SELECT FROM information_schema.tables
     WHERE table_name = 'your_table_name'
   );

   -- Check if column exists
   SELECT EXISTS (
     SELECT FROM information_schema.columns
     WHERE table_name = 'your_table' AND column_name = 'your_column'
   );
   ```
4. **Development Testing**: Always test migrations in development Supabase instance first

---

## Additional Notes

### Why "segment" Index Was Changed

The original index `idx_events_segment_type` attempted to create an index on:
```sql
ON events(segment, event_type_id)
```

However:
- The table name should be `segmentation_events` (not `events`)
- There is no `segment` column directly on `segmentation_events`
- The `segment` value comes from joining with `nps_clients` table

**Better Alternative**: Index on `(client_name, event_type_id)` is more useful because:
- Compliance queries filter by `client_name` and `event_type_id`
- Example: "Get all QBR events for SA Health"
- This matches the actual query pattern in `useEventCompliance.ts`

---

## Status

**Fixed**: ✅
**Deployed**: Pending (awaiting Supabase deployment)
**Verified**: Pending (requires deployment + testing)

---

## References

- Migration File: `docs/migrations/20251202_add_composite_indexes.sql`
- Commit: `a715bfb` (Fix: Correct table and column names in composite indexes migration)
- Related Files:
  - `src/hooks/useEvents.ts` (segmentation_events usage)
  - `src/hooks/useMeetings.ts` (unified_meetings usage)
  - `src/hooks/useActions.ts` (actions table usage)
