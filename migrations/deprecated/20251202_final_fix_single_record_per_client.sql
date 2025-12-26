-- Migration: Final Fix - Single Record Per Client-Year
-- Date: 2025-12-02
-- Purpose: Fix remaining issue where clients appear twice (once per segment)
-- Issue: Previous fix still groups by segment, creating 2 records for segment changes
-- Example: SA Health (iPro) appears twice - once for Nurture, once for Collaboration
--
-- Solution: Remove segment from GROUP BY and use LATEST segment for display

DROP MATERIALIZED VIEW IF EXISTS event_compliance_summary CASCADE;

CREATE MATERIALIZED VIEW event_compliance_summary AS
WITH
-- CTE 1: Get current segment for each client (for display purposes only)
current_client_segments AS (
  SELECT DISTINCT ON (client_name)
    client_name,
    segment,
    cse
  FROM nps_clients
  WHERE segment IS NOT NULL
    AND client_name != 'Parkway'
  ORDER BY client_name
),

-- CTE 2: Get all tier IDs for each client-year (from segment change history)
client_tier_mappings AS (
  SELECT DISTINCT
    cs.client_name,
    EXTRACT(YEAR FROM cs.effective_from)::INTEGER as year,
    cs.tier_id
  FROM client_segmentation cs
  WHERE cs.effective_from IS NOT NULL
    AND cs.client_name != 'Parkway'

  UNION

  -- Also include clients without segment change history (use current tier)
  SELECT DISTINCT
    c.client_name,
    EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER as year,
    t.id as tier_id
  FROM nps_clients c
  INNER JOIN segmentation_tiers t ON t.tier_name = c.segment
  WHERE c.segment IS NOT NULL
    AND c.client_name != 'Parkway'
    AND NOT EXISTS (
      SELECT 1 FROM client_segmentation cs2
      WHERE cs2.client_name = c.client_name
    )
),

-- CTE 3: Get tier requirements with event type details
tier_requirements AS (
  SELECT
    ter.tier_id,
    ter.event_type_id,
    ter.required_count,
    ter.is_mandatory,
    et.event_name,
    et.event_code
  FROM tier_event_requirements ter
  JOIN segmentation_event_types et ON et.id = ter.event_type_id
  WHERE ter.required_count > 0  -- Exclude greyed-out events with 0 requirement
),

-- CTE 4: Combine requirements across ALL segment periods for each client-year
-- KEY FIX: Remove segment from GROUP BY to ensure single record per client-year
combined_requirements AS (
  SELECT
    ctm.client_name,
    ctm.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code,
    MAX(tr.required_count) as required_count,  -- Take max if event in multiple tiers
    BOOL_OR(tr.is_mandatory) as is_mandatory    -- TRUE if mandatory in ANY tier
  FROM client_tier_mappings ctm
  INNER JOIN tier_requirements tr ON tr.tier_id = ctm.tier_id
  GROUP BY
    ctm.client_name,
    ctm.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code
),

-- CTE 5: Aggregate completed events by client, year, and event type
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

-- CTE 6: Calculate per-event-type compliance for each client
event_type_compliance AS (
  SELECT
    cr.client_name,
    cr.year,
    cr.event_type_id,
    cr.event_name,
    cr.event_code,
    cr.required_count as expected_count,
    COALESCE(ec.completed_count, 0) as actual_count,
    cr.is_mandatory,
    COALESCE(ec.completed_events, '[]'::json) as events,

    -- Calculate compliance percentage
    CASE
      WHEN cr.required_count > 0 THEN
        ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.required_count) * 100)
      WHEN COALESCE(ec.completed_count, 0) > 0 THEN 100
      ELSE 0
    END as compliance_percentage,

    -- Determine status based on compliance percentage
    CASE
      WHEN cr.required_count > 0 THEN
        CASE
          WHEN ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.required_count) * 100) < 50 THEN 'critical'
          WHEN ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.required_count) * 100) < 100 THEN 'at-risk'
          WHEN ROUND((COALESCE(ec.completed_count, 0)::DECIMAL / cr.required_count) * 100) = 100 THEN 'compliant'
          ELSE 'exceeded'
        END
      WHEN COALESCE(ec.completed_count, 0) > 0 THEN 'exceeded'
      ELSE 'critical'
    END as status,

    -- Priority level based on is_mandatory flag
    CASE
      WHEN cr.is_mandatory THEN 'high'
      ELSE 'medium'
    END as priority_level

  FROM combined_requirements cr
  LEFT JOIN event_counts ec
    ON ec.client_name = cr.client_name
    AND ec.event_year = cr.year
    AND ec.event_type_id = cr.event_type_id
),

-- CTE 7: Aggregate to client-year level with all event compliance data
client_year_summary AS (
  SELECT
    etc.client_name,
    ccs.segment,  -- Get current segment from separate CTE
    ccs.cse,      -- Get CSE from separate CTE
    etc.year,

    -- Aggregate event_compliance as JSON array
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
        etc.is_mandatory DESC,  -- Mandatory events first
        etc.compliance_percentage ASC  -- Lowest compliance first
    ) as event_compliance,

    -- Calculate overall compliance metrics
    COUNT(*) as total_event_types_count,
    COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100) as compliant_event_types_count,

    -- Overall compliance score: (Compliant Event Types / Total Event Types) × 100
    ROUND(
      (COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100)::DECIMAL /
       NULLIF(COUNT(*), 0)) * 100
    ) as overall_compliance_score,

    -- Overall status based on score
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
  INNER JOIN current_client_segments ccs ON ccs.client_name = etc.client_name
  GROUP BY etc.client_name, ccs.segment, ccs.cse, etc.year
)

-- Final SELECT: Return client-year compliance summary
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

-- ============================================================================
-- RECREATE INDEXES
-- ============================================================================

CREATE INDEX idx_event_compliance_client_year
ON event_compliance_summary(client_name, year);

CREATE INDEX idx_event_compliance_cse
ON event_compliance_summary(cse);

CREATE INDEX idx_event_compliance_year
ON event_compliance_summary(year DESC);

CREATE INDEX idx_event_compliance_status
ON event_compliance_summary(overall_status);

CREATE INDEX idx_event_compliance_segment
ON event_compliance_summary(segment);

CREATE INDEX idx_event_compliance_cse_year
ON event_compliance_summary(cse, year DESC);

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================

GRANT SELECT ON event_compliance_summary TO anon, authenticated;

-- ============================================================================
-- REFRESH
-- ============================================================================

REFRESH MATERIALIZED VIEW event_compliance_summary;

-- ============================================================================
-- VERIFICATION
-- ============================================================================

-- Should return ONLY 1 record for SA Health (iPro) in 2025
SELECT
  client_name,
  year,
  segment,
  overall_compliance_score,
  total_event_types_count
FROM event_compliance_summary
WHERE client_name = 'SA Health (iPro)'
  AND year = 2025;

-- Expected: 1 row with segment='Collaboration' (current segment)
