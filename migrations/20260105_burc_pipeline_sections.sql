-- BURC Pipeline Sections Migration
-- Aligns pipeline structure with BURC Dial 2 Risk Profile sections:
-- 1. Green Section (90% probability) - High confidence, in forecast
-- 2. Yellow Section (50% probability) - Medium confidence, partially in forecast
-- 3. Red Section (20% probability) - Low confidence, at risk
-- 4. Pipeline Section (30% probability) - Not included in forecasts
-- 5. Lost/Moved Out - Removed from current year
-- 6. Business Case - Requires business justification

-- Add section_color column to track BURC section
ALTER TABLE burc_pipeline_detail
ADD COLUMN IF NOT EXISTS section_color VARCHAR(20) DEFAULT 'pipeline';

-- Add pipeline_status for tracking deal lifecycle
ALTER TABLE burc_pipeline_detail
ADD COLUMN IF NOT EXISTS pipeline_status VARCHAR(30) DEFAULT 'active';

-- Add in_forecast flag
ALTER TABLE burc_pipeline_detail
ADD COLUMN IF NOT EXISTS in_forecast BOOLEAN DEFAULT false;

-- Add notes field for deal context
ALTER TABLE burc_pipeline_detail
ADD COLUMN IF NOT EXISTS notes TEXT;

-- Add last_updated tracking
ALTER TABLE burc_pipeline_detail
ADD COLUMN IF NOT EXISTS last_updated TIMESTAMPTZ DEFAULT NOW();

-- Update section_color based on probability
UPDATE burc_pipeline_detail
SET section_color = CASE
  WHEN probability >= 0.85 THEN 'green'
  WHEN probability >= 0.45 AND probability < 0.85 THEN 'yellow'
  WHEN probability >= 0.25 AND probability < 0.45 THEN 'pipeline'
  WHEN probability < 0.25 THEN 'red'
  ELSE 'pipeline'
END
WHERE section_color IS NULL OR section_color = 'pipeline';

-- Update in_forecast based on section
UPDATE burc_pipeline_detail
SET in_forecast = CASE
  WHEN section_color IN ('green', 'yellow') THEN true
  ELSE false
END;

-- Create index for efficient querying
CREATE INDEX IF NOT EXISTS idx_burc_pipeline_section ON burc_pipeline_detail(fiscal_year, section_color);
CREATE INDEX IF NOT EXISTS idx_burc_pipeline_status ON burc_pipeline_detail(fiscal_year, pipeline_status);

-- Create view for pipeline summary by section
CREATE OR REPLACE VIEW burc_pipeline_by_section AS
SELECT
  fiscal_year,
  section_color,
  pipeline_status,
  forecast_category,
  in_forecast,
  COUNT(*) as deal_count,
  SUM(net_booking) as total_net_booking,
  SUM(weighted_revenue) as total_weighted,
  SUM(CASE WHEN forecast_category = 'Best Case' THEN net_booking ELSE 0 END) as best_case_value,
  SUM(CASE WHEN forecast_category = 'Business Case' THEN net_booking ELSE 0 END) as business_case_value,
  SUM(CASE WHEN forecast_category = 'Pipeline' THEN net_booking ELSE 0 END) as pipeline_value
FROM burc_pipeline_detail
WHERE pipeline_status = 'active'
GROUP BY fiscal_year, section_color, pipeline_status, forecast_category, in_forecast
ORDER BY fiscal_year DESC,
  CASE section_color
    WHEN 'green' THEN 1
    WHEN 'yellow' THEN 2
    WHEN 'pipeline' THEN 3
    WHEN 'red' THEN 4
    ELSE 5
  END;

-- Add comments
COMMENT ON COLUMN burc_pipeline_detail.section_color IS 'BURC Dial 2 section: green (90%), yellow (50%), pipeline (30%), red (20%)';
COMMENT ON COLUMN burc_pipeline_detail.pipeline_status IS 'Deal status: active, lost, moved_out, won, deferred';
COMMENT ON COLUMN burc_pipeline_detail.in_forecast IS 'Whether deal is included in revenue forecast';
