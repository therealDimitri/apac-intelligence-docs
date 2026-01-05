-- Migration: Churn Prediction System
-- Created: 2026-01-05
-- Description: Creates table to store client churn risk predictions based on multiple factors

-- =============================================
-- 1. Create churn_predictions table
-- =============================================

CREATE TABLE IF NOT EXISTS churn_predictions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name VARCHAR(255) NOT NULL,
  client_id INTEGER,
  client_uuid TEXT,
  risk_score NUMERIC(5,2) NOT NULL CHECK (risk_score >= 0 AND risk_score <= 100),
  risk_level VARCHAR(20) NOT NULL CHECK (risk_level IN ('high', 'medium', 'low')),
  risk_factors JSONB NOT NULL DEFAULT '[]'::jsonb,
  recommended_actions JSONB NOT NULL DEFAULT '[]'::jsonb,
  predicted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  model_version VARCHAR(20) NOT NULL DEFAULT 'v1.0',

  -- Feature scores (for transparency)
  nps_trend_score NUMERIC(5,2),
  compliance_trend_score NUMERIC(5,2),
  support_ticket_score NUMERIC(5,2),
  ar_aging_score NUMERIC(5,2),
  revenue_trend_score NUMERIC(5,2),
  renewal_proximity_score NUMERIC(5,2),
  engagement_freq_score NUMERIC(5,2),

  -- Raw feature values
  feature_data JSONB,

  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- 2. Create indexes for performance
-- =============================================

CREATE INDEX idx_churn_predictions_client_name ON churn_predictions(client_name);
CREATE INDEX idx_churn_predictions_client_uuid ON churn_predictions(client_uuid);
CREATE INDEX idx_churn_predictions_risk_level ON churn_predictions(risk_level);
CREATE INDEX idx_churn_predictions_risk_score ON churn_predictions(risk_score DESC);
CREATE INDEX idx_churn_predictions_predicted_at ON churn_predictions(predicted_at DESC);
CREATE INDEX idx_churn_predictions_composite ON churn_predictions(risk_level, risk_score DESC, predicted_at DESC);

-- =============================================
-- 3. Create updated_at trigger
-- =============================================

CREATE OR REPLACE FUNCTION update_churn_predictions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_churn_predictions_updated_at
  BEFORE UPDATE ON churn_predictions
  FOR EACH ROW
  EXECUTE FUNCTION update_churn_predictions_updated_at();

-- =============================================
-- 4. Create RLS policies
-- =============================================

ALTER TABLE churn_predictions ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read churn predictions
CREATE POLICY "Allow authenticated users to read churn predictions"
  ON churn_predictions
  FOR SELECT
  TO authenticated
  USING (true);

-- Allow service role to insert/update churn predictions
CREATE POLICY "Allow service role to insert churn predictions"
  ON churn_predictions
  FOR INSERT
  TO service_role
  WITH CHECK (true);

CREATE POLICY "Allow service role to update churn predictions"
  ON churn_predictions
  FOR UPDATE
  TO service_role
  USING (true);

-- =============================================
-- 5. Create function to get latest predictions
-- =============================================

CREATE OR REPLACE FUNCTION get_latest_churn_predictions()
RETURNS TABLE (
  id UUID,
  client_name VARCHAR(255),
  client_id INTEGER,
  client_uuid TEXT,
  risk_score NUMERIC(5,2),
  risk_level VARCHAR(20),
  risk_factors JSONB,
  recommended_actions JSONB,
  predicted_at TIMESTAMPTZ,
  model_version VARCHAR(20)
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ON (cp.client_name)
    cp.id,
    cp.client_name,
    cp.client_id,
    cp.client_uuid,
    cp.risk_score,
    cp.risk_level,
    cp.risk_factors,
    cp.recommended_actions,
    cp.predicted_at,
    cp.model_version
  FROM churn_predictions cp
  ORDER BY cp.client_name, cp.predicted_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 6. Create function to calculate churn risk history
-- =============================================

CREATE OR REPLACE FUNCTION get_churn_risk_history(
  p_client_name TEXT,
  p_days_back INTEGER DEFAULT 90
)
RETURNS TABLE (
  predicted_at TIMESTAMPTZ,
  risk_score NUMERIC(5,2),
  risk_level VARCHAR(20)
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    cp.predicted_at,
    cp.risk_score,
    cp.risk_level
  FROM churn_predictions cp
  WHERE cp.client_name = p_client_name
    AND cp.predicted_at >= NOW() - (p_days_back || ' days')::INTERVAL
  ORDER BY cp.predicted_at ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- 7. Grant necessary permissions
-- =============================================

GRANT SELECT ON churn_predictions TO authenticated;
GRANT ALL ON churn_predictions TO service_role;
GRANT EXECUTE ON FUNCTION get_latest_churn_predictions() TO authenticated;
GRANT EXECUTE ON FUNCTION get_churn_risk_history(TEXT, INTEGER) TO authenticated;

-- =============================================
-- 8. Add comments for documentation
-- =============================================

COMMENT ON TABLE churn_predictions IS 'Stores churn risk predictions for clients based on multiple factors including NPS trends, compliance, support tickets, AR aging, revenue trends, and engagement frequency';
COMMENT ON COLUMN churn_predictions.risk_score IS 'Churn risk score from 0-100, where higher values indicate greater risk';
COMMENT ON COLUMN churn_predictions.risk_level IS 'Risk categorisation: high (>70), medium (40-70), low (<40)';
COMMENT ON COLUMN churn_predictions.risk_factors IS 'Array of JSON objects describing specific risk factors identified';
COMMENT ON COLUMN churn_predictions.recommended_actions IS 'Array of JSON objects with recommended actions to mitigate churn risk';
COMMENT ON COLUMN churn_predictions.model_version IS 'Version of the prediction model used';

-- =============================================
-- Migration Complete
-- =============================================
