-- Aging Accounts Database Migration
-- Purpose: Store aging accounts receivable data for automated weekly imports
-- Date: 2025-12-05

-- =====================================================
-- 1. Main aging_accounts table
-- =====================================================
CREATE TABLE IF NOT EXISTS aging_accounts (
  id SERIAL PRIMARY KEY,

  -- CSE and Client Info
  cse_name TEXT NOT NULL,
  client_name TEXT NOT NULL,
  client_name_normalized TEXT NOT NULL,
  most_recent_comment TEXT,

  -- Aging Buckets (in dollars)
  current_amount DECIMAL(12,2) DEFAULT 0,           -- Not yet overdue
  days_1_to_30 DECIMAL(12,2) DEFAULT 0,             -- 1-30 days overdue
  days_31_to_60 DECIMAL(12,2) DEFAULT 0,            -- 31-60 days overdue
  days_61_to_90 DECIMAL(12,2) DEFAULT 0,            -- 61-90 days overdue
  days_91_to_120 DECIMAL(12,2) DEFAULT 0,           -- 91-120 days overdue
  days_121_to_180 DECIMAL(12,2) DEFAULT 0,          -- 121-180 days overdue
  days_181_to_270 DECIMAL(12,2) DEFAULT 0,          -- 181-270 days overdue
  days_271_to_365 DECIMAL(12,2) DEFAULT 0,          -- 271-365 days overdue
  days_over_365 DECIMAL(12,2) DEFAULT 0,            -- Over 365 days overdue

  -- Calculated Totals
  total_outstanding DECIMAL(12,2) DEFAULT 0,
  total_overdue DECIMAL(12,2) GENERATED ALWAYS AS (
    days_1_to_30 + days_31_to_60 + days_61_to_90 +
    days_91_to_120 + days_121_to_180 + days_181_to_270 +
    days_271_to_365 + days_over_365
  ) STORED,

  -- Metadata
  is_inactive BOOLEAN DEFAULT false,                -- True for inactive clients with outstanding AR
  data_source TEXT DEFAULT 'excel_import',          -- Source of data (excel_import, api, manual)
  import_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(), -- When this data was imported
  week_ending_date DATE,                            -- Week ending date from the Excel file

  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. Indexes for performance
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_aging_accounts_cse ON aging_accounts(cse_name);
CREATE INDEX IF NOT EXISTS idx_aging_accounts_client ON aging_accounts(client_name_normalized);
CREATE INDEX IF NOT EXISTS idx_aging_accounts_import_date ON aging_accounts(import_date DESC);
CREATE INDEX IF NOT EXISTS idx_aging_accounts_week_ending ON aging_accounts(week_ending_date DESC);
CREATE UNIQUE INDEX IF NOT EXISTS idx_aging_accounts_unique_cse_client_week
  ON aging_accounts(cse_name, client_name_normalized, week_ending_date);

-- =====================================================
-- 3. Historical snapshots table (optional - for trend analysis)
-- =====================================================
CREATE TABLE IF NOT EXISTS aging_accounts_history (
  id SERIAL PRIMARY KEY,
  cse_name TEXT NOT NULL,
  client_name_normalized TEXT NOT NULL,
  week_ending_date DATE NOT NULL,
  total_outstanding DECIMAL(12,2),
  total_overdue DECIMAL(12,2),
  percent_under_60_days DECIMAL(5,2),
  percent_under_90_days DECIMAL(5,2),
  snapshot_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  CONSTRAINT unique_snapshot UNIQUE (cse_name, client_name_normalized, week_ending_date)
);

CREATE INDEX IF NOT EXISTS idx_aging_history_cse ON aging_accounts_history(cse_name);
CREATE INDEX IF NOT EXISTS idx_aging_history_week ON aging_accounts_history(week_ending_date DESC);

-- =====================================================
-- 4. Materialized view for CSE compliance dashboard
-- =====================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS aging_compliance_summary AS
SELECT
  cse_name,
  week_ending_date,
  COUNT(DISTINCT client_name_normalized) as total_clients,
  SUM(total_outstanding) as total_outstanding,
  SUM(total_overdue) as total_overdue,

  -- Calculate compliance metrics (exclude current - not overdue yet)
  SUM(days_1_to_30 + days_31_to_60) as amount_under_60_days,
  SUM(days_1_to_30 + days_31_to_60 + days_61_to_90) as amount_under_90_days,

  -- Compliance percentages
  CASE
    WHEN SUM(total_overdue) > 0 THEN
      ROUND((SUM(days_1_to_30 + days_31_to_60) / SUM(total_overdue)) * 100, 2)
    ELSE 100
  END as percent_under_60_days,

  CASE
    WHEN SUM(total_overdue) > 0 THEN
      ROUND((SUM(days_1_to_30 + days_31_to_60 + days_61_to_90) / SUM(total_overdue)) * 100, 2)
    ELSE 100
  END as percent_under_90_days,

  -- Goals: 90% under 60 days, 100% under 90 days
  CASE
    WHEN SUM(total_overdue) = 0 THEN true
    WHEN SUM(total_overdue) > 0 THEN
      (SUM(days_1_to_30 + days_31_to_60) / SUM(total_overdue)) * 100 >= 90 AND
      (SUM(days_1_to_30 + days_31_to_60 + days_61_to_90) / SUM(total_overdue)) * 100 >= 100
    ELSE false
  END as meets_goals,

  MAX(import_date) as last_updated
FROM aging_accounts
WHERE week_ending_date IS NOT NULL
GROUP BY cse_name, week_ending_date;

CREATE UNIQUE INDEX IF NOT EXISTS idx_aging_compliance_cse_week
  ON aging_compliance_summary(cse_name, week_ending_date DESC);

-- =====================================================
-- 5. Function to refresh compliance summary
-- =====================================================
CREATE OR REPLACE FUNCTION refresh_aging_compliance()
RETURNS void AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY aging_compliance_summary;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 6. Trigger to auto-refresh compliance on data changes
-- =====================================================
CREATE OR REPLACE FUNCTION trigger_refresh_aging_compliance()
RETURNS trigger AS $$
BEGIN
  -- Refresh the materialized view after insert/update/delete
  PERFORM refresh_aging_compliance();
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS aging_accounts_refresh_compliance ON aging_accounts;
CREATE TRIGGER aging_accounts_refresh_compliance
  AFTER INSERT OR UPDATE OR DELETE ON aging_accounts
  FOR EACH STATEMENT
  EXECUTE FUNCTION trigger_refresh_aging_compliance();

-- =====================================================
-- 7. RLS Policies (if using Supabase RLS)
-- =====================================================
ALTER TABLE aging_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE aging_accounts_history ENABLE ROW LEVEL SECURITY;

-- Allow service role full access
CREATE POLICY "Service role has full access to aging_accounts"
  ON aging_accounts FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Allow authenticated users to read their own CSE's data
CREATE POLICY "Users can read own CSE aging accounts"
  ON aging_accounts FOR SELECT
  TO authenticated
  USING (
    cse_name IN (
      SELECT DISTINCT cse_name
      FROM user_profiles
      WHERE id = auth.uid()
    )
  );

-- Admins can see all aging accounts
CREATE POLICY "Admins can read all aging accounts"
  ON aging_accounts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND role IN ('admin', 'leader')
    )
  );

-- Similar policies for history table
CREATE POLICY "Service role has full access to aging_accounts_history"
  ON aging_accounts_history FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Users can read own CSE aging history"
  ON aging_accounts_history FOR SELECT
  TO authenticated
  USING (
    cse_name IN (
      SELECT DISTINCT cse_name
      FROM user_profiles
      WHERE id = auth.uid()
    )
  );

CREATE POLICY "Admins can read all aging history"
  ON aging_accounts_history FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid()
      AND role IN ('admin', 'leader')
    )
  );

-- =====================================================
-- 8. Helper functions
-- =====================================================

-- Function to get latest aging data for a CSE
CREATE OR REPLACE FUNCTION get_latest_aging_data(p_cse_name TEXT)
RETURNS TABLE (
  client_name TEXT,
  client_name_normalized TEXT,
  total_outstanding DECIMAL,
  total_overdue DECIMAL,
  current_amount DECIMAL,
  days_1_to_30 DECIMAL,
  days_31_to_60 DECIMAL,
  days_61_to_90 DECIMAL,
  days_over_90 DECIMAL,
  most_recent_comment TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    a.client_name,
    a.client_name_normalized,
    a.total_outstanding,
    a.total_overdue,
    a.current_amount,
    a.days_1_to_30,
    a.days_31_to_60,
    a.days_61_to_90,
    (a.days_91_to_120 + a.days_121_to_180 + a.days_181_to_270 +
     a.days_271_to_365 + a.days_over_365) as days_over_90,
    a.most_recent_comment
  FROM aging_accounts a
  WHERE a.cse_name = p_cse_name
    AND a.week_ending_date = (
      SELECT MAX(week_ending_date)
      FROM aging_accounts
      WHERE cse_name = p_cse_name
    )
  ORDER BY a.total_outstanding DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 9. Comments for documentation
-- =====================================================
COMMENT ON TABLE aging_accounts IS
  'Stores aging accounts receivable data imported weekly from Excel files. Each row represents a client''s AR status for a specific week.';

COMMENT ON COLUMN aging_accounts.current_amount IS
  'Amount not yet overdue (0 days old). NOT included in aging compliance calculations.';

COMMENT ON COLUMN aging_accounts.total_overdue IS
  'Sum of all overdue amounts (days_1_to_30 through days_over_365). Automatically calculated.';

COMMENT ON COLUMN aging_accounts.week_ending_date IS
  'The week ending date from the source Excel file. Used to track which week this data represents.';

COMMENT ON MATERIALIZED VIEW aging_compliance_summary IS
  'Pre-calculated compliance metrics per CSE per week. Automatically refreshed on data changes.';
