-- ============================================================================
-- Add Client-Specific Event Exclusions Support
-- ============================================================================
-- Date: 2025-12-23
-- Purpose: Allow excluding specific event types from specific clients
--
-- Use Case: Department of Health - Victoria should not have Health Check (Opal)
-- requirement, but other Nurture tier clients should keep it.
-- ============================================================================

-- Step 1: Create exclusions table
CREATE TABLE IF NOT EXISTS client_event_exclusions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_name TEXT NOT NULL,
  event_type_id UUID NOT NULL REFERENCES segmentation_event_types(id),
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by TEXT,
  UNIQUE(client_name, event_type_id)
);

-- Grant access
GRANT SELECT ON client_event_exclusions TO anon, authenticated;
GRANT ALL ON client_event_exclusions TO service_role;

-- Create index
CREATE INDEX IF NOT EXISTS idx_client_event_exclusions_client
  ON client_event_exclusions(client_name);

-- Step 2: Insert exclusion for Department of Health - Victoria
INSERT INTO client_event_exclusions (client_name, event_type_id, reason, created_by)
SELECT
  'Department of Health - Victoria',
  id,
  'DoH Victoria does not require Health Check (Opal) events per business decision - Dec 2025',
  'system'
FROM segmentation_event_types
WHERE event_name = 'Health Check (Opal)'
ON CONFLICT (client_name, event_type_id) DO NOTHING;

-- Step 3: Update materialized view to respect exclusions
DROP MATERIALIZED VIEW IF EXISTS event_compliance_summary CASCADE;

CREATE MATERIALIZED VIEW event_compliance_summary AS
WITH
client_segment_periods AS (
  SELECT DISTINCT
    cs.client_name,
    cs.tier_id,
    COALESCE(t.tier_name, c.segment) as segment,
    c.cse,
    EXTRACT(YEAR FROM cs.effective_from)::INTEGER as year
  FROM client_segmentation cs
  JOIN segmentation_tiers t ON t.id = cs.tier_id
  LEFT JOIN nps_clients c ON c.client_name = cs.client_name
  WHERE cs.effective_from IS NOT NULL
    AND cs.client_name != 'Parkway'

  UNION

  SELECT DISTINCT
    c.client_name,
    t.id as tier_id,
    c.segment,
    c.cse,
    EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER as year
  FROM nps_clients c
  LEFT JOIN segmentation_tiers t ON t.tier_name = c.segment
  WHERE c.segment IS NOT NULL
    AND c.client_name != 'Parkway'
    AND NOT EXISTS (
      SELECT 1 FROM client_segmentation cs2
      WHERE cs2.client_name = c.client_name
    )
),

latest_segment AS (
  SELECT DISTINCT ON (client_name, year)
    client_name,
    segment,
    cse,
    year
  FROM client_segment_periods
  ORDER BY client_name, year, segment DESC
),

tier_requirements AS (
  SELECT
    ter.tier_id,
    ter.event_type_id,
    ter.frequency as expected_frequency,
    et.event_name,
    et.event_code
  FROM tier_event_requirements ter
  JOIN segmentation_event_types et ON et.id = ter.event_type_id
  WHERE ter.frequency > 0
),

-- UPDATED: Combine requirements with client-specific exclusions support
combined_requirements AS (
  SELECT
    csp.client_name,
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code,
    MAX(tr.expected_frequency) as expected_count
  FROM client_segment_periods csp
  INNER JOIN tier_requirements tr ON tr.tier_id = csp.tier_id
  -- EXCLUDE client-specific exclusions
  WHERE NOT EXISTS (
    SELECT 1 FROM client_event_exclusions cee
    WHERE cee.client_name = csp.client_name
      AND cee.event_type_id = tr.event_type_id
  )
  GROUP BY
    csp.client_name,
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code
),

event_counts AS (
  SELECT
    se.client_name,
    se.event_year,
    se.event_type_id,
    COUNT(*) FILTER (WHERE se.completed = true) as completed_count,
    COUNT(*) as total_count,
    json_agg(
      json_build_object(
        'id', se.id,
        'event_date', se.event_date,
        'period', se.period,
        'completed', se.completed,
        'completed_date', se.completed_date,
        'notes', se.notes,
        'meeting_link', se.meeting_link
      )
      ORDER BY se.event_date DESC
    ) FILTER (WHERE se.completed = true) as completed_events
  FROM segmentation_events se
  GROUP BY se.client_name, se.event_year, se.event_type_id
),

event_type_compliance AS (
  SELECT
    cr.client_name,
    cr.year,
    cr.event_type_id,
    cr.event_name,
    cr.event_code,
    cr.expected_count,
    COALESCE(ec.completed_count, 0) as actual_count,
    COALESCE(ec.completed_events, '[]'::json) as events,
    CASE
      WHEN cr.expected_count > 0 THEN
        ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.expected_count) * 100)
      WHEN COALESCE(ec.completed_count, 0) > 0 THEN 100
      ELSE 0
    END as compliance_percentage,
    CASE
      WHEN cr.expected_count > 0 THEN
        CASE
          WHEN ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.expected_count) * 100) < 50 THEN 'critical'
          WHEN ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.expected_count) * 100) < 100 THEN 'at-risk'
          WHEN ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.expected_count) * 100) = 100 THEN 'compliant'
          ELSE 'exceeded'
        END
      WHEN COALESCE(ec.completed_count, 0) > 0 THEN 'exceeded'
      ELSE 'critical'
    END as status,
    'high' as priority_level,
    TRUE as is_mandatory
  FROM combined_requirements cr
  LEFT JOIN event_counts ec
    ON ec.client_name = cr.client_name
    AND ec.event_year = cr.year
    AND ec.event_type_id = cr.event_type_id
),

client_year_summary AS (
  SELECT
    etc.client_name,
    ls.segment,
    ls.cse,
    etc.year,
    json_agg(
      json_build_object(
        'event_type_id', etc.event_type_id,
        'event_type_name', etc.event_name,
        'event_code', etc.event_code,
        'expected_count', etc.expected_count,
        'actual_count', etc.actual_count,
        'compliance_percentage', etc.compliance_percentage,
        'status', etc.status,
        'priority_level', etc.priority_level,
        'is_mandatory', etc.is_mandatory,
        'events', etc.events
      )
      ORDER BY
        etc.is_mandatory DESC,
        etc.compliance_percentage ASC
    ) as event_compliance,
    COUNT(*) as total_event_types_count,
    COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100) as compliant_event_types_count,
    ROUND(
      (COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100)::DECIMAL /
       NULLIF(COUNT(*), 0)) * 100
    ) as overall_compliance_score,
    CASE
      WHEN ROUND(
        (COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100)::DECIMAL /
         NULLIF(COUNT(*), 0)) * 100
      ) < 50 THEN 'critical'
      WHEN ROUND(
        (COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100)::DECIMAL /
         NULLIF(COUNT(*), 0)) * 100
      ) < 100 THEN 'at-risk'
      ELSE 'compliant'
    END as overall_status,
    NOW() as last_updated
  FROM event_type_compliance etc
  INNER JOIN latest_segment ls
    ON ls.client_name = etc.client_name
    AND ls.year = etc.year
  GROUP BY etc.client_name, ls.segment, ls.cse, etc.year
)

SELECT
  client_name,
  segment,
  cse,
  year,
  event_compliance,
  overall_compliance_score,
  overall_status,
  compliant_event_types_count,
  total_event_types_count,
  last_updated
FROM client_year_summary
ORDER BY year DESC, client_name;

-- Recreate indexes
CREATE INDEX idx_event_compliance_client_year ON event_compliance_summary(client_name, year);
CREATE INDEX idx_event_compliance_cse ON event_compliance_summary(cse);
CREATE INDEX idx_event_compliance_year ON event_compliance_summary(year DESC);
CREATE INDEX idx_event_compliance_status ON event_compliance_summary(overall_status);
CREATE INDEX idx_event_compliance_segment ON event_compliance_summary(segment);
CREATE INDEX idx_event_compliance_cse_year ON event_compliance_summary(cse, year DESC);
CREATE UNIQUE INDEX idx_event_compliance_unique_client_year ON event_compliance_summary(client_name, year);

-- Grant permissions
GRANT SELECT ON event_compliance_summary TO anon, authenticated;

-- Notify PostgREST to reload schema
NOTIFY pgrst, 'reload schema';

-- ============================================================================
-- VERIFICATION
-- ============================================================================
-- After running this migration, verify with:
--
-- SELECT client_name, overall_compliance_score,
--        (SELECT COUNT(*) FROM json_array_elements(event_compliance) ec
--         WHERE ec->>'event_type_name' = 'Health Check (Opal)') as has_health_check
-- FROM event_compliance_summary
-- WHERE client_name = 'Department of Health - Victoria' AND year = 2025;
--
-- Expected: has_health_check = 0, overall_compliance_score should be recalculated
-- ============================================================================
