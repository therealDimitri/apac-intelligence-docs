# Phase 9: Moonshot Features - Design Document

**Created:** 2026-02-06
**Status:** Approved
**Scope:** 7 features (VR/AR excluded)

---

## Overview

Phase 9 implements advanced "moonshot" features that transform the CS dashboard into an intelligent, immersive platform. These features leverage real-time AI, 3D visualisation, and predictive simulation.

### Features

1. **Meeting Co-Host & Transcription** - Real-time meeting assistance with live transcription
2. **Sentiment Analysis During Calls** - Detect emotional dynamics in real-time
3. **Digital Twin / Client Simulation** - AI personas trained on client behaviour
4. **Deal Negotiation Sandbox** - Practice negotiations with predictive outcomes
5. **Background AI Task Queue** - Async processing for heavy AI workloads
6. **3D Pipeline Landscape** - WebGL terrain visualisation of deals
7. **Network Graph Visualisation** - Interactive relationship mapping

---

## Architecture Overview

### Shared Infrastructure

| Component | Technology | Purpose |
|-----------|------------|---------|
| WebSocket Hub | Supabase Realtime + custom | Real-time transcription, sentiment streaming |
| Background Jobs | Supabase + cron workers | Async AI processing |
| Graph Layer | PostgreSQL + relationship_edges table | Relationship queries |

### Feature Groupings

| Group | Features | Shared Tech |
|-------|----------|-------------|
| Real-time Meeting | Co-Host, Transcription, Sentiment | WebSocket, Deepgram, streaming AI |
| Simulation | Digital Twin, Deal Sandbox | Monte Carlo engine, scenario modelling |
| Visualisation | 3D Pipeline, Network Graph | Three.js, D3.js force graphs |
| Background Processing | AI Task Queue | Worker processes, progress tracking |

### External Services

- **Deepgram** - Real-time speech-to-text transcription
- **OpenAI/Anthropic** - Sentiment analysis, co-host intelligence, twin responses

---

## Feature 1: Background AI Task Queue

### Purpose

Asynchronous processing for heavy AI tasks that shouldn't block the UI.

### Database Schema

```sql
-- Task definitions and status tracking
CREATE TABLE ai_task_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_type TEXT NOT NULL,
  priority INTEGER DEFAULT 50,
  status TEXT DEFAULT 'pending',
  payload JSONB NOT NULL,
  result JSONB,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  created_by TEXT NOT NULL,
  scheduled_for TIMESTAMPTZ DEFAULT now(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  progress_percent INTEGER DEFAULT 0,
  progress_message TEXT,
  estimated_duration_ms INTEGER,
  actual_duration_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Task dependencies for chained workflows
CREATE TABLE ai_task_dependencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID REFERENCES ai_task_queue(id) ON DELETE CASCADE,
  depends_on_task_id UUID REFERENCES ai_task_queue(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(task_id, depends_on_task_id)
);

-- Task execution logs
CREATE TABLE ai_task_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID REFERENCES ai_task_queue(id) ON DELETE CASCADE,
  log_level TEXT DEFAULT 'info',
  message TEXT NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Scheduled recurring tasks
CREATE TABLE ai_scheduled_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  task_type TEXT NOT NULL,
  payload_template JSONB NOT NULL,
  schedule_cron TEXT NOT NULL,
  enabled BOOLEAN DEFAULT true,
  last_run_at TIMESTAMPTZ,
  next_run_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_task_queue_status ON ai_task_queue(status, priority DESC, scheduled_for);
CREATE INDEX idx_task_queue_type ON ai_task_queue(task_type, status);
```

### Task Types

| Type | Description | Duration |
|------|-------------|----------|
| `twin_training` | Build/update digital twin | 30-60s |
| `bulk_analysis` | Analyse multiple clients/deals | 1-5min |
| `report_generation` | Generate PDF/PPTX reports | 20-40s |
| `simulation_batch` | Run multiple scenarios | 2-10min |
| `embedding_generation` | Generate semantic embeddings | 10-30s |
| `meeting_summary` | Post-meeting analysis | 15-30s |

### API Routes

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/tasks` | GET, POST | List/create tasks |
| `/api/tasks/[id]` | GET, DELETE | Get status/cancel task |
| `/api/tasks/[id]/logs` | GET | Get execution logs |
| `/api/tasks/scheduled` | GET, POST | Manage recurring tasks |
| `/api/cron/task-worker` | GET | Process pending tasks |

### Components

- `TaskQueueDashboard.tsx` - View all tasks with filters
- `TaskProgressCard.tsx` - Individual task with progress bar
- `TaskNotificationToast.tsx` - Completion notifications
- `ScheduledTasksManager.tsx` - Configure recurring tasks

---

## Feature 2: Network Graph Visualisation

### Purpose

Interactive force-directed graph showing relationships between clients, stakeholders, deals, products, and CSEs.

### Database Schema

```sql
-- Saved visualisation configurations
CREATE TABLE visualisation_configs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  vis_type TEXT NOT NULL,
  config JSONB NOT NULL,
  created_by TEXT NOT NULL,
  is_default BOOLEAN DEFAULT false,
  shared_with TEXT[],
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Relationship graph edges
CREATE TABLE relationship_edges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_type TEXT NOT NULL,
  source_id TEXT NOT NULL,
  source_label TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id TEXT NOT NULL,
  target_label TEXT NOT NULL,
  relationship_type TEXT NOT NULL,
  strength DECIMAL(3,2) DEFAULT 0.5,
  metadata JSONB,
  last_interaction_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Graph layout cache
CREATE TABLE graph_layout_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cache_key TEXT UNIQUE NOT NULL,
  layout_data JSONB NOT NULL,
  node_count INTEGER,
  edge_count INTEGER,
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_edges_source ON relationship_edges(source_type, source_id);
CREATE INDEX idx_edges_target ON relationship_edges(target_type, target_id);
CREATE INDEX idx_edges_type ON relationship_edges(relationship_type);
```

### Node Types

- Clients, Stakeholders, Deals, Products, CSEs

### Edge Types

- `owns`, `influences`, `competes_with`, `refers_to`, `reports_to`

### Interactions

- Drag nodes to manually arrange
- Double-click to expand/collapse clusters
- Right-click for context menu
- Search to locate and zoom
- Filter panel for node/edge types

### API Routes

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/visualisation/network-graph` | GET | Get nodes and edges |
| `/api/visualisation/graph/path` | GET | Find path between nodes |
| `/api/visualisation/configs` | GET, POST | Save/load view configs |
| `/api/visualisation/layout-cache` | GET, POST | Cache/retrieve layouts |

### Components

- `NetworkGraph.tsx` - Main graph container
- `GraphNode.tsx` - Individual node
- `GraphEdge.tsx` - Relationship line
- `GraphControls.tsx` - Filter, search, layout
- `NodeDetailPanel.tsx` - Entity details slide-out
- `PathFinder.tsx` - Shortest path visualisation

---

## Feature 3: Digital Twin & Deal Sandbox

### Purpose

AI personas trained on client behaviour for practice conversations and deal negotiation simulation.

### Database Schema

```sql
-- Digital twin profiles
CREATE TABLE client_digital_twins (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID,
  client_name TEXT NOT NULL,
  personality_profile JSONB NOT NULL,
  historical_patterns JSONB,
  stakeholder_dynamics JSONB,
  pain_points TEXT[],
  success_triggers TEXT[],
  objection_patterns JSONB,
  decision_timeline TEXT,
  budget_sensitivity TEXT,
  ai_model_version TEXT,
  last_trained_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Simulation scenarios
CREATE TABLE simulation_scenarios (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  twin_id UUID REFERENCES client_digital_twins(id),
  created_by TEXT NOT NULL,
  scenario_type TEXT NOT NULL,
  scenario_name TEXT NOT NULL,
  initial_context JSONB NOT NULL,
  objectives TEXT[],
  constraints JSONB,
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Simulation conversation turns
CREATE TABLE simulation_turns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scenario_id UUID REFERENCES simulation_scenarios(id) ON DELETE CASCADE,
  turn_number INTEGER NOT NULL,
  actor TEXT NOT NULL,
  message TEXT NOT NULL,
  sentiment DECIMAL(3,2),
  twin_internal_state JSONB,
  deal_probability_delta DECIMAL(5,2),
  coaching_note TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Deal sandbox configurations
CREATE TABLE deal_sandboxes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  deal_id UUID,
  client_name TEXT NOT NULL,
  deal_name TEXT NOT NULL,
  base_value DECIMAL(12,2) NOT NULL,
  current_terms JSONB NOT NULL,
  variables JSONB NOT NULL,
  constraints JSONB NOT NULL,
  win_probability DECIMAL(5,2),
  created_by TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Sandbox negotiation moves
CREATE TABLE sandbox_moves (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sandbox_id UUID REFERENCES deal_sandboxes(id) ON DELETE CASCADE,
  move_number INTEGER NOT NULL,
  move_type TEXT NOT NULL,
  actor TEXT NOT NULL,
  terms_change JSONB NOT NULL,
  rationale TEXT,
  client_reaction TEXT,
  new_win_probability DECIMAL(5,2),
  deal_value_impact DECIMAL(12,2),
  coaching_feedback TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### Twin Training Process

1. **Data Aggregation** - Pull NPS, meetings, support, deal history
2. **Pattern Extraction** - AI analyses communication style, objections
3. **Profile Generation** - Structured personality with predictions
4. **Continuous Learning** - Update based on new interactions

### Scenario Types

- `renewal_negotiation`
- `upsell_pitch`
- `objection_handling`
- `crisis_response`

### API Routes

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/twins` | GET, POST | List/create twins |
| `/api/twins/[id]` | GET, PUT, DELETE | Manage twin |
| `/api/twins/[id]/train` | POST | Retrain twin |
| `/api/simulations` | GET, POST | List/create scenarios |
| `/api/simulations/[id]/turn` | POST | Submit message, get response |
| `/api/sandbox` | GET, POST | List/create sandboxes |
| `/api/sandbox/[id]/move` | POST | Make negotiation move |
| `/api/sandbox/[id]/reset` | POST | Reset to initial state |

### Components

- `DigitalTwinBuilder.tsx` - Create/train twins
- `TwinProfileCard.tsx` - View personality summary
- `SimulationChat.tsx` - Interactive conversation
- `SimulationCoach.tsx` - Real-time feedback
- `DealSandbox.tsx` - Negotiation playground
- `TermsSlider.tsx` - Adjust deal variables
- `OutcomePredictor.tsx` - Probability impact display
- `SimulationReplay.tsx` - Review with annotations

---

## Feature 4: 3D Pipeline Landscape

### Purpose

WebGL terrain where deals are positioned spatially for immersive pipeline exploration.

### Spatial Mapping

- **X-axis**: Deal stage (left=early, right=closed)
- **Y-axis**: Deal value (height)
- **Z-axis**: Time to close (depth)
- **Colour**: Health/probability
- **Size**: ARR impact

### Interactions

- Orbit controls to rotate/zoom
- Click deal for detail panel
- Filter by CSE, tier, product
- Time scrubber for animation
- Fly-through presentation mode

### Tech Stack

- `@react-three/fiber` - React renderer for Three.js
- `@react-three/drei` - Helpers (OrbitControls, Text)
- `@react-three/postprocessing` - Visual effects
- `three` - Core 3D library

### API Routes

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/visualisation/pipeline-3d` | GET | Get deals for 3D view |

### Components

- `PipelineLandscape.tsx` - Main 3D container
- `DealMesh.tsx` - Individual deal object
- `TerrainGrid.tsx` - Stage/value grid floor
- `PipelineControls.tsx` - Filters, time scrubber

### Performance

- Level of Detail (LOD) for zoom levels
- Instanced meshes for similar objects
- Frustum culling
- WebWorker for calculations

---

## Feature 5: Meeting Co-Host, Transcription & Sentiment

### Purpose

Real-time meeting assistance with live transcription, AI suggestions, and sentiment tracking.

### Database Schema

```sql
-- Meeting sessions
CREATE TABLE meeting_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meeting_id UUID REFERENCES unified_meetings(id),
  client_name TEXT NOT NULL,
  participants TEXT[],
  status TEXT DEFAULT 'scheduled',
  started_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  transcription_enabled BOOLEAN DEFAULT true,
  cohost_enabled BOOLEAN DEFAULT true,
  sentiment_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Transcription segments
CREATE TABLE transcription_segments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES meeting_sessions(id) ON DELETE CASCADE,
  speaker TEXT,
  speaker_role TEXT,
  content TEXT NOT NULL,
  start_time_ms INTEGER NOT NULL,
  end_time_ms INTEGER NOT NULL,
  confidence DECIMAL(3,2),
  sentiment_score DECIMAL(3,2),
  sentiment_label TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Co-host suggestions
CREATE TABLE cohost_suggestions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES meeting_sessions(id) ON DELETE CASCADE,
  trigger_segment_id UUID REFERENCES transcription_segments(id),
  suggestion_type TEXT NOT NULL,
  content TEXT NOT NULL,
  context TEXT,
  priority TEXT DEFAULT 'normal',
  shown_at TIMESTAMPTZ,
  actioned BOOLEAN DEFAULT false,
  dismissed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Sentiment timeline
CREATE TABLE meeting_sentiment_timeline (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES meeting_sessions(id) ON DELETE CASCADE,
  timestamp_ms INTEGER NOT NULL,
  overall_sentiment DECIMAL(3,2),
  client_sentiment DECIMAL(3,2),
  internal_sentiment DECIMAL(3,2),
  tension_detected BOOLEAN DEFAULT false,
  key_moment TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### Data Flow

```
Browser Mic → WebSocket → Deepgram → Transcription
                                         ↓
                         ┌───────────────┼───────────────┐
                         ↓               ↓               ↓
                   Save Segment    Sentiment AI    Co-Host AI
                         ↓               ↓               ↓
                      Supabase     Update Score   Generate Tip
                         ↓               ↓               ↓
                   ←←←← Supabase Realtime Broadcast ←←←←
```

### Suggestion Types

- `talking_point` - Relevant data to mention
- `objection_response` - Counter to client concern
- `data_point` - Stats to support argument
- `warning` - Risk detected in conversation
- `question` - Suggested clarifying question

### API Routes

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/meetings/[id]/session` | POST, DELETE | Start/end session |
| `/api/meetings/[id]/transcription/stream` | WebSocket | Audio stream |
| `/api/meetings/[id]/cohost/suggestions` | GET | Fetch suggestions |
| `/api/meetings/[id]/sentiment` | GET | Get timeline |
| `/api/meetings/[id]/summary` | POST | Generate summary |

### Components

- `MeetingCoHost.tsx` - Main container
- `TranscriptionPanel.tsx` - Live transcript
- `SentimentGauge.tsx` - Real-time visualisation
- `CoHostSuggestionCard.tsx` - Actionable tips
- `MeetingControls.tsx` - Start/stop, toggles
- `PostMeetingSummary.tsx` - AI summary with key moments

---

## Implementation Order

| Phase | Features | Rationale |
|-------|----------|-----------|
| **9.1** | Background AI Task Queue | Foundation for async processing |
| **9.2** | Network Graph Visualisation | Lower complexity, validates graph model |
| **9.3** | Digital Twin & Deal Sandbox | Builds on task queue, high value |
| **9.4** | 3D Pipeline Landscape | Complex WebGL, leverages graph work |
| **9.5** | Meeting Co-Host & Transcription | External API integration |
| **9.6** | Sentiment Analysis | Extends meeting features |

---

## File Summary

### Database Migrations (6 files)

```
supabase/migrations/
├── 20260207_01_ai_task_queue.sql
├── 20260207_02_relationship_graph.sql
├── 20260207_03_visualisation_configs.sql
├── 20260207_04_digital_twins.sql
├── 20260207_05_deal_sandbox.sql
└── 20260207_06_meeting_sessions.sql
```

### API Routes (25 files)

```
src/app/api/
├── tasks/
│   ├── route.ts
│   ├── [id]/route.ts
│   ├── [id]/logs/route.ts
│   └── scheduled/route.ts
├── cron/task-worker/route.ts
├── twins/
│   ├── route.ts
│   ├── [id]/route.ts
│   └── [id]/train/route.ts
├── simulations/
│   ├── route.ts
│   └── [id]/turn/route.ts
├── sandbox/
│   ├── route.ts
│   ├── [id]/route.ts
│   ├── [id]/move/route.ts
│   └── [id]/reset/route.ts
├── visualisation/
│   ├── pipeline-3d/route.ts
│   ├── network-graph/route.ts
│   ├── graph/path/route.ts
│   ├── configs/route.ts
│   └── layout-cache/route.ts
└── meetings/[id]/
    ├── session/route.ts
    ├── transcription/stream/route.ts
    ├── cohost/suggestions/route.ts
    ├── sentiment/route.ts
    └── summary/route.ts
```

### Components (28 files)

```
src/components/
├── tasks/ (5 files)
├── twins/ (6 files)
├── sandbox/ (4 files)
├── visualisation/ (11 files)
└── meetings/ (7 files)
```

### Hooks (8 files)

```
src/hooks/
├── useTaskQueue.ts
├── useDigitalTwin.ts
├── useSimulation.ts
├── useDealSandbox.ts
├── useNetworkGraph.ts
├── usePipeline3D.ts
├── useMeetingSession.ts
└── useTranscription.ts
```

### Page Routes (6 files)

```
src/app/(dashboard)/
├── tasks/page.tsx
├── twins/page.tsx
├── sandbox/page.tsx
├── visualisation/pipeline/page.tsx
├── visualisation/network/page.tsx
└── meetings/[id]/live/page.tsx
```

---

## Dependencies

```json
{
  "@react-three/fiber": "^8.x",
  "@react-three/drei": "^9.x",
  "@react-three/postprocessing": "^2.x",
  "three": "^0.160.x",
  "d3-force-3d": "^3.x",
  "@deepgram/sdk": "^3.x"
}
```

---

## Environment Variables

```
DEEPGRAM_API_KEY=           # Real-time transcription
OPENAI_API_KEY=             # Already exists
```

---

## Total Scope

| Category | Count |
|----------|-------|
| Database migrations | 6 |
| API routes | 25 |
| Components | 28 |
| Hooks | 8 |
| Page routes | 6 |
| **Total new files** | **~73** |
