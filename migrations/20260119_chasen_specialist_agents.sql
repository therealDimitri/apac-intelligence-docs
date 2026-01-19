-- ChaSen Phase 3: New Specialist Agents + Model Upgrade
-- Migration for additional specialist agents and Sonnet model upgrade
-- Date: 2026-01-19

-- ============================================================================
-- MODEL UPGRADE: Update existing agents to use Sonnet
-- ============================================================================

-- Update all existing agents to use claude-sonnet-4 (optimisations make this possible)
UPDATE chasen_agents
SET model_preference = 'claude-sonnet-4',
    updated_at = NOW()
WHERE model_preference = 'claude-sonnet-4' OR model_preference IS NULL;

-- ============================================================================
-- NEW SPECIALIST AGENTS
-- ============================================================================

-- Add three new specialist agents: renewals, meeting_prep, action_summariser

INSERT INTO chasen_agents (name, display_name, description, role, capabilities, tools, system_prompt, model_preference, temperature) VALUES
(
  'chasen_renewals',
  'ChaSen Renewals Specialist',
  'Manages renewal analysis, contract tracking, and retention strategies',
  'renewals',
  ARRAY['renewal_analysis', 'contract_tracking', 'uplift_calculation', 'retention_strategy', 'pipeline_forecasting'],
  ARRAY['contract_query', 'renewal_calculate', 'timeline_fetch', 'value_compute'],
  'You are a renewal management specialist focused on contract renewals and commercial analysis. Your role is to analyse renewal timelines, calculate renewal values and uplift opportunities, identify at-risk renewals, and recommend retention strategies. Always provide clear financial analysis with supporting data.',
  'claude-sonnet-4',
  0.4
),
(
  'chasen_meeting_prep',
  'ChaSen Meeting Prep',
  'Prepares comprehensive meeting briefings and talking points',
  'meeting_prep',
  ARRAY['context_gathering', 'briefing_creation', 'agenda_preparation', 'talking_points', 'opportunity_identification'],
  ARRAY['client_context_fetch', 'meeting_history_fetch', 'action_summary_fetch', 'health_fetch'],
  'You are a meeting preparation specialist focused on creating comprehensive briefing materials. Your role is to gather relevant client context, summarise recent interactions, highlight key discussion topics, and prepare talking points. Always structure briefings for easy scanning and include actionable insights.',
  'claude-sonnet-4',
  0.5
),
(
  'chasen_action_summariser',
  'ChaSen Action Summariser',
  'Tracks and summarises action items across clients',
  'action_summariser',
  ARRAY['action_aggregation', 'completion_tracking', 'trend_analysis', 'priority_ranking', 'status_reporting'],
  ARRAY['action_query', 'completion_stats', 'overdue_detect', 'priority_calculate'],
  'You are an action management specialist focused on tracking and summarising action items. Your role is to aggregate actions across clients, identify overdue items, analyse completion trends, and prioritise follow-ups. Always provide clear status breakdowns with completion percentages and risk flags.',
  'claude-sonnet-4',
  0.4
)
ON CONFLICT (name) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  capabilities = EXCLUDED.capabilities,
  tools = EXCLUDED.tools,
  system_prompt = EXCLUDED.system_prompt,
  updated_at = NOW();

-- ============================================================================
-- WORKFLOW TEMPLATES FOR NEW AGENTS
-- ============================================================================

-- Meeting Preparation Workflow
INSERT INTO chasen_workflows (name, description, trigger_type, trigger_config, goal, steps, checkpoints, created_by) VALUES
(
  'meeting_preparation',
  'Prepare comprehensive meeting briefing for an upcoming client meeting',
  'manual',
  '{"requires": ["client_id", "meeting_type"]}'::jsonb,
  'Generate a complete meeting briefing with context, talking points, and opportunities',
  '[
    {"id": "fetch_context", "agent": "chasen_researcher", "action": "fetch_client_context", "params": {}},
    {"id": "fetch_history", "agent": "chasen_researcher", "action": "fetch_meeting_history", "params": {"timeframe": "90d"}},
    {"id": "fetch_actions", "agent": "chasen_action_summariser", "action": "summarise_client_actions", "params": {}},
    {"id": "fetch_health", "agent": "chasen_analyst", "action": "analyse_health_status", "params": {}},
    {"id": "prep_briefing", "agent": "chasen_meeting_prep", "action": "create_briefing", "dependencies": ["fetch_context", "fetch_history", "fetch_actions", "fetch_health"]}
  ]'::jsonb,
  '[]'::jsonb,
  'system'
),
-- Renewal Analysis Workflow
(
  'renewal_analysis',
  'Analyse upcoming renewals and identify at-risk contracts',
  'manual',
  '{"requires": ["timeframe"]}'::jsonb,
  'Generate a renewal pipeline analysis with risk assessment and recommendations',
  '[
    {"id": "fetch_renewals", "agent": "chasen_renewals", "action": "fetch_upcoming_renewals", "params": {}},
    {"id": "analyse_health", "agent": "chasen_analyst", "action": "batch_health_analysis", "params": {}},
    {"id": "assess_risk", "agent": "chasen_predictor", "action": "renewal_risk_scoring", "dependencies": ["fetch_renewals", "analyse_health"]},
    {"id": "generate_report", "agent": "chasen_renewals", "action": "create_renewal_report", "dependencies": ["assess_risk"]}
  ]'::jsonb,
  '[
    {"after_step": "assess_risk", "validation": "Review risk scores before final report", "requires_approval": false}
  ]'::jsonb,
  'system'
),
-- Action Status Report Workflow
(
  'action_status_report',
  'Generate comprehensive action status report',
  'manual',
  '{"requires": ["scope", "timeframe"]}'::jsonb,
  'Generate an action status report with completion rates and follow-up priorities',
  '[
    {"id": "aggregate_actions", "agent": "chasen_action_summariser", "action": "aggregate_all_actions", "params": {}},
    {"id": "analyse_completion", "agent": "chasen_action_summariser", "action": "calculate_completion_stats", "dependencies": ["aggregate_actions"]},
    {"id": "identify_overdue", "agent": "chasen_action_summariser", "action": "flag_overdue_actions", "dependencies": ["aggregate_actions"]},
    {"id": "generate_report", "agent": "chasen_writer", "action": "draft_action_report", "dependencies": ["analyse_completion", "identify_overdue"]}
  ]'::jsonb,
  '[]'::jsonb,
  'system'
)
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- UPDATE INTENT ROUTING
-- ============================================================================

-- These intents should route to the new specialist agents:
-- - 'renewal_analysis' -> chasen_renewals
-- - 'meeting_preparation' -> chasen_meeting_prep
-- - 'action_summary' -> chasen_action_summariser

COMMENT ON TABLE chasen_agents IS 'Multi-agent definitions including specialist agents for renewals, meeting prep, and action summarisation';
