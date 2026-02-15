-- NPS Survey Metadata Table
-- Stores survey cycle information (surveys sent, etc.)

CREATE TABLE IF NOT EXISTS nps_survey_metadata (
  id SERIAL PRIMARY KEY,
  period VARCHAR(10) NOT NULL UNIQUE,
  surveys_sent INTEGER NOT NULL,
  survey_start_date DATE,
  survey_end_date DATE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert Q4 2025 metadata
INSERT INTO nps_survey_metadata (period, surveys_sent, survey_start_date, notes)
VALUES ('Q4 25', 142, '2025-10-01', 'Q4 2025 APAC NPS Survey - 142 surveys sent, 43 responses received (30.28% response rate)')
ON CONFLICT (period) DO UPDATE
SET surveys_sent = EXCLUDED.surveys_sent,
    survey_start_date = EXCLUDED.survey_start_date,
    notes = EXCLUDED.notes,
    updated_at = NOW();

-- Insert historical periods (approximate counts based on response data)
INSERT INTO nps_survey_metadata (period, surveys_sent, notes)
VALUES
  ('Q2 25', 150, 'Q2 2025 APAC NPS Survey - estimated based on 46 responses'),
  ('Q4 24', 200, 'Q4 2024 APAC NPS Survey - estimated based on 73 responses'),
  ('Q2 24', 100, 'Q2 2024 APAC NPS Survey - estimated based on 24 responses'),
  ('2023', 50, '2023 Annual NPS Survey - estimated based on 13 responses')
ON CONFLICT (period) DO NOTHING;

-- Create index
CREATE INDEX IF NOT EXISTS idx_survey_metadata_period ON nps_survey_metadata(period);

-- Verify data
SELECT
  period,
  surveys_sent,
  (SELECT COUNT(*) FROM nps_responses WHERE period = nps_survey_metadata.period) as responses_received,
  ROUND((SELECT COUNT(*) FROM nps_responses WHERE period = nps_survey_metadata.period)::numeric / surveys_sent * 100, 2) as response_rate_pct
FROM nps_survey_metadata
ORDER BY
  CASE
    WHEN period ~ '^\d{4}$' THEN CAST(period AS INTEGER)
    ELSE CAST(SUBSTRING(period FROM '\d{2}$') AS INTEGER) + 2000
  END DESC,
  CASE
    WHEN period ~ '^Q\d' THEN CAST(SUBSTRING(period FROM 'Q(\d)') AS INTEGER)
    ELSE 0
  END DESC;
