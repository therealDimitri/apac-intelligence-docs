-- Migration: Add Client Event Exclusions for Greyed-Out Events
-- Date: 2025-12-02
-- Purpose: Support client-specific event exclusions (greyed-out in Excel)
-- Issue: Some events are required by tier but don't apply to specific clients
-- Example: Whitespace Demos (Sunrise) is greyed out for SA Health (iPro)
--
-- Solution: Create client_event_exclusions table and update materialized view

-- ============================================================================
-- 1. REFRESH MATERIALIZED VIEW TO INCLUDE NEW APAC CLIENT FORUM EVENT
-- ============================================================================

REFRESH MATERIALIZED VIEW event_compliance_summary;

-- ============================================================================
-- 2. CREATE CLIENT EVENT EXCLUSIONS TABLE
-- ============================================================================

CREATE TABLE IF NOT EXISTS client_event_exclusions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name TEXT NOT NULL,
  event_type_id UUID NOT NULL REFERENCES segmentation_event_types(id),
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  created_by TEXT,

  -- Ensure unique combination
  UNIQUE(client_name, event_type_id)
);

-- Create index for fast lookups
CREATE INDEX IF NOT EXISTS idx_client_event_exclusions_client
ON client_event_exclusions(client_name);

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON client_event_exclusions TO authenticated;
GRANT SELECT ON client_event_exclusions TO anon;

-- ============================================================================
-- 3. INSERT EXCLUSIONS FOR SA HEALTH (iPro)
-- ============================================================================

-- Based on Excel: These events are greyed out for SA Health (iPro)
INSERT INTO client_event_exclusions (client_name, event_type_id, reason)
VALUES
  -- Whitespace Demos (Sunrise) - greyed out
  ('SA Health (iPro)', '79f7ee4a-def2-4de2-91cd-43f6d2d9296e', 'Greyed out in Excel - does not apply to this client'),

  -- Health Check (Opal) - greyed out (only required in Nurture tier, but excluded for this client)
  ('SA Health (iPro)', 'cf5c4f53-c562-4ab7-81f9-b4c79d34089a', 'Greyed out in Excel - does not apply to this client'),

  -- EVP Engagement - greyed out
  ('SA Health (iPro)', 'f1fa97ca-2a61-4aa0-a21f-d873d2858774', 'Greyed out in Excel - does not apply to this client')
ON CONFLICT (client_name, event_type_id) DO NOTHING;

-- ============================================================================
-- 4. UPDATE MATERIALIZED VIEW TO RESPECT EXCLUSIONS
-- ============================================================================

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
  WHERE ter.required_count > 0  -- Exclude events with 0 requirement
),

-- CTE 4: Combine requirements across ALL segment periods for each client-year
-- EXCLUDE events that are in client_event_exclusions table
combined_requirements AS (
  SELECT
    ctm.client_name,
    ctm.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code,
    MAX(tr.required_count) as required_count,
    BOOL_OR(tr.is_mandatory) as is_mandatory
  FROM client_tier_mappings ctm
  INNER JOIN tier_requirements tr ON tr.tier_id = ctm.tier_id
  -- EXCLUDE greyed-out events for this client
  WHERE NOT EXISTS (
    SELECT 1 FROM client_event_exclusions cee
    WHERE cee.client_name = ctm.client_name
      AND cee.event_type_id = tr.event_type_id
  )
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
    ccs.segment,
    ccs.cse,
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
        etc.is_mandatory DESC,
        etc.compliance_percentage ASC
    ) as event_compliance,

    -- Calculate overall compliance metrics
    COUNT(*) as total_event_types_count,
    COUNT(*) FILTER (WHERE etc.compliance_percentage >= 100) as compliant_event_types_count,

    -- Overall compliance score
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

-- Final SELECT
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

CREATE INDEX IF NOT EXISTS idx_event_compliance_client_year
ON event_compliance_summary(client_name, year);

CREATE INDEX IF NOT EXISTS idx_event_compliance_cse
ON event_compliance_summary(cse);

CREATE INDEX IF NOT EXISTS idx_event_compliance_year
ON event_compliance_summary(year DESC);

CREATE INDEX IF NOT EXISTS idx_event_compliance_status
ON event_compliance_summary(overall_status);

CREATE INDEX IF NOT EXISTS idx_event_compliance_segment
ON event_compliance_summary(segment);

CREATE INDEX IF NOT EXISTS idx_event_compliance_cse_year
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

-- Check SA Health (iPro) - should now show 8 event types (not 11)
-- Excluded: Whitespace Demos, Health Check (Opal), EVP Engagement
SELECT
  client_name,
  year,
  segment,
  overall_compliance_score,
  total_event_types_count,
  compliant_event_types_count
FROM event_compliance_summary
WHERE client_name = 'SA Health (iPro)'
  AND year = 2025;

-- Expected: 8 event types (was 11 before exclusions)
-- Compliant: 8 of 8 (100%) - all required events completed!
