# Unified Strategic Planning Workflow: Design Guide

**Date:** 11 January 2026
**Status:** Approved for Implementation
**Author:** Claude AI + Jimmy Leimonitis

---

## Executive Summary

**Current State:** Two separate workflows (Territory Planning + Account Planning) with significant data overlap but different owners (CSE vs CAM)

**Recommended State:** Single "Strategic Planning" workflow with role-based views and collaborative ownership

---

## Key Industry Insights (2025-2026)

| Trend | Source | Implication |
|-------|--------|-------------|
| **Unified Territory Management** | Salesforce, Persistent | Single source of truth for all planning data |
| **AI-First Planning** | Gainsight Copilot, ChurnZero Consult | Auto-generate plans from customer data |
| **Outcome Metrics > Activity Metrics** | 2026 CS Planning Guide | Focus on value realisation, not health scores |
| **Real-time Collaboration** | Totango, Figma model | Presence indicators, live editing, shared portals |
| **Revenue Engineering** | Industry shift | CS as growth driver, not support function |

---

## Recommended Unified Workflow Structure

### 5 Steps (Consolidated from 7 + 5 = 12 combined)

```
┌─────────────────────────────────────────────────────────────────────┐
│  UNIFIED STRATEGIC PLANNING WORKFLOW                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Step 1: CONTEXT & SELECTION                                        │
│  ├── CSE/CAM selects (role auto-detected from login)                │
│  ├── Territory auto-loaded based on assignment                      │
│  ├── Client selection (single for Account Plan, all for Territory)  │
│  └── Plan Type toggle: "Territory Overview" | "Account Deep-Dive"   │
│                                                                      │
│  Step 2: PORTFOLIO & HEALTH SNAPSHOT                                │
│  ├── [Territory View] Multi-client portfolio grid                   │
│  ├── [Account View] Single client detailed snapshot                 │
│  ├── Auto-populated: ARR, NPS, Health, Segment, Support SLA        │
│  └── Shared: FY26 Targets vs Pipeline (coverage metrics)           │
│                                                                      │
│  Step 3: RELATIONSHIPS & OPPORTUNITIES                              │
│  ├── [Territory View] Top opportunities with MEDDPICC               │
│  ├── [Account View] Stakeholder map + Account opportunities        │
│  ├── Shared: MEDDPICC scoring component                            │
│  └── AI: Auto-suggest key contacts from meeting transcripts        │
│                                                                      │
│  Step 4: RISKS & ACTIONS                                            │
│  ├── Risk assessment (portfolio-level OR account-level)             │
│  ├── Action plan with owners, dates, priorities                    │
│  ├── AI: Predictive churn indicators, recommended interventions    │
│  └── Shared: Same data structure for both views                    │
│                                                                      │
│  Step 5: REVIEW & COLLABORATE                                       │
│  ├── Summary view of entire plan                                   │
│  ├── Real-time collaboration: CAM + CSE co-editing                 │
│  ├── Comments & approvals workflow                                 │
│  └── Export: PDF, Success Snapshot (Gainsight-style)               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Role-Based Views (Same Data, Different Perspectives)

| Element | CSE View | CAM View |
|---------|----------|----------|
| **Default Mode** | Territory Overview | Account Deep-Dive |
| **Portfolio** | All assigned clients | Clients they oversee |
| **Metrics Focus** | Pipeline, Coverage, ACV | Health, NPS, Engagement |
| **Stakeholders** | Summary per client | Detailed relationship map |
| **Opportunities** | Multi-client pipeline | Single-account deals |
| **Actions** | Execution-focused | Strategic-focused |
| **Collaboration** | Tags CAM for review | Tags CSE for execution |

---

## Collaborative Features (Following Figma/Notion Model)

### Real-Time Collaboration
```
┌─────────────────────────────────────────────────────────┐
│  📍 Anu Pradhan is viewing Step 3                       │
│  ✏️  Tracey Bland is editing Stakeholder Map            │
│                                                          │
│  [Avatar] [Avatar]  2 collaborators active              │
└─────────────────────────────────────────────────────────┘
```

### In-Context Comments
```
┌─────────────────────────────────────────────────────────┐
│  💬 Comment on "Barwon Health - Risk: Contract review"  │
│  ┌─────────────────────────────────────────────────────┐│
│  │ @Tracey - Can you schedule exec meeting before      ││
│  │ renewal? - Anu, 2 hours ago                         ││
│  │                                                      ││
│  │ ↳ Done, meeting set for Feb 15 - Tracey, 1 hour ago ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

---

## Data Model

### Unified `strategic_plans` Table Schema

```sql
CREATE TABLE strategic_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_type TEXT CHECK (plan_type IN ('territory', 'account', 'hybrid')),
  fiscal_year INTEGER NOT NULL DEFAULT 2026,

  -- Ownership (collaborative)
  primary_owner TEXT NOT NULL,           -- CSE or CAM name
  primary_owner_role TEXT,               -- 'CSE' or 'CAM'
  collaborators TEXT[] DEFAULT '{}',     -- Array of team members

  -- Context
  territory TEXT,                        -- Region/territory name
  client_id UUID,                        -- For account plans
  client_name TEXT,                      -- For account plans

  -- Unified data (JSONB)
  portfolio_data JSONB DEFAULT '[]',     -- Clients in scope
  snapshot_data JSONB DEFAULT '{}',      -- Health metrics
  stakeholders_data JSONB DEFAULT '[]',  -- Relationship mapping
  opportunities_data JSONB DEFAULT '[]', -- Pipeline with MEDDPICC
  targets_data JSONB DEFAULT '{}',       -- FY targets & coverage
  risks_data JSONB DEFAULT '[]',         -- Risk assessment
  actions_data JSONB DEFAULT '[]',       -- Action plans
  value_data JSONB DEFAULT '{}',         -- Outcomes & value realisation

  -- Collaboration
  comments JSONB DEFAULT '[]',           -- In-context comments
  activity_log JSONB DEFAULT '[]',       -- Edit history
  active_editors JSONB DEFAULT '[]',     -- Real-time presence

  -- Status
  status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'in_review', 'approved', 'archived')),
  completion_percentage INTEGER DEFAULT 0,
  steps_completed JSONB DEFAULT '{}',

  -- Workflow
  submitted_at TIMESTAMPTZ,
  submitted_by TEXT,
  approved_by TEXT,
  approved_at TIMESTAMPTZ,

  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- Constraints
  CONSTRAINT valid_plan_type CHECK (
    (plan_type = 'territory' AND client_id IS NULL) OR
    (plan_type = 'account' AND client_id IS NOT NULL) OR
    (plan_type = 'hybrid')
  )
);

-- Indexes for performance
CREATE INDEX idx_strategic_plans_owner ON strategic_plans(primary_owner);
CREATE INDEX idx_strategic_plans_type ON strategic_plans(plan_type);
CREATE INDEX idx_strategic_plans_fiscal_year ON strategic_plans(fiscal_year);
CREATE INDEX idx_strategic_plans_status ON strategic_plans(status);
CREATE INDEX idx_strategic_plans_client ON strategic_plans(client_id) WHERE client_id IS NOT NULL;

-- Real-time subscriptions trigger
CREATE OR REPLACE FUNCTION notify_plan_update()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM pg_notify('plan_updates', json_build_object(
    'plan_id', NEW.id,
    'updated_by', NEW.primary_owner,
    'updated_at', NEW.updated_at
  )::text);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER strategic_plans_notify
AFTER UPDATE ON strategic_plans
FOR EACH ROW EXECUTE FUNCTION notify_plan_update();
```

### Supporting Tables

```sql
-- Plan comments for collaboration
CREATE TABLE plan_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID REFERENCES strategic_plans(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES plan_comments(id),  -- For threading
  author TEXT NOT NULL,
  content TEXT NOT NULL,
  entity_type TEXT,  -- 'risk', 'opportunity', 'action', 'stakeholder'
  entity_id TEXT,    -- Reference to specific item
  resolved BOOLEAN DEFAULT FALSE,
  resolved_by TEXT,
  resolved_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Real-time presence tracking
CREATE TABLE plan_presence (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID REFERENCES strategic_plans(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_role TEXT,
  current_step TEXT,
  last_active TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(plan_id, user_name)
);

-- Activity log for audit trail
CREATE TABLE plan_activity_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID REFERENCES strategic_plans(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  action TEXT NOT NULL,  -- 'created', 'updated', 'commented', 'submitted', 'approved'
  details JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## UI/UX Specifications

### 1. Horizontal Stepper (PatternFly-style)

```
[1. Context] ──── [2. Portfolio] ──── [3. Relationships] ──── [4. Risks] ──── [5. Review]
     ●                  ○                    ○                    ○               ○
  Current            Pending              Pending              Pending         Pending
```

### 2. Plan Type Toggle (Top of Page)

```tsx
<div className="flex gap-2 p-1 bg-gray-100 rounded-lg">
  <button className={planType === 'territory' ? 'bg-white shadow' : ''}>
    🗺️ Territory Overview
  </button>
  <button className={planType === 'account' ? 'bg-white shadow' : ''}>
    🏢 Account Deep-Dive
  </button>
</div>
```

### 3. AI Assistant Panel (Gainsight Copilot-style)

```
┌─────────────────────────────────────────────────────────┐
│  🤖 ChaSen AI Insights                                  │
│  ─────────────────────────────────────────────────────  │
│  Based on your portfolio:                               │
│                                                          │
│  ⚠️  3 clients at renewal risk (Health < 50)           │
│  📈 Barwon Health showing positive NPS trend (+12)     │
│  💡 Recommend: Schedule QBR with WA Health before Q2   │
│                                                          │
│  [Generate Plan Draft]  [Suggest Actions]               │
└─────────────────────────────────────────────────────────┘
```

### 4. Collaboration Presence Indicator

```tsx
<div className="flex items-center gap-2">
  <div className="flex -space-x-2">
    {activeEditors.map(editor => (
      <Avatar key={editor.name} className="ring-2 ring-white" />
    ))}
  </div>
  <span className="text-sm text-gray-500">
    {activeEditors.length} collaborators active
  </span>
</div>
```

---

## Implementation Phases

### Phase 1: Foundation (2-3 weeks)
- [ ] Create unified `strategic_plans` database table
- [ ] Build shared component library:
  - [ ] MEDDPICC scoring component
  - [ ] Risk assessment component
  - [ ] Action plan component
  - [ ] Client selector component
- [ ] Implement plan type toggle with role-based defaults
- [ ] Create API routes for CRUD operations

### Phase 2: Core Workflow (3-4 weeks)
- [ ] Build 5-step wizard with progressive disclosure
- [ ] Implement role-based views (same data, different UI)
- [ ] Add auto-population from existing data sources:
  - [ ] Client health summary
  - [ ] NPS scores
  - [ ] Support metrics
  - [ ] Pipeline opportunities
  - [ ] CSE/CAM targets
- [ ] Port existing Territory/Account logic to unified workflow

### Phase 3: Collaboration (2-3 weeks)
- [ ] Real-time presence indicators (Supabase Realtime)
- [ ] In-context commenting system
- [ ] Activity log and version history
- [ ] @mentions and notifications
- [ ] Approval workflow (submit → review → approve)

### Phase 4: AI Enhancement (2-3 weeks)
- [ ] AI plan draft generation from portfolio data
- [ ] Predictive risk indicators
- [ ] Smart action suggestions based on client health
- [ ] Auto-stakeholder detection from meeting transcripts
- [ ] MEDDPICC coaching suggestions

---

## File Structure

```
src/
├── app/(dashboard)/planning/
│   ├── strategic/
│   │   ├── new/
│   │   │   └── page.tsx              # New unified planning page
│   │   ├── [id]/
│   │   │   └── page.tsx              # Edit existing plan
│   │   └── page.tsx                  # Plans list/dashboard
│   ├── territory/                     # (Legacy - redirect to strategic)
│   └── account/                       # (Legacy - redirect to strategic)
├── components/planning/
│   ├── unified/
│   │   ├── PlanTypeToggle.tsx
│   │   ├── StepWizard.tsx
│   │   ├── ContextStep.tsx
│   │   ├── PortfolioStep.tsx
│   │   ├── RelationshipsStep.tsx
│   │   ├── RisksActionsStep.tsx
│   │   ├── ReviewStep.tsx
│   │   ├── CollaborationPanel.tsx
│   │   ├── PresenceIndicator.tsx
│   │   └── AIInsightsPanel.tsx
│   ├── shared/
│   │   ├── MEDDPICCScoring.tsx
│   │   ├── RiskAssessment.tsx
│   │   ├── ActionPlanEditor.tsx
│   │   ├── ClientSelector.tsx
│   │   └── StakeholderMap.tsx
│   └── index.ts
├── hooks/
│   ├── useStrategicPlan.ts
│   ├── usePlanPresence.ts
│   ├── usePlanComments.ts
│   └── usePlanAI.ts
├── lib/
│   └── planning/
│       ├── types.ts
│       ├── validation.ts
│       └── calculations.ts
└── app/api/planning/
    ├── strategic/
    │   ├── route.ts                  # GET/POST plans
    │   └── [id]/
    │       ├── route.ts              # GET/PUT/DELETE plan
    │       ├── comments/route.ts
    │       ├── presence/route.ts
    │       └── ai/route.ts
    └── shared/
        ├── portfolio/route.ts
        ├── opportunities/route.ts
        └── targets/route.ts
```

---

## Success Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Time to complete plan | ~45 min | ~20 min |
| Plans completed per quarter | TBD | +50% |
| CSE/CAM collaboration rate | Separate | 100% shared |
| Data accuracy (auto-populated) | ~60% | >90% |
| AI suggestion adoption | 0% | >40% |

---

## Migration Strategy

1. **Keep existing pages functional** during development
2. **Build unified workflow in `/planning/strategic/`**
3. **Add "Try New Planning" banner** to existing pages
4. **Collect feedback** from pilot users
5. **Redirect legacy URLs** after validation
6. **Archive old code** after 30 days of stable operation

---

## References

- [Gainsight Success Planning](https://www.gainsight.com/customer-success/success-planning/)
- [ChurnZero AI Features](https://churnzero.com/features/)
- [Totango Outcome Success Plans](https://www.totango.com/product-features/outcome-success-plans)
- [PatternFly Wizard Guidelines](https://www.patternfly.org/components/wizard/design-guidelines/)
- [2026 Customer Success Planning Guide](https://advocacymaven.com/2026-customer-success-planning-guide/)
