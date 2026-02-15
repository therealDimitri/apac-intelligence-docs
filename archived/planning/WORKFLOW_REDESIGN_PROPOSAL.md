# Strategic Planning Workflow Redesign Proposal

## Executive Summary

This document proposes a restructured planning workflow that groups methodologies by theme, reduces cognitive load, and introduces structured questionnaires with required answers and scoring mechanisms.

**Key Enhancement:** Each questionnaire section is **informed by real database data and AI-generated insights** to reduce manual research burden and improve answer quality.

---

## Data-Driven AI Context Architecture

### Available Data Sources for Pre-Population

Every questionnaire section will be informed by:

| Data Type | Source | Use Case |
|-----------|--------|----------|
| **Health Trends** | `client_health_history`, `predictive_health_scores` | Risk context, trajectory |
| **Meeting History** | `unified_meetings` (AI summaries, sentiment) | Recent discussions, commitments |
| **NPS Feedback** | `nps_responses`, `nps_topic_classifications` | Voice of customer, pain themes |
| **Financial Data** | `/api/planning/financials/*`, `client_arr` | ARR, growth, renewal risk |
| **Support Metrics** | `support_sla_metrics` | Service quality, ticket aging |
| **Stakeholders** | `stakeholder_relationships`, `stakeholder_influences` | Org mapping, influence scores |
| **AI Insights** | `account_plan_ai_insights`, `next_best_actions` | Pre-generated recommendations |
| **MEDDPICC** | `meddpicc_scores` | Deal qualification history |
| **Engagement** | `/api/planning/timeline` | Activity patterns, velocity |
| **External Research** | Web search via ChaSen AI | Industry news, competitor intel |

### How Data Informs Each Step

```
┌─────────────────────────────────────────────────────────────────┐
│  USER SELECTS CLIENT                                            │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  AI CONTEXT ENGINE (ChaSen Methodology API)                     │
│  ├── Fetch: Health history, NPS, Meetings, Financials          │
│  ├── Fetch: Stakeholders, Support metrics, Timeline            │
│  ├── Fetch: Existing AI insights, MEDDPICC scores              │
│  ├── Search: Industry news, competitor activity (web)          │
│  └── Generate: Pre-populated suggestions per questionnaire     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  QUESTIONNAIRE WITH AI SUGGESTIONS                              │
│  ├── Pre-filled draft answers (editable)                       │
│  ├── Supporting evidence from data                              │
│  ├── "Why we suggest this" explanations                        │
│  └── User confirms/edits before proceeding                     │
└─────────────────────────────────────────────────────────────────┘
```

### API Endpoints for Data Access

The ChaSen Methodology API (`/api/chasen/methodology`) now supports:

| Action | Purpose | Data Sources Used |
|--------|---------|-------------------|
| `gather_full_context` | Fetch all client data at once | All tables below |
| `pre_populate_questionnaire` | Generate AI suggestions per step | Context + AI generation |
| `gap_analysis` | Gap Selling current/future state analysis | Health, NPS, Financials |
| `analyze_questionnaire_response` | Score user answers | AI evaluation |

### Data Sources Per Questionnaire Step

#### Step 2: Discovery & Diagnosis
| Question | Primary Data Sources | Evidence Type |
|----------|---------------------|---------------|
| Current problems | `nps_responses`, `unified_meetings` (AI summaries), `support_sla_metrics` | NPS themes, meeting notes, ticket patterns |
| Suffering metrics | `client_health_history`, `aging_accounts`, `predictive_health_scores` | Health trends, financial pressure |
| Desired future state | `clients` (segment, industry), `portfolio_initiatives` | Industry benchmarks, stated goals |
| Quantified impact | `clients` (ARR, churn_probability), `aging_accounts` | Revenue at risk, outstanding amounts |
| Root cause | `nps_topic_classifications`, `account_plan_ai_insights` | Theme analysis, AI patterns |
| Cost of inaction | `client_health_history` (trend), `predictive_health_scores` | Trajectory prediction |

#### Step 3: Stakeholder Intelligence
| Question | Primary Data Sources | Evidence Type |
|----------|---------------------|---------------|
| Stakeholder list | `stakeholder_relationships`, `stakeholder_influences` | Known contacts, influence scores |
| Career goals/pressures | `unified_meetings` (mentions), AI inference from role | Meeting context, role analysis |
| Political dynamics | `stakeholder_influences`, `unified_meetings` | Org relationships, meeting dynamics |
| "That's right" moment | `nps_responses` (individual), `unified_meetings` (sentiment) | Stated concerns, emotional patterns |
| Unspoken worries | `nps_responses`, `support_sla_metrics` (critical issues) | Detractor comments, escalations |

#### Step 4: Opportunity Strategy
| Question | Primary Data Sources | Evidence Type |
|----------|---------------------|---------------|
| MEDDPICC Metrics | `clients` (ARR, growth), `account_plan_ai_insights` | Quantified outcomes |
| Economic Buyer | `stakeholder_relationships` (role=Economic Buyer) | Decision-maker identification |
| Decision Criteria | `unified_meetings`, `nps_responses` | Evaluation mentions |
| Decision Process | `unified_meetings` (timeline mentions), `segmentation_events` | Process evidence |
| Paper Process | `clients` (compliance), `segmentation_events` | Procurement patterns |
| Identify Pain | `nps_responses`, `support_sla_metrics` | Stated pain points |
| Champion | `stakeholder_relationships` (sentiment=positive) | Internal advocates |
| Competition | `unified_meetings`, external research | Competitor mentions |

#### Step 5: Risk & Recovery
| Question | Primary Data Sources | Evidence Type |
|----------|---------------------|---------------|
| Risk identification | `clients` (health_score, churn_probability), `actions` (overdue) | Quantified risk factors |
| Revenue at risk | `clients` (ARR), `aging_accounts` (outstanding) | Financial exposure |
| Accusation Audit | `nps_responses` (detractor comments), `support_sla_metrics` | Negative feedback |
| Empathy Response | AI generation from context | Methodology application |
| Recovery Story | `chasen_success_patterns`, similar client lookup | Reference cases |

#### Step 6: Action & Narrative
| Question | Primary Data Sources | Evidence Type |
|----------|---------------------|---------------|
| Suggested actions | `next_best_actions`, `account_plan_ai_insights` | AI recommendations |
| Territory narrative | Aggregate of all client data | Portfolio-level synthesis |
| Reference stories | `chasen_success_patterns`, `portfolio_initiatives` (successful) | Proven outcomes |

---

## Current State Issues

### 1. Methodology Fragmentation
- **Voss** techniques scattered across Steps 3 and 4
- **Gap Selling** isolated in Step 2 without connection to stakeholder/relationship context
- **StoryBrand** only at the end (Step 5) - feels disconnected
- **MEDDPICC** is passive display only, not interactive reflection

### 2. High Cognitive Load
- Users constantly switch between different methodology frameworks
- No clear "complete this section fully" guidance
- Mixed data entry (financials, relationships, risks) in same steps

### 3. Lack of Structured Reflection
- Most fields are free-form text without guidance
- No scoring mechanisms to encourage self-assessment
- No required questions to ensure thorough analysis

---

## Proposed New Workflow Structure

### Overview: 6 Steps (Down from 5, but more focused)

| Step | Name | Theme | Primary Methodologies |
|------|------|-------|----------------------|
| 1 | **Setup & Context** | Configuration | - |
| 2 | **Discovery & Diagnosis** | Understanding Problems | Gap Selling, MEDDPICC (Pain) |
| 3 | **Stakeholder Intelligence** | People & Politics | Voss (all techniques) |
| 4 | **Opportunity Strategy** | Pipeline & Deals | MEDDPICC (full), StoryBrand |
| 5 | **Risk & Recovery** | Mitigation Planning | Voss (Accusation Audit), Wortmann |
| 6 | **Action & Narrative** | Execution Plan | StoryBrand, Summary |

---

## Detailed Step Breakdown

### Step 1: Setup & Context
**Purpose:** Quick configuration (unchanged but streamlined)

**Fields:**
- Owner selection
- Territory auto-populate
- Collaborators
- Plan timeframe

**Time to complete:** ~2 minutes

---

### Step 2: Discovery & Diagnosis
**Theme:** Understanding the client's world before proposing solutions

**Grouped Methodologies:**
1. **Gap Selling (Keenan)** - Current State Analysis
2. **MEDDPICC - Identify Pain (i)** - Pain quantification

#### Gap Selling Questionnaire (Required)

For each priority client, complete:

| Question | Type | Required |
|----------|------|----------|
| What specific problems are they experiencing today? | Free text | Yes |
| What business metrics are suffering? (revenue, efficiency, risk) | Free text | Yes |
| What is their desired future state? | Free text | Yes |
| What is the quantified business impact of the gap? | Free text + $ estimate | Yes |
| What is the root cause of this gap? | Free text | Yes |
| If they don't solve this, what happens in 12 months? | Free text | Yes |

**Gap Diagnosis Confidence Score (Self-Assessment 1-5):**

| Question | Score 1-5 |
|----------|-----------|
| I clearly understand their current problems | [ ] |
| I can articulate their desired future state | [ ] |
| I have quantified the business impact in dollars/time | [ ] |
| I understand the root cause, not just symptoms | [ ] |
| I know the cost of inaction | [ ] |

**Minimum Score Required:** 15/25 to proceed

---

### Step 3: Stakeholder Intelligence
**Theme:** Understanding the people and politics

**Grouped Methodologies:**
1. **Voss - Tactical Empathy** - Understanding emotions
2. **Voss - Black Swans** - Hidden motivators
3. **Voss - Labelling & Mirroring** - Communication techniques
4. **Voss - Calibrated Questions** - Discovery questions

#### Stakeholder Analysis Questionnaire (Per Key Stakeholder)

**Basic Information:**
| Field | Type |
|-------|------|
| Name | Text |
| Title | Text |
| Role | Dropdown: Economic Buyer / Champion / Influencer / User / Blocker |
| Relationship Strength | 1-5 scale |

**Voss: Black Swan Discovery (Required)**

| Question | Type | Required |
|----------|------|----------|
| What are their personal career goals/pressures? | Free text | Yes |
| What political dynamics affect their decisions? | Free text | Yes |
| What would make them feel deeply understood ("That's right" moment)? | Free text | Yes |
| What are they most worried about that they haven't said? | Free text | Yes |

**Voss: Tactical Empathy Score (Self-Assessment 1-5):**

| Question | Score 1-5 |
|----------|-----------|
| I understand their emotional state | [ ] |
| I know their unspoken concerns | [ ] |
| I understand the political dynamics they navigate | [ ] |
| I can articulate what success means to them personally | [ ] |
| I have identified potential "Black Swans" | [ ] |

**Calibrated Questions Prepared (Log which ones you'll use):**

| Question Template | Will Use? | Notes |
|-------------------|-----------|-------|
| "How would you measure success 12 months from now?" | [ ] | |
| "What would need to be true for your team to embrace this change?" | [ ] | |
| "How does this fit with your 5-year strategic vision?" | [ ] | |
| "What happens if nothing changes?" | [ ] | |
| "How am I supposed to do that?" (make them solve it) | [ ] | |
| "What's the biggest challenge you face with this?" | [ ] | |
| Custom: _______________ | [ ] | |

---

### Step 4: Opportunity Strategy
**Theme:** Deal-specific strategy and qualification

**Grouped Methodologies:**
1. **MEDDPICC (Full Framework)** - Deal qualification
2. **StoryBrand** - Opportunity-level narrative

#### MEDDPICC Assessment (Per Opportunity)

**Required Self-Assessment (1-5 scale per element):**

| Element | Question | Score 1-5 | Evidence/Notes |
|---------|----------|-----------|----------------|
| **M** - Metrics | Have I identified the specific business metrics this impacts? | [ ] | |
| **E** - Economic Buyer | Have I identified and engaged the person who can say yes? | [ ] | |
| **D** - Decision Criteria | Do I know how they will evaluate options? | [ ] | |
| **D** - Decision Process | Do I know the steps and timeline to make a decision? | [ ] | |
| **P** - Paper Process | Do I understand legal, procurement, compliance requirements? | [ ] | |
| **I** - Identify Pain | Have I deeply understood and quantified their pain? | [ ] | |
| **C** - Champion | Do I have an internal advocate who wants us to win? | [ ] | |
| **C** - Competition | Do I know who else is being considered and our differentiation? | [ ] | |

**Stage-Gate Validation:**
- Discovery (min 8/40): Pain identified
- Qualification (min 16/40): Metrics + Champion confirmed
- Proposal (min 24/40): Economic Buyer + Criteria known
- Negotiation (min 32/40): Process + Paper understood
- Commit (min 36/40): All elements strong

**StoryBrand: Opportunity Narrative**

| Element | Question | Required |
|---------|----------|----------|
| Hero | Who is the hero in this opportunity and what do they want? | Yes |
| Villain | What problems (external, internal, philosophical) are they facing? | Yes |
| Guide | How does Altera position as the guide, not the hero? | Yes |
| Plan | What is our simple 3-step plan to help them? | Yes |
| Call to Action | What specific action are we asking them to take next? | Yes |
| Success | What does success look like if they work with us? | Yes |
| Failure | What do they avoid by choosing us? | Yes |

---

### Step 5: Risk & Recovery
**Theme:** Identifying and mitigating risks with proven techniques

**Grouped Methodologies:**
1. **Voss - Accusation Audit** - Pre-emptive objection handling
2. **Voss - Tactical Empathy Statements** - Building trust
3. **Wortmann - Recovery Stories** - Reference selling

#### Risk Assessment Questionnaire (Per Risk)

**Risk Identification:**
| Field | Type |
|-------|------|
| Client | Dropdown |
| Risk Description | Free text (required) |
| Revenue at Risk | Auto-calculated from ARR |
| Churn Probability | Slider 0-100% |

**Voss: Accusation Audit (Required)**

| Question | Response |
|----------|----------|
| What is the worst thing they might be thinking about us? | Free text (required) |
| Complete the sentence: "I imagine you might be feeling that..." | Free text (required) |
| What objection are they most likely to raise? | Free text (required) |

**Voss: Tactical Empathy Response (Required)**

| Question | Response |
|----------|----------|
| How will you acknowledge their frustration without agreeing? | Free text (required) |
| What labelling statement will you use? (e.g., "It seems like...") | Free text (required) |

**Wortmann: Recovery Story (Required for High-Risk)**

| Question | Response |
|----------|----------|
| Do you have a similar client who faced this challenge? | Yes/No + Name |
| What was their situation before? | Free text |
| What did they do (with Altera)? | Free text |
| What was the outcome/result? | Free text with metrics |

**Risk Mitigation Score (Self-Assessment 1-5):**

| Question | Score 1-5 |
|----------|-----------|
| I have anticipated their worst thoughts about us | [ ] |
| I have prepared empathetic responses | [ ] |
| I have a relevant recovery story to share | [ ] |
| I have a clear mitigation action plan | [ ] |

---

### Step 6: Action & Narrative
**Theme:** Execution planning and territory narrative

**Components:**
1. **Action Plan** - All actions with owners, dates, priorities
2. **StoryBrand: Territory Narrative** - Overarching story

#### Action Plan Requirements

Each action must have:
| Field | Required |
|-------|----------|
| Description | Yes |
| Owner | Yes (CSE/CAM dropdown) |
| Due Date | Yes |
| Priority | Yes (Critical/High/Medium/Low) |
| Linked Risk | Optional |
| Linked Opportunity | Optional |
| Methodology Alignment | Auto-tagged |

**Action Completeness Score:**

| Criteria | Points |
|----------|--------|
| All at-risk clients have actions | +10 |
| All selected opportunities have actions | +10 |
| All actions have owners | +10 |
| All actions have due dates | +10 |
| 80%+ actions linked to risks/opps | +10 |

**Minimum: 30/50 to submit**

#### StoryBrand: Territory Narrative (Required)

| Element | Question | Required |
|---------|----------|----------|
| Territory Hero | Who is the collective "hero" in your territory? What do they want? | Yes |
| Territory Villain | What are the common challenges across your portfolio? | Yes |
| Altera as Guide | How does Altera help heroes in this territory succeed? | Yes |
| The Plan | What is your 3-step territory plan for this quarter? | Yes |
| Success Vision | What does success look like in 12 months? | Yes |
| Key Reference Stories | What 2-3 success stories will you deploy this quarter? | Yes |

---

## Scoring Summary

### Per-Step Minimum Scores

| Step | Minimum Score | Basis |
|------|---------------|-------|
| 2. Discovery | 15/25 | Gap Diagnosis Confidence |
| 3. Stakeholders | 15/25 per stakeholder | Tactical Empathy Score |
| 4. Opportunities | Stage-appropriate MEDDPICC | Stage-gate validation |
| 5. Risks | 12/20 per high-risk | Risk Mitigation Score |
| 6. Actions | 30/50 | Action Completeness Score |

### Overall Plan Health

- **Green (Ready):** All step minimums met, 80%+ completion
- **Amber (Review):** Some gaps, 60-80% completion
- **Red (Incomplete):** Step minimums not met, <60% completion

---

## Implementation Phases

### Phase 1: Restructure Steps
- Reorganise form into 6 new steps
- Group methodology sections by step theme
- Update navigation and progress tracking

### Phase 2: Add Questionnaires
- Create questionnaire components for each methodology
- Implement required field validation
- Add 1-5 scoring UI components

### Phase 3: Scoring Logic
- Implement score calculations
- Add step minimum validation
- Create visual score indicators

### Phase 4: Data Migration
- Update FormData interface
- Ensure backward compatibility
- Migrate existing plans

---

## Benefits of Redesign

1. **Reduced Cognitive Load:** Complete one methodology theme before moving on
2. **Better Learning:** Users deeply engage with each methodology
3. **Measurable Quality:** Scores indicate plan thoroughness
4. **Required Reflection:** No skipping critical analysis
5. **Actionable Outputs:** Every question drives specific insights
6. **Clear Progression:** Know exactly what "done" looks like per step

---

## Next Steps

1. Review and approve this proposal
2. Create detailed UI mockups for each step
3. Implement questionnaire components
4. Build scoring engine
5. Update step navigation
6. Test with pilot users
