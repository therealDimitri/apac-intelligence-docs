# User Workflows

## CSE Morning Routine

```
1. Open dashboard (/) → see personalised greeting + stats
2. Review Executive Briefing → 12-section operational report
3. Listen to Audio Briefing (optional) → ElevenLabs TTS (charlie voice, hardcoded)
4. Check Portfolio Health Stats → health distribution gauge
5. Review Predictive Alerts → grouped by category (Churn Risk, Health Trajectory, etc.), collapsible sections
6. Filter "My Clients" → focus on assigned portfolio
7. Check overdue actions → prioritise follow-ups
8. Review ChaSen AI suggestions → act on proactive nudges
```

**Components**: ActionableIntelligenceDashboard, ExecutiveBriefing, AudioBriefingPlayer, PortfolioHealthStats

## Client Deep Dive

```
1. Navigate to /clients or /client-profiles
2. Click client → /clients/[clientId]/v2 (three-column layout)
3. LEFT: Client overview, metadata, contact info
4. CENTRE: Activity feed (meetings, notes, actions, comments)
5. RIGHT: UnifiedSidebar emerging details
6. Tabs: NPS Analysis, Portfolio Analysis
7. Deep link via URL params: ?section=...&highlight=...&tab=...
```

**Components**: ClientDetailTabs, LeftColumn, CenterColumn, RightColumn, UnifiedSidebar

## Meeting Workflow

### Before Meeting
```
1. /meetings → list view (cards grouped by status/CSE)
2. MeetingAnalyticsDashboard → statistics overview
3. Quick view → MeetingDetailTabs for context
4. ChaSen suggests talking points based on client context
```

### During Meeting (Phase 9)
```
1. /meetings/[id]/live → Meeting Co-Host
2. Real-time transcription with speaker identification
3. Sentiment gauge tracking conversation tone
4. AI coaching suggestions (talking points, objection responses)
5. Knowledge graph RAG for contextual data points
```

### After Meeting
```
1. Create/edit via EditMeetingModal or UniversalMeetingModal
2. AI extracts actions from meeting notes
3. Actions auto-created and linked to client
4. Follow-up tracked via action inbox
```

**Components**: CompactMeetingCard, MeetingDetailTabs, MeetingCoHost, TranscriptionPanel, SentimentGauge

## Action Management

```
1. /actions → Kanban board (default) or inbox view
2. View modes: Kanban, List, Status, Calendar, Link to Initiative
3. Group by: status, due date, priority, client
4. Bulk operations: select multiple, bulk status update
5. Click action card → ActionSlideOutEdit slide-out editor (full CRUD, comments, history)
6. /actions/[id] → standalone detail page (DOMPurify HTML rendering for notes)
7. Context-aware back nav: ?from= and ?title= query params for breadcrumb context
8. Actions can also be created/edited from goal detail pages (Projects → Child Items tab)
```

**Components**: ActionSlideOutEdit (shared across Actions page + Goal detail), KanbanBoard, BulkActionsBar

## Strategic Planning

```
1. /planning → Account Planning Coach hub → My Plans tab
   - Plan cards with status badges (Draft/In Progress/Pending Review/Approved/Archived)
   - Filter by status, Group By: owner/status/territory/client
   - Collapsible group sections with plan count + avg completion %
   - Inline plan rename (click title to edit)
2. Click plan → /planning/strategic/new?id=... → Plan Detail
   - Left sidebar: parent/child step tree (expand/collapse sub-steps)
   - Breadcrumbs: Planning > CSE Name > Step > Sub-step
   - 6 steps with sub-step rendering (only active sub-section shown):
     Setup (single view)
     Discovery: Summary | Gap Discovery | Client Gap Diagnosis
     Stakeholders: Overview | Tactical Empathy | Black Swan | "That's Right" | Calibrated Qs | Accusation Audit
     Opportunities: AI Tips | Plan Coverage | Qualification | StoryBrand | Forecast Simulation
     Risks: Risk Overview | Recovery Confidence | Accusation Audit | Recovery Narrative | Mitigation
     Actions: Plan Summary | Action Readiness | Actions
   - Scroll-to-top on step/sub-step change
3. ChaSen AI Coach (right sidebar):
   - Sub-step aware coaching buttons per methodology
   - Auto-suggestions on sub-step entry (1.5s debounce, cached)
   - Dynamic quick tips referencing specific client names, health scores, NPS
   - Methodologies: Gap Selling (Discovery), Voss (Stakeholders), MEDDPICC (Opportunities), Wortmann (Recovery)
4. Approval workflow via ApprovalPanel (submit/approve/reject)
```

**Components**: AIInsightsPanel, AISuggestionCard, ApprovalPanel, CollapsibleSection

## Executive Briefing

```
1. Auto-generated (daily/weekly) with 12 data sections
2. Sections:
   - Strategic: Portfolio Health, Opportunities, Financial Performance
   - Operational: Operating Rhythm, Segmentation, Meeting Activity
   - Risk: Alerts, Pending Actions, Working Capital
   - Customer Voice: NPS, Support Health, News
3. AI summary with coach-like, encouraging tone
4. Optional audio briefing (OpenAI TTS)
5. Caching: 4h (daily), 24h (weekly)
6. Available via dashboard or on-demand API
```

## Operating Rhythm

```
1. /operating-rhythm → orbit visualisation
2. Annual view: Activities on innermost orbit, clients at 130px, milestones at 180px
3. CSE view: Filtered to individual CSE's clients
4. Completion tracking: Only count completed=true AND event_date<=now()
5. Compliance scores derive from event counts vs targets
```

## Goals & Projects

```
1. /goals-initiatives → landing page with 9 tabs:
   Overview, Dashboard, Strategy Map, Pillar, BU Goals, Team, Projects, Timeline, Workload
2. 3-tier hierarchy: BU Goals → Team Goals → Projects (display labels; DB: company/team/initiative)
3. Tab features:
   - Dashboard: Actions reporting widget (status breakdown, overdue count), scope-sensitive insights
   - Strategy Map: XYFlow with zoom controls (bottom-right), fullscreen support
   - Timeline/Gantt: Default collapsed, hierarchical DFS sort, "Mon 10" day format,
     router.push for user drills (browser Back works), router.replace for mount sync only
   - Kanban: Softened column header borders (border-white/50)
4. Goal detail (/goals-initiatives/[type]/[id]):
   - Compact metadata bar (progress% | status | date range | owner)
   - Auto-sizing description with line-clamp-3 + "Show more"
   - AI Suggest for check-ins (popover with right-0, max-width for viewport safety)
   - Projects: Linked Actions section with ActionSlideOutEdit (initiative auto-linked)
5. Automations panel via Zap icon (top-right) — AutomationRulesPanel
6. /goals-initiatives/new → create with templates
7. Approval workflow + MS Graph integration for role-based access
```

### Goal Type Display Labels
- DB `company` → UI "BU Goal"
- DB `team` → UI "Team"
- DB `initiative` → UI "Project"
- Shared labels: `src/lib/goals/labels.ts`
