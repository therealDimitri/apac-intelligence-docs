# Account Prioritisation Matrix v2.0 - Design Document

**Date:** 2026-01-13
**Status:** Design Proposal
**Authors:** CSE/CAM Planning Team + Claude AI

---

## Executive Summary

The current Account Prioritisation Matrix uses a generic ARR vs Health Score quadrant system that doesn't align with Altera's official 6-tier segmentation methodology. This document proposes a redesigned matrix that:

1. **Aligns with Altera's Segmentation** - Uses the official Spend × Satisfaction model
2. **Incorporates FY2026 ACV Targets** - Adds weighted ACV (wtd) targets to prioritisation
3. **Integrates Sales Methodologies** - Practical elements from Gap Selling, Never Split the Difference, StoryBrand, and What's Your Story
4. **Provides Actionable Guidance** - Data-driven recommendations for CSE/CAM actions

---

## Part 1: Current State Analysis

### Current Matrix Problems

| Issue | Impact |
|-------|--------|
| Uses ARR vs Health Score axes | Doesn't match Altera's Spend × Satisfaction model |
| Generic quadrant names (Protect & Grow, Nurture, Develop, Support) | Confusing overlap with actual segment names |
| No ACV target integration | Misses critical FY planning data |
| No engagement methodology | Generic advice without structured approach |
| Binary positioning | Accounts either "in" or "out" of quadrant |

### Current Altera Segmentation (6 Tiers)

```
HIGH SPEND
    │
    │  ┌─────────────────┐  ┌─────────────────┐
    │  │ SLEEPING GIANT  │  │     GIANT       │
    │  │ (Very High/Low) │  │ (Very High/High)│
    │  │ Obj: ↑Satisfact │  │ Obj: Reference  │
    │  └─────────────────┘  └─────────────────┘
    │  ┌─────────────────┐  ┌─────────────────┐
    │  │    NURTURE      │  │  COLLABORATION  │
    │  │ (High/Low)      │  │ (High/High)     │
    │  │ Obj: ↑Satisfact │  │ Obj: Reference  │
    │  └─────────────────┘  └─────────────────┘
    │  ┌─────────────────┐  ┌─────────────────┐
    │  │    MAINTAIN     │  │    LEVERAGE     │
    │  │ (Low/Low)       │  │ (Low/High)      │
    │  │ Obj: ↑Satisfact │  │ Obj: ↑Spend     │
    │  └─────────────────┘  └─────────────────┘
    │
LOW SPEND
          LOW SATISFACTION ───────────► HIGH SATISFACTION
```

---

## Part 2: Sales Methodology Integration

### Key Principles Extracted

#### From Gap Selling (Keenan)

**Core Concept:** The GAP between Current State and Future State creates urgency to buy.

**Applicable Elements:**
- **Current State Assessment** - Where is the client now? (NPS, Health Score, Compliance)
- **Future State Vision** - Where do they want to be? (Strategic goals, ACV potential)
- **Gap Quantification** - Size of the gap = Priority level

**Application in Matrix:**
- Accounts with larger gaps between current performance and ACV potential = Higher priority
- "Gap Score" = (ACV Target - Current ARR) / Current ARR × Health Factor

#### From Never Split the Difference (Chris Voss)

**Core Concept:** Tactical empathy and calibrated questions drive engagement.

**Applicable Elements:**
- **Labeling** - Acknowledge the client's situation ("It seems like...")
- **Calibrated Questions** - "How" and "What" questions that guide discovery
- **Getting to "That's Right"** - Confirm understanding before proposing solutions
- **Black Swans** - Hidden motivators we need to discover

**Application in Matrix:**
- Clients in "Low Satisfaction" segments need empathy-first approach
- Pre-defined discovery questions per segment tier
- "Unknown factors" flag for accounts needing deeper investigation

#### From Building a StoryBrand (Donald Miller)

**Core Concept:** The client is the Hero; we are the Guide. SB7 Framework.

**SB7 Framework:**
1. **Hero** (Client) has a **Want** (business goal)
2. **Problem** (internal, external, philosophical) blocks them
3. **Guide** (Altera) with **Empathy** + **Authority**
4. Gives them a **Plan** (3 simple steps)
5. **Calls them to Action**
6. Shows what's at stake: **Failure** (if they don't act)
7. Shows the **Success** (if they do act)

**Application in Matrix:**
- Each quadrant defines: Problem Type, Plan Steps, Stakes
- Engagement playbooks structured as Hero's Journey
- Clear "What's at Stake" messaging per segment

#### From What's Your Story (Craig Wortmann)

**Core Concept:** Stories ignite performance. Use the Story Matrix and Win Book.

**Applicable Elements:**
- **Story Matrix** - Catalogue of stories by situation × outcome type
- **Win Book** - Collection of success stories for reference selling
- **Story Canvas** - Structure for crafting compelling narratives

**Application in Matrix:**
- Link reference clients to similar accounts in same segment
- "Similar Success Story" suggestions per account
- Track and surface relevant case studies

---

## Part 3: Redesigned Matrix - "Value-Velocity Matrix"

### New Axes: Value Potential × Velocity Readiness

Instead of generic ARR vs Health Score, we use business-meaningful dimensions:

**X-Axis: VELOCITY READINESS** (How ready is the client to move forward?)
- Combines: Health Score + NPS + Compliance % + Engagement Recency
- Scale: 0-100 (Low → High readiness)

**Y-Axis: VALUE POTENTIAL** (What's the strategic value opportunity?)
- Combines: wtd ACV Target + Current ARR + Gap Size + Segment Tier Weight
- Scale: Calculated dollar value ($)

### New Quadrants Aligned with Altera Methodology

```
HIGH VALUE POTENTIAL
    │
    │  ┌──────────────────────┐  ┌──────────────────────┐
    │  │     🔥 RESCUE        │  │    🚀 ACCELERATE     │
    │  │  (High Value/Low     │  │  (High Value/High    │
    │  │   Velocity)          │  │   Velocity)          │
    │  │                      │  │                      │
    │  │  Segments: Sleeping  │  │  Segments: Giant,    │
    │  │  Giant, Nurture      │  │  Collaboration       │
    │  │                      │  │                      │
    │  │  Strategy: GAP-CLOSE │  │  Strategy: EXPAND    │
    │  │  Priority: URGENT    │  │  Priority: HIGH      │
    │  └──────────────────────┘  └──────────────────────┘
    │  ┌──────────────────────┐  ┌──────────────────────┐
    │  │     🛡️ STABILISE     │  │    📈 CULTIVATE      │
    │  │  (Low Value/Low      │  │  (Low Value/High     │
    │  │   Velocity)          │  │   Velocity)          │
    │  │                      │  │                      │
    │  │  Segments: Maintain  │  │  Segments: Leverage  │
    │  │                      │  │                      │
    │  │  Strategy: EMPATHY   │  │  Strategy: GROW      │
    │  │  Priority: MONITOR   │  │  Priority: MEDIUM    │
    │  └──────────────────────┘  └──────────────────────┘
    │
LOW VALUE POTENTIAL
          LOW VELOCITY ──────────────────► HIGH VELOCITY
            READINESS                        READINESS
```

---

## Part 4: Quadrant Definitions with Methodology Integration

### 🚀 ACCELERATE (Top-Right: High Value, High Velocity)

**Altera Segments:** Giant, Collaboration

**Client Profile:**
- High spend, high satisfaction
- Strong health score and NPS
- Meeting compliance requirements
- Active engagement

**Strategic Objective:** Reference & Expand

**Gap Selling Application:**
- Current State: Strong relationship, proven value
- Future State: Strategic partner, reference customer
- Gap Focus: Identify untapped expansion opportunities

**StoryBrand Narrative:**
- Problem: "Even successful partnerships can plateau"
- Plan: 1) Quarterly business reviews, 2) Co-innovation sessions, 3) Joint case study development
- Stakes: Without growth focus, competitors encroach

**Engagement Playbook:**
| Week | Action | Voss Technique |
|------|--------|----------------|
| 1 | Schedule strategic review | Calibrated Question: "What would make this partnership even more valuable?" |
| 2 | Present expansion proposal | Labeling: "It seems like you've been thinking about [area]" |
| 3 | Co-develop success story | "That's Right" moment: Confirm shared vision |

**Key Metrics to Track:**
- Expansion ARR
- Reference activities completed
- NPS trend
- Upsell pipeline value

---

### 🔥 RESCUE (Top-Left: High Value, Low Velocity)

**Altera Segments:** Sleeping Giant, Nurture

**Client Profile:**
- High spend but dissatisfied
- Low health score or declining NPS
- Compliance issues or missed events
- At-risk relationship

**Strategic Objective:** Increase Satisfaction (Urgent)

**Gap Selling Application:**
- Current State: Significant revenue at risk, satisfaction declining
- Future State: Restored confidence, protected revenue
- Gap Focus: Quantify the cost of inaction (churn risk)

**StoryBrand Narrative:**
- Problem (External): Service issues, unmet expectations
- Problem (Internal): Client feels undervalued, frustrated
- Problem (Philosophical): "Partners should understand our business"
- Plan: 1) Executive escalation call, 2) Satisfaction action plan, 3) Quick win delivery
- Stakes: Revenue loss, damaged reputation, competitive displacement

**Engagement Playbook:**
| Week | Action | Voss Technique |
|------|--------|----------------|
| 1 | Acknowledge concerns call | Labeling: "It sounds like you've been frustrated with..." |
| 2 | Present recovery plan | Accusation Audit: "You probably think we've dropped the ball" |
| 3 | Deliver first quick win | Calibrated Question: "How would you measure our progress?" |
| 4 | Executive check-in | "That's Right" moment: Validate improvement |

**Key Metrics to Track:**
- Satisfaction trend (weekly)
- Open support tickets
- Time to resolution
- Executive engagement frequency

**Story Matrix - Rescue Success Stories:**
- Link to similar clients who recovered from Nurture → Collaboration
- Quantify the turnaround metrics

---

### 📈 CULTIVATE (Bottom-Right: Low Value, High Velocity)

**Altera Segments:** Leverage

**Client Profile:**
- Lower spend but highly satisfied
- Strong health score and NPS
- Good compliance
- Ready for expansion

**Strategic Objective:** Increase Spend

**Gap Selling Application:**
- Current State: Happy but underutilising our solutions
- Future State: Full product suite adoption, increased ACV
- Gap Focus: Calculate unrealised value vs. potential

**StoryBrand Narrative:**
- Problem: "You're only getting partial value from your investment"
- Plan: 1) Value assessment, 2) Expansion roadmap, 3) Phased implementation
- Stakes: Competitors offer bundled solutions; staying small means falling behind

**Engagement Playbook:**
| Week | Action | Voss Technique |
|------|--------|----------------|
| 1 | Value realisation review | Calibrated Question: "What challenges are you solving elsewhere that we might help with?" |
| 2 | Expansion opportunity mapping | Mirroring: Repeat their language about growth areas |
| 3 | Present phased proposal | "How am I supposed to do that?" (Let them problem-solve) |
| 4 | Close expansion deal | Ackerman Model: Strategic pricing negotiation |

**Key Metrics to Track:**
- Whitespace analysis (products not purchased)
- Pipeline value in Leverage accounts
- Expansion conversion rate
- Time from opportunity to close

---

### 🛡️ STABILISE (Bottom-Left: Low Value, Low Velocity)

**Altera Segments:** Maintain

**Client Profile:**
- Lower spend and lower satisfaction
- Health score needs improvement
- May have compliance gaps
- Requires foundational work

**Strategic Objective:** Increase Satisfaction (Foundation)

**Gap Selling Application:**
- Current State: Struggling relationship, basic needs not met
- Future State: Stable, satisfied customer ready for growth
- Gap Focus: Identify root cause before expansion discussions

**StoryBrand Narrative:**
- Problem: "Basic expectations aren't being met"
- Plan: 1) Diagnostic assessment, 2) Quick win implementation, 3) Quarterly health check
- Stakes: Without stabilisation, churn is inevitable

**Engagement Playbook:**
| Week | Action | Voss Technique |
|------|--------|----------------|
| 1 | Discovery call | Open-ended: "Help me understand what's working and what's not" |
| 2 | Root cause analysis | Labeling: "It seems like [specific issue] has been particularly frustrating" |
| 3 | Present improvement plan | Calibrated Question: "What would need to happen for you to feel confident in us again?" |
| 4 | Implement first improvement | Black Swan hunt: Look for hidden motivators |

**Key Metrics to Track:**
- Support ticket resolution time
- Compliance improvement rate
- NPS trajectory
- Meeting attendance rate

---

## Part 5: Value-Velocity Score Calculation

### Velocity Readiness Score (0-100)

```typescript
function calculateVelocityReadiness(client: Client): number {
  const weights = {
    healthScore: 0.30,      // 30% - Overall health
    nps: 0.25,              // 25% - Satisfaction indicator
    compliance: 0.25,       // 25% - Engagement discipline
    recency: 0.20           // 20% - Recent engagement
  }

  const healthComponent = client.healthScore * weights.healthScore
  const npsComponent = normaliseNPS(client.nps) * weights.nps  // -100 to 100 → 0 to 100
  const complianceComponent = client.compliancePercentage * weights.compliance
  const recencyComponent = calculateRecencyScore(client.daysSinceLastMeeting) * weights.recency

  return healthComponent + npsComponent + complianceComponent + recencyComponent
}

function normaliseNPS(nps: number): number {
  // Convert -100 to 100 scale → 0 to 100 scale
  return (nps + 100) / 2
}

function calculateRecencyScore(days: number | null): number {
  if (days === null) return 50 // Unknown = neutral
  if (days <= 14) return 100   // Very recent
  if (days <= 30) return 85    // Recent
  if (days <= 60) return 70    // Acceptable
  if (days <= 90) return 50    // Needs attention
  if (days <= 180) return 25   // At risk
  return 0                      // Critical
}
```

### Value Potential Score

```typescript
function calculateValuePotential(client: Client, acvTarget: number): number {
  const segmentWeight = SEGMENT_WEIGHTS[client.segment]
  const gapRatio = acvTarget > 0 ? (acvTarget - client.arr) / Math.max(client.arr, 1) : 0
  const gapOpportunity = Math.max(0, acvTarget - client.arr)

  return (client.arr * segmentWeight) + (gapOpportunity * 0.5)
}

const SEGMENT_WEIGHTS = {
  'Giant': 1.5,
  'Sleeping Giant': 1.4,
  'Collaboration': 1.3,
  'Nurture': 1.2,
  'Leverage': 1.1,
  'Maintain': 1.0
}
```

### Quadrant Assignment

```typescript
function assignQuadrant(velocityScore: number, valueScore: number, medianValue: number): Quadrant {
  const highVelocity = velocityScore >= 60
  const highValue = valueScore >= medianValue

  if (highValue && highVelocity) return 'ACCELERATE'
  if (highValue && !highVelocity) return 'RESCUE'
  if (!highValue && highVelocity) return 'CULTIVATE'
  return 'STABILISE'
}
```

---

## Part 6: Additional Applications Across Planning Pages

### 1. Territory Overview Page (`/planning`)

**Gap Selling Integration:**
- Add "Territory Gap Analysis" section showing aggregate current state vs targets
- Visual comparison of portfolio-wide gaps
- Prioritised action list based on gap size

**StoryBrand Integration:**
- Territory narrative: "Your territory is the hero; here's the journey to FY26 success"
- Clear 3-step plan per territory

### 2. Account Deep-Dive Page (`/planning/account/new`)

**Full Methodology Integration:**

| Section | Methodology Applied |
|---------|---------------------|
| Executive Summary | StoryBrand SB7 narrative structure |
| Stakeholder Map | Voss - Black Swan identification (who has hidden influence?) |
| Opportunity Analysis | Gap Selling - Current → Future state visualisation |
| Engagement History | Wortmann - Story Matrix of past successes |
| Action Plan | Voss - Calibrated questions for next steps |

**New Features:**
- "Client's Story" section - Client as Hero narrative
- "Hidden Motivators" flag - Black Swan investigation prompts
- "Reference Story" suggestions - Similar successful accounts

### 3. Strategic Planning Wizard (`/planning/strategic/new`)

**Enhanced Sections:**

**Step 1: Portfolio Assessment**
- Auto-generate Gap Analysis per account
- Show aggregate "Gap to Target" vs "Gap to Close"

**Step 2: Prioritisation Matrix** (Redesigned)
- Use new Value-Velocity Matrix
- Interactive quadrant filtering
- Engagement playbook links per quadrant

**Step 3: Action Planning**
- Pre-populated with Voss-style calibrated questions
- StoryBrand-structured talking points
- Wortmann Story Matrix integration

### 4. Pipeline Page (`/pipeline`)

**Gap Selling Integration:**
- Add "Gap Score" column to opportunities
- Sort/filter by gap size
- Highlight deals where gap hasn't been quantified

**Voss Integration:**
- "Black Swan Status" indicator - have we identified hidden motivators?
- "That's Right" checkpoint - has client confirmed understanding?

### 5. Client Health Dashboard

**StoryBrand Integration:**
- Each client card shows their "Hero's Journey" stage
- Stakes visualisation - "What's at risk if we don't act"

### 6. AI Coach (Chasen) Enhancements

**Methodology-Aware Suggestions:**
- Context-aware prompts based on quadrant
- Gap Selling questions for discovery
- Voss techniques for difficult conversations
- StoryBrand narrative templates

**Example AI Prompts:**
```
For RESCUE accounts:
"Based on [Client]'s declining NPS, here are Voss-style questions to
uncover the root cause:
1. 'It seems like our response times have been frustrating...'
2. 'What would need to happen for you to feel confident in us again?'
3. 'How are you currently solving [problem] without us?'"
```

### 7. Meeting Preparation (`/planning` - Upcoming Meetings)

**Pre-Meeting Playbook:**
- Auto-generate StoryBrand-structured agenda
- Suggest Voss calibrated questions based on account status
- Surface relevant success stories from Story Matrix

---

## Part 7: Data Requirements

### New Database Fields Needed

```sql
-- Add to clients or create new planning_metadata table
ALTER TABLE nps_clients ADD COLUMN IF NOT EXISTS
  fy26_acv_target DECIMAL(12,2),
  gap_score DECIMAL(5,2),
  value_potential_score DECIMAL(12,2),
  velocity_readiness_score DECIMAL(5,2),
  assigned_quadrant VARCHAR(20),
  black_swan_status VARCHAR(20), -- 'identified', 'investigating', 'unknown'
  hero_journey_stage VARCHAR(20), -- 'problem', 'guide_met', 'plan_accepted', 'acting', 'success'
  last_thats_right_date DATE,
  updated_at TIMESTAMP DEFAULT NOW()
;

-- Story Matrix table for reference selling
CREATE TABLE IF NOT EXISTS story_matrix (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  story_type VARCHAR(50), -- 'success', 'failure', 'turnaround', 'expansion'
  segment VARCHAR(50),
  client_name VARCHAR(255),
  situation TEXT,
  action_taken TEXT,
  outcome TEXT,
  metrics_achieved JSONB,
  applicable_segments TEXT[],
  created_by VARCHAR(255),
  created_at TIMESTAMP DEFAULT NOW()
);
```

### API Endpoints Needed

| Endpoint | Purpose |
|----------|---------|
| `GET /api/planning/value-velocity` | Calculate scores for all portfolio clients |
| `GET /api/planning/gap-analysis/:client` | Detailed gap analysis for single client |
| `GET /api/story-matrix` | Retrieve relevant success stories |
| `POST /api/story-matrix` | Add new success story |
| `GET /api/planning/playbook/:quadrant` | Get engagement playbook for quadrant |

---

## Part 8: Implementation Phases

### Phase 1: Matrix Redesign (Core)
- Update Account Prioritisation Matrix component
- Implement Value-Velocity score calculation
- Update quadrant definitions and styling
- Add segment alignment indicators

### Phase 2: Engagement Playbooks
- Create playbook content for each quadrant
- Add expandable guidance panels
- Integrate Voss-style question prompts

### Phase 3: AI Integration
- Update Chasen with methodology-aware prompts
- Add context-sensitive suggestions
- Implement Story Matrix search

### Phase 4: Full Application
- Extend to all Planning pages
- Add Gap Score to Pipeline
- Implement Hero Journey tracking

---

## Part 9: Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| ACV Target Achievement | ≥90% of wtd targets | Quarterly review |
| Rescue → Accelerate Conversion | ≥30% of Rescue accounts improve | 6-month tracking |
| Engagement Playbook Usage | ≥70% of CSE/CAMs use | Analytics tracking |
| Time to First Action | ≤3 days after quadrant assignment | System logging |
| Story Matrix Growth | ≥2 new stories/quarter/CSE | Content tracking |

---

## Appendix: Quick Reference Cards

### Quadrant Cheat Sheet

| Quadrant | Segments | First Action | Key Question |
|----------|----------|--------------|--------------|
| 🚀 ACCELERATE | Giant, Collaboration | Schedule strategic review | "What would make this partnership even more valuable?" |
| 🔥 RESCUE | Sleeping Giant, Nurture | Acknowledgement call | "It sounds like we've let you down - help me understand" |
| 📈 CULTIVATE | Leverage | Value realisation review | "What challenges are you solving elsewhere that we might help with?" |
| 🛡️ STABILISE | Maintain | Discovery diagnostic | "What's working and what's not?" |

### Voss Techniques Quick Reference

| Technique | Usage | Example |
|-----------|-------|---------|
| Labeling | Acknowledge emotions | "It seems like you're frustrated with..." |
| Mirroring | Encourage elaboration | Repeat last 3 words as question |
| Calibrated Questions | Guide discovery | "How would you measure success?" |
| Accusation Audit | Preempt objections | "You probably think we've dropped the ball" |
| "That's Right" | Confirm understanding | Get them to say "That's right" not "You're right" |

---

## Sources

- [Gap Selling: Complete Framework](https://qwilr.com/blog/gap-selling/)
- [Gap Selling Methodology - A Sales Growth Company](https://salesgrowth.com/gap-selling-method/)
- [Never Split the Difference - Freshworks Summary](https://www.freshworks.com/explore-crm/summary-of-never-split-the-difference/)
- [Chris Voss Negotiation Strategies - RO Hammer](https://www.rohammer.com/blog/changing-the-game-how-chris-vosss-never-split-the-difference-is-reshaping-sales-negotiation-strategies)
- [StoryBrand 7-Part Framework - Gravity Global](https://www.gravityglobal.com/blog/complete-guide-storybrand-framework)
- [Building a StoryBrand 2.0](https://www.dckap.com/resources/building-storybrand-2-0/)
- [Craig Wortmann's Story Matrix - Medium](https://medium.com/@TheFullRatchet/sales-mastery-storytelling-at-scaling-startups-featuring-craig-wortmann-79f573eeb12a)
- [What's Your Story - Wired for Youth Summary](https://wiredforyouth.com/summaries/whats-your-story-craig-wortmann/)
