# ChaSen Tools

## Tool Definitions

14 tools defined in `src/lib/chasen-tools.ts` using Anthropic `tool_use` format.

### Read Tools (execute immediately)

| Tool | Purpose | Data Source |
|------|---------|-------------|
| `search_meetings` | Find meetings by client, date, or topic | `unified_meetings` |
| `search_actions` | Find actions by status, client, or owner | `actions` |
| `get_client_detail` | Get full client profile with health score | `portfolio_clients`, health history |
| `search_knowledge_graph` | Search RAG knowledge base | `chasen_knowledge` |
| `get_portfolio_summary` | Portfolio-level health and metrics | `portfolio_clients` aggregate |
| `get_health_prediction` | Client health forecast | `health_predictions` |
| `get_portfolio_insights` | Cross-client pattern insights | `portfolio_insights` |
| `get_my_digest` | User's personalised daily briefing | `user_digests` |

### Write Tools (require user approval)

| Tool | Purpose | Target Table |
|------|---------|-------------|
| `create_action` | Create a new action item | `actions` |
| `update_action_status` | Update action status | `actions` |
| `create_meeting_note` | Add a meeting note | `unified_meetings` |
| `create_email_draft` | Draft an email | `communication_drafts` |
| `update_client_health_note` | Update client health notes | `portfolio_clients` |
| `what_if_analysis` | Run historical scenario modelling | `what-if-analysis.ts` engine |

## Tool Orchestration

1. User sends message
2. LLM decides which tools to call via `toolChoice: 'auto'`
3. Read tools execute immediately, results injected back
4. Write tools generate an approval request
5. User confirms/denies write operations
6. `maxSteps: 5` prevents runaway tool loops

## Important Gotchas

- Tool `inputSchema` must use `as any` cast for Vercel AI SDK compatibility
- Each tool must complete in < 1s (fast DB queries only) to fit within 25s Netlify timeout
- Write tools include `isWriteTool()` check — never auto-execute writes
- `createToolApproval()` generates approval UI for write operations

## AI Hooks (Phase 7)

| Hook | Purpose |
|------|---------|
| `useAnomalyDetection` | IQR-based statistical outlier detection |
| `useLeadingIndicators` | Early warning signal detection |
| `usePredictiveField` | Ghost text suggestions with debounced API |
| `useImageAnalysis` | Clipboard paste-to-analyse with Claude Vision |
| `usePdfIngestion` | PDF upload with progress tracking |
| `useNaturalLanguageChart` | NL-to-chart conversion |
| `useDismissalLearning` | Learn from user feedback |
| `useAmbientAwareness` | Track cursor, scroll, focus for contextual AI |
| `usePlanAI` | Planning AI — 6 action types: gap_summary_analysis, gap_client_diagnosis, coverage_analysis, tactical_empathy_coach, accusation_audit_coach, recovery_narrative_coach |

## AI API Routes

| Endpoint | Purpose |
|----------|---------|
| `/api/ai/field-suggestions` | Context-aware field suggestions |
| `/api/ai/analyse-image` | Claude Vision image analysis |
| `/api/ai/analyse-pdf` | PDF content analysis |
| `/api/ai/generate-chart` | NL-to-chart spec |
| `/api/ai/parse-action` | NL command parsing |
| `/api/chasen/stream` | Main streaming chat |
| `/api/chasen/explain` | Contextual metric explanation |
| `/api/chasen/what-if` | Scenario analysis |
| `/api/chasen/workflows` | NL workflow CRUD |
| `/api/chasen/recommend-actions` | AI action recommendations |
| `/api/planning/strategic/new/ai` | Planning AI coaching (new plans) — Gap Selling, Voss, MEDDPICC, Wortmann prompts |
| `/api/planning/strategic/[id]/ai` | Planning AI coaching (existing plans) — same prompt builders |
