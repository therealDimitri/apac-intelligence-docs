# Unified Strategic Planning - Implementation Plan

**Date:** 4 February 2026
**Status:** Planning
**Design Document:** `docs/guides/DESIGN-unified-strategic-planning-2026-01-11.md`

---

## Implementation Philosophy

This plan follows a **progressive enhancement** approach:
1. Build core functionality first (MVP)
2. Add advanced features incrementally
3. Experimental/moonshot features in later phases
4. Each phase delivers usable value

---

## Phase 1: Foundation (Weeks 1-3)

### 1.1 Database Schema
- [ ] Create `strategic_plans` table with JSONB columns for flexibility
- [ ] Create `plan_comments` table for collaboration
- [ ] Create `plan_presence` table for real-time tracking
- [ ] Create `plan_activity_log` table for audit trail
- [ ] Create `plan_change_log` table for version tracking
- [ ] Create `plan_review_schedule` table for Operating Rhythm integration
- [ ] Add RLS policies for all new tables
- [ ] Create database indexes for query performance

### 1.2 API Routes
- [ ] `POST /api/planning/strategic` - Create new plan
- [ ] `GET /api/planning/strategic` - List plans (with filters)
- [ ] `GET /api/planning/strategic/[id]` - Get single plan
- [ ] `PUT /api/planning/strategic/[id]` - Update plan
- [ ] `DELETE /api/planning/strategic/[id]` - Delete plan
- [ ] `POST /api/planning/strategic/[id]/comments` - Add comment
- [ ] `GET /api/planning/strategic/[id]/comments` - Get comments
- [ ] `POST /api/planning/strategic/[id]/submit` - Submit for approval
- [ ] `POST /api/planning/strategic/[id]/approve` - Approve plan

### 1.3 Core Components
- [ ] `PlanTypeToggle.tsx` - Territory/Account toggle
- [ ] `StepWizard.tsx` - Main wizard container with step navigation
- [ ] `WizardStep.tsx` - Individual step wrapper
- [ ] `StepNavigation.tsx` - Step indicator/progress bar
- [ ] `ClientSelector.tsx` - Client selection dropdown with search

### 1.4 Type Definitions
- [ ] Define `StrategicPlan` TypeScript interface
- [ ] Define `PlanStep` types for each wizard step
- [ ] Define `PlanComment`, `PlanActivity` types
- [ ] Define validation schemas (Zod)

---

## Phase 2: Core Wizard Steps (Weeks 4-6)

### 2.1 Step 1: Context & Selection
- [ ] `ContextStep.tsx` - Main component
- [ ] Auto-detect user role (CSE/CAM) from session
- [ ] Territory auto-load based on assignment
- [ ] Client selection (single for Account, multi for Territory)
- [ ] Plan type toggle integration
- [ ] Basic ChaSen suggestion: "Based on your portfolio..."

### 2.2 Step 2: Portfolio & Targets
- [ ] `PortfolioStep.tsx` - Main component
- [ ] `PortfolioGrid.tsx` - Multi-client grid view
- [ ] `ClientSnapshot.tsx` - Single client view
- [ ] Auto-populate: ARR, NPS, Health, Segment from existing data
- [ ] Target entry fields (FY quota, coverage target)
- [ ] `CoverageGauge.tsx` - Visual coverage ratio

### 2.3 Step 3: Pipeline & Opportunities
- [ ] `PipelineStep.tsx` - Main component
- [ ] `OpportunityForm.tsx` - Add/Edit opportunity modal
- [ ] `OpportunityCard.tsx` - Single opportunity display
- [ ] `PipelineTable.tsx` - Sortable opportunity list
- [ ] `MEDDPICCScoring.tsx` - 8-criteria scoring component
- [ ] `ForecastSummary.tsx` - Target/Committed/Forecast/Gap display
- [ ] Dynamic forecast recalculation on changes

### 2.4 Step 4: Risks & Actions
- [ ] `RisksActionsStep.tsx` - Main component
- [ ] `RiskAssessment.tsx` - Risk entry with severity
- [ ] `ActionPlanEditor.tsx` - Action items with owners/dates
- [ ] `RevenueAtRisk.tsx` - What-if modelling component
- [ ] Link risks to opportunities

### 2.5 Step 5: Review & Forecast
- [ ] `ReviewStep.tsx` - Main component
- [ ] `ForecastBands.tsx` - Best/Likely/Worst visualization
- [ ] `ExecutiveSummary.tsx` - Auto-generated summary
- [ ] `ExportOptions.tsx` - PDF, Excel, Success Snapshot
- [ ] `SubmitForApproval.tsx` - Submission modal

---

## Phase 3: Collaboration Features (Weeks 7-9)

### 3.1 Real-Time Presence
- [ ] Set up Supabase Realtime channel for plans
- [ ] `PresenceIndicator.tsx` - Show active editors
- [ ] `usePlanPresence.ts` - Hook for presence state
- [ ] Cursor position sharing (optional)

### 3.2 Comments & Threads
- [ ] `CommentPanel.tsx` - Side panel for comments
- [ ] `CommentThread.tsx` - Threaded discussion
- [ ] `usePlanComments.ts` - Hook for comments
- [ ] @mention support with notifications
- [ ] Entity-linked comments (per risk, opportunity, etc.)

### 3.3 Approval Workflow
- [ ] `ApproverDashboard.tsx` - Pending approvals list
- [ ] `ChangeLogPanel.tsx` - View changes during review
- [ ] Collaborative editing with change tracking
- [ ] Approval/withdrawal actions
- [ ] Notification system (immediate + digest)

### 3.4 Activity Logging
- [ ] Automatic activity logging on all changes
- [ ] `ActivityTimeline.tsx` - Visual activity history
- [ ] Export activity log for audit

---

## Phase 4: Responsive Design (Weeks 10-11)

### 4.1 Layout System
- [ ] Create responsive layout components
- [ ] Define breakpoints matching device matrix
- [ ] `useDeviceType.ts` - Hook to detect device category
- [ ] `AdaptiveLayout.tsx` - Layout wrapper

### 4.2 Desktop Layouts (1280px+)
- [ ] 14" laptop layout (2-column + overlay)
- [ ] 16" laptop layout (2-column + sidebar)
- [ ] Wide monitor layout (3-column)
- [ ] Ultra-wide layout (4-panel)
- [ ] 5K layout (5-panel Mission Control)

### 4.3 Tablet Layouts (768-1279px)
- [ ] iPad Pro/Air layout (2-column, touch-optimised)
- [ ] iPad Mini layout (single column)
- [ ] Split View support
- [ ] Apple Pencil integration (notes)

### 4.4 Mobile Layouts (320-767px)
- [ ] Bottom navigation bar component
- [ ] Sheet-based interactions
- [ ] Swipeable card stacks
- [ ] Collapsible sections
- [ ] Touch target sizing (44×44px minimum)

### 4.5 Cross-Device Features
- [ ] Layout memory (persist per device)
- [ ] State sync via Supabase Realtime
- [ ] Offline mode with conflict resolution

---

## Phase 5: Basic ChaSen AI Integration (Weeks 12-14)

### 5.1 AI Infrastructure
- [ ] `usePlanAI.ts` - Hook for AI interactions
- [ ] `/api/chasen/planning/suggest` - Suggestion endpoint
- [ ] Context assembly for AI prompts
- [ ] Response parsing and display

### 5.2 Per-Step Suggestions
- [ ] Step 1: Priority client suggestion
- [ ] Step 2: Target allocation suggestions
- [ ] Step 3: Opportunity discovery from NPS/meetings
- [ ] Step 3: MEDDPICC auto-fill from data
- [ ] Step 4: Risk auto-generation
- [ ] Step 5: Executive summary generation

### 5.3 AI UI Components
- [ ] `AIInsightsPanel.tsx` - Suggestion display
- [ ] `AISuggestionCard.tsx` - Individual suggestion
- [ ] Accept/dismiss/feedback actions
- [ ] Confidence indicators

---

## Phase 6: Advanced Data Visualisation (Weeks 15-17)

### 6.1 Core Charts
- [ ] Install/configure charting library (Recharts or similar)
- [ ] `PipelineWaterfall.tsx` - Pipeline changes
- [ ] `ForecastChart.tsx` - Trend with confidence bands
- [ ] `HealthRadar.tsx` - Multi-dimensional health
- [ ] `CoverageGauge.tsx` - Visual coverage ratio

### 6.2 Interactive Features
- [ ] Drill-down navigation on all charts
- [ ] Hover tooltips with details
- [ ] Click-to-filter interactions
- [ ] Comparative overlays

### 6.3 Storytelling Features
- [ ] `NarrativeDashboard.tsx` - Story-based display
- [ ] `AnnotatedTimeline.tsx` - Timeline with context
- [ ] `BeforeAfterSlider.tsx` - Comparison slider
- [ ] Auto-generated insights per chart

### 6.4 Collaborative Visualisation
- [ ] Shared cursors on dashboards
- [ ] Annotation threads on data points
- [ ] Presentation mode

---

## Phase 7: Advanced AI Features (Weeks 18-21)

### 7.1 Proactive Intelligence
- [ ] Ambient awareness (cursor/scroll tracking)
- [ ] Predictive field population
- [ ] "Why this?" explainability
- [ ] Learning from dismissals

### 7.2 Multi-Modal Interaction
- [ ] Voice input integration
- [ ] Screenshot intelligence (paste to analyse)
- [ ] Document ingestion (PDF drag-drop)

### 7.3 Natural Language
- [ ] Natural language to chart generation
- [ ] Natural language actions ("Move close date to April")
- [ ] Query anything about data

### 7.4 Advanced Predictions
- [ ] Confidence cone forecasts
- [ ] Anomaly highlighting
- [ ] Leading indicator alerts
- [ ] Monte Carlo forecasting

---

## Phase 8: Experimental Features (Weeks 22-26)

### 8.1 Deal Intelligence
- [ ] Deal genome mapping infrastructure
- [ ] Win/loss pattern analysis
- [ ] Competitor move prediction
- [ ] Economic indicator integration

### 8.2 Autonomous Features
- [ ] Relationship autopilot (healthy accounts)
- [ ] Event trigger responses
- [ ] Predictive gift/recognition
- [ ] Auto-draft communications

### 8.3 Real-Time Intelligence
- [ ] News sentiment stream
- [ ] Live support dashboard
- [ ] Industry movement tracking

### 8.4 Immersive Features
- [ ] Time-lapse replay
- [ ] Haptic notifications (Apple Watch)
- [ ] Spatial audio briefings (exploration)

---

## Phase 9: Moonshot Features (Weeks 27+)

### 9.1 Digital Twin
- [ ] Client organisation simulation
- [ ] Deal negotiation sandbox
- [ ] Territory simulation

### 9.2 Meeting Intelligence
- [ ] Meeting co-host infrastructure
- [ ] Real-time transcription integration
- [ ] Sentiment analysis during calls
- [ ] Commitment tracking

### 9.3 Parallel Processing
- [ ] Background AI task queue
- [ ] Multi-deal processing
- [ ] Human review workflow

### 9.4 Advanced Visualisation
- [ ] 3D pipeline landscape (WebGL)
- [ ] VR/AR exploration (Vision Pro)
- [ ] Network graph visualisation

---

## Technical Dependencies

### Required Packages
```bash
# Charts
npm install recharts d3

# Real-time
# (Already have Supabase)

# PDF Generation
npm install @react-pdf/renderer

# Voice Input
npm install @anthropic-ai/voice-sdk  # or Web Speech API

# Animations
npm install framer-motion

# Form Handling
npm install react-hook-form zod @hookform/resolvers
```

### Infrastructure
- [ ] Supabase Realtime channels configured
- [ ] Edge Functions for AI processing
- [ ] File storage for exports
- [ ] Notification service (email/push)

---

## Success Metrics

### Phase 1-2 (MVP)
- Plans can be created, saved, edited
- All 5 steps functional
- Basic data auto-population working

### Phase 3-4 (Collaboration)
- Multiple users can edit simultaneously
- Comments and approvals working
- Works on all device sizes

### Phase 5-6 (Intelligence)
- AI suggestions at each step
- Charts telling stories with insights
- Drill-down working throughout

### Phase 7+ (Advanced)
- Measurable time savings (target: 50% reduction in plan creation time)
- User satisfaction scores
- Adoption rate across team

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Scope creep | Strict phase gates, MVP first |
| AI quality | Human review always required |
| Performance | Lazy loading, pagination, caching |
| Complexity | Progressive enhancement, feature flags |
| Adoption | User testing each phase, iterate |

---

## Review Checkpoints

- **Week 3:** Database and API review
- **Week 6:** Core wizard demo
- **Week 9:** Collaboration testing
- **Week 11:** Responsive design review
- **Week 14:** AI integration review
- **Week 17:** Visualisation review
- **Week 21:** Advanced features review
- **Week 26:** Experimental features review
