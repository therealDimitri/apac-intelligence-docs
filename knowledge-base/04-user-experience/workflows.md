# User Workflows

## CSE Morning Routine

```
1. Open dashboard (/) → see personalised greeting + stats
2. Review Executive Briefing → 12-section operational report
3. Listen to Audio Briefing (optional) → OpenAI TTS summary
4. Check Portfolio Health Stats → health distribution gauge
5. Review Actionable Intelligence → Key Insights, Alerts, Priority clients
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
1. /actions → action inbox view
2. Group by: status, due date, priority, client
3. View modes: list or kanban board
4. Bulk operations: select multiple, bulk status update
5. Quick create via modal or action bar
6. Link to initiative via LinkToInitiativeTab
7. /actions/inbox → inbox-specific view
```

**Components**: Modern-actions components, KanbanBoard, BulkActionsBar, CreateActionModal

## Strategic Planning

```
1. /planning → Account Planning Coach hub
2. Guided multi-step workflow:
   Step 1: Context (PredictiveInput for Plan Purpose)
   Step 2: Discovery/Diagnosis (LeadingIndicatorAlerts, AnomalyBadge)
   Step 3: Stakeholder Intelligence (PredictiveInput for Black Swans)
   Step 4: Opportunity Strategy (StoryBrand, MEDDPICC Coach)
   Step 5: Risk Recovery (PredictiveInput for Mitigation)
   Step 6: Action Narrative (PredictiveInput, NextBestActions)
3. Goal linking and approval workflow
```

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

## Goals & Initiatives

```
1. /goals-initiatives → landing page with tabs
2. 3-tier hierarchy: Company Goals → Team Goals → Initiatives
3. /goals-initiatives/new → create with templates
4. Link actions to initiatives for progress tracking
5. Approval workflow for goal changes
6. MS Graph integration for role-based access
```
