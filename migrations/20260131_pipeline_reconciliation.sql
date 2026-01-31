-- ============================================================================
-- Pipeline-to-Forecast Reconciliation
-- Created: 31 January 2026
-- Purpose: Create views and tables for reconciling Dial 2 pipeline with
--          waterfall forecast values
-- ============================================================================

-- ============================================================
-- 1. WATERFALL MAPPING NOTES TABLE
-- Documents how waterfall values relate to pipeline sections
-- ============================================================
CREATE TABLE IF NOT EXISTS burc_waterfall_mapping_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,
  waterfall_category TEXT NOT NULL,
  included_sections TEXT[], -- e.g., ['green', 'yellow'] for pipeline sections
  included_product_lines TEXT[], -- e.g., ['SW', 'PS', 'Maint', 'HW']
  weighting_formula TEXT, -- e.g., 'probability * 0.8' or 'unweighted'
  notes TEXT,
  documented_by TEXT,
  documented_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(fiscal_year, waterfall_category)
);

-- ============================================================
-- 2. PIPELINE FORECAST LINEAGE VIEW
-- Shows Dial 2 pipeline deals grouped by section and linked to waterfall
-- ============================================================
CREATE OR REPLACE VIEW burc_pipeline_forecast_lineage AS
WITH pipeline_by_section AS (
  -- Aggregate pipeline deals by forecast category
  SELECT
    fiscal_year,
    forecast_category,
    COUNT(*) as deal_count,
    SUM(sw_revenue) as sw_total,
    SUM(ps_revenue) as ps_total,
    SUM(maint_revenue) as maint_total,
    SUM(hw_revenue) as hw_total,
    SUM(total_revenue) as total_revenue,
    STRING_AGG(DISTINCT client_name, ', ') as clients,
    STRING_AGG(deal_name, ', ') as deals
  FROM burc_pipeline_detail
  WHERE fiscal_year >= 2025
  GROUP BY fiscal_year, forecast_category
),
waterfall_comparison AS (
  -- Get waterfall values for comparison
  SELECT
    fiscal_year,
    category as waterfall_category,
    amount as waterfall_amount,
    description
  FROM burc_waterfall
  WHERE fiscal_year >= 2025
)
SELECT
  p.fiscal_year,
  p.forecast_category as pipeline_section,
  p.deal_count,
  p.sw_total,
  p.ps_total,
  p.maint_total,
  p.hw_total,
  p.total_revenue as pipeline_total,
  p.clients,
  p.deals,
  w.waterfall_category,
  w.waterfall_amount,
  w.description as waterfall_description,
  -- Calculate variance
  CASE
    WHEN w.waterfall_amount IS NOT NULL THEN
      p.total_revenue - w.waterfall_amount
    ELSE NULL
  END as variance,
  -- Flag discrepancies over threshold
  CASE
    WHEN ABS(COALESCE(p.total_revenue, 0) - COALESCE(w.waterfall_amount, 0)) > 50000 THEN 'FLAG'
    WHEN ABS(COALESCE(p.total_revenue, 0) - COALESCE(w.waterfall_amount, 0)) > 10000 THEN 'REVIEW'
    ELSE 'OK'
  END as reconciliation_status
FROM pipeline_by_section p
LEFT JOIN waterfall_comparison w
  ON p.fiscal_year = w.fiscal_year
  AND (
    -- Match pipeline sections to waterfall categories
    (p.forecast_category ILIKE '%committed%' AND w.waterfall_category ILIKE '%committed%')
    OR (p.forecast_category ILIKE '%best case%' AND w.waterfall_category ILIKE '%best%')
    OR (p.forecast_category ILIKE '%pipeline%' AND w.waterfall_category ILIKE '%pipeline%')
    OR (p.forecast_category ILIKE '%business case%' AND w.waterfall_category ILIKE '%business%')
  )
ORDER BY p.fiscal_year DESC, p.total_revenue DESC;

-- ============================================================
-- 3. RECONCILIATION SUMMARY VIEW
-- High-level summary of pipeline vs waterfall reconciliation
-- ============================================================
CREATE OR REPLACE VIEW burc_reconciliation_summary AS
WITH pipeline_totals AS (
  SELECT
    fiscal_year,
    SUM(CASE WHEN forecast_category ILIKE '%committed%' THEN total_revenue ELSE 0 END) as committed_pipeline,
    SUM(CASE WHEN forecast_category ILIKE '%best case%' THEN total_revenue ELSE 0 END) as best_case_pipeline,
    SUM(CASE WHEN forecast_category ILIKE '%pipeline%' AND forecast_category NOT ILIKE '%best%' THEN total_revenue ELSE 0 END) as standard_pipeline,
    SUM(CASE WHEN forecast_category ILIKE '%business case%' THEN total_revenue ELSE 0 END) as business_case_pipeline,
    SUM(total_revenue) as total_pipeline,
    COUNT(*) as total_deals
  FROM burc_pipeline_detail
  WHERE fiscal_year >= 2025
  GROUP BY fiscal_year
),
waterfall_totals AS (
  SELECT
    fiscal_year,
    SUM(CASE WHEN category ILIKE '%committed%' OR category ILIKE '%backlog%' THEN amount ELSE 0 END) as committed_waterfall,
    SUM(CASE WHEN category ILIKE '%best%' THEN amount ELSE 0 END) as best_case_waterfall,
    SUM(CASE WHEN category ILIKE '%pipeline%' AND category NOT ILIKE '%best%' THEN amount ELSE 0 END) as standard_waterfall,
    SUM(amount) as total_waterfall
  FROM burc_waterfall
  WHERE fiscal_year >= 2025
  GROUP BY fiscal_year
)
SELECT
  COALESCE(p.fiscal_year, w.fiscal_year) as fiscal_year,
  p.committed_pipeline,
  w.committed_waterfall,
  p.committed_pipeline - COALESCE(w.committed_waterfall, 0) as committed_variance,
  p.best_case_pipeline,
  w.best_case_waterfall,
  p.best_case_pipeline - COALESCE(w.best_case_waterfall, 0) as best_case_variance,
  p.standard_pipeline,
  w.standard_waterfall,
  p.standard_pipeline - COALESCE(w.standard_waterfall, 0) as pipeline_variance,
  p.total_pipeline,
  w.total_waterfall,
  p.total_pipeline - COALESCE(w.total_waterfall, 0) as total_variance,
  p.total_deals,
  -- Overall reconciliation status
  CASE
    WHEN ABS(COALESCE(p.total_pipeline, 0) - COALESCE(w.total_waterfall, 0)) > 500000 THEN 'CRITICAL'
    WHEN ABS(COALESCE(p.total_pipeline, 0) - COALESCE(w.total_waterfall, 0)) > 100000 THEN 'REVIEW'
    ELSE 'RECONCILED'
  END as overall_status
FROM pipeline_totals p
FULL OUTER JOIN waterfall_totals w ON p.fiscal_year = w.fiscal_year
ORDER BY fiscal_year DESC;

-- ============================================================
-- 4. INDEXES AND RLS
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_waterfall_mapping_year
  ON burc_waterfall_mapping_notes(fiscal_year);

ALTER TABLE burc_waterfall_mapping_notes ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY IF NOT EXISTS "Allow authenticated read on mapping notes"
  ON burc_waterfall_mapping_notes FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY IF NOT EXISTS "Allow service role all on mapping notes"
  ON burc_waterfall_mapping_notes FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Grant permissions
GRANT SELECT ON burc_waterfall_mapping_notes TO anon;
GRANT SELECT ON burc_waterfall_mapping_notes TO authenticated;
GRANT SELECT ON burc_pipeline_forecast_lineage TO anon;
GRANT SELECT ON burc_pipeline_forecast_lineage TO authenticated;
GRANT SELECT ON burc_reconciliation_summary TO anon;
GRANT SELECT ON burc_reconciliation_summary TO authenticated;

-- ============================================================
-- 5. SEED INITIAL MAPPING NOTES
-- ============================================================
INSERT INTO burc_waterfall_mapping_notes (fiscal_year, waterfall_category, included_sections, included_product_lines, weighting_formula, notes, documented_by)
VALUES
  (2026, 'Committed/Backlog', ARRAY['committed', 'backlog'], ARRAY['SW', 'PS', 'Maint', 'HW'], 'unweighted (100%)', 'Fully committed deals with signed agreements', 'System'),
  (2026, 'Best Case PS', ARRAY['best case'], ARRAY['PS'], 'unweighted (100%)', 'Professional Services opportunities in final stages', 'System'),
  (2026, 'Best Case Maint', ARRAY['best case'], ARRAY['Maint'], 'unweighted (100%)', 'Maintenance contract renewals in final stages', 'System'),
  (2026, 'Pipeline PS', ARRAY['pipeline'], ARRAY['PS'], 'weighted by probability', 'PS opportunities weighted by close probability', 'System'),
  (2026, 'Pipeline SW', ARRAY['pipeline'], ARRAY['SW'], 'weighted by probability', 'Software opportunities weighted by close probability', 'System')
ON CONFLICT (fiscal_year, waterfall_category) DO NOTHING;

-- ============================================================
-- 6. COMMENTS
-- ============================================================
COMMENT ON TABLE burc_waterfall_mapping_notes IS 'Documents how waterfall forecast values map to Dial 2 pipeline sections';
COMMENT ON VIEW burc_pipeline_forecast_lineage IS 'Shows pipeline deals grouped by section with linkage to waterfall values for reconciliation';
COMMENT ON VIEW burc_reconciliation_summary IS 'High-level summary comparing total pipeline by category to waterfall forecast values';
