# Feature Matrix

## Core Platform Features

| Feature | Page Route | API Route | DB Tables | Status |
|---------|-----------|-----------|-----------|--------|
| Dashboard | `/` | Multiple | `portfolio_clients`, `actions`, `unified_meetings` | Live |
| Client Profiles | `/client-profiles` | `/api/clients` | `portfolio_clients`, `client_health_history` | Live |
| Client Detail | `/clients/[id]/v2` | Multiple | All client-related tables | Live |
| Meeting Management | `/meetings` | `/api/meetings` | `unified_meetings`, `topics` | Live |
| Actions & Tasks | `/actions` | `/api/actions` | `actions`, `action_comments`, `action_relations` | Live |
| Segmentation | `/compliance` | `/api/compliance` | `segmentation_events`, `event_compliance_summary` | Live |
| Operating Rhythm | `/operating-rhythm` | `/api/compliance` | `segmentation_events`, `tier_event_requirements` | Live |
| NPS Analytics | `/nps` | `/api/nps` | `nps_responses`, `nps_topic_classifications` | Live |
| Support Health | `/support` | `/api/support` | `support_case_details`, `support_sla_latest` (view) | Live |
| Working Capital | `/aging-accounts` | `/api/aging-accounts` | `aging_accounts` | Live |
| Team Performance | `/team-performance` | `/api/team-performance` | Various | Live |
| Financial (BURC) | `/burc` | `/api/analytics/burc` | `burc_*` tables | Live |
| Pipeline | `/pipeline` | `/api/pipeline` | `pipeline_deals` | Live |

## Strategic Planning

| Feature | Page Route | API Route | DB Tables | Status |
|---------|-----------|-----------|-----------|--------|
| Account Planning | `/planning` | `/api/plans` | Various | Live |
| Strategic Plans | `/planning/strategic` | `/api/plans` | Various | Live |
| Per-Client Gap Confidence | `/planning/strategic/new` (Gap Discovery sub-step) | — | In-memory (plan state) | Live |
| Goals & Initiatives | `/goals-initiatives` | `/api/goals` | `company_goals`, `team_goals`, `portfolio_initiatives` | Live |
| Goal Approvals | `/goals-initiatives/approvals` | `/api/goals/[id]` | `goal_approvals`, `goal_audit_log` | Live |
| Relationship Autopilot | `/planning/autopilot` | `/api/autopilot` | `relationship_autopilot_rules`, `scheduled_touchpoints` | Live |
| Recognition | `/planning/recognition` | `/api/recognition` | `recognition_occasions`, `recognition_suggestions` | Live |

## AI & Intelligence

| Feature | Page Route | API Route | Key Files | Status |
|---------|-----------|-----------|-----------|--------|
| ChaSen AI Chat | Floating widget | `/api/chasen/stream` | `chasen-tools.ts`, `chasen-agents.ts` | Live |
| Executive Briefing | `/` (embedded) | `/api/briefings/generate` | `executive-briefing.ts` | Live |
| Audio Briefing | `/` (embedded) | `/api/briefings/audio` | ElevenLabs → MeloTTS → OpenAI TTS | Live |
| Explain This | Global (right-click) | `/api/chasen/explain` | `useExplainThis.ts` | Live |
| Predictive Health | Background | `/api/cron/predictive-forecast` | `predictive-health.ts` | Live |
| Portfolio Patterns | Background | `/api/cron/portfolio-patterns` | `portfolio-patterns.ts` | Live |
| Personalised Digest | Background | `/api/digest` | `personalised-digest.ts` | Live |
| What-If Analysis | Via ChaSen | `/api/chasen/what-if` | `what-if-analysis.ts` | Live |
| Sentiment Analysis | Background | `/api/sentiment` | `sentiment-analysis.ts` | Live |

## Visualisations

| Feature | Page Route | API Route | Key Components | Status |
|---------|-----------|-----------|---------------|--------|
| Network Graph | `/visualisation/network` | `/api/visualisation/network-graph` | `NetworkGraph.tsx` (D3) | Live |
| 3D Pipeline | `/visualisation/pipeline` | `/api/visualisation/pipeline-3d` | `PipelineLandscape.tsx` (Three.js) | Live |
| Digital Twins | `/twins` | `/api/twins` | `TwinProfileCard`, `SimulationChat` | Live |
| Deal Sandbox | `/sandbox` | `/api/sandbox` | `DealSandbox`, `TermsSlider` | Live |
| AI Task Queue | `/tasks` | `/api/tasks` | `TaskQueueDashboard` | Live |
| Meeting Co-Host | `/meetings/[id]/live` | `/api/meetings/[id]/session` | `MeetingCoHost`, `TranscriptionPanel` | Live |

## Resources

| Feature | Page Route | API Route | Status |
|---------|-----------|-----------|--------|
| Sales Hub | `/sales-hub` | `/api/sales-hub` | Live |
| Guides & Templates | `/guides` | `/api/guides` | Live |
| Email Templates | `/guides/email-templates` | `/api/email-templates` | Live |
| News Intelligence | Settings | `/api/cron/news-fetch` | Live |

## Administration

| Feature | Page Route | API Route | Status |
|---------|-----------|-----------|--------|
| Data Quality | `/admin/data-quality` | `/api/admin/data-quality` | Live |
| MS Graph Role Mapping | `/admin/ms-graph-role-mapping` | `/api/ms-graph` | Live |
| Audit Log | `/admin/audit-log` | `/api/admin/audit-log` | Live |
| Settings | `/settings/*` | Various | Live |

## Navigation Groups

| # | Group | Pages in Sidebar |
|---|-------|-----------------|
| 1 | Command Centre | Dashboard, CS Operating Rhythm |
| 2 | Success Plans | Account Planning, Goals & Initiatives, Approvals, Autopilot, Recognition |
| 3 | Clients | Portfolio Health, Segmentation Progress |
| 4 | Action Hub | Meetings, Actions & Tasks, AI Task Queue |
| 5 | Analytics | CS Team Performance, NPS, Support Health, Working Capital |
| 6 | AI Lab | Digital Twins, Deal Sandbox |
| 7 | Visualisations | Network Graph, 3D Pipeline |
| 8 | Resources | Sales Hub, Guides & Templates |
