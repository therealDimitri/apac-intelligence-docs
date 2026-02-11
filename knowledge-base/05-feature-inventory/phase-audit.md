# Phase Audit

> Last audited: 2026-02-11

## Summary

| Phase | Total | Live | Wired | Scaffolded | Missing |
|-------|-------|------|-------|------------|---------|
| 7 (AI Components) | 9 | 9 | 0 | 0 | 0 |
| 8 (Experimental) | 9 | 9 | 0 | 0 | 0 |
| 9 (Moonshot) | 7 | 7 | 0 | 0 | 0 |
| 10 (ChaSen AI) | 19 | 19 | 0 | 0 | 0 |
| 11 (Dashboard Consolidation) | 8 | 8 | 0 | 0 | 0 |
| **TOTAL** | **52** | **52** | **0** | **0** | **0** |

**Status definitions:**
- **LIVE**: Fully functional, integrated UI, real data flow
- **WIRED**: Core logic complete, API operational, minor UI/integration polish needed
- **SCAFFOLDED**: Files exist with placeholder comments or mocks
- **MISSING**: No implementation found

## Phase 7: AI Components

| Feature | Status | Evidence |
|---------|--------|----------|
| PredictiveInput | LIVE | Full component with ghost text, confidence indicators, voice input |
| LeadingIndicatorAlerts | LIVE | Urgency levels, confidence bars, trend indicators, expandable actions |
| AnomalyHighlight | LIVE | IQR outlier detection, severity badges, inline highlights |
| useAnomalyDetection | LIVE | 400+ lines of statistical logic (IQR, trend break, plateau detection) |
| useLeadingIndicators | LIVE | Hook logic + portfolio card + per-client integration on detail page |
| usePredictiveField | LIVE | Debounced API calls, confidence scoring, dismissal learning |
| /api/ai/field-suggestions | LIVE | Field-specific prompts, Anthropic integration, confidence calculation |
| /api/ai/analyse-image | LIVE | Claude Vision integration |
| /api/ai/generate-chart | LIVE | NL-to-chart generation |

## Phase 8: Experimental Features

| Feature | Status | Evidence |
|---------|--------|----------|
| Executive Briefing | LIVE | 12 data sections, caching (4h daily/24h weekly), AI summary, audio TTS (ElevenLabs charlie voice, Accept header fix) |
| /api/briefings/generate | LIVE | Period selection, CSE filtering, cache management, force-refresh |
| /api/briefings/audio | LIVE | OpenAI TTS integration |
| Competitors Tracking | LIVE | CRUD APIs, DB migration confirms table existence |
| Autopilot Rules | LIVE | Full CRUD with tier filtering, health ranges, condition matching, cooldown |
| Autopilot Suggestions | LIVE | API returns pending touchpoints, `scheduled_touchpoints` table |
| Recognition Occasions | LIVE | Full CRUD with occasions and suggestions |
| Communications Draft | LIVE | AI-generated email drafts with CRUD operations |
| Timeline Replay | LIVE | Full scrubber, health/NPS/ARR/actions metric cards, event markers, key moments, play/pause/speed controls. Gantt: hierarchical DFS sort, default collapsed, "Mon 10" day format, push/replace drill navigation |

## Phase 9: Moonshot Features

| Feature | Status | Evidence |
|---------|--------|----------|
| AI Task Queue | LIVE | Full schema, `/api/tasks` with status filtering, priority, retry logic |
| Network Graph | LIVE | D3 force-directed graph with pan/zoom, dragging, node selection |
| Digital Twins | LIVE | Full twin profiles with communication styles, scenario configs, simulation turns |
| Deal Sandbox | LIVE | Sandbox with negotiation moves, AI client reactions, reset functionality |
| 3D Pipeline (PipelineLandscape) | LIVE | Three.js/React Three Fiber with 3D deal meshes, stage colours, orbit controls |
| Meeting Co-Host | LIVE | Live transcription, sentiment gauge, AI coaching suggestions |
| Health Predictions | LIVE | MSTL decomposition, 30d/90d forecasts, contributing factors |

## Phase 10: ChaSen AI

| Feature | Status | Evidence |
|---------|--------|----------|
| Ambient Awareness → ChaSen (F1) | LIVE | useAmbientAwareness integrated into FloatingChaSenAI, 4 context domains (dashboard, goals, sentiment, automation) |
| ChaSen Tools (F2) | LIVE | 20 tools in Anthropic tool_use format — 13 read (immediate) + 5 write (approval) + 2 workflow |
| Knowledge Graph RAG (F3) | LIVE | 5 data sources synced, incremental sync, graph_sync_status tracking |
| Learning Loop (F4) | LIVE | Dismissal patterns feed back into prompt generation, memory extraction |
| Structured Output (F5) | LIVE | tool_use structured outputs replacing regex JSON parsing |
| Email Assist & Content Generation (F6) | LIVE | AI email writing with tone adjustment, subject lines, intros, CTA strengthening, content expansion |
| Predictive Health Engine (F7) | LIVE | @bsull/augurs MSTL decomposition, daily cron |
| NL Workflows (F8) | LIVE | ChaSen tools for CRUD, WorkflowManager UI, WorkflowApprovalQueue, tabbed approvals page, workflow-evaluator cron |
| Cross-Client Patterns & Agent Orchestration (F9) | LIVE | Multi-agent orchestration with intent classification, specialist agents, weekly pattern detection cron |
| Meeting Co-Pilot RAG (F10) | LIVE | DB-backed rate limiting/dedup, LLM-powered suggestion generation, transcription-to-cohost trigger wiring |
| "Time Machine" What-If (F11) | LIVE | Timeline building, AI scenario modelling |
| Personalised Digest (F12) | LIVE | Per-user daily briefing with AI coaching insight |
| "Explain This" (F13) | LIVE | Right-click context menu, floating explanation popover |
| Document Upload & Processing (F14) | LIVE | Multi-format parsing (PDF/DOCX/XLSX/CSV/TXT), size-based routing (< 4MB direct, >= 4MB Supabase Storage), AI summary |
| Multi-Model AI Routing (F15) | LIVE | 6 models via MatchaAI proxy (Gemini Flash default, Claude 3.7/4/4.5, GPT-4o/Mini), user-selectable |
| Operating Rhythm Context (F16) | LIVE | Cadence-aware context loading for autopilot, touchpoints, recognition queries |
| Goal Automation Rules (F17) | LIVE | CRUD API, staleness cron, PL/pgSQL auto-complete + progress rollup triggers, admin panel UI |
| Meeting Brief Generation (F18) | LIVE | ChaSen tool + API + slide-in panel with copy/print, aggregates initiatives/financials/NPS/actions |
| Smart Goal Fields (F19) | LIVE | ChaSen suggest_goal_metadata tool, debounced client/owner/priority suggestions, duplicate detection |

## Phase 11: Dashboard Consolidation

| Feature | Status | Evidence |
|---------|--------|----------|
| KPIHeroRow | LIVE | 6 metric cards (Gross Revenue, Net Revenue, Pipeline, Revenue at Risk, NRR/GRR, Rule of 40) self-fetching from `burc_executive_summary` |
| DashboardHeader | LIVE | Personalised greeting, collapsible AI briefing (indigo->navy gradient), audio player |
| useBurcFinancials hook | LIVE | 3 parallel API fetches with `autoFetch` lazy-load option |
| 5-tab consolidated dashboard | LIVE | Overview, Actions & Priorities, Financial Performance, Pipeline & Renewals, Analytics |
| Financials component extraction | LIVE | 16 standalone components in `src/components/financials/` (from 4,178-line monolith) |
| `singleTab` prop on ActionableIntelligenceDashboard | LIVE | Locks to Priority Matrix tab without duplicating 1,600 lines |
| `/financials` 301 redirect | LIVE | Permanent redirect to `/` via `next.config.ts` |
| `burc-export.ts` standalone PDF utility | LIVE | Extracted from financials page, dynamic jsPDF import |

## Quality Highlights

1. **Phase 7**: Full accessibility support (ARIA), dark mode, mobile responsive
2. **Phase 8**: Parallel Promise.all() data loading, configurable cache TTL
3. **Phase 9**: Digital twin personality configs (analytical/decisive/collaborative/cautious)
4. **Phase 10**: Native Anthropic tool_use (no regex), 20 tools with read/write distinction, 6-model routing, size-based upload bypass for Netlify limits
5. **Phase 11**: Lazy-load pattern (`autoFetch: false`) — Financial/Pipeline/Analytics tabs only trigger API calls when opened, keeping initial load fast
