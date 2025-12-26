-- Migration: Update Health Score Formula with Actions Management and Recency
-- Date: 2025-12-03
-- Purpose: Enhance health score to include:
--   1. Actions Management (completion rate + open actions)
--   2. Recency (days since last interaction with bonus/penalty)
--
-- NEW FORMULA BREAKDOWN (100 points total):
--   - NPS Score (20 points)
--   - Engagement (15 points) - Meeting frequency in last 30/90 days
--   - Recency (15 points) - Days since last meeting (bonus/penalty)
--   - Compliance (30 points) - Segmentation event compliance
--   - Actions Management (20 points) - Completion rate (15) + Open actions penalty (5)
--
-- RECENCY SCORING:
--   - Last meeting within 7 days: +15 points (excellent)
--   - Last meeting within 14 days: +12 points (good)
--   - Last meeting within 30 days: +10 points (acceptable)
--   - Last meeting within 60 days: +5 points (concerning)
--   - Last meeting within 90 days: +2 points (at risk)
--   - Last meeting >90 days ago: 0 points (critical)
--
-- ACTIONS MANAGEMENT SCORING:
--   - Completion rate component (15 points max):
--     * 80-100% completion: 15 points
--     * 60-80% completion: 12 points
--     * 40-60% completion: 8 points
--     * 20-40% completion: 4 points
--     * <20% completion: 2 points
--   - Open actions penalty (5 points max):
--     * 0 open actions: +5 points
--     * 1-2 open actions: +4 points
--     * 3-5 open actions: +2 points
--     * >5 open actions: 0 points

-- ============================================================================
-- 1. DROP EXISTING VIEW
-- ============================================================================

DROP MATERIALIZED VIEW IF EXISTS client_health_summary CASCADE;

-- ============================================================================
-- 2. CREATE UPDATED MATERIALIZED VIEW
-- ============================================================================

CREATE MATERIALIZED VIEW client_health_summary AS
SELECT
  c.id,
  c.client_name,
  c.segment,
  c.cse,
  c.created_at,
  c.updated_at,

  -- NPS Metrics (cached calculation from nps_responses)
  COALESCE(nps_metrics.nps_score, 0) as nps_score,
  COALESCE(nps_metrics.promoter_count, 0) as promoter_count,
  COALESCE(nps_metrics.passive_count, 0) as passive_count,
  COALESCE(nps_metrics.detractor_count, 0) as detractor_count,
  COALESCE(nps_metrics.response_count, 0) as response_count,
  nps_metrics.last_response_date,

  -- Engagement Metrics (from unified_meetings)
  meeting_metrics.last_meeting_date,
  COALESCE(meeting_metrics.meeting_count_30d, 0) as meeting_count_30d,
  COALESCE(meeting_metrics.meeting_count_90d, 0) as meeting_count_90d,
  COALESCE(meeting_metrics.days_since_last_meeting, 999) as days_since_last_meeting,

  -- Action Metrics (from actions table) - ENHANCED
  COALESCE(action_metrics.total_actions_count, 0) as total_actions_count,
  COALESCE(action_metrics.completed_actions_count, 0) as completed_actions_count,
  COALESCE(action_metrics.open_actions_count, 0) as open_actions_count,
  COALESCE(action_metrics.overdue_actions_count, 0) as overdue_actions_count,
  COALESCE(action_metrics.completion_rate, 0) as completion_rate,

  -- Compliance Metrics (from segmentation_event_compliance)
  compliance_metrics.compliance_percentage,
  compliance_metrics.compliance_status,

  -- Calculated Health Score (0-100 scale)
  -- NEW FORMULA: NPS (20) + Engagement (15) + Recency (15) + Compliance (30) + Actions (20)
  LEAST(100, GREATEST(0, ROUND(
    -- 1. NPS Score Component (20 points max)
    -- Convert NPS from -100/+100 scale to 0-20 point contribution
    ((COALESCE(nps_metrics.nps_score, 0) + 100) / 200.0 * 20) +

    -- 2. Engagement Component (15 points max)
    -- Based on meeting frequency in last 30 and 90 days
    (CASE
      WHEN COALESCE(meeting_metrics.meeting_count_30d, 0) >= 3 THEN 8
      WHEN COALESCE(meeting_metrics.meeting_count_30d, 0) >= 2 THEN 6
      WHEN COALESCE(meeting_metrics.meeting_count_30d, 0) >= 1 THEN 4
      ELSE 1
    END) +
    (CASE
      WHEN COALESCE(meeting_metrics.meeting_count_90d, 0) >= 6 THEN 7
      WHEN COALESCE(meeting_metrics.meeting_count_90d, 0) >= 4 THEN 5
      WHEN COALESCE(meeting_metrics.meeting_count_90d, 0) >= 2 THEN 3
      WHEN COALESCE(meeting_metrics.meeting_count_90d, 0) >= 1 THEN 1
      ELSE 0
    END) +

    -- 3. Recency Component (15 points max) - NEW
    -- Days since last meeting - critical for relationship health
    (CASE
      WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 7 THEN 15
      WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 14 THEN 12
      WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 30 THEN 10
      WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 60 THEN 5
      WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 90 THEN 2
      ELSE 0
    END) +

    -- 4. Compliance Component (30 points max)
    -- Segmentation event compliance percentage
    (COALESCE(compliance_metrics.compliance_percentage, 50) / 100.0 * 30) +

    -- 5. Actions Management Component (20 points max) - ENHANCED
    -- Part A: Completion Rate (15 points max)
    (CASE
      WHEN COALESCE(action_metrics.completion_rate, 0) >= 80 THEN 15
      WHEN COALESCE(action_metrics.completion_rate, 0) >= 60 THEN 12
      WHEN COALESCE(action_metrics.completion_rate, 0) >= 40 THEN 8
      WHEN COALESCE(action_metrics.completion_rate, 0) >= 20 THEN 4
      WHEN COALESCE(action_metrics.total_actions_count, 0) = 0 THEN 10  -- No actions = neutral score
      ELSE 2
    END) +
    -- Part B: Open Actions Penalty (5 points max)
    (CASE
      WHEN COALESCE(action_metrics.open_actions_count, 0) = 0 THEN 5
      WHEN COALESCE(action_metrics.open_actions_count, 0) <= 2 THEN 4
      WHEN COALESCE(action_metrics.open_actions_count, 0) <= 5 THEN 2
      ELSE 0
    END)
  ))) as health_score,

  -- Calculated Status based on health score
  CASE
    WHEN ROUND(
      ((COALESCE(nps_metrics.nps_score, 0) + 100) / 200.0 * 20) +
      (CASE
        WHEN COALESCE(meeting_metrics.meeting_count_30d, 0) >= 3 THEN 8
        WHEN COALESCE(meeting_metrics.meeting_count_30d, 0) >= 2 THEN 6
        WHEN COALESCE(meeting_metrics.meeting_count_30d, 0) >= 1 THEN 4
        ELSE 1
      END) +
      (CASE
        WHEN COALESCE(meeting_metrics.meeting_count_90d, 0) >= 6 THEN 7
        WHEN COALESCE(meeting_metrics.meeting_count_90d, 0) >= 4 THEN 5
        WHEN COALESCE(meeting_metrics.meeting_count_90d, 0) >= 2 THEN 3
        WHEN COALESCE(meeting_metrics.meeting_count_90d, 0) >= 1 THEN 1
        ELSE 0
      END) +
      (CASE
        WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 7 THEN 15
        WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 14 THEN 12
        WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 30 THEN 10
        WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 60 THEN 5
        WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 90 THEN 2
        ELSE 0
      END) +
      (COALESCE(compliance_metrics.compliance_percentage, 50) / 100.0 * 30) +
      (CASE
        WHEN COALESCE(action_metrics.completion_rate, 0) >= 80 THEN 15
        WHEN COALESCE(action_metrics.completion_rate, 0) >= 60 THEN 12
        WHEN COALESCE(action_metrics.completion_rate, 0) >= 40 THEN 8
        WHEN COALESCE(action_metrics.completion_rate, 0) >= 20 THEN 4
        WHEN COALESCE(action_metrics.total_actions_count, 0) = 0 THEN 10
        ELSE 2
      END) +
      (CASE
        WHEN COALESCE(action_metrics.open_actions_count, 0) = 0 THEN 5
        WHEN COALESCE(action_metrics.open_actions_count, 0) <= 2 THEN 4
        WHEN COALESCE(action_metrics.open_actions_count, 0) <= 5 THEN 2
        ELSE 0
      END)
    ) >= 75 THEN 'healthy'
    WHEN ROUND(
      ((COALESCE(nps_metrics.nps_score, 0) + 100) / 200.0 * 20) +
      (CASE
        WHEN COALESCE(meeting_metrics.meeting_count_30d, 0) >= 3 THEN 8
        WHEN COALESCE(meeting_metrics.meeting_count_30d, 0) >= 2 THEN 6
        WHEN COALESCE(meeting_metrics.meeting_count_30d, 0) >= 1 THEN 4
        ELSE 1
      END) +
      (CASE
        WHEN COALESCE(meeting_metrics.meeting_count_90d, 0) >= 6 THEN 7
        WHEN COALESCE(meeting_metrics.meeting_count_90d, 0) >= 4 THEN 5
        WHEN COALESCE(meeting_metrics.meeting_count_90d, 0) >= 2 THEN 3
        WHEN COALESCE(meeting_metrics.meeting_count_90d, 0) >= 1 THEN 1
        ELSE 0
      END) +
      (CASE
        WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 7 THEN 15
        WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 14 THEN 12
        WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 30 THEN 10
        WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 60 THEN 5
        WHEN COALESCE(meeting_metrics.days_since_last_meeting, 999) <= 90 THEN 2
        ELSE 0
      END) +
      (COALESCE(compliance_metrics.compliance_percentage, 50) / 100.0 * 30) +
      (CASE
        WHEN COALESCE(action_metrics.completion_rate, 0) >= 80 THEN 15
        WHEN COALESCE(action_metrics.completion_rate, 0) >= 60 THEN 12
        WHEN COALESCE(action_metrics.completion_rate, 0) >= 40 THEN 8
        WHEN COALESCE(action_metrics.completion_rate, 0) >= 20 THEN 4
        WHEN COALESCE(action_metrics.total_actions_count, 0) = 0 THEN 10
        ELSE 2
      END) +
      (CASE
        WHEN COALESCE(action_metrics.open_actions_count, 0) = 0 THEN 5
        WHEN COALESCE(action_metrics.open_actions_count, 0) <= 2 THEN 4
        WHEN COALESCE(action_metrics.open_actions_count, 0) <= 5 THEN 2
        ELSE 0
      END)
    ) < 50 THEN 'critical'
    ELSE 'at-risk'
  END as status,

  -- Metadata
  NOW() as last_refreshed

FROM nps_clients c

-- LEFT JOIN for NPS Metrics (calculate NPS score from responses)
LEFT JOIN LATERAL (
  SELECT
    -- NPS = % Promoters (9-10) - % Detractors (0-6)
    ROUND(
      (COUNT(*) FILTER (WHERE score >= 9)::DECIMAL / NULLIF(COUNT(*), 0) * 100) -
      (COUNT(*) FILTER (WHERE score <= 6)::DECIMAL / NULLIF(COUNT(*), 0) * 100)
    ) as nps_score,
    COUNT(*) FILTER (WHERE score >= 9) as promoter_count,
    COUNT(*) FILTER (WHERE score BETWEEN 7 AND 8) as passive_count,
    COUNT(*) FILTER (WHERE score <= 6) as detractor_count,
    COUNT(*) as response_count,
    MAX(response_date) as last_response_date
  FROM nps_responses r
  WHERE r.client_name = c.client_name
) nps_metrics ON true

-- LEFT JOIN for Meeting Metrics (engagement data + recency)
LEFT JOIN LATERAL (
  SELECT
    MAX(meeting_date) as last_meeting_date,
    COUNT(*) FILTER (WHERE meeting_date >= CURRENT_DATE - INTERVAL '30 days') as meeting_count_30d,
    COUNT(*) FILTER (WHERE meeting_date >= CURRENT_DATE - INTERVAL '90 days') as meeting_count_90d,
    COALESCE(CURRENT_DATE - MAX(meeting_date)::DATE, 999) as days_since_last_meeting
  FROM unified_meetings m
  WHERE m.client_name = c.client_name
) meeting_metrics ON true

-- LEFT JOIN for Action Metrics (ENHANCED with completion rate)
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) as total_actions_count,
    COUNT(*) FILTER (WHERE "Status" IN ('Completed', 'Closed')) as completed_actions_count,
    COUNT(*) FILTER (WHERE "Status" NOT IN ('Completed', 'Closed', 'Cancelled')) as open_actions_count,
    COUNT(*) FILTER (
      WHERE "Status" NOT IN ('Completed', 'Closed', 'Cancelled')
        AND "Due_Date" IS NOT NULL
        AND TO_DATE("Due_Date", 'DD/MM/YYYY') < CURRENT_DATE
    ) as overdue_actions_count,
    -- Completion Rate: (Completed / Total) * 100
    CASE
      WHEN COUNT(*) > 0 THEN
        ROUND((COUNT(*) FILTER (WHERE "Status" IN ('Completed', 'Closed'))::DECIMAL / COUNT(*) * 100))
      ELSE 0
    END as completion_rate
  FROM actions a
  WHERE a.client = c.client_name
) action_metrics ON true

-- LEFT JOIN for Compliance Metrics (segmentation event compliance)
LEFT JOIN LATERAL (
  SELECT
    AVG(compliance_percentage) as compliance_percentage,
    CASE
      WHEN AVG(compliance_percentage) >= 90 THEN 'compliant'
      WHEN AVG(compliance_percentage) >= 70 THEN 'warning'
      ELSE 'non-compliant'
    END as compliance_status
  FROM segmentation_event_compliance ec
  WHERE ec.client_name = c.client_name
    AND ec.year = EXTRACT(YEAR FROM CURRENT_DATE)::INTEGER
) compliance_metrics ON true

-- Exclude churned clients
WHERE c.client_name != 'Parkway'

ORDER BY c.client_name;

-- ============================================================================
-- 3. CREATE INDEXES FOR FAST LOOKUPS
-- ============================================================================

-- Primary lookup by client name
CREATE UNIQUE INDEX idx_client_health_summary_client_name
ON client_health_summary(client_name);

-- Lookup by CSE (for CSE-specific views)
CREATE INDEX idx_client_health_summary_cse
ON client_health_summary(cse);

-- Lookup by health score (for sorting)
CREATE INDEX idx_client_health_summary_health_score
ON client_health_summary(health_score DESC);

-- Lookup by status (for filtering)
CREATE INDEX idx_client_health_summary_status
ON client_health_summary(status);

-- Lookup by segment (for segment-specific views)
CREATE INDEX idx_client_health_summary_segment
ON client_health_summary(segment);

-- ============================================================================
-- 4. GRANT PERMISSIONS (FOR ANON/AUTHENTICATED USERS)
-- ============================================================================

GRANT SELECT ON client_health_summary TO anon, authenticated;

-- ============================================================================
-- 5. INITIAL REFRESH
-- ============================================================================

REFRESH MATERIALIZED VIEW client_health_summary;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify the updated formula:
SELECT
  client_name,
  health_score,
  status,
  nps_score,
  meeting_count_30d,
  days_since_last_meeting,
  completion_rate,
  open_actions_count,
  compliance_percentage
FROM client_health_summary
ORDER BY health_score DESC
LIMIT 10;
