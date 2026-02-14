# Phase 9-10 Developer Reference

> Detailed API routes, components, hooks, and integration patterns for Phase 9 (Moonshot) and Phase 10 (ChaSen AI Advanced).

## Phase 9: Moonshot Features

### 9.1: Background AI Task Queue

**Database Tables:** `ai_task_queue`, `ai_task_dependencies`, `ai_task_logs`, `ai_scheduled_tasks`

**Task Types:** `twin_training`, `bulk_analysis`, `report_generation`, `simulation_batch`, `embedding_generation`, `meeting_summary`

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/tasks` | GET, POST | List/create tasks |
| `/api/tasks/[id]` | GET, DELETE | Get/cancel task |
| `/api/tasks/[id]/logs` | GET | Get execution logs |
| `/api/tasks/scheduled` | GET, POST | Manage recurring tasks |
| `/api/cron/task-worker` | GET | Process pending tasks |

**Components:** `TaskQueueDashboard`, `TaskProgressCard` | **Hook:** `useTaskQueue` | **Route:** `/tasks`

### 9.2: Relationship Network Graph

**Database Tables:** `visualisation_configs`, `relationship_edges`, `graph_layout_cache`

**Functions:** `clean_expired_graph_cache()`, `get_connected_nodes(node_type, node_id, max_depth)`

**Node Types:** `client`, `stakeholder`, `deal`, `product`, `cse`

**Relationship Types:** `owns`, `influences`, `competes_with`, `refers_to`, `reports_to`, `assigned_to`, `sold_to`

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/visualisation/network-graph` | GET | Get nodes and edges |
| `/api/visualisation/graph/path` | GET | Find shortest path |
| `/api/visualisation/configs` | GET, POST | List/save configurations |
| `/api/visualisation/configs/[id]` | GET, PUT, DELETE | Manage configuration |

**Components:** `NetworkGraph` (D3 force-directed), `GraphNode`, `GraphEdge`, `NetworkGraphSkeleton`

**Hook:** `useNetworkGraph` | **Route:** `/visualisation/network`

**Key Files:** Components: `src/components/visualisation/`, Hook: `src/hooks/useNetworkGraph.ts`, Migration: `supabase/migrations/20260207_02_relationship_graph.sql`

### 9.3: Digital Twin & Deal Sandbox

**Digital Twin Tables:** `client_digital_twins`, `simulation_scenarios`, `simulation_turns`

**Deal Sandbox Tables:** `deal_sandboxes`, `sandbox_moves`

**Scenario Types:** `renewal_negotiation`, `upsell_pitch`, `objection_handling`, `crisis_response`

**Communication Styles:** `analytical`, `decisive`, `collaborative`, `cautious`

**Move Types:** `discount`, `term_extension`, `feature_add`, `feature_remove`, `payment_terms`, `bundling`

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/twins` | GET, POST | List/create twins |
| `/api/twins/[id]` | GET, DELETE | Get/delete twin |
| `/api/twins/[id]/train` | POST | Queue twin training task |
| `/api/twins/[id]/scenarios` | GET, POST | List/create scenarios |
| `/api/twins/[id]/scenarios/[scenarioId]` | GET | Get scenario details |
| `/api/twins/[id]/simulate` | POST | Run simulation turn |
| `/api/sandbox` | GET, POST | List/create sandboxes |
| `/api/sandbox/[id]` | GET, DELETE | Get/delete sandbox |
| `/api/sandbox/[id]/move` | POST | Make negotiation move |
| `/api/sandbox/[id]/reset` | POST | Reset sandbox |

**Twin Components:** `TwinProfileCard`, `DigitalTwinBuilder`, `SimulationChat`

**Sandbox Components:** `DealSandbox`, `TermsSlider`

**Hooks:** `useDigitalTwin`, `useDealSandbox`

**Routes:** `/twins`, `/sandbox`

### 9.4: 3D Pipeline Landscape

**Dependencies:** `three`, `@react-three/fiber`, `@react-three/drei`

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/visualisation/pipeline-3d` | GET | Fetch deals with 3D positions |

**3D Coordinate Mapping:**
- **X-axis (0-5)**: Stage progression (Lead -> Closed)
- **Y-axis**: Deal value (logarithmic scale)
- **Z-axis**: Days to close

**Components:** `DealMesh`, `TerrainGrid`, `PipelineControls`, `PipelineLandscape`

**Hook:** `usePipeline3D` | **Route:** `/visualisation/pipeline`

```typescript
type DealStage = 'lead' | 'qualified' | 'proposal' | 'negotiation' | 'closed_won' | 'closed_lost'
```

### 9.5: Meeting Co-Host & Transcription

**Tables:** `meeting_sessions`, `transcription_segments`, `cohost_suggestions`, `meeting_sentiment_timeline`

**Session Status:** `scheduled`, `active`, `ended`, `cancelled`

**Speaker Roles:** `client`, `internal`, `unknown`

**Suggestion Types:** `talking_point`, `objection_response`, `data_point`, `warning`, `question`

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/meetings/[id]/session` | POST | Start/end sessions |
| `/api/meetings/[id]/transcription` | GET, POST | Transcription segments |
| `/api/meetings/[id]/cohost` | GET, POST, PUT | Suggestions |
| `/api/meetings/[id]/sentiment` | GET, POST | Sentiment timeline |
| `/api/meetings/[id]/summary` | POST | AI meeting summary |

**Components:** `TranscriptionPanel`, `SentimentGauge`, `CoHostSuggestionCard`, `MeetingCoHost`

**Hooks:** `useMeetingSession`, `useTranscription`

**Exported helpers:** `getAudioInputDevices()` — enumerate browser audio inputs (requires mic permission grant first)

**Route:** `/meetings/[id]/live`

**Implementation Notes:**
- Dynamic import with `ssr: false` for MeetingCoHost (browser-only audio APIs)
- `meeting_sessions.meeting_id` references `unified_meetings.id` which is **INTEGER** type
- 5-second polling interval for real-time updates
- Sentiment scores: -1.0 (negative) to +1.0 (positive)
- **Audio device selector**: Settings gear opens panel to choose audio input device. Supports virtual devices (Microsoft Teams Audio Device, BlackHole) for capturing system/meeting audio instead of just the microphone
- Virtual device detection: when `audioDeviceId` is set, `echoCancellation`, `noiseSuppression`, `autoGainControl` are disabled to preserve the original audio signal
- Device selection persisted in `localStorage` (`cohost-audio-device` key)
- Mic permission flow: uses `navigator.permissions.query()` (Chrome/Edge) with `.catch()` fallback for Safari (tries `enumerateDevices()` directly). Shows explicit "Allow Microphone Access" button when permission not yet granted

### 9.6: Sentiment Analysis

**Tables:** `client_sentiment_snapshots`, `sentiment_alerts`, `sentiment_analysis_queue`, `sentiment_thresholds`

**Alert Types:** `sentiment_drop`, `sustained_negative`, `sudden_change`, `emotion_spike`

**Emotion Types:** `satisfaction`, `frustration`, `urgency`, `concern`, `enthusiasm`, `disappointment`, `confidence`, `uncertainty`

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/sentiment/client/[clientId]` | GET | Client sentiment history |
| `/api/sentiment/analyse` | POST | On-demand analysis |
| `/api/sentiment/alerts` | GET | Pending alerts |
| `/api/sentiment/alerts/[id]` | GET, PUT | Manage alert |
| `/api/cron/sentiment-snapshot` | GET | Daily snapshot cron |

**Components:** `SentimentSparkline`, `SentimentTrendChart`, `SentimentAlertCard`, `ClientSentimentPanel`

**Hook:** `useSentimentAnalysis` | **Service:** `src/lib/sentiment-analysis.ts`

**Threshold Configuration:**

| Tier | Drop Threshold | Negative Threshold | Sustained Days |
|------|---------------|-------------------|----------------|
| Global | -0.30 | -0.50 | 7 |
| Strategic | -0.20 | -0.40 | 5 |
| Enterprise | -0.25 | -0.45 | 6 |
| Growth | -0.35 | -0.55 | 10 |

---

## Phase 10: ChaSen AI — 13 Features

Design doc: `.claude/plans/fizzy-riding-fog.md`

### F1: Ambient Awareness -> ChaSen Context

- `FloatingChaSenAI.tsx` calls `useAmbientAwareness()` and includes ambient state in API request
- Stream route injects context: focus area, inferred intent, engagement level, dwell time
- Proactive nudges when `inferredIntent === 'considering'` and `engagementLevel > 60`
- **Gotcha**: `AmbientState.focusAreas` is `FocusArea[]`, `sections` is `Map<string, SectionVisibility>`

### F2: ChaSen Tool Use System

- **Tool definitions**: `src/lib/chasen-tools.ts` — 14 tools in Anthropic `tool_use` format
- **Stream route**: Passes tools to `streamText()` with `toolChoice: 'auto'`
- **Read tools** (immediate): `search_meetings`, `search_actions`, `get_client_detail`, `search_knowledge_graph`, `get_portfolio_summary`, `get_health_prediction`, `get_portfolio_insights`, `get_my_digest`
- **Write tools** (approval): `create_action`, `update_action_status`, `create_meeting_note`, `create_email_draft`, `update_client_health_note`, `what_if_analysis`
- **Constraint**: Each tool call < 1s. `maxSteps: 5` within 25s Netlify window.
- **Gotcha**: Tool `inputSchema` needs `as any` cast for Vercel AI SDK

### F3: Knowledge Graph Completion

| Sync Function | Source Table | Node Type | Key Edges |
|--------------|-------------|-----------|-----------|
| `syncProductsToGraph()` | `product_catalog` | `product` | -> sold_to -> client |
| `syncDealsToGraph()` | `pipeline_deals` | `deal` | -> for_client -> client |
| `syncEmailThreadsToGraph()` | `communication_drafts` | `communication` | -> about -> client |
| `syncContractsToGraph()` | `burc_annual_financials` | `contract` | -> with -> client |
| `syncNewsToGraph()` | `news_articles` | `news` | -> mentions -> client |

- **Incremental sync**: `graph_sync_status` tracks `last_synced_at` per source
- **Gotcha**: `findSimilarNodes` takes `number[]` (embedding vector), NOT string

### F4: Learning Loop

- `FloatingChaSenAI.tsx` calls `useDismissalLearning()` and `filterSuggestions()`
- Stream route accepts `feedbackContext: { suppressedTopics, preferredTopics, recentDismissals }`
- `chasen-prompts.ts` tracks `clickCount` and `lastClicked` per prompt
- **Gotcha**: `useDismissalLearning` takes `DismissalLearningConfig` object (NOT string)

### F5: Structured Output System

- **Core**: `src/lib/structured-output.ts` — `callWithStructuredOutput<T>(messages, toolSchema, options)`
- **Schemas**: meetingSummary, extractActions, sentiment, parsedCommand, briefingSection, digestSummary
- **Files using it**: meeting summary route, action extraction, sentiment-analysis.ts, executive-briefing.ts, personalised-digest.ts
- **Gotcha**: When remapping shapes (e.g., `summary` -> `executiveSummary`), use separate variable for raw result

### F7: Predictive Health Engine

- **Engine**: `src/lib/predictive-health.ts` — Uses `@bsull/augurs` MSTL decomposition
- **Cron**: `src/app/api/cron/predictive-forecast/route.ts` — Daily prediction
- **DB**: `health_predictions` — 30d/90d forecasts with contributing factors
- **ChaSen tool**: `get_health_prediction(client_name)`
- **Trends**: `improving`, `stable`, `declining`, `critical_decline`

### F8: Natural Language Workflows

- **Parser/executor**: `src/lib/chasen-workflows.ts`
- **API**: `src/app/api/chasen/workflows/route.ts` — CRUD
- **DB columns** on `chasen_workflows`: `user_email`, `natural_language_rule`, `parsed_trigger`, `parsed_actions`, `approval_mode`, `last_triggered_at`, `trigger_count`
- **Approval modes**: `auto` (low-risk), `review` (all), `manual` (suggest only)

### F9: Cross-Client Pattern Detection

- **Engine**: `src/lib/portfolio-patterns.ts`
- **Cron**: `src/app/api/cron/portfolio-patterns/route.ts` — Weekly
- **DB**: `portfolio_insights` — patterns with affected clients and evidence
- **Insight types**: `product_correlation`, `segment_trend`, `support_cluster`, `churn_pattern`

### F10: Meeting Co-Pilot Real-Time RAG

- Added `generateRAGSuggestion()` to `/api/meetings/[id]/cohost/route.ts`
- Extracts entities from transcript, queries `findSimilarNodes()`, traverses graph edges
- **Rate limit**: Max 1 RAG query per 10 seconds per session
- **Suggestion type**: `data_point` with source `knowledge_graph`

### F11: Time Machine — Historical What-If

- **Engine**: `src/lib/what-if-analysis.ts`
- **API**: `src/app/api/chasen/what-if/route.ts` — POST `{ client_name, scenario, time_range_months }`
- **ChaSen tool**: `what_if_analysis`
- **Response**: `{ actual_trajectory[], modelled_trajectory[], key_divergence_points[], estimated_impact, confidence }`

### F12: Personalised Daily Digest

- **Generator**: `src/lib/personalised-digest.ts`
- **Page**: `src/app/(dashboard)/digest/page.tsx` — bento grid dashboard
- **Cron**: `src/app/api/cron/daily-digest/route.ts`
- **On-demand**: `src/app/api/digest/route.ts` — GET `?email=`
- **DB**: `user_digests` — cached per (user_email, digest_date) with UPSERT
- **Client resolution**: `user_role_assignments` -> `portfolio_clients` -> `cse_profiles` -> fallback all
- **UI layout**: Bento grid (`grid-cols-1 md:grid-cols-2 lg:grid-cols-3`). High-priority cards span 2 cols on lg. All cards collapsed by default (scan-first). Click to expand inline (multi-expand, not accordion). Priority pill bar replaces counter grid.
- **Design tokens**: Uses `PriorityColors.critical` (high), `.medium`, `.low` from `design-tokens.ts`
- **State**: `expandedSections: Set<string>` keyed by section title (stable across re-sorts)

### F13: Explain This — Contextual Education

- **Hook**: `src/hooks/useExplainThis.ts` — right-click handler on `data-explain-*` elements
- **Popover**: `src/components/ai/ExplainThisPopover.tsx` — rendered globally in layout
- **API**: `src/app/api/chasen/explain/route.ts` — non-streaming
- **Data attributes**: `data-explain-type`, `data-explain-value`, `data-explain-client`
- **Response**: `{ explanation, factors[], trend, recommendation }`
- **Gotcha**: `setPopoverPosition` must be in `requestAnimationFrame()` (ESLint rule)

### Phase 10 Summary Tables

**Database Tables:**

| Table | Feature | Purpose |
|-------|---------|---------|
| `graph_sync_status` | F3 | Incremental graph sync timestamps |
| `health_predictions` | F7 | 30d/90d health forecasts |
| `chasen_workflows` (extended) | F8 | NL workflow columns |
| `portfolio_insights` | F9 | Cross-portfolio patterns |
| `user_digests` | F12 | Per-user daily briefings |

**API Routes:**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/chasen/explain` | POST | Contextual explanation (F13) |
| `/api/chasen/what-if` | POST | What-if analysis (F11) |
| `/api/chasen/workflows` | GET, POST, DELETE | NL workflow CRUD (F8) |
| `/api/digest` | GET | On-demand digest (F12) |
| `/api/cron/predictive-forecast` | GET | Daily health prediction (F7) |
| `/api/cron/portfolio-patterns` | GET | Weekly pattern detection (F9) |
| `/api/cron/daily-digest` | GET | Morning digest (F12) |

**Key Files:**

| File | Feature | Purpose |
|------|---------|---------|
| `src/lib/structured-output.ts` | F5 | Shared structured output |
| `src/lib/chasen-tools.ts` | F2 | 14 tools in tool_use format |
| `src/lib/predictive-health.ts` | F7 | Health forecasting |
| `src/lib/chasen-workflows.ts` | F8 | Workflow parsing/execution |
| `src/lib/portfolio-patterns.ts` | F9 | Pattern detection |
| `src/lib/personalised-digest.ts` | F12 | User-scoped briefings |
| `src/lib/what-if-analysis.ts` | F11 | Scenario modelling |
| `src/hooks/useExplainThis.ts` | F13 | Context menu hook |
| `src/components/ai/ExplainThisPopover.tsx` | F13 | Explanation popover |
