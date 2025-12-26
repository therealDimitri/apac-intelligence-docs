-- Migration: Fix Event Compliance Materialized View to Handle Segment Changes
-- Date: 2025-12-02
-- Purpose: Fix duplicate event types caused by segment changes (e.g., Nurture → Collaboration)
-- Issue: Current view creates separate requirements for each segment period, causing duplicates
-- Fix: Aggregate requirements across all segment periods and deduplicate event types
--
-- Example Issue:
--   SA Health (iPro) has Nurture (Jan-Aug) → Collaboration (Sep onwards)
--   This creates duplicates: SLA/Service Review appears twice (0 events, then 7 events)
--   Dashboard shows the first occurrence (0 events) instead of the actual total
--
-- Solution:
--   1. Use client_segmentation table to get ALL segment periods for the year
--   2. Combine tier requirements from all periods (max required_count per event type)
--   3. Count ALL completed events for the year regardless of segment period
--   4. Deduplicate so each event type appears only ONCE with total counts

-- ============================================================================
-- 1. DROP AND RECREATE MATERIALIZED VIEW
-- ============================================================================

DROP MATERIALIZED VIEW IF EXISTS event_compliance_summary CASCADE;

CREATE MATERIALIZED VIEW event_compliance_summary AS
WITH
-- CTE 1: Get all client-segment-tier mappings including segment change history
-- This replaces the old client_tiers CTE that only looked at current segment
client_segment_periods AS (
  SELECT DISTINCT
    cs.client_name,
    cs.tier_id,
    COALESCE(t.tier_name, c.segment) as segment,  -- Fallback to nps_clients if no history
    c.cse,
    EXTRACT(YEAR FROM cs.effective_from)::INTEGER as year
  FROM client_segmentation cs
  JOIN segmentation_tiers t ON t.id = cs.tier_id
  LEFT JOIN nps_clients c ON c.client_name = cs.client_name
  WHERE cs.effective_from IS NOT NULL
    AND cs.client_name != 'Parkway'  -- Exclude churned clients

  UNION

  -- Also include clients without segment change history (use current segment)
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

-- CTE 2: Get tier requirements with event type details
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

-- CTE 3: Combine requirements across all segment periods for each client-year
-- Deduplicate event types by taking MAX required_count if event appears in multiple tiers
combined_requirements AS (
  SELECT
    csp.client_name,
    csp.segment,  -- Use LATEST segment name for display
    csp.cse,
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code,
    MAX(tr.required_count) as required_count,  -- Take max if event in multiple tiers
    BOOL_OR(tr.is_mandatory) as is_mandatory    -- TRUE if mandatory in ANY tier
  FROM client_segment_periods csp
  INNER JOIN tier_requirements tr ON tr.tier_id = csp.tier_id
  GROUP BY
    csp.client_name,
    csp.segment,
    csp.cse,
    csp.year,
    tr.event_type_id,
    tr.event_name,
    tr.event_code
),

-- CTE 4: Aggregate completed events by client, year, and event type
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

-- CTE 5: Calculate per-event-type compliance for each client
event_type_compliance AS (
  SELECT
    cr.client_name,
    cr.segment,
    cr.cse,
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

-- CTE 6: Aggregate to client-year level with all event compliance data
client_year_summary AS (
  SELECT
    etc.client_name,
    etc.segment,
    etc.cse,
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
  GROUP BY etc.client_name, etc.segment, etc.cse, etc.year
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
-- 2. RECREATE INDEXES FOR FAST LOOKUPS
-- ============================================================================

-- Primary lookup by client name and year
CREATE INDEX idx_event_compliance_client_year
ON event_compliance_summary(client_name, year);

-- Lookup by CSE (for CSE-specific views)
CREATE INDEX idx_event_compliance_cse
ON event_compliance_summary(cse);

-- Lookup by year (for yearly reports)
CREATE INDEX idx_event_compliance_year
ON event_compliance_summary(year DESC);

-- Lookup by overall status (for filtering)
CREATE INDEX idx_event_compliance_status
ON event_compliance_summary(overall_status);

-- Lookup by segment (for segment-specific views)
CREATE INDEX idx_event_compliance_segment
ON event_compliance_summary(segment);

-- Composite index for CSE + year queries
CREATE INDEX idx_event_compliance_cse_year
ON event_compliance_summary(cse, year DESC);

-- ============================================================================
-- 3. GRANT PERMISSIONS
-- ============================================================================

GRANT SELECT ON event_compliance_summary TO anon, authenticated;

-- ============================================================================
-- 4. INITIAL REFRESH
-- ============================================================================

REFRESH MATERIALIZED VIEW event_compliance_summary;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify SA Health (iPro) no longer has duplicates:
SELECT
  client_name,
  year,
  segment,
  overall_compliance_score,
  json_array_length(event_compliance) as event_type_count
FROM event_compliance_summary
WHERE client_name = 'SA Health (iPro)'
  AND year = 2025;

-- Expected: Should show ~9-10 unique event types, not 18 duplicates

-- Check all events for SA Health (iPro):
SELECT
  jsonb_pretty(event_compliance::jsonb)
FROM event_compliance_summary
WHERE client_name = 'SA Health (iPro)'
  AND year = 2025;

-- ============================================================================
-- NOTES
-- ============================================================================

-- Key Changes from Previous Version:
-- 1. Uses client_segmentation table to get ALL segment periods for a year
-- 2. Combines tier requirements across periods (max required_count per event)
-- 3. Deduplicates event types so each appears only ONCE
-- 4. Counts ALL events for the year regardless of which segment period
--
-- This fixes the duplicate event issue where SA Health (iPro) showed:
--   - SLA/Service Review: 0 events (wrong) + 7 events (correct) = duplicate
-- Now shows:
--   - SLA/Service Review: 7 events (single, correct entry)
