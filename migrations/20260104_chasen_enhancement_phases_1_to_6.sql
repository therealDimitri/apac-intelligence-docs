-- ============================================================================
-- ChaSen AI Enhancement - Phases 1-6 Database Migration
-- ============================================================================
-- Date: 2026-01-04
-- Description: Comprehensive schema for all ChaSen enhancement phases
-- ============================================================================

-- ============================================================================
-- PHASE 1: MEMORY ARCHITECTURE
-- ============================================================================

-- 1.1 Episodic Memory - Learn from past experiences
CREATE TABLE IF NOT EXISTS chasen_episodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_email TEXT NOT NULL,
  conversation_id UUID REFERENCES chasen_conversations(id) ON DELETE SET NULL,
  query TEXT NOT NULL,
  response_summary TEXT,
  outcome TEXT CHECK (outcome IN ('success', 'partial', 'failure', 'unknown')),
  feedback_rating INTEGER CHECK (feedback_rating BETWEEN 1 AND 5),
  entities JSONB DEFAULT '[]'::jsonb,
  -- Entity structure: [{ "type": "client|person|topic|product", "name": "...", "id": "..." }]
  tags TEXT[] DEFAULT '{}',
  embedding VECTOR(1536),
  context_snapshot JSONB DEFAULT '{}'::jsonb,
  -- Context: { "page": "...", "client_id": "...", "segment": "..." }
  duration_ms INTEGER,
  token_count INTEGER,
  model_used TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  accessed_at TIMESTAMPTZ DEFAULT NOW(),
  access_count INTEGER DEFAULT 0,
  is_archived BOOLEAN DEFAULT FALSE
);

CREATE INDEX IF NOT EXISTS idx_episodes_user ON chasen_episodes(user_email);
CREATE INDEX IF NOT EXISTS idx_episodes_outcome ON chasen_episodes(outcome);
CREATE INDEX IF NOT EXISTS idx_episodes_created ON chasen_episodes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_episodes_embedding ON chasen_episodes USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX IF NOT EXISTS idx_episodes_entities ON chasen_episodes USING gin (entities);

-- 1.2 Procedural Memory - Store reusable workflows
CREATE TABLE IF NOT EXISTS chasen_procedures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  task_type TEXT NOT NULL,
  -- Types: meeting_prep, risk_analysis, email_draft, action_creation, report_generation, escalation
  trigger_patterns TEXT[] DEFAULT '{}',
  -- Patterns that trigger this procedure
  steps JSONB NOT NULL DEFAULT '[]'::jsonb,
  -- Steps: [{ "order": 1, "action": "...", "tools": [...], "params": {...}, "fallback": "..." }]
  prerequisites JSONB DEFAULT '[]'::jsonb,
  -- Prerequisites: [{ "type": "data|permission|context", "requirement": "..." }]
  success_criteria JSONB DEFAULT '[]'::jsonb,
  outputs JSONB DEFAULT '[]'::jsonb,
  success_rate FLOAT DEFAULT 0,
  execution_count INTEGER DEFAULT 0,
  avg_duration_seconds INTEGER,
  last_executed TIMESTAMPTZ,
  created_by TEXT,
  is_system BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  version INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_procedures_type ON chasen_procedures(task_type);
CREATE INDEX IF NOT EXISTS idx_procedures_active ON chasen_procedures(is_active);
CREATE INDEX IF NOT EXISTS idx_procedures_triggers ON chasen_procedures USING gin (trigger_patterns);

-- 1.3 Semantic Memory - Structured knowledge ontology
CREATE TABLE IF NOT EXISTS chasen_concepts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  canonical_name TEXT NOT NULL,
  -- Lowercase, normalized version for matching
  category TEXT NOT NULL,
  -- Categories: client, person, product, process, metric, term, entity
  subcategory TEXT,
  definition TEXT,
  aliases TEXT[] DEFAULT '{}',
  attributes JSONB DEFAULT '{}'::jsonb,
  -- Flexible attributes based on category
  embedding VECTOR(1536),
  source TEXT,
  -- Where this concept was learned from
  confidence FLOAT DEFAULT 1.0,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(canonical_name, category)
);

CREATE INDEX IF NOT EXISTS idx_concepts_category ON chasen_concepts(category);
CREATE INDEX IF NOT EXISTS idx_concepts_canonical ON chasen_concepts(canonical_name);
CREATE INDEX IF NOT EXISTS idx_concepts_embedding ON chasen_concepts USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX IF NOT EXISTS idx_concepts_aliases ON chasen_concepts USING gin (aliases);

-- 1.4 Concept Relationships - Graph edges
CREATE TABLE IF NOT EXISTS chasen_relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_concept_id UUID NOT NULL REFERENCES chasen_concepts(id) ON DELETE CASCADE,
  target_concept_id UUID NOT NULL REFERENCES chasen_concepts(id) ON DELETE CASCADE,
  relationship_type TEXT NOT NULL,
  -- Types: owns, uses, manages, reports_to, depends_on, contains, related_to, produces, consumes
  weight FLOAT DEFAULT 1.0,
  -- Strength of relationship (0-1)
  properties JSONB DEFAULT '{}'::jsonb,
  -- Additional relationship metadata
  source TEXT,
  confidence FLOAT DEFAULT 1.0,
  is_bidirectional BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(source_concept_id, target_concept_id, relationship_type)
);

CREATE INDEX IF NOT EXISTS idx_relationships_source ON chasen_relationships(source_concept_id);
CREATE INDEX IF NOT EXISTS idx_relationships_target ON chasen_relationships(target_concept_id);
CREATE INDEX IF NOT EXISTS idx_relationships_type ON chasen_relationships(relationship_type);

-- ============================================================================
-- PHASE 2: GRAPHRAG
-- ============================================================================

-- 2.1 Knowledge Graph Entities (for client-centric graph)
CREATE TABLE IF NOT EXISTS chasen_graph_nodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type TEXT NOT NULL,
  -- Types: client, contact, contract, meeting, action, nps_response, health_score, product, cse
  entity_id TEXT NOT NULL,
  -- Reference to the actual entity in source table
  label TEXT NOT NULL,
  properties JSONB DEFAULT '{}'::jsonb,
  embedding VECTOR(1536),
  last_synced TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(entity_type, entity_id)
);

CREATE INDEX IF NOT EXISTS idx_graph_nodes_type ON chasen_graph_nodes(entity_type);
CREATE INDEX IF NOT EXISTS idx_graph_nodes_entity ON chasen_graph_nodes(entity_id);
CREATE INDEX IF NOT EXISTS idx_graph_nodes_embedding ON chasen_graph_nodes USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- 2.2 Knowledge Graph Edges
CREATE TABLE IF NOT EXISTS chasen_graph_edges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_node_id UUID NOT NULL REFERENCES chasen_graph_nodes(id) ON DELETE CASCADE,
  target_node_id UUID NOT NULL REFERENCES chasen_graph_nodes(id) ON DELETE CASCADE,
  edge_type TEXT NOT NULL,
  -- Types: HAS_CONTACT, OWNS_CONTRACT, ATTENDED, CREATED, ASSIGNED_TO, RELATES_TO, etc.
  properties JSONB DEFAULT '{}'::jsonb,
  weight FLOAT DEFAULT 1.0,
  valid_from TIMESTAMPTZ,
  valid_to TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_graph_edges_source ON chasen_graph_edges(source_node_id);
CREATE INDEX IF NOT EXISTS idx_graph_edges_target ON chasen_graph_edges(target_node_id);
CREATE INDEX IF NOT EXISTS idx_graph_edges_type ON chasen_graph_edges(edge_type);

-- 2.3 Graph Communities (for global context)
CREATE TABLE IF NOT EXISTS chasen_graph_communities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  level INTEGER DEFAULT 0,
  -- Hierarchy level (0 = top)
  parent_community_id UUID REFERENCES chasen_graph_communities(id),
  node_ids UUID[] DEFAULT '{}',
  summary TEXT,
  -- AI-generated summary of the community
  embedding VECTOR(1536),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_communities_level ON chasen_graph_communities(level);
CREATE INDEX IF NOT EXISTS idx_communities_nodes ON chasen_graph_communities USING gin (node_ids);

-- ============================================================================
-- PHASE 3: MULTI-AGENT ARCHITECTURE
-- ============================================================================

-- 3.1 Agent Definitions
CREATE TABLE IF NOT EXISTS chasen_agents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  description TEXT,
  role TEXT NOT NULL,
  -- Roles: researcher, analyst, writer, executor, predictor, orchestrator
  capabilities TEXT[] DEFAULT '{}',
  tools TEXT[] DEFAULT '{}',
  -- Tools this agent can use
  system_prompt TEXT,
  model_preference TEXT DEFAULT 'claude-sonnet-4',
  temperature FLOAT DEFAULT 0.7,
  max_tokens INTEGER DEFAULT 4096,
  is_active BOOLEAN DEFAULT TRUE,
  priority INTEGER DEFAULT 0,
  -- Higher = preferred for ambiguous tasks
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3.2 Agent Task Queue
CREATE TABLE IF NOT EXISTS chasen_agent_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_task_id UUID REFERENCES chasen_agent_tasks(id),
  agent_id UUID REFERENCES chasen_agents(id),
  user_email TEXT NOT NULL,
  conversation_id UUID REFERENCES chasen_conversations(id),
  task_type TEXT NOT NULL,
  -- Types: query, research, analysis, draft, execute, verify, orchestrate
  status TEXT DEFAULT 'pending',
  -- Status: pending, assigned, in_progress, waiting_human, completed, failed, cancelled
  priority TEXT DEFAULT 'normal',
  -- Priority: low, normal, high, urgent
  input JSONB NOT NULL,
  output JSONB,
  error TEXT,
  context JSONB DEFAULT '{}'::jsonb,
  dependencies UUID[] DEFAULT '{}',
  -- Other task IDs this depends on
  requires_approval BOOLEAN DEFAULT FALSE,
  approved_by TEXT,
  approved_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  duration_ms INTEGER,
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_agent_tasks_status ON chasen_agent_tasks(status);
CREATE INDEX IF NOT EXISTS idx_agent_tasks_agent ON chasen_agent_tasks(agent_id);
CREATE INDEX IF NOT EXISTS idx_agent_tasks_user ON chasen_agent_tasks(user_email);
CREATE INDEX IF NOT EXISTS idx_agent_tasks_created ON chasen_agent_tasks(created_at DESC);

-- 3.3 Agent Messages (inter-agent communication)
CREATE TABLE IF NOT EXISTS chasen_agent_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID REFERENCES chasen_agent_tasks(id) ON DELETE CASCADE,
  from_agent_id UUID REFERENCES chasen_agents(id),
  to_agent_id UUID REFERENCES chasen_agents(id),
  message_type TEXT NOT NULL,
  -- Types: request, response, handoff, broadcast, error, status
  content JSONB NOT NULL,
  metadata JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_agent_messages_task ON chasen_agent_messages(task_id);
CREATE INDEX IF NOT EXISTS idx_agent_messages_from ON chasen_agent_messages(from_agent_id);
CREATE INDEX IF NOT EXISTS idx_agent_messages_to ON chasen_agent_messages(to_agent_id);

-- ============================================================================
-- PHASE 4: AUTONOMOUS WORKFLOWS
-- ============================================================================

-- 4.1 Workflow Definitions
CREATE TABLE IF NOT EXISTS chasen_workflows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  trigger_type TEXT NOT NULL,
  -- Types: manual, scheduled, event, threshold
  trigger_config JSONB DEFAULT '{}'::jsonb,
  -- Config for trigger (schedule, event name, threshold values)
  goal TEXT NOT NULL,
  success_criteria JSONB DEFAULT '[]'::jsonb,
  constraints JSONB DEFAULT '[]'::jsonb,
  steps JSONB NOT NULL DEFAULT '[]'::jsonb,
  -- Steps: [{ "id": "...", "agent": "...", "action": "...", "params": {...}, "dependencies": [...] }]
  checkpoints JSONB DEFAULT '[]'::jsonb,
  -- Checkpoints: [{ "after_step": "...", "validation": "...", "requires_approval": true }]
  fallback_strategy TEXT DEFAULT 'retry',
  -- Strategies: retry, skip, escalate, abort
  max_duration_seconds INTEGER DEFAULT 3600,
  is_active BOOLEAN DEFAULT TRUE,
  created_by TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workflows_trigger ON chasen_workflows(trigger_type);
CREATE INDEX IF NOT EXISTS idx_workflows_active ON chasen_workflows(is_active);

-- 4.2 Workflow Executions
CREATE TABLE IF NOT EXISTS chasen_workflow_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workflow_id UUID NOT NULL REFERENCES chasen_workflows(id),
  user_email TEXT,
  status TEXT DEFAULT 'pending',
  -- Status: pending, running, paused, waiting_approval, completed, failed, cancelled
  current_step TEXT,
  step_results JSONB DEFAULT '{}'::jsonb,
  -- Results keyed by step ID
  context JSONB DEFAULT '{}'::jsonb,
  error TEXT,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  paused_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workflow_executions_workflow ON chasen_workflow_executions(workflow_id);
CREATE INDEX IF NOT EXISTS idx_workflow_executions_status ON chasen_workflow_executions(status);
CREATE INDEX IF NOT EXISTS idx_workflow_executions_user ON chasen_workflow_executions(user_email);

-- 4.3 Workflow Approvals
CREATE TABLE IF NOT EXISTS chasen_workflow_approvals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  execution_id UUID NOT NULL REFERENCES chasen_workflow_executions(id) ON DELETE CASCADE,
  checkpoint_id TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  -- Status: pending, approved, rejected, expired
  requested_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ,
  approved_by TEXT,
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT,
  context JSONB DEFAULT '{}'::jsonb
);

CREATE INDEX IF NOT EXISTS idx_approvals_execution ON chasen_workflow_approvals(execution_id);
CREATE INDEX IF NOT EXISTS idx_approvals_status ON chasen_workflow_approvals(status);

-- ============================================================================
-- PHASE 5: MCP INTEGRATION
-- ============================================================================

-- 5.1 MCP Server Configurations
CREATE TABLE IF NOT EXISTS chasen_mcp_servers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  description TEXT,
  server_type TEXT NOT NULL,
  -- Types: filesystem, github, slack, calendar, salesforce, jira, custom
  connection_config JSONB NOT NULL,
  -- Encrypted connection details
  capabilities TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  health_status TEXT DEFAULT 'unknown',
  last_health_check TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5.2 MCP Tool Registry
CREATE TABLE IF NOT EXISTS chasen_mcp_tools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  server_id UUID NOT NULL REFERENCES chasen_mcp_servers(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  input_schema JSONB,
  output_schema JSONB,
  embedding VECTOR(1536),
  -- For tool search
  usage_count INTEGER DEFAULT 0,
  avg_execution_ms INTEGER,
  success_rate FLOAT DEFAULT 1.0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(server_id, name)
);

CREATE INDEX IF NOT EXISTS idx_mcp_tools_server ON chasen_mcp_tools(server_id);
CREATE INDEX IF NOT EXISTS idx_mcp_tools_embedding ON chasen_mcp_tools USING ivfflat (embedding vector_cosine_ops) WITH (lists = 50);

-- 5.3 MCP Tool Executions
CREATE TABLE IF NOT EXISTS chasen_mcp_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tool_id UUID NOT NULL REFERENCES chasen_mcp_tools(id),
  task_id UUID REFERENCES chasen_agent_tasks(id),
  user_email TEXT NOT NULL,
  input JSONB NOT NULL,
  output JSONB,
  status TEXT DEFAULT 'pending',
  -- Status: pending, running, completed, failed
  error TEXT,
  duration_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_mcp_executions_tool ON chasen_mcp_executions(tool_id);
CREATE INDEX IF NOT EXISTS idx_mcp_executions_status ON chasen_mcp_executions(status);

-- ============================================================================
-- PHASE 6: PREDICTIVE INTELLIGENCE
-- ============================================================================

-- 6.1 Prediction Models
CREATE TABLE IF NOT EXISTS chasen_prediction_models (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  model_type TEXT NOT NULL,
  -- Types: churn, nps_trend, health_forecast, renewal_risk, engagement
  description TEXT,
  features JSONB NOT NULL,
  -- Feature definitions
  model_config JSONB DEFAULT '{}'::jsonb,
  performance_metrics JSONB DEFAULT '{}'::jsonb,
  -- Accuracy, precision, recall, etc.
  model_binary BYTEA,
  -- Serialized model (for simple models)
  model_path TEXT,
  -- Path to model file (for larger models)
  version INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT TRUE,
  trained_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6.2 Predictions
CREATE TABLE IF NOT EXISTS chasen_predictions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  model_id UUID NOT NULL REFERENCES chasen_prediction_models(id),
  entity_type TEXT NOT NULL,
  -- Types: client, contract, cse_portfolio
  entity_id TEXT NOT NULL,
  prediction_type TEXT NOT NULL,
  -- Types: churn_probability, nps_forecast, health_forecast, risk_score
  predicted_value FLOAT,
  predicted_label TEXT,
  confidence FLOAT,
  explanation JSONB DEFAULT '{}'::jsonb,
  -- Feature importances, reasoning
  risk_factors TEXT[] DEFAULT '{}',
  recommended_actions JSONB DEFAULT '[]'::jsonb,
  valid_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_predictions_entity ON chasen_predictions(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_predictions_type ON chasen_predictions(prediction_type);
CREATE INDEX IF NOT EXISTS idx_predictions_created ON chasen_predictions(created_at DESC);

-- 6.3 Proactive Insights
CREATE TABLE IF NOT EXISTS chasen_proactive_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_email TEXT,
  -- NULL for global insights
  insight_type TEXT NOT NULL,
  -- Types: risk, opportunity, anomaly, milestone, trend, recommendation
  priority TEXT DEFAULT 'medium',
  -- Priority: low, medium, high, critical
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  entity_type TEXT,
  entity_id TEXT,
  entity_name TEXT,
  data JSONB DEFAULT '{}'::jsonb,
  -- Supporting data
  suggested_actions JSONB DEFAULT '[]'::jsonb,
  source TEXT,
  -- What triggered this insight
  expires_at TIMESTAMPTZ,
  is_read BOOLEAN DEFAULT FALSE,
  is_dismissed BOOLEAN DEFAULT FALSE,
  dismissed_by TEXT,
  dismissed_at TIMESTAMPTZ,
  action_taken TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_insights_user ON chasen_proactive_insights(user_email);
CREATE INDEX IF NOT EXISTS idx_insights_type ON chasen_proactive_insights(insight_type);
CREATE INDEX IF NOT EXISTS idx_insights_priority ON chasen_proactive_insights(priority);
CREATE INDEX IF NOT EXISTS idx_insights_entity ON chasen_proactive_insights(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_insights_active ON chasen_proactive_insights(is_dismissed, expires_at);

-- 6.4 Anomaly Detections
CREATE TABLE IF NOT EXISTS chasen_anomalies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  metric_name TEXT NOT NULL,
  entity_type TEXT,
  entity_id TEXT,
  expected_value FLOAT,
  actual_value FLOAT,
  deviation_percent FLOAT,
  severity TEXT DEFAULT 'medium',
  -- Severity: low, medium, high, critical
  detection_method TEXT,
  -- Method: statistical, ml, rule-based
  is_acknowledged BOOLEAN DEFAULT FALSE,
  acknowledged_by TEXT,
  acknowledged_at TIMESTAMPTZ,
  resolution TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_anomalies_metric ON chasen_anomalies(metric_name);
CREATE INDEX IF NOT EXISTS idx_anomalies_entity ON chasen_anomalies(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_anomalies_severity ON chasen_anomalies(severity);

-- ============================================================================
-- DEFAULT DATA: AGENT DEFINITIONS
-- ============================================================================

INSERT INTO chasen_agents (name, display_name, description, role, capabilities, tools, system_prompt, model_preference, temperature) VALUES
(
  'chasen_orchestrator',
  'ChaSen Orchestrator',
  'Routes queries to appropriate specialist agents and coordinates multi-agent workflows',
  'orchestrator',
  ARRAY['task_routing', 'workflow_coordination', 'context_management', 'agent_selection'],
  ARRAY['agent_dispatch', 'workflow_execute', 'context_fetch'],
  'You are the ChaSen Orchestrator. Your role is to understand user intent, break down complex requests into subtasks, and route them to the appropriate specialist agents. Always provide a clear plan before execution.',
  'claude-sonnet-4',
  0.3
),
(
  'chasen_researcher',
  'ChaSen Researcher',
  'Searches and synthesises information from all available data sources',
  'researcher',
  ARRAY['data_search', 'information_synthesis', 'fact_finding', 'context_gathering'],
  ARRAY['semantic_search', 'graph_search', 'database_query', 'document_fetch'],
  'You are a research specialist. Your role is to find accurate, relevant information from available data sources. Always cite your sources and indicate confidence levels.',
  'claude-sonnet-4',
  0.5
),
(
  'chasen_analyst',
  'ChaSen Analyst',
  'Analyses data, identifies patterns, and generates insights',
  'analyst',
  ARRAY['data_analysis', 'pattern_detection', 'trend_analysis', 'statistical_analysis'],
  ARRAY['sql_query', 'chart_generate', 'statistics_compute', 'prediction_fetch'],
  'You are a data analyst specialist. Your role is to analyse data, identify patterns and trends, and provide actionable insights. Use numbers and evidence to support your findings.',
  'claude-sonnet-4',
  0.4
),
(
  'chasen_writer',
  'ChaSen Writer',
  'Drafts communications, reports, and documentation',
  'writer',
  ARRAY['email_drafting', 'report_writing', 'documentation', 'summarisation'],
  ARRAY['template_fetch', 'tone_adjust', 'format_convert'],
  'You are a communications specialist. Your role is to draft clear, professional communications tailored to the audience and context. Match the tone and style requested.',
  'claude-sonnet-4',
  0.7
),
(
  'chasen_executor',
  'ChaSen Executor',
  'Executes actions in connected systems',
  'executor',
  ARRAY['action_creation', 'meeting_scheduling', 'data_update', 'notification_send'],
  ARRAY['action_crud', 'meeting_crud', 'notification_send', 'mcp_execute'],
  'You are an execution specialist. Your role is to carry out approved actions in connected systems. Always verify before executing and report the results.',
  'claude-sonnet-4',
  0.2
),
(
  'chasen_predictor',
  'ChaSen Predictor',
  'Generates predictions and proactive recommendations',
  'predictor',
  ARRAY['churn_prediction', 'risk_scoring', 'trend_forecasting', 'recommendation_generation'],
  ARRAY['model_predict', 'anomaly_detect', 'insight_generate'],
  'You are a predictive intelligence specialist. Your role is to analyse patterns and generate predictions about future outcomes. Always explain your reasoning and confidence levels.',
  'claude-sonnet-4',
  0.4
)
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- DEFAULT DATA: WORKFLOW TEMPLATES
-- ============================================================================

INSERT INTO chasen_workflows (name, description, trigger_type, trigger_config, goal, steps, checkpoints, created_by) VALUES
(
  'client_qbr_prep',
  'Prepare comprehensive QBR materials for a client',
  'manual',
  '{"requires": ["client_id"]}'::jsonb,
  'Generate complete QBR preparation materials including health analysis, NPS insights, action summary, and recommendations',
  '[
    {"id": "gather_health", "agent": "chasen_researcher", "action": "fetch_health_data", "params": {"timeframe": "90d"}},
    {"id": "gather_nps", "agent": "chasen_researcher", "action": "fetch_nps_data", "params": {"timeframe": "180d"}},
    {"id": "gather_actions", "agent": "chasen_researcher", "action": "fetch_actions", "params": {"status": "all"}},
    {"id": "gather_meetings", "agent": "chasen_researcher", "action": "fetch_meetings", "params": {"timeframe": "90d"}},
    {"id": "analyse_health", "agent": "chasen_analyst", "action": "analyse_health_trends", "dependencies": ["gather_health"]},
    {"id": "analyse_nps", "agent": "chasen_analyst", "action": "analyse_nps_sentiment", "dependencies": ["gather_nps"]},
    {"id": "generate_insights", "agent": "chasen_predictor", "action": "generate_risk_opportunities", "dependencies": ["analyse_health", "analyse_nps"]},
    {"id": "draft_summary", "agent": "chasen_writer", "action": "draft_qbr_summary", "dependencies": ["generate_insights", "gather_actions", "gather_meetings"]}
  ]'::jsonb,
  '[
    {"after_step": "generate_insights", "validation": "Review insights before drafting", "requires_approval": false}
  ]'::jsonb,
  'system'
),
(
  'risk_client_outreach',
  'Proactive outreach for at-risk clients',
  'threshold',
  '{"metric": "health_score", "operator": "<", "value": 50, "check_interval": "daily"}'::jsonb,
  'Identify risk factors, generate mitigation plan, and draft outreach communication',
  '[
    {"id": "analyse_risk", "agent": "chasen_analyst", "action": "deep_risk_analysis", "params": {}},
    {"id": "predict_churn", "agent": "chasen_predictor", "action": "predict_churn_probability", "dependencies": ["analyse_risk"]},
    {"id": "generate_plan", "agent": "chasen_predictor", "action": "generate_mitigation_plan", "dependencies": ["predict_churn"]},
    {"id": "draft_outreach", "agent": "chasen_writer", "action": "draft_outreach_email", "dependencies": ["generate_plan"]}
  ]'::jsonb,
  '[
    {"after_step": "draft_outreach", "validation": "Review outreach before sending", "requires_approval": true}
  ]'::jsonb,
  'system'
),
(
  'daily_portfolio_digest',
  'Generate daily digest of portfolio changes and insights',
  'scheduled',
  '{"cron": "0 7 * * 1-5", "timezone": "Australia/Sydney"}'::jsonb,
  'Summarise overnight changes, new risks, opportunities, and recommended actions for the day',
  '[
    {"id": "detect_changes", "agent": "chasen_researcher", "action": "detect_overnight_changes", "params": {"since": "last_business_day"}},
    {"id": "detect_anomalies", "agent": "chasen_predictor", "action": "detect_anomalies", "dependencies": ["detect_changes"]},
    {"id": "prioritise", "agent": "chasen_analyst", "action": "prioritise_items", "dependencies": ["detect_anomalies"]},
    {"id": "generate_digest", "agent": "chasen_writer", "action": "generate_digest", "dependencies": ["prioritise"]}
  ]'::jsonb,
  '[]'::jsonb,
  'system'
)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- DEFAULT DATA: PROCEDURE TEMPLATES
-- ============================================================================

INSERT INTO chasen_procedures (name, description, task_type, trigger_patterns, steps, is_system) VALUES
(
  'standard_meeting_prep',
  'Standard procedure for preparing meeting briefs',
  'meeting_prep',
  ARRAY['prepare for meeting', 'meeting prep', 'brief me on', 'get ready for'],
  '[
    {"order": 1, "action": "fetch_client_context", "tools": ["database_query"], "params": {"include": ["health", "nps", "segment"]}},
    {"order": 2, "action": "fetch_recent_activity", "tools": ["database_query"], "params": {"days": 30}},
    {"order": 3, "action": "fetch_open_actions", "tools": ["database_query"], "params": {}},
    {"order": 4, "action": "fetch_meeting_history", "tools": ["database_query"], "params": {"limit": 5}},
    {"order": 5, "action": "generate_talking_points", "tools": ["llm_generate"], "params": {}},
    {"order": 6, "action": "format_brief", "tools": ["template_render"], "params": {"template": "meeting_brief"}}
  ]'::jsonb,
  TRUE
),
(
  'risk_escalation_email',
  'Procedure for drafting risk escalation emails',
  'email_draft',
  ARRAY['escalate risk', 'raise concern', 'alert about', 'flag issue'],
  '[
    {"order": 1, "action": "gather_risk_evidence", "tools": ["database_query", "semantic_search"], "params": {}},
    {"order": 2, "action": "assess_severity", "tools": ["rule_engine"], "params": {}},
    {"order": 3, "action": "identify_stakeholders", "tools": ["database_query"], "params": {}},
    {"order": 4, "action": "draft_email", "tools": ["llm_generate"], "params": {"tone": "professional", "urgency": "high"}},
    {"order": 5, "action": "add_recommendations", "tools": ["llm_generate"], "params": {}}
  ]'::jsonb,
  TRUE
)
ON CONFLICT DO NOTHING;

-- ============================================================================
-- RLS POLICIES
-- ============================================================================

-- Enable RLS on new tables
ALTER TABLE chasen_episodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_procedures ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_concepts ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_relationships ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_graph_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_graph_edges ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_graph_communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_agents ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_agent_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_agent_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_workflows ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_workflow_executions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_workflow_approvals ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_mcp_servers ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_mcp_tools ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_mcp_executions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_prediction_models ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_predictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_proactive_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE chasen_anomalies ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read all tables
CREATE POLICY "Allow authenticated read" ON chasen_episodes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_procedures FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_concepts FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_relationships FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_graph_nodes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_graph_edges FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_graph_communities FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_agents FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_agent_tasks FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_agent_messages FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_workflows FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_workflow_executions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_workflow_approvals FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_mcp_servers FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_mcp_tools FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_mcp_executions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_prediction_models FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_predictions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_proactive_insights FOR SELECT TO authenticated USING (true);
CREATE POLICY "Allow authenticated read" ON chasen_anomalies FOR SELECT TO authenticated USING (true);

-- Service role can do everything
CREATE POLICY "Service role full access" ON chasen_episodes FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_procedures FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_concepts FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_relationships FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_graph_nodes FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_graph_edges FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_graph_communities FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_agents FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_agent_tasks FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_agent_messages FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_workflows FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_workflow_executions FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_workflow_approvals FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_mcp_servers FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_mcp_tools FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_mcp_executions FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_prediction_models FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_predictions FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_proactive_insights FOR ALL TO service_role USING (true);
CREATE POLICY "Service role full access" ON chasen_anomalies FOR ALL TO service_role USING (true);

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Function to get similar episodes
CREATE OR REPLACE FUNCTION get_similar_episodes(
  query_embedding VECTOR(1536),
  user_email_filter TEXT DEFAULT NULL,
  limit_count INT DEFAULT 5,
  similarity_threshold FLOAT DEFAULT 0.7
)
RETURNS TABLE (
  id UUID,
  query TEXT,
  response_summary TEXT,
  outcome TEXT,
  similarity FLOAT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    e.id,
    e.query,
    e.response_summary,
    e.outcome,
    1 - (e.embedding <=> query_embedding) AS similarity
  FROM chasen_episodes e
  WHERE (user_email_filter IS NULL OR e.user_email = user_email_filter)
    AND e.embedding IS NOT NULL
    AND 1 - (e.embedding <=> query_embedding) >= similarity_threshold
  ORDER BY e.embedding <=> query_embedding
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to traverse graph from a node
CREATE OR REPLACE FUNCTION traverse_graph(
  start_node_id UUID,
  max_depth INT DEFAULT 2,
  edge_types TEXT[] DEFAULT NULL
)
RETURNS TABLE (
  node_id UUID,
  entity_type TEXT,
  label TEXT,
  depth INT,
  path UUID[]
) AS $$
WITH RECURSIVE graph_traversal AS (
  -- Base case: start node
  SELECT
    n.id AS node_id,
    n.entity_type,
    n.label,
    0 AS depth,
    ARRAY[n.id] AS path
  FROM chasen_graph_nodes n
  WHERE n.id = start_node_id

  UNION ALL

  -- Recursive case: follow edges
  SELECT
    n.id AS node_id,
    n.entity_type,
    n.label,
    gt.depth + 1 AS depth,
    gt.path || n.id AS path
  FROM graph_traversal gt
  JOIN chasen_graph_edges e ON e.source_node_id = gt.node_id
  JOIN chasen_graph_nodes n ON n.id = e.target_node_id
  WHERE gt.depth < max_depth
    AND NOT n.id = ANY(gt.path)  -- Prevent cycles
    AND (edge_types IS NULL OR e.edge_type = ANY(edge_types))
)
SELECT * FROM graph_traversal;
$$ LANGUAGE sql;

-- Function to generate proactive insights
CREATE OR REPLACE FUNCTION generate_insight(
  p_user_email TEXT,
  p_insight_type TEXT,
  p_priority TEXT,
  p_title TEXT,
  p_description TEXT,
  p_entity_type TEXT DEFAULT NULL,
  p_entity_id TEXT DEFAULT NULL,
  p_entity_name TEXT DEFAULT NULL,
  p_data JSONB DEFAULT '{}'::jsonb,
  p_suggested_actions JSONB DEFAULT '[]'::jsonb,
  p_source TEXT DEFAULT NULL,
  p_expires_in_hours INT DEFAULT 24
)
RETURNS UUID AS $$
DECLARE
  new_id UUID;
BEGIN
  INSERT INTO chasen_proactive_insights (
    user_email, insight_type, priority, title, description,
    entity_type, entity_id, entity_name, data, suggested_actions,
    source, expires_at
  ) VALUES (
    p_user_email, p_insight_type, p_priority, p_title, p_description,
    p_entity_type, p_entity_id, p_entity_name, p_data, p_suggested_actions,
    p_source, NOW() + (p_expires_in_hours || ' hours')::INTERVAL
  )
  RETURNING id INTO new_id;

  RETURN new_id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE chasen_episodes IS 'Episodic memory: stores past interaction experiences for learning';
COMMENT ON TABLE chasen_procedures IS 'Procedural memory: stores reusable workflows and how-to knowledge';
COMMENT ON TABLE chasen_concepts IS 'Semantic memory: structured knowledge ontology';
COMMENT ON TABLE chasen_graph_nodes IS 'Knowledge graph nodes for GraphRAG';
COMMENT ON TABLE chasen_agents IS 'Multi-agent definitions and configurations';
COMMENT ON TABLE chasen_workflows IS 'Autonomous workflow definitions';
COMMENT ON TABLE chasen_proactive_insights IS 'AI-generated proactive insights and recommendations';
