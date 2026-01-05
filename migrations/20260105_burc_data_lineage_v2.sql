-- BURC Data Lineage and Audit Trail System V2
-- Fix: Corrected aggregate function nesting issue in get_batch_stats

-- Create BURC Data Lineage Table
CREATE TABLE IF NOT EXISTS burc_data_lineage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_file VARCHAR(500) NOT NULL,
  source_sheet VARCHAR(100) NOT NULL,
  source_row INTEGER NOT NULL,
  source_column VARCHAR(50) NOT NULL,
  source_cell_reference VARCHAR(20),
  target_table VARCHAR(100) NOT NULL,
  target_id UUID,
  target_column VARCHAR(100) NOT NULL,
  old_value TEXT,
  new_value TEXT,
  change_type VARCHAR(20) NOT NULL,
  sync_batch_id UUID NOT NULL,
  synced_at TIMESTAMPTZ DEFAULT NOW(),
  synced_by VARCHAR(100),
  validation_status VARCHAR(20),
  validation_message TEXT,
  metadata JSONB,
  CONSTRAINT chk_change_type CHECK (change_type IN ('insert', 'update', 'delete')),
  CONSTRAINT chk_validation_status CHECK (validation_status IN ('valid', 'warning', 'error', NULL))
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_lineage_target ON burc_data_lineage(target_table, target_id);
CREATE INDEX IF NOT EXISTS idx_lineage_source_file ON burc_data_lineage(source_file, source_sheet);
CREATE INDEX IF NOT EXISTS idx_lineage_batch ON burc_data_lineage(sync_batch_id);
CREATE INDEX IF NOT EXISTS idx_lineage_synced_at ON burc_data_lineage(synced_at DESC);
CREATE INDEX IF NOT EXISTS idx_lineage_change_type ON burc_data_lineage(change_type);
CREATE INDEX IF NOT EXISTS idx_lineage_target_column ON burc_data_lineage(target_table, target_column);
CREATE INDEX IF NOT EXISTS idx_lineage_metadata ON burc_data_lineage USING GIN(metadata);

-- Create BURC Sync Batches Table
CREATE TABLE IF NOT EXISTS burc_sync_batches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  duration_ms INTEGER,
  status VARCHAR(20) DEFAULT 'running',
  files_processed INTEGER DEFAULT 0,
  records_inserted INTEGER DEFAULT 0,
  records_updated INTEGER DEFAULT 0,
  records_deleted INTEGER DEFAULT 0,
  records_skipped INTEGER DEFAULT 0,
  records_failed INTEGER DEFAULT 0,
  errors JSONB,
  warnings JSONB,
  triggered_by VARCHAR(100),
  sync_type VARCHAR(50),
  source_files JSONB,
  config JSONB,
  CONSTRAINT chk_batch_status CHECK (status IN ('running', 'completed', 'failed', 'partial'))
);

CREATE INDEX IF NOT EXISTS idx_batch_status ON burc_sync_batches(status);
CREATE INDEX IF NOT EXISTS idx_batch_started_at ON burc_sync_batches(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_batch_triggered_by ON burc_sync_batches(triggered_by);
CREATE INDEX IF NOT EXISTS idx_batch_errors ON burc_sync_batches USING GIN(errors);
CREATE INDEX IF NOT EXISTS idx_batch_source_files ON burc_sync_batches USING GIN(source_files);

-- Create BURC File Registry
CREATE TABLE IF NOT EXISTS burc_file_registry (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  file_path VARCHAR(500) NOT NULL UNIQUE,
  file_name VARCHAR(255) NOT NULL,
  file_type VARCHAR(50) NOT NULL,
  file_size BIGINT,
  file_hash VARCHAR(64),
  last_modified TIMESTAMPTZ,
  first_processed_at TIMESTAMPTZ,
  last_processed_at TIMESTAMPTZ,
  total_syncs INTEGER DEFAULT 0,
  last_sync_batch_id UUID,
  last_sync_status VARCHAR(20),
  is_valid BOOLEAN DEFAULT true,
  validation_errors JSONB,
  total_rows_processed INTEGER DEFAULT 0,
  total_changes_made INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_file_registry_type ON burc_file_registry(file_type);
CREATE INDEX IF NOT EXISTS idx_file_registry_last_processed ON burc_file_registry(last_processed_at DESC);
CREATE INDEX IF NOT EXISTS idx_file_registry_hash ON burc_file_registry(file_hash);

-- Helper function to complete a sync batch
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

-- Fixed function to get batch statistics (no nested aggregates)
CREATE OR REPLACE FUNCTION get_batch_stats(p_batch_id UUID)
RETURNS TABLE (
  total_changes BIGINT,
  by_table JSONB,
  by_change_type JSONB,
  error_count BIGINT,
  warning_count BIGINT
)
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
  v_total BIGINT;
  v_by_table JSONB;
  v_by_change_type JSONB;
  v_errors BIGINT;
  v_warnings BIGINT;
BEGIN
  -- Get total changes
  SELECT COUNT(*) INTO v_total
  FROM burc_data_lineage
  WHERE sync_batch_id = p_batch_id;

  -- Get by table
  SELECT COALESCE(jsonb_object_agg(target_table, cnt), '{}'::jsonb)
  INTO v_by_table
  FROM (
    SELECT target_table, COUNT(*) as cnt
    FROM burc_data_lineage
    WHERE sync_batch_id = p_batch_id
    GROUP BY target_table
  ) t;

  -- Get by change type
  SELECT COALESCE(jsonb_object_agg(change_type, cnt), '{}'::jsonb)
  INTO v_by_change_type
  FROM (
    SELECT change_type, COUNT(*) as cnt
    FROM burc_data_lineage
    WHERE sync_batch_id = p_batch_id
    GROUP BY change_type
  ) c;

  -- Get error count
  SELECT COALESCE(jsonb_array_length(errors), 0)
  INTO v_errors
  FROM burc_sync_batches
  WHERE id = p_batch_id;

  -- Get warning count
  SELECT COALESCE(jsonb_array_length(warnings), 0)
  INTO v_warnings
  FROM burc_sync_batches
  WHERE id = p_batch_id;

  RETURN QUERY SELECT v_total, v_by_table, v_by_change_type, v_errors, v_warnings;
END;
$$;

-- Enable RLS
ALTER TABLE burc_data_lineage ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_sync_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE burc_file_registry ENABLE ROW LEVEL SECURITY;

-- RLS policies
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow authenticated read access to lineage') THEN
    CREATE POLICY "Allow authenticated read access to lineage"
      ON burc_data_lineage FOR SELECT TO authenticated USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow authenticated read access to sync batches') THEN
    CREATE POLICY "Allow authenticated read access to sync batches"
      ON burc_sync_batches FOR SELECT TO authenticated USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow authenticated read access to file registry') THEN
    CREATE POLICY "Allow authenticated read access to file registry"
      ON burc_file_registry FOR SELECT TO authenticated USING (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow service role full access to lineage') THEN
    CREATE POLICY "Allow service role full access to lineage"
      ON burc_data_lineage FOR ALL TO service_role USING (true) WITH CHECK (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow service role full access to sync batches') THEN
    CREATE POLICY "Allow service role full access to sync batches"
      ON burc_sync_batches FOR ALL TO service_role USING (true) WITH CHECK (true);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Allow service role full access to file registry') THEN
    CREATE POLICY "Allow service role full access to file registry"
      ON burc_file_registry FOR ALL TO service_role USING (true) WITH CHECK (true);
  END IF;
END $$;

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_burc_file_registry_updated_at ON burc_file_registry;
CREATE TRIGGER update_burc_file_registry_updated_at
  BEFORE UPDATE ON burc_file_registry
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

SELECT 'BURC data lineage v2 migration completed' AS status;
