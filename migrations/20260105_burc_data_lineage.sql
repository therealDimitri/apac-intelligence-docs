-- ============================================================================
-- BURC Data Lineage and Audit Trail System
-- ============================================================================
-- Date: 5 January 2026
-- Purpose: Track complete data flow from Excel source to database tables
-- Related: BURC sync system, data quality, audit requirements
-- ============================================================================

-- ============================================================================
-- 1. BURC Data Lineage Table
-- ============================================================================
-- Tracks every data change with full source reference back to Excel

CREATE TABLE IF NOT EXISTS burc_data_lineage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Source Information (Excel file details)
  source_file VARCHAR(500) NOT NULL,           -- Full path or name of Excel file
  source_sheet VARCHAR(100) NOT NULL,          -- Worksheet name
  source_row INTEGER NOT NULL,                 -- Row number in Excel (1-based)
  source_column VARCHAR(50) NOT NULL,          -- Column name or letter (e.g., 'A' or 'Client')
  source_cell_reference VARCHAR(20),           -- Full cell reference (e.g., 'A5')

  -- Target Information (Database details)
  target_table VARCHAR(100) NOT NULL,          -- Database table name
  target_id UUID,                              -- ID of affected record (if available)
  target_column VARCHAR(100) NOT NULL,         -- Database column name

  -- Change Details
  old_value TEXT,                              -- Previous value (NULL for inserts)
  new_value TEXT,                              -- New value (NULL for deletes)
  change_type VARCHAR(20) NOT NULL,            -- insert, update, delete

  -- Sync Context
  sync_batch_id UUID NOT NULL,                 -- Link to sync batch
  synced_at TIMESTAMPTZ DEFAULT NOW(),         -- When this change occurred
  synced_by VARCHAR(100),                      -- User or system that triggered sync

  -- Additional Context
  validation_status VARCHAR(20),               -- valid, warning, error
  validation_message TEXT,                     -- Details if validation failed
  metadata JSONB,                              -- Additional context (formulas, formatting, etc.)

  -- Indexes for fast queries
  CONSTRAINT chk_change_type CHECK (change_type IN ('insert', 'update', 'delete')),
  CONSTRAINT chk_validation_status CHECK (validation_status IN ('valid', 'warning', 'error', NULL))
);

-- Indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_lineage_target ON burc_data_lineage(target_table, target_id);
CREATE INDEX IF NOT EXISTS idx_lineage_source_file ON burc_data_lineage(source_file, source_sheet);
CREATE INDEX IF NOT EXISTS idx_lineage_batch ON burc_data_lineage(sync_batch_id);
CREATE INDEX IF NOT EXISTS idx_lineage_synced_at ON burc_data_lineage(synced_at DESC);
CREATE INDEX IF NOT EXISTS idx_lineage_change_type ON burc_data_lineage(change_type);
CREATE INDEX IF NOT EXISTS idx_lineage_target_column ON burc_data_lineage(target_table, target_column);

-- GIN index for JSONB metadata queries
CREATE INDEX IF NOT EXISTS idx_lineage_metadata ON burc_data_lineage USING GIN(metadata);

COMMENT ON TABLE burc_data_lineage IS 'Complete audit trail from Excel source to database changes';
COMMENT ON COLUMN burc_data_lineage.source_cell_reference IS 'Full Excel cell reference (e.g., A5, Priority Matrix!B10)';
COMMENT ON COLUMN burc_data_lineage.metadata IS 'Additional context: Excel formulas, formatting, calculation details, etc.';

-- ============================================================================
-- 2. BURC Sync Batches Table
-- ============================================================================
-- Tracks sync operations and their outcomes

CREATE TABLE IF NOT EXISTS burc_sync_batches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Timing
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  duration_ms INTEGER,                         -- Calculated: completed_at - started_at

  -- Status
  status VARCHAR(20) DEFAULT 'running',        -- running, completed, failed, partial

  -- Statistics
  files_processed INTEGER DEFAULT 0,
  records_inserted INTEGER DEFAULT 0,
  records_updated INTEGER DEFAULT 0,
  records_deleted INTEGER DEFAULT 0,
  records_skipped INTEGER DEFAULT 0,
  records_failed INTEGER DEFAULT 0,

  -- Error Tracking
  errors JSONB,                                -- Array of error objects
  warnings JSONB,                              -- Array of warning objects

  -- Context
  triggered_by VARCHAR(100),                   -- User or system that started sync
  sync_type VARCHAR(50),                       -- manual, scheduled, webhook, etc.
  source_files JSONB,                          -- Array of processed file paths

  -- Configuration
  config JSONB,                                -- Sync settings used

  CONSTRAINT chk_batch_status CHECK (status IN ('running', 'completed', 'failed', 'partial'))
);

-- Indexes for batch queries
CREATE INDEX IF NOT EXISTS idx_batch_status ON burc_sync_batches(status);
CREATE INDEX IF NOT EXISTS idx_batch_started_at ON burc_sync_batches(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_batch_triggered_by ON burc_sync_batches(triggered_by);

-- GIN indexes for JSONB queries
CREATE INDEX IF NOT EXISTS idx_batch_errors ON burc_sync_batches USING GIN(errors);
CREATE INDEX IF NOT EXISTS idx_batch_source_files ON burc_sync_batches USING GIN(source_files);

COMMENT ON TABLE burc_sync_batches IS 'Tracks BURC sync operations and their outcomes';
COMMENT ON COLUMN burc_sync_batches.errors IS 'Array of error objects with file, row, column, message';
COMMENT ON COLUMN burc_sync_batches.warnings IS 'Array of warning objects for non-blocking issues';

-- ============================================================================
-- 3. BURC File Registry
-- ============================================================================
-- Tracks all BURC files and their processing history

CREATE TABLE IF NOT EXISTS burc_file_registry (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- File Information
  file_path VARCHAR(500) NOT NULL UNIQUE,
  file_name VARCHAR(255) NOT NULL,
  file_type VARCHAR(50) NOT NULL,              -- burc_monthly, client_health, priority_matrix, etc.

  -- File Metadata
  file_size BIGINT,                            -- File size in bytes
  file_hash VARCHAR(64),                       -- SHA-256 hash for change detection
  last_modified TIMESTAMPTZ,                   -- File system last modified date

  -- Processing History
  first_processed_at TIMESTAMPTZ,
  last_processed_at TIMESTAMPTZ,
  total_syncs INTEGER DEFAULT 0,
  last_sync_batch_id UUID,
  last_sync_status VARCHAR(20),

  -- Validation
  is_valid BOOLEAN DEFAULT true,
  validation_errors JSONB,

  -- Statistics
  total_rows_processed INTEGER DEFAULT 0,
  total_changes_made INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT fk_last_sync_batch FOREIGN KEY (last_sync_batch_id)
    REFERENCES burc_sync_batches(id) ON DELETE SET NULL
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_file_registry_type ON burc_file_registry(file_type);
CREATE INDEX IF NOT EXISTS idx_file_registry_last_processed ON burc_file_registry(last_processed_at DESC);
CREATE INDEX IF NOT EXISTS idx_file_registry_hash ON burc_file_registry(file_hash);

COMMENT ON TABLE burc_file_registry IS 'Registry of all BURC Excel files and their processing history';
COMMENT ON COLUMN burc_file_registry.file_hash IS 'SHA-256 hash for detecting file changes';

-- ============================================================================
-- 4. Helper Functions
-- ============================================================================

-- Function to complete a sync batch
CREATE OR REPLACE FUNCTION complete_sync_batch(
  p_batch_id UUID,
  p_status VARCHAR(20) DEFAULT 'completed'
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE burc_sync_batches
  SET
    completed_at = NOW(),
    duration_ms = EXTRACT(EPOCH FROM (NOW() - started_at)) * 1000,
    status = p_status
  WHERE id = p_batch_id;
END;
$$;

-- Function to get lineage for a specific record
CREATE OR REPLACE FUNCTION get_record_lineage(
  p_table_name VARCHAR(100),
  p_record_id UUID
)
RETURNS TABLE (
  change_date TIMESTAMPTZ,
  change_type VARCHAR(20),
  column_name VARCHAR(100),
  old_value TEXT,
  new_value TEXT,
  source_file VARCHAR(500),
  source_sheet VARCHAR(100),
  source_cell VARCHAR(20),
  batch_id UUID
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    synced_at,
    change_type,
    target_column,
    old_value,
    new_value,
    source_file,
    source_sheet,
    source_cell_reference,
    sync_batch_id
  FROM burc_data_lineage
  WHERE target_table = p_table_name
    AND target_id = p_record_id
  ORDER BY synced_at DESC;
$$;

-- Function to get source cell for a specific field
CREATE OR REPLACE FUNCTION get_source_cell(
  p_table_name VARCHAR(100),
  p_record_id UUID,
  p_column_name VARCHAR(100)
)
RETURNS TABLE (
  source_file VARCHAR(500),
  source_sheet VARCHAR(100),
  source_cell VARCHAR(20),
  synced_at TIMESTAMPTZ,
  current_value TEXT
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    source_file,
    source_sheet,
    source_cell_reference,
    synced_at,
    new_value
  FROM burc_data_lineage
  WHERE target_table = p_table_name
    AND target_id = p_record_id
    AND target_column = p_column_name
  ORDER BY synced_at DESC
  LIMIT 1;
$$;

-- Function to get batch statistics
CREATE OR REPLACE FUNCTION get_batch_stats(p_batch_id UUID)
RETURNS TABLE (
  total_changes INTEGER,
  by_table JSONB,
  by_change_type JSONB,
  error_count INTEGER,
  warning_count INTEGER
)
LANGUAGE sql
STABLE
AS $$
  SELECT
    COUNT(*)::INTEGER as total_changes,
    jsonb_object_agg(
      target_table,
      COUNT(*)
    ) as by_table,
    jsonb_object_agg(
      change_type,
      COUNT(*)
    ) as by_change_type,
    (
      SELECT COUNT(*)::INTEGER
      FROM jsonb_array_elements((SELECT errors FROM burc_sync_batches WHERE id = p_batch_id))
    ) as error_count,
    (
      SELECT COUNT(*)::INTEGER
      FROM jsonb_array_elements((SELECT warnings FROM burc_sync_batches WHERE id = p_batch_id))
    ) as warning_count
  FROM burc_data_lineage
  WHERE sync_batch_id = p_batch_id
  GROUP BY sync_batch_id;
$$;

-- ============================================================================
-- 5. RLS Policies
-- ============================================================================

-- Enable RLS
ALTER TABLE burc_data_lineage ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_sync_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_file_registry ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to view all lineage data
CREATE POLICY "Allow authenticated read access to lineage"
  ON burc_data_lineage
  FOR SELECT
  TO authenticated
  USING (true);

-- Allow authenticated users to view all sync batches
CREATE POLICY "Allow authenticated read access to sync batches"
  ON burc_sync_batches
  FOR SELECT
  TO authenticated
  USING (true);

-- Allow authenticated users to view file registry
CREATE POLICY "Allow authenticated read access to file registry"
  ON burc_file_registry
  FOR SELECT
  TO authenticated
  USING (true);

-- Allow service role to manage all data (for sync scripts)
CREATE POLICY "Allow service role full access to lineage"
  ON burc_data_lineage
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow service role full access to sync batches"
  ON burc_sync_batches
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Allow service role full access to file registry"
  ON burc_file_registry
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- ============================================================================
-- 6. Triggers for Updated_At
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_burc_file_registry_updated_at
  BEFORE UPDATE ON burc_file_registry
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Verification
-- ============================================================================

DO $$
DECLARE
  v_lineage_count INTEGER;
  v_batch_count INTEGER;
  v_file_count INTEGER;
BEGIN
  -- Check tables exist
  SELECT COUNT(*) INTO v_lineage_count
  FROM information_schema.tables
  WHERE table_name = 'burc_data_lineage';

  SELECT COUNT(*) INTO v_batch_count
  FROM information_schema.tables
  WHERE table_name = 'burc_sync_batches';

  SELECT COUNT(*) INTO v_file_count
  FROM information_schema.tables
  WHERE table_name = 'burc_file_registry';

  IF v_lineage_count = 0 THEN
    RAISE EXCEPTION 'Migration failed: burc_data_lineage table not created';
  END IF;

  IF v_batch_count = 0 THEN
    RAISE EXCEPTION 'Migration failed: burc_sync_batches table not created';
  END IF;

  IF v_file_count = 0 THEN
    RAISE EXCEPTION 'Migration failed: burc_file_registry table not created';
  END IF;

  RAISE NOTICE '✓ Migration successful: BURC data lineage system created';
  RAISE NOTICE '  - burc_data_lineage: Complete audit trail';
  RAISE NOTICE '  - burc_sync_batches: Sync operation tracking';
  RAISE NOTICE '  - burc_file_registry: File processing history';
  RAISE NOTICE '  - Helper functions: get_record_lineage, get_source_cell, get_batch_stats';
END $$;
