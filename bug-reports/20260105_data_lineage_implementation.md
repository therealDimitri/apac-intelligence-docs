# Bug Report: Data Lineage System Implementation

**Date:** 5 January 2026
**Reporter:** Claude Code
**Status:** RESOLVED
**Severity:** N/A (New Feature Implementation)

## Summary

Implemented comprehensive BURC Data Lineage and Audit Trail System to track data flow from Excel source files to database tables. This addresses the need for variance explanation, data quality validation, and regulatory compliance.

## Issue Description

**Previous State:**
- No traceability from Excel source to database records
- Unable to explain why values changed
- No audit trail for data modifications
- Difficult to validate data quality
- Limited compliance capabilities

**Required State:**
- Complete lineage tracking from source to destination
- Variance explanation ("Why did this value change?")
- Full audit trail with timestamps and user tracking
- Data quality validation capabilities
- Compliance-ready audit logs

## Implementation

### Database Layer

**File:** `docs/migrations/20260105_burc_data_lineage.sql`

**Tables Created:**

1. **burc_data_lineage**
   - Tracks every data change with full source reference
   - Columns: source file/sheet/row/column, target table/id/column, old/new values
   - Indexes for fast queries by table, source file, batch, date
   - RLS policies for security

2. **burc_sync_batches**
   - Tracks sync operations and outcomes
   - Columns: timing, status, statistics, errors, warnings
   - Batch-level aggregation of changes

3. **burc_file_registry**
   - Tracks all BURC files and processing history
   - Columns: file path/hash, processing stats, validation status
   - Change detection via SHA-256 hash

**Helper Functions:**
- `get_record_lineage()` - Get complete change history for a record
- `get_source_cell()` - Get Excel source for a specific field
- `get_batch_stats()` - Get statistics for a sync batch
- `complete_sync_batch()` - Mark batch as complete with duration

### Library Layer

**File:** `src/lib/burc-lineage-tracker.ts`

**Class:** `LineageTracker`

**Key Methods:**
- `startBatch()` - Initialize a new sync batch
- `trackChange()` - Track a single data change
- `flushChanges()` - Batch insert changes to database
- `completeBatch()` - Finalize batch with status
- `queryLineage()` - Query lineage for a record
- `getSourceCell()` - Get source Excel cell for a field
- `getBatch()` / `getBatchStats()` - Get batch details
- `registerFile()` - Register/update file in registry

**Features:**
- Automatic cell reference generation
- Batch operations to minimize database calls
- Error tracking and statistics
- File hash calculation for change detection
- Singleton instance for convenience

### API Layer

**Files:**
- `src/app/api/burc/lineage/route.ts`
- `src/app/api/burc/lineage/batch/[id]/route.ts`
- `src/app/api/burc/lineage/batches/route.ts`

**Endpoints:**

1. **GET /api/burc/lineage**
   - Query lineage for specific record
   - Get change history for table/column
   - Get source cell for field
   - Get all changes in a batch

2. **GET /api/burc/lineage/batch/:id**
   - Get batch details and statistics
   - Returns batch info + aggregated stats

3. **GET /api/burc/lineage/batches**
   - List recent sync batches
   - Supports pagination via limit parameter

### UI Layer

**Components:**

1. **BURCDataLineage** (`src/components/burc/BURCDataLineage.tsx`)
   - Visual representation of data flow
   - Summary statistics (files, fields, last sync)
   - Detailed change table with all modifications
   - Click to see full change details
   - Source file → Database mapping

2. **BURCVarianceExplainer** (`src/components/burc/BURCVarianceExplainer.tsx`)
   - "Why did this value change?" component
   - Shows before/after values
   - Displays source Excel file, sheet, cell reference
   - Timestamp and user who triggered sync
   - Instructions for updating the value
   - Link to complete change history

3. **Admin Page** (`src/app/(dashboard)/admin/data-lineage/page.tsx`)
   - Browse sync batches with filters
   - View batch details and statistics
   - Search records by table/ID
   - Export audit logs to CSV
   - Overview dashboard with metrics

### Integration Scripts

**File:** `scripts/sync-burc-with-lineage-example.mjs`

**Purpose:** Example integration showing how to add lineage tracking to existing sync scripts.

**Pattern:**
```javascript
1. Start batch with context
2. Register file(s) being processed
3. Extract data from Excel
4. For each change:
   - Track with source cell reference
   - Flush periodically
5. Update batch statistics
6. Complete batch with final status
```

### Documentation

**File:** `docs/BURC_DATA_LINEAGE_SYSTEM.md`

**Contents:**
- System architecture overview
- Complete database schema documentation
- Helper functions reference
- Usage examples for sync scripts
- UI components documentation
- API endpoint reference
- Use cases and examples
- Best practices
- Migration guide
- Troubleshooting
- Performance considerations
- Security and RLS policies
- Roadmap for future enhancements

## Testing Performed

### Database Testing

✅ Migration runs successfully
✅ All tables created with correct schema
✅ Indexes created for performance
✅ Helper functions work as expected
✅ RLS policies enforce security
✅ Foreign key constraints valid

### Integration Testing

✅ LineageTracker can start/complete batches
✅ Change tracking works for insert/update/delete
✅ Batch flushing handles large volumes
✅ File registration detects changes via hash
✅ Statistics update correctly
✅ Error handling captures failures

### API Testing

✅ Lineage queries return correct data
✅ Source cell lookups work
✅ Batch details include statistics
✅ Batches list supports pagination
✅ Error responses return appropriate status codes

### UI Testing

✅ BURCDataLineage renders lineage table
✅ BURCVarianceExplainer shows source information
✅ Admin page displays batches and statistics
✅ Search functionality works
✅ Export to CSV generates valid files

## Files Changed

### Created Files

1. **Database Migration:**
   - `/docs/migrations/20260105_burc_data_lineage.sql`

2. **Library:**
   - `/src/lib/burc-lineage-tracker.ts`

3. **API Endpoints:**
   - `/src/app/api/burc/lineage/route.ts`
   - `/src/app/api/burc/lineage/batch/[id]/route.ts`
   - `/src/app/api/burc/lineage/batches/route.ts`

4. **UI Components:**
   - `/src/components/burc/BURCDataLineage.tsx`
   - `/src/components/burc/BURCVarianceExplainer.tsx`

5. **Admin Page:**
   - `/src/app/(dashboard)/admin/data-lineage/page.tsx`

6. **Scripts:**
   - `/scripts/sync-burc-with-lineage-example.mjs`

7. **Documentation:**
   - `/docs/BURC_DATA_LINEAGE_SYSTEM.md`
   - `/docs/bug-reports/20260105_data_lineage_implementation.md` (this file)

### Modified Files

None - This is a new feature implementation with no modifications to existing code.

## Known Limitations

1. **Existing Data:** Lineage tracking only applies to data synced after migration. Historical data has no lineage.

2. **Manual Edits:** Changes made directly in the database (not via sync scripts) are not tracked unless explicitly logged.

3. **File Access:** Requires file system access to calculate hashes and read Excel files.

4. **Performance:** Very large syncs (>100,000 records) should use smaller flush batches (50 instead of 100).

5. **Cell Formulas:** Currently tracks values only, not Excel formulas (planned for Phase 2).

## Migration Steps

To enable lineage tracking in your environment:

### 1. Run Database Migration

```bash
# Using psql
psql $DATABASE_URL < docs/migrations/20260105_burc_data_lineage.sql

# Or using Supabase CLI
supabase db push
```

### 2. Verify Tables Created

```sql
SELECT table_name FROM information_schema.tables
WHERE table_name LIKE 'burc_%';

-- Should return:
-- burc_data_lineage
-- burc_sync_batches
-- burc_file_registry
```

### 3. Update Sync Scripts

Add LineageTracker to your existing sync scripts:

```javascript
import { LineageTracker } from '@/lib/burc-lineage-tracker';

// At start of sync
const tracker = new LineageTracker();
const batchId = await tracker.startBatch({...});

// When making changes
tracker.trackChange({...});

// At end of sync
await tracker.completeBatch('completed');
```

See `scripts/sync-burc-with-lineage-example.mjs` for complete example.

### 4. Add UI Components (Optional)

Add variance explainers to your data displays:

```tsx
<BURCVarianceExplainer
  targetTable="your_table"
  targetId={recordId}
  column="field_name"
  currentValue={current}
  previousValue={previous}
/>
```

### 5. Grant Admin Access

Update admin navigation to include data lineage page at `/admin/data-lineage`.

## Rollback Procedure

If you need to remove the lineage system:

```sql
-- Drop tables (in order to respect foreign keys)
DROP TABLE IF EXISTS burc_data_lineage;
DROP TABLE IF EXISTS burc_sync_batches;
DROP TABLE IF EXISTS burc_file_registry;

-- Drop functions
DROP FUNCTION IF EXISTS get_record_lineage;
DROP FUNCTION IF EXISTS get_source_cell;
DROP FUNCTION IF EXISTS get_batch_stats;
DROP FUNCTION IF EXISTS complete_sync_batch;
DROP FUNCTION IF EXISTS update_updated_at_column;
```

## Future Enhancements

### Phase 2 (Q1 2026)
- Real-time lineage updates via Supabase Realtime
- Data lineage visualisation (flowcharts showing data flow)
- Automated variance alerts when values change unexpectedly
- Machine learning for anomaly detection

### Phase 3 (Q2 2026)
- Multi-file lineage (tracing across multiple Excel files)
- Formula tracking (track Excel formulas, not just values)
- Cell-level conflict resolution
- Time-travel queries ("show me this record as it was on date X")

## Success Metrics

### Functional Requirements Met

✅ Complete traceability from Excel to database
✅ Variance explanation capability
✅ Full audit trail with timestamps
✅ Data quality validation support
✅ Compliance-ready audit logs

### Non-Functional Requirements Met

✅ Performance: Handles large syncs with batch flushing
✅ Security: RLS policies enforce access control
✅ Usability: Clear UI components and admin interface
✅ Maintainability: Well-documented with examples
✅ Scalability: Indexed for fast queries

## Support

For questions or issues:
1. Review documentation: `docs/BURC_DATA_LINEAGE_SYSTEM.md`
2. Check example script: `scripts/sync-burc-with-lineage-example.mjs`
3. View admin page: `/admin/data-lineage`
4. Review recent batches for error messages

## Related Issues

- None (initial implementation)

## Sign-Off

**Implemented by:** Claude Code
**Reviewed by:** Pending
**Approved by:** Pending
**Date Completed:** 5 January 2026

## Appendix: Example Queries

### Find all changes to a specific record

```sql
SELECT * FROM burc_data_lineage
WHERE target_table = 'actions'
  AND target_id = 'record-uuid'
ORDER BY synced_at DESC;
```

### Find source of current value

```sql
SELECT source_file, source_sheet, source_cell_reference, new_value
FROM burc_data_lineage
WHERE target_table = 'actions'
  AND target_id = 'record-uuid'
  AND target_column = 'Status'
ORDER BY synced_at DESC
LIMIT 1;
```

### Get batch summary

```sql
SELECT
  id,
  status,
  files_processed,
  records_inserted + records_updated + records_deleted as total_changes,
  duration_ms,
  started_at
FROM burc_sync_batches
ORDER BY started_at DESC
LIMIT 10;
```

### Find failed syncs

```sql
SELECT
  id,
  started_at,
  errors,
  source_files
FROM burc_sync_batches
WHERE status = 'failed'
ORDER BY started_at DESC;
```

### Track file processing history

```sql
SELECT
  file_name,
  total_syncs,
  total_changes_made,
  last_processed_at,
  last_sync_status
FROM burc_file_registry
ORDER BY last_processed_at DESC;
```
