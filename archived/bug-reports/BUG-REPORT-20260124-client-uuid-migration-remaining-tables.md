# Bug Report: Missing client_uuid Foreign Keys in Remaining Tables

**Date**: 2026-01-24
**Type**: Enhancement / Data Integrity
**Status**: Resolved

## Summary

Several tables in the database were still using string-based `client_name` matching instead of UUID-based foreign key relationships. This created inconsistent data access patterns and made it difficult to maintain referential integrity across the system.

## Tables Affected

### Tables that needed client_uuid added (NEW migration):
| Table | Current State | Action Taken |
|-------|---------------|--------------|
| `client_health_history` | Had `client_id` (TEXT) | Added `client_uuid` (UUID) with FK to clients |
| `portfolio_initiatives` | Had `client_id` (TEXT) | Added `client_uuid` (UUID) with FK to clients |
| `health_status_alerts` | Had `client_id` (TEXT) | Added `client_uuid` (UUID) with FK to clients |

### Tables already having client_uuid (verified):
| Table | Status |
|-------|--------|
| `client_segmentation` | Has `client_uuid` |
| `aging_accounts` | Has `client_uuid` |
| `nps_responses` | Has `client_uuid` |
| `unified_meetings` | Has `client_uuid` |
| `actions` | Has `client_uuid` |

## Root Cause

The original client unification migration (`03_backfill_client_ids.sql`) added `client_id` (UUID) columns to some tables, but the migration may not have been fully applied or the columns were typed as TEXT in some cases. The database schema audit revealed inconsistencies.

## Solution

Created migration `20260124_add_client_uuid_to_remaining_tables.sql` which:

1. **Adds client_uuid columns** to tables missing proper UUID foreign keys
2. **Creates indexes** for efficient querying on the new columns
3. **Backfills data** using the `client_name_aliases` table for alias resolution:
   - Direct match on canonical_name (case-insensitive)
   - Fallback to alias lookup via client_name_aliases
4. **Creates triggers** for auto-population on INSERT/UPDATE
5. **Updates monitoring view** (`client_uuid_backfill_status`) to track coverage
6. **Logs unresolved names** to `client_unresolved_names` table for review

## Migration File

**Location**: `/supabase/migrations/20260124_add_client_uuid_to_remaining_tables.sql`

### Key Components:

```sql
-- Add columns with FK reference
ALTER TABLE client_health_history
ADD COLUMN IF NOT EXISTS client_uuid UUID REFERENCES clients(id);

-- Backfill using alias resolution
UPDATE client_health_history chh
SET client_uuid = c.id
FROM clients c
WHERE chh.client_uuid IS NULL
  AND chh.client_name IS NOT NULL
  AND (
    LOWER(TRIM(c.canonical_name)) = LOWER(TRIM(chh.client_name))
    OR EXISTS (
      SELECT 1 FROM client_name_aliases cna
      WHERE LOWER(TRIM(cna.canonical_name)) = LOWER(TRIM(c.canonical_name))
      AND LOWER(TRIM(cna.display_name)) = LOWER(TRIM(chh.client_name))
    )
  );

-- Auto-populate trigger for future inserts
CREATE TRIGGER trigger_client_health_history_resolve_uuid
  BEFORE INSERT OR UPDATE ON client_health_history
  FOR EACH ROW
  EXECUTE FUNCTION resolve_client_uuid_from_name();
```

## Verification

After running the migration, verify coverage with:

```sql
SELECT * FROM client_uuid_backfill_status;
```

Check for unresolved client names:

```sql
SELECT * FROM client_unresolved_names WHERE resolved = false ORDER BY source_table, original_name;
```

## Dependencies

- `clients` table with `id` (UUID) and `canonical_name` columns
- `client_name_aliases` table with `canonical_name` and `display_name` columns
- `resolve_client_id()` function (optional, triggers have fallback logic)
- `client_unresolved_names` table for logging

## Testing Checklist

- [x] Migration file created in correct location
- [x] Build passes with no TypeScript errors
- [ ] Migration applied to database (manual step)
- [ ] Verify backfill coverage with monitoring view
- [ ] Review any unresolved client names

## Notes

This migration re-backfills existing tables with `client_uuid` columns (client_segmentation, aging_accounts, nps_responses) in case any NULL values remain from previous incomplete runs. This is safe as it only updates rows where `client_uuid IS NULL`.
