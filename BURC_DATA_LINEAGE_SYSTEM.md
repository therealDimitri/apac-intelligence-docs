# BURC Data Lineage and Audit Trail System

## Overview

The BURC Data Lineage system provides complete traceability from Excel source files to database records. Every change is tracked with full audit trail, enabling variance explanation, data quality validation, and regulatory compliance.

## Architecture

### Components

1. **Database Layer** (`docs/migrations/20260105_burc_data_lineage.sql`)
   - `burc_data_lineage` - Complete audit trail of all changes
   - `burc_sync_batches` - Sync operation tracking
   - `burc_file_registry` - File processing history

2. **Library Layer** (`src/lib/burc-lineage-tracker.ts`)
   - `LineageTracker` class - Core tracking functionality
   - Helper functions for querying lineage data

3. **API Layer** (`src/app/api/burc/lineage/`)
   - `/api/burc/lineage` - Query lineage for records
   - `/api/burc/lineage/batch/:id` - Batch details and statistics
   - `/api/burc/lineage/batches` - List recent batches

4. **UI Layer**
   - `BURCDataLineage` - Visual lineage representation
   - `BURCVarianceExplainer` - "Why did this change?" component
   - Admin page - Browse batches and search records

## Database Schema

### burc_data_lineage

Tracks every data change with complete source reference.

```sql
CREATE TABLE burc_data_lineage (
  id UUID PRIMARY KEY,

  -- Source (Excel)
  source_file VARCHAR(500),
  source_sheet VARCHAR(100),
  source_row INTEGER,
  source_column VARCHAR(50),
  source_cell_reference VARCHAR(20),  -- e.g., "A5" or "Priority Matrix!B10"

  -- Target (Database)
  target_table VARCHAR(100),
  target_id UUID,
  target_column VARCHAR(100),

  -- Change Details
  old_value TEXT,
  new_value TEXT,
  change_type VARCHAR(20),  -- insert, update, delete

  -- Sync Context
  sync_batch_id UUID,
  synced_at TIMESTAMPTZ,
  synced_by VARCHAR(100),

  -- Validation
  validation_status VARCHAR(20),  -- valid, warning, error
  validation_message TEXT,
  metadata JSONB
);
```

**Indexes:**
- `idx_lineage_target` - Fast lookup by table/ID
- `idx_lineage_source_file` - Fast lookup by source file
- `idx_lineage_batch` - Fast lookup by batch
- `idx_lineage_synced_at` - Temporal queries
- `idx_lineage_metadata` - JSONB queries

### burc_sync_batches

Tracks sync operations and their outcomes.

```sql
CREATE TABLE burc_sync_batches (
  id UUID PRIMARY KEY,

  -- Timing
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  duration_ms INTEGER,

  -- Status
  status VARCHAR(20),  -- running, completed, failed, partial

  -- Statistics
  files_processed INTEGER,
  records_inserted INTEGER,
  records_updated INTEGER,
  records_deleted INTEGER,
  records_skipped INTEGER,
  records_failed INTEGER,

  -- Error Tracking
  errors JSONB,
  warnings JSONB,

  -- Context
  triggered_by VARCHAR(100),
  sync_type VARCHAR(50),
  source_files JSONB,
  config JSONB
);
```

### burc_file_registry

Tracks all BURC files and their processing history.

```sql
CREATE TABLE burc_file_registry (
  id UUID PRIMARY KEY,

  -- File Information
  file_path VARCHAR(500) UNIQUE,
  file_name VARCHAR(255),
  file_type VARCHAR(50),

  -- File Metadata
  file_size BIGINT,
  file_hash VARCHAR(64),  -- SHA-256 for change detection
  last_modified TIMESTAMPTZ,

  -- Processing History
  first_processed_at TIMESTAMPTZ,
  last_processed_at TIMESTAMPTZ,
  total_syncs INTEGER,
  last_sync_batch_id UUID,
  last_sync_status VARCHAR(20),

  -- Validation
  is_valid BOOLEAN,
  validation_errors JSONB,

  -- Statistics
  total_rows_processed INTEGER,
  total_changes_made INTEGER
);
```

## Helper Functions

### get_record_lineage

Get complete change history for a record.

```sql
SELECT * FROM get_record_lineage(
  p_table_name := 'actions',
  p_record_id := 'uuid-here'
);
```

Returns: All changes to the record, ordered by date.

### get_source_cell

Get the Excel source for a specific field.

```sql
SELECT * FROM get_source_cell(
  p_table_name := 'actions',
  p_record_id := 'uuid-here',
  p_column_name := 'Status'
);
```

Returns: Source file, sheet, cell reference, and current value.

### get_batch_stats

Get statistics for a sync batch.

```sql
SELECT * FROM get_batch_stats(p_batch_id := 'uuid-here');
```

Returns: Total changes, breakdown by table and change type, error counts.

## Usage

### In Sync Scripts

```javascript
import { LineageTracker } from '@/lib/burc-lineage-tracker';

async function syncData() {
  const tracker = new LineageTracker();

  try {
    // 1. Start batch
    const batchId = await tracker.startBatch({
      triggeredBy: 'sync-script',
      syncType: 'manual',
      sourceFiles: ['/path/to/file.xlsx']
    });

    // 2. Register file
    await tracker.registerFile({
      filePath: '/path/to/file.xlsx',
      fileName: 'file.xlsx',
      fileType: 'burc_monthly',
      fileSize: 1024000,
      fileHash: 'sha256-hash'
    });

    // 3. Process data and track changes
    for (const row of data) {
      // Your insert/update logic here...
      const result = await insertOrUpdate(row);

      // Track the change
      tracker.trackChange({
        sourceFile: '/path/to/file.xlsx',
        sourceSheet: 'Summary',
        sourceRow: row.rowNumber,
        sourceColumn: 'B',
        targetTable: 'burc_ebita_monthly',
        targetId: result.id,
        targetColumn: 'target_ebita',
        oldValue: row.oldValue,
        newValue: row.newValue,
        changeType: row.isNew ? 'insert' : 'update'
      });

      // Flush periodically
      if (tracker.changes.length >= 100) {
        await tracker.flushChanges();
      }
    }

    // 4. Update statistics
    tracker.stats.filesProcessed++;
    await tracker.updateBatchStats();

    // 5. Complete batch
    await tracker.completeBatch('completed');

  } catch (error) {
    tracker.addError({ message: error.message });
    await tracker.completeBatch('failed');
  }
}
```

### Querying Lineage

#### Get lineage for a record

```typescript
const tracker = getLineageTracker();

const lineage = await tracker.queryLineage('actions', 'record-uuid');
// Returns: Array of all changes to this record
```

#### Get source cell for a field

```typescript
const sourceCell = await tracker.getSourceCell(
  'actions',
  'record-uuid',
  'Status'
);

console.log(`Value comes from ${sourceCell.sourceFile}`);
console.log(`Sheet: ${sourceCell.sourceSheet}`);
console.log(`Cell: ${sourceCell.sourceCell}`);
```

#### Get batch details

```typescript
const batch = await tracker.getBatch('batch-uuid');
const stats = await tracker.getBatchStats('batch-uuid');

console.log(`Batch processed ${batch.filesProcessed} files`);
console.log(`Total changes: ${stats.totalChanges}`);
console.log(`By table:`, stats.byTable);
```

## UI Components

### BURCDataLineage

Shows complete audit trail for a record.

```tsx
import { BURCDataLineage } from '@/components/burc/BURCDataLineage';

<BURCDataLineage
  targetTable="actions"
  targetId="record-uuid"
  title="Action Lineage"
  description="Complete change history"
/>
```

Features:
- Summary statistics (files, fields, last sync)
- Detailed change table with filters
- Source file → Database mapping
- Click to see full change details

### BURCVarianceExplainer

Explains why a value changed.

```tsx
import { BURCVarianceExplainer } from '@/components/burc/BURCVarianceExplainer';

<BURCVarianceExplainer
  targetTable="actions"
  targetId="record-uuid"
  column="Status"
  currentValue="Completed"
  previousValue="In Progress"
  label="Action Status"
/>
```

Features:
- Before/after values
- Source Excel file, sheet, cell reference
- Timestamp and user
- Instructions for updating the value
- Link to full lineage

## Admin Page

Access: `/admin/data-lineage`

### Sync Batches Tab

- Browse recent sync operations
- Filter by status (completed, failed, partial, running)
- View batch statistics
- Export batch data to CSV

### Search Records Tab

- Search for lineage by table and record ID
- View complete change history
- Drill down into specific changes

### Overview Tab

- Total batches processed
- Success/failure rates
- Recent activity timeline

## API Endpoints

### GET /api/burc/lineage

Query lineage data.

**Parameters:**
- `table` - Target table name
- `id` - Record ID
- `column` - Column name (optional)
- `batchId` - Batch ID (optional)
- `source=true` - Get source cell only

**Examples:**

```bash
# Get lineage for a record
GET /api/burc/lineage?table=actions&id=uuid

# Get source cell for a field
GET /api/burc/lineage?table=actions&id=uuid&column=Status&source=true

# Get changes in a batch
GET /api/burc/lineage?batchId=uuid

# Get change history for table/column
GET /api/burc/lineage?table=actions&column=Status&limit=100
```

### GET /api/burc/lineage/batch/:id

Get batch details and statistics.

**Response:**
```json
{
  "success": true,
  "data": {
    "batch": {
      "id": "uuid",
      "status": "completed",
      "filesProcessed": 3,
      "recordsInserted": 150,
      "recordsUpdated": 75,
      ...
    },
    "stats": {
      "totalChanges": 225,
      "byTable": {
        "actions": 100,
        "burc_ebita_monthly": 125
      },
      "byChangeType": {
        "insert": 150,
        "update": 75
      },
      "errorCount": 0,
      "warningCount": 2
    }
  }
}
```

### GET /api/burc/lineage/batches

Get recent sync batches.

**Parameters:**
- `limit` - Number of batches to return (default: 20)

## Use Cases

### 1. Variance Explanation

**Question:** "Why did the EBITA target change from $500k to $550k?"

**Answer:**
1. Query lineage for the EBITA record
2. Find the change to `target_ebita` column
3. Show: File "2026 APAC Performance.xlsx", Sheet "Summary", Cell "B5"
4. Changed on: 2026-01-05 at 14:30
5. Changed by: sync-burc-monthly.mjs

### 2. Data Quality Validation

**Question:** "Is this value from the correct Excel file?"

**Answer:**
1. Query source cell for the field
2. Verify source file path matches expected location
3. Check file hash to confirm file hasn't changed unexpectedly
4. Validate cell reference matches documented mapping

### 3. Audit Trail

**Question:** "Show me all changes to this client's data in the last month"

**Answer:**
1. Query lineage filtered by client_uuid and date range
2. Group by table and column
3. Show chronological timeline of changes
4. Export to CSV for audit report

### 4. Error Investigation

**Question:** "Why did the sync fail?"

**Answer:**
1. Query batch by ID
2. Review errors array in batch record
3. Check which files/rows caused failures
4. Examine validation_status and validation_message in lineage records

## Best Practices

### 1. Always Track Changes

Track every insert, update, and delete operation.

```javascript
// Bad: No lineage tracking
await db.query('INSERT INTO ...');

// Good: Track the change
const result = await db.query('INSERT INTO ... RETURNING id');
tracker.trackChange({
  sourceFile: filePath,
  sourceSheet: sheetName,
  sourceRow: rowNum,
  sourceColumn: 'A',
  targetTable: 'table_name',
  targetId: result.rows[0].id,
  targetColumn: 'column_name',
  oldValue: null,
  newValue: value,
  changeType: 'insert'
});
```

### 2. Flush Periodically

Avoid memory issues by flushing changes regularly.

```javascript
if (tracker.changes.length >= 100) {
  await tracker.flushChanges();
}
```

### 3. Register Files

Always register files in the registry for change detection.

```javascript
await tracker.registerFile({
  filePath: fullPath,
  fileName: path.basename(fullPath),
  fileType: 'burc_monthly',
  fileSize: stats.size,
  fileHash: calculateHash(fullPath)
});
```

### 4. Handle Errors

Add errors to batch for visibility.

```javascript
try {
  // Sync logic...
} catch (error) {
  tracker.addError({
    type: 'sync_error',
    message: error.message,
    file: filePath,
    row: rowNum
  });
  await tracker.completeBatch('failed');
}
```

### 5. Provide Metadata

Include additional context in metadata field.

```javascript
tracker.trackChange({
  // ... other fields ...
  metadata: {
    formula: cell.f,  // Excel formula
    format: cell.z,   // Cell format
    comment: cell.c   // Cell comment
  }
});
```

## Migration Guide

### Step 1: Run Migration

```bash
# Apply the migration
psql $DATABASE_URL < docs/migrations/20260105_burc_data_lineage.sql
```

### Step 2: Update Sync Scripts

Add LineageTracker to your existing sync scripts:

```javascript
// Before
async function syncData() {
  const data = extractFromExcel();
  await insertToDatabase(data);
}

// After
async function syncData() {
  const tracker = new LineageTracker();
  const batchId = await tracker.startBatch({...});

  const data = extractFromExcel();

  for (const row of data) {
    const result = await insertToDatabase(row);
    tracker.trackChange({...});  // Track the change
  }

  await tracker.completeBatch('completed');
}
```

### Step 3: Update UI

Add variance explanation to data displays:

```tsx
<BURCVarianceExplainer
  targetTable="your_table"
  targetId={recordId}
  column="your_column"
  currentValue={currentValue}
  previousValue={previousValue}
/>
```

## Troubleshooting

### Issue: "No active batch" error

**Cause:** Trying to track changes without starting a batch.

**Solution:** Always call `startBatch()` before tracking changes.

### Issue: "Failed to insert lineage records"

**Cause:** Database constraints or RLS policies blocking insert.

**Solution:** Ensure using service role key, not anon key.

### Issue: No lineage data showing

**Cause:** RLS policies blocking read access.

**Solution:** Use authenticated user or service role to query data.

### Issue: Batch stuck in "running" status

**Cause:** Script crashed before calling `completeBatch()`.

**Solution:** Always use try/finally to ensure completion:

```javascript
try {
  // Sync logic...
} finally {
  if (tracker.currentBatchId) {
    await tracker.completeBatch('failed');
  }
}
```

## Performance Considerations

### Batch Size

- Flush changes every 100 records to balance memory and database calls
- For large syncs (>10,000 records), flush every 50 records

### Indexes

All critical indexes are created by migration:
- Target table/ID lookup
- Source file/sheet lookup
- Batch ID lookup
- Temporal queries

### Query Optimisation

Use specific queries instead of loading all lineage:

```javascript
// Bad: Load all lineage
const allLineage = await tracker.queryLineage(table, id);
const sourceCell = allLineage.find(r => r.targetColumn === column);

// Good: Query specific cell
const sourceCell = await tracker.getSourceCell(table, id, column);
```

## Security

### RLS Policies

- **Authenticated users**: Read-only access to all lineage data
- **Service role**: Full read/write access for sync scripts
- **Anonymous users**: No access

### Data Privacy

Lineage data may contain sensitive information:
- Restrict admin page access to authorised users
- Consider data retention policies
- Implement export restrictions for sensitive tables

## Roadmap

### Phase 2 Enhancements

- [ ] Real-time lineage updates via Supabase Realtime
- [ ] Data lineage visualisation (flowcharts)
- [ ] Automated variance alerts
- [ ] Machine learning for anomaly detection
- [ ] Integration with approval workflows
- [ ] Time-travel queries ("show me this record as it was on date X")

### Phase 3 Enhancements

- [ ] Multi-file lineage (tracing across multiple Excel files)
- [ ] Formula tracking (track Excel formulas, not just values)
- [ ] Cell-level conflict resolution
- [ ] Lineage API for external systems
- [ ] Data lineage export to data catalogue

## Support

For questions or issues:
1. Check this documentation
2. Review example script: `scripts/sync-burc-with-lineage-example.mjs`
3. Check admin page: `/admin/data-lineage`
4. Review recent batches for error messages

## Related Documentation

- [Database Schema](./database-schema.md)
- [BURC Sync Scripts](../scripts/README.md)
- [Database Standards](./DATABASE_STANDARDS.md)
