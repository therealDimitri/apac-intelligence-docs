# Unified Strategic Planning Workflow: Design Guide

**Date:** 11 January 2026 (Updated: 3 February 2026)
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
│  ├── Plan Type toggle: "Territory Overview" | "Account Deep-Dive"   │
│  └── 🤖 ChaSen: "Based on your portfolio, I recommend focusing on   │
│       [Client] - here's why..." (priority suggestion)               │
│                                                                      │
│  Step 2: PORTFOLIO & TARGETS                                        │
│  ├── [Territory View] Multi-client portfolio grid with targets      │
│  ├── [Account View] Single client snapshot + account target         │
│  ├── Auto-populated: ARR, NPS, Health, Segment, Support SLA        │
│  ├── Sales Targets: FY quota, current coverage, gap to target       │
│  ├── Pipeline Summary: Total pipeline value, weighted forecast      │
│  └── 🤖 ChaSen: Auto-suggest target allocations based on segment,   │
│       historical performance, and growth potential                  │
│                                                                      │
│  Step 3: PIPELINE & OPPORTUNITIES                                   │
│  ├── Opportunity Management: Add/Edit/Remove opportunities          │
│  ├── Per opportunity: Value, Stage, Probability, Close Date         │
│  ├── MEDDPICC scoring per opportunity (8 criteria)                  │
│  ├── Dynamic Forecast: Updates instantly when opportunities change  │
│  ├── Coverage Calculator: Pipeline ÷ Gap = Coverage ratio           │
│  ├── Stakeholder mapping linked to opportunities                    │
│  └── 🤖 ChaSen: Auto-suggest opportunities from NPS themes,         │
│       meeting notes, product gaps; pre-fill MEDDPICC from data      │
│                                                                      │
│  Step 4: RISKS & ACTIONS                                            │
│  ├── Risk assessment (portfolio-level OR account-level)             │
│  ├── Revenue-at-risk calculations linked to opportunities           │
│  ├── Action plan with owners, dates, priorities                    │
│  ├── What-if modelling: "If we lose [Opp], forecast drops to..."   │
│  └── 🤖 ChaSen: Predictive churn indicators, auto-generate actions  │
│       with Voss scripts, suggest recovery stories from Story Matrix │
│                                                                      │
│  Step 5: REVIEW & FORECAST                                          │
│  ├── Summary: Target vs Forecast vs Committed                       │
│  ├── Forecast confidence bands (best/likely/worst case)             │
│  ├── Real-time collaboration: CAM + CSE co-editing                 │
│  ├── Comments & approvals workflow                                 │
│  ├── Export: PDF, Excel forecast model, Success Snapshot            │
│  └── 🤖 ChaSen: Generate executive summary, highlight gaps,         │
│       suggest Next Best Actions to close coverage gap               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Integrated Sales Methodologies

The unified workflow incorporates five proven sales methodologies through the **A.C.T.I.O.N. Framework™**:

### The A.C.T.I.O.N. Framework™

| Stage | Name | Methodology | Application in Workflow |
|-------|------|-------------|------------------------|
| **A** | Assess | Gap Selling (Keenan) | Step 2: Portfolio & Health Snapshot |
| **C** | Connect | Never Split the Difference (Voss) | Step 3: Relationships - Tactical empathy with stakeholders |
| **T** | Transform | Building a StoryBrand (Miller) | Step 4: Risks - Position client as hero, Altera as guide |
| **I** | Identify | Black Swans (Voss) | Step 3: Uncover hidden motivators |
| **O** | Orchestrate | What's Your Story (Wortmann) | Step 5: Reference selling with Story Matrix |
| **N** | Navigate | Calibrated Questions (Voss) | All steps: Guide to "That's Right" moments |

### Methodology Integration by Step

```
Step 1: CONTEXT & SELECTION
└── No methodology - pure data selection

Step 2: PORTFOLIO & HEALTH SNAPSHOT
├── Gap Selling: Current State → Gap → Future State analysis
├── Value-Velocity Matrix: Quadrant assignment (Accelerate/Rescue/Cultivate/Stabilise)
└── Momentum Intelligence: Rate of change tracking

Step 3: RELATIONSHIPS & OPPORTUNITIES
├── MEDDPICC: 8-criteria opportunity qualification
├── Voss Techniques: Labeling, mirroring, calibrated questions
├── Checkpoint Recording: Track "That's Right" moments, Black Swan discoveries
└── Hero Journey Tracking: Client transformation stage

Step 4: RISKS & ACTIONS
├── Gap Selling: Quantify cost of inaction
├── Accusation Audit: Pre-empt objections (Voss)
├── StoryBrand SB7: Problem → Guide → Plan → Success narrative
└── Recovery Stories: Wortmann Story Matrix for at-risk clients

Step 5: REVIEW & COLLABORATE
├── Next Best Conversation: AI-generated talk tracks
├── Value Realisation Ledger: Proof points for reference selling
└── Story Matrix: Curated success stories by situation
```

### MEDDPICC Scoring (Opportunity Qualification)

| Element | Description | Score Range |
|---------|-------------|-------------|
| **M**etrics | Quantified business impact | 1-5 |
| **E**conomic Buyer | Decision-maker identified and engaged | 1-5 |
| **D**ecision Criteria | Understanding of evaluation factors | 1-5 |
| **D**ecision Process | Timeline and approval workflow | 1-5 |
| **P**aper Process | Procurement/legal requirements | 1-5 |
| **I**dentify Pain | Documented business pain points | 1-5 |
| **C**hampion | Internal advocate with power and influence | 1-5 |
| **C**ompetition | Competitive landscape awareness | 1-5 |

### Hero Journey Stages (Client Transformation)

| Stage | Client Mindset | Altera's Role |
|-------|----------------|---------------|
| Ordinary World | "Things are fine as they are" | Plant seeds of awareness |
| Call to Adventure | "Something needs to change" | Clarify problem, quantify gap |
| Meeting the Guide | "These people understand us" | Demonstrate empathy AND authority |
| Crossing Threshold | "Let's do this" | Provide clear plan, early wins |
| Tests & Allies | "This is harder than expected" | Support through challenges |
| Approach | "We're going to make it" | Maintain momentum |
| Ordeal | "This is the test" | Exceptional support |
| Reward | "We made the right choice" | Document ROI, plan expansion |
| Return (Advocate) | "I want to share our success" | Nurture advocacy |

### Conversation Checkpoints (Voss Milestones)

- ✓ **"That's Right" Moment** - Client confirms deep understanding
- 🦢 **Black Swan Discovery** - Hidden motivator uncovered
- 🏷️ **Effective Label** - "It seems like..." acknowledged
- ❓ **Calibrated Question** - "How/What" question advanced conversation
- 🪞 **Mirror Success** - Repetition prompted elaboration
- 🛡️ **Accusation Audit** - Preempted objection successfully
- 📊 **Gap Quantified** - Current→Future gap with numbers
- 💎 **Value Delivered** - Proof point documented
- 📖 **Story Resonated** - Reference story connected

---

## Sales Targets & Pipeline Management

### Target Structure

```
Territory Target (FY26)
├── Quota: $X (assigned by leadership)
├── Committed: $Y (signed contracts, renewals confirmed)
├── Forecast: $Z (weighted pipeline)
├── Gap: Quota - Committed - Forecast
└── Coverage: Pipeline ÷ Gap (target: 3x)

Account Target (per client)
├── ARR Target: Based on segment & growth potential
├── Current ARR: From BURC data
├── Expansion Target: ARR Target - Current ARR
└── Pipeline: Opportunities for this account
```

### Opportunity Management

Each opportunity includes:

| Field | Description | Source |
|-------|-------------|--------|
| **Name** | Opportunity title | User input / AI suggested |
| **Value** | Deal size in $ | User input / AI estimated |
| **Stage** | Discovery → Qualified → Proposal → Negotiation → Closed | User input |
| **Probability** | Win likelihood % (auto-calculated from stage + MEDDPICC) | Calculated |
| **Close Date** | Expected close | User input |
| **MEDDPICC Score** | 8-criteria qualification (0-40) | User input / AI pre-filled |
| **Linked Client** | Associated account | User selection |
| **Linked Stakeholders** | Key contacts for this deal | User selection |
| **Products** | Products/solutions in scope | User selection |

### Dynamic Forecast Calculation

```
Weighted Forecast = Σ (Opportunity Value × Probability)

When user adds/removes/edits opportunity:
1. Recalculate weighted forecast
2. Update coverage ratio
3. Show delta: "Forecast changed by +$X / -$X"
4. Update forecast bands (best/likely/worst)
```

### Forecast Confidence Bands

| Scenario | Calculation |
|----------|-------------|
| **Best Case** | Committed + All Pipeline at 100% |
| **Likely Case** | Committed + Weighted Forecast |
| **Worst Case** | Committed only |
| **Stretch** | Best Case + AI-identified whitespace |

### Pipeline UI Mockup

```
┌─────────────────────────────────────────────────────────────────────┐
│  📊 Pipeline & Forecast                          [+ Add Opportunity] │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Target: $2.5M    Committed: $1.2M    Forecast: $800K    Gap: $500K │
│  ████████████████████████░░░░░░░░░░░░░░░░░░░  Coverage: 2.4x        │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │ Barwon Health - EMR Upgrade                           $250,000  │ │
│  │ Stage: Proposal  │  Close: Mar 2026  │  MEDDPICC: 28/40  │ 65%  │ │
│  │ 🤖 "Strong champion identified. Missing: Paper Process clarity" │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐ │
│  │ WA Health - Analytics Module                          $180,000  │ │
│  │ Stage: Discovery │  Close: Jun 2026  │  MEDDPICC: 18/40  │ 30%  │ │
│  │ 🤖 "Needs Economic Buyer access. Suggest QBR to engage CFO."   │ │
│  └─────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  🤖 ChaSen Suggestions:                                             │
│  ├── "Barwon Health mentioned 'reporting gaps' in NPS - potential   │
│  │    $50K Analytics upsell"                                        │
│  └── "GHA renewal in 90 days - no expansion opportunity logged"    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## ChaSen AI Integration (Per Step)

ChaSen AI reduces cognitive burden by auto-suggesting responses at every step:

### Step 1: Context & Selection
| Trigger | ChaSen Response |
|---------|-----------------|
| User opens planning | "Based on your portfolio, I recommend focusing on **[Client]** - they have a renewal in 45 days and declining NPS. Want me to start their account plan?" |
| User selects territory | "Your territory has 3 clients at risk and $500K in pipeline gap. Here's a priority order..." |

### Step 2: Portfolio & Targets
| Trigger | ChaSen Response |
|---------|-----------------|
| Target entry | "Based on [Client]'s segment (Giant) and 15% YoY growth, I suggest a target of $X. Similar clients average $Y." |
| Gap identified | "You need $500K to hit quota. Here are 3 expansion opportunities I've identified from meeting notes and NPS feedback..." |
| Coverage low | "Coverage is 1.8x (target: 3x). Consider adding these whitespace opportunities: [list]" |

### Step 3: Pipeline & Opportunities
| Trigger | ChaSen Response |
|---------|-----------------|
| Add opportunity | Auto-fill fields: Value (from similar deals), Stage, MEDDPICC scores (from existing data) |
| MEDDPICC low score | "Economic Buyer score is 1/5. I found a CFO mention in meeting notes - want me to add them as a stakeholder?" |
| Opportunity stalled | "This deal has been in Proposal for 45 days. Common blockers at this stage: [list]. Suggested action: [Voss technique]" |
| Missing pipeline | "No opportunities for [Client] despite $50K expansion target. Their recent NPS mentioned 'mobile access' - matches our Mobile App product." |
| **News trigger** | "📰 Barwon Health announced $5M IT modernisation project yesterday. Suggested opportunity: EMR Upgrade ($200K)." |
| **Tender match** | "🏛️ WA Health tender matches our Analytics product. Deadline: 15 Feb. Add to pipeline?" |
| **Deal health warning** | "⚠️ Deal health dropped to 45/100 - no meeting in 21 days, champion hasn't responded to 2 emails." |
| **Competitor mention** | "🔴 Competitor 'Epic' mentioned in last meeting transcript. Suggested response: [competitive positioning]" |

### Step 4: Risks & Actions
| Trigger | ChaSen Response |
|---------|-----------------|
| Risk identified | Auto-generate Accusation Audit: "The worst they might think is... I imagine you're feeling..." |
| Action needed | "For this risk, I suggest: [Action] using [Voss/Gap/StoryBrand technique]. Here's a script: '...'" |
| Revenue at risk | "If [Opportunity] is lost, forecast drops to $X (below quota by $Y). Mitigation: [actions]" |
| Churn prediction | "Based on declining health trend, [Client] has 35% churn probability. Similar clients were saved by: [Story Matrix match]" |
| **Champion risk** | "🚨 Your champion Sarah hasn't attended last 3 meetings. Suggest: Multi-thread to backup contact [name]." |
| **Support escalation** | "⚠️ 5 P1 tickets in 30 days. Support health dropped to 42%. Suggest: Executive escalation call." |
| **Contract cliff** | "📅 Renewal in 60 days, but no renewal conversation logged. Auto-created action: Schedule renewal kickoff." |
| **Stakeholder change** | "📰 News: CFO at [Client] stepping down. Risk: Economic Buyer relationship. Suggest: Identify successor." |
| **AR aging risk** | "💰 $45K overdue >90 days. Financial risk flagged. Suggest: Involve finance team." |

### Step 5: Review & Forecast
| Trigger | ChaSen Response |
|---------|-----------------|
| Plan review | Auto-generate executive summary: "Territory has $X committed, $Y forecast, with primary risks at [clients]. Key actions: [top 3]" |
| Coverage gap | "To close the $500K gap, prioritise: 1) [Opp A] - highest MEDDPICC, 2) [Opp B] - fastest close date" |
| Export | "I've highlighted 3 areas that need attention before leadership review: [list]" |

### AI Pre-Population Sources

ChaSen auto-populates from ALL available data sources:

| Data Source | Used For |
|-------------|----------|
| **Meetings & Engagement** | |
| `unified_meetings` | Opportunity discovery, stakeholder sentiment, action items, meeting effectiveness |
| `unified_meetings.topics` | Topic extraction → product matching → opportunity suggestion |
| `unified_meetings.risks` | Auto-populate risk register from meeting-detected risks |
| `unified_meetings.decisions` | Commitment tracking, deal advancement signals |
| **NPS & Sentiment** | |
| `nps_responses` | Pain points → opportunity themes, detractor recovery actions |
| `nps_topic_classifications` | Categorised feedback → product recommendations |
| **Support & Operations** | |
| `support_sla_metrics` | SLA%, CSAT, backlog → risk scoring |
| `support_case_details` | Ticket volume, resolution times → support health trend |
| **Financials** | |
| `burc_annual_financials` | ARR, targets, churn, revenue vs target |
| `burc_attrition_risk` | Churn probability scoring → risk alerts |
| `burc_contracts` | Renewal dates, contract terms → renewal pipeline |
| `aging_accounts` | AR aging → financial risk, collection actions |
| **Stakeholders** | |
| `stakeholder_relationships` | MEDDPICC Economic Buyer/Champion, influence scoring |
| `stakeholder_influences` | Political dynamics, relationship strength |
| **News & Tenders** | |
| `news_articles` + `news_article_clients` | Client news → opportunity/risk triggers |
| `tender_opportunities` | Government tenders → pipeline opportunities |
| `news_stakeholder_mentions` | Stakeholder movements, leadership changes |
| **Product & Whitespace** | |
| `product_catalog` | Product matching for opportunities |
| Stack gap analysis | Whitespace → expansion opportunity suggestions |
| **Operating Rhythm** | |
| `segmentation_events` | Compliance tracking → engagement actions |
| `segmentation_compliance_scores` | Engagement health → relationship scoring |
| **Historical & Learning** | |
| `client_health_history` | Trend analysis, momentum scoring |
| `meddpicc_scores` | Historical scoring patterns |
| `actions` | Overdue action → risk escalation |
| `chasen_conversations` | Past AI advice per client → continuity |
| `chasen_feedback` | What worked → refine suggestions |

---

## Cutting-Edge AI Features (Inspired by Industry Leaders)

### Revenue Intelligence (Gong/Clari-inspired)

| Feature | Description | Data Sources |
|---------|-------------|--------------|
| **Deal Health Score** | AI-scored 0-100 deal likelihood based on engagement signals, not just stage | `unified_meetings`, `stakeholder_relationships`, `meddpicc_scores`, email activity |
| **Stalled Deal Detection** | Alert when deal hasn't progressed in X days with suggested unblock actions | Opportunity stage history, meeting frequency |
| **Win/Loss Prediction** | ML model predicting win probability with explanation ("Missing CFO engagement") | Historical won/lost deals, MEDDPICC patterns |
| **Talk Ratio Analysis** | Meeting effectiveness based on client vs CSE talk time from transcripts | `unified_meetings.transcript` |
| **Competitive Displacement Alerts** | Detect when competitor is mentioned in meetings/NPS | `unified_meetings.topics`, `nps_responses.feedback` |

### Buyer Engagement Intelligence (People.ai/6sense-inspired)

| Feature | Description | Data Sources |
|---------|-------------|--------------|
| **Buyer Engagement Score** | Aggregate engagement across all contacts at an account | Meeting attendance, email opens, NPS responses |
| **Multi-Threading Score** | Are we engaging multiple stakeholders or single-threaded? | `stakeholder_relationships`, meeting attendees |
| **Champion Risk Detection** | Alert when champion goes quiet or leaves | Meeting patterns, news mentions, LinkedIn changes |
| **Buying Committee Mapping** | Auto-detect decision-making unit from meeting attendees | `unified_meetings.attendees`, stakeholder data |
| **Intent Signals** | Detect buying intent from news, tenders, meeting topics | `news_articles`, `tender_opportunities`, `unified_meetings.topics` |

### Predictive Analytics (Gainsight/ChurnZero-inspired)

| Feature | Description | Data Sources |
|---------|-------------|--------------|
| **Churn Prediction Model** | 30/60/90 day churn probability with contributing factors | `burc_attrition_risk`, health trends, support metrics |
| **Expansion Propensity** | Which clients most likely to expand based on patterns | Usage signals, NPS, health trajectory |
| **Renewal Forecast** | Predicted renewal outcome with confidence bands | Contract dates, health, engagement, competitive signals |
| **Revenue Impact Modelling** | If [client] churns, portfolio ARR drops by $X | `burc_annual_financials`, pipeline |
| **Next Best Action (NBA)** | ML-ranked actions by predicted impact on health/revenue | Historical action effectiveness, current state |

### Conversation Intelligence (Chorus/Gong-inspired)

| Feature | Description | Data Sources |
|---------|-------------|--------------|
| **Key Moment Detection** | Auto-flag commitments, objections, pricing discussions | `unified_meetings.transcript` |
| **Sentiment Trajectory** | Track sentiment across meetings - improving or declining? | `unified_meetings.sentiment_*` |
| **Competitor Mention Tracking** | When/how competitors are mentioned in conversations | Meeting transcripts, NPS feedback |
| **Action Item Extraction** | Auto-generate actions from meeting transcripts | `unified_meetings.next_steps`, AI analysis |
| **Talk Track Effectiveness** | Which scripts/approaches lead to positive outcomes? | Meeting sentiment + deal progression correlation |

### Proactive Intelligence (Novel)

| Feature | Description | Data Sources |
|---------|-------------|--------------|
| **News-Triggered Alerts** | "Barwon Health announced digital transformation - schedule discovery call" | `news_articles`, AI scoring |
| **Tender Opportunity Matching** | "WA Health tender matches our EMR - deadline in 30 days" | `tender_opportunities` |
| **Stakeholder Movement Alerts** | "CFO at Gippsland changed - relationship reset needed" | News, LinkedIn, meeting attendance gaps |
| **Meeting Gap Detection** | "No meeting with [client] in 45 days - risk of relationship decay" | `unified_meetings`, segment requirements |
| **Contract Cliff Alerts** | "5 renewals in Q2 worth $2.1M - start engagement now" | `burc_contracts` |
| **Cross-Sell Triggers** | "Client mentioned 'mobile' 3x in meetings - matches Mobile App product" | Meeting topics, `product_catalog` |

### AI-Powered Automation (Gainsight Copilot-inspired)

| Feature | Description | Trigger |
|---------|-------------|---------|
| **Auto-Generate QBR Deck** | Create QBR slides from last quarter's data | 30 days before QBR |
| **Draft Renewal Proposal** | Pre-fill renewal document with ARR, value delivered, expansion options | 90 days before renewal |
| **Risk Mitigation Playbook** | Auto-suggest playbook based on risk type | When health drops below threshold |
| **Meeting Prep Brief** | 1-page summary before client meetings with recent context | 24 hours before meeting |
| **Executive Summary Generator** | Leadership-ready summary of territory/account status | On demand or weekly |
| **Action Email Drafts** | Pre-written email for each action item with Voss techniques | When action created |

### Implementation Priority

| Phase | Features | Complexity |
|-------|----------|------------|
| **Phase 4a** | Deal Health Score, Stalled Deal Detection, Churn Prediction | Medium |
| **Phase 4b** | News/Tender Alerts, Meeting Gap Detection, Contract Cliffs | Medium |
| **Phase 4c** | Win/Loss Prediction, Multi-Threading Score, Buying Committee | High |
| **Phase 5** | Talk Ratio Analysis, Conversation Intelligence, Auto-Decks | High (requires transcript processing) |

---

## UX Cohesion: Preventing Information Overload

### Core Principle: Progressive Disclosure

Users see **summary first**, details on demand. Never dump all data at once.

```
┌─────────────────────────────────────────────────────────────────────┐
│  LAYER 1: GLANCEABLE (Always Visible)                               │
│  ├── 3 key metrics: Target | Forecast | Gap                         │
│  ├── 1 priority alert (most urgent)                                 │
│  └── Overall plan health: ●●●○○ (3/5 steps complete)               │
│                                                                      │
│  LAYER 2: SUMMARY (Collapsed by Default)                            │
│  ├── Top 3 opportunities by value                                   │
│  ├── Top 3 risks by severity                                        │
│  └── ChaSen's #1 recommended action                                 │
│                                                                      │
│  LAYER 3: DETAIL (Click to Expand)                                  │
│  ├── Full opportunity list with MEDDPICC                            │
│  ├── Complete risk register with mitigation plans                   │
│  └── All AI suggestions with evidence                               │
│                                                                      │
│  LAYER 4: DEEP DIVE (Separate Panel/Modal)                          │
│  ├── Full data tables                                               │
│  ├── Historical trends                                              │
│  └── Supporting evidence from source systems                        │
└─────────────────────────────────────────────────────────────────────┘
```

### Smart Prioritisation: AI-Ranked Importance

ChaSen ranks ALL insights by urgency × impact, shows only top items:

| Priority | Criteria | Display |
|----------|----------|---------|
| 🔴 **Critical** | Revenue at risk, churn imminent, deadline <7 days | Always visible, red badge |
| 🟠 **High** | Deal stalled, health declining, renewal <30 days | Visible in summary, orange |
| 🟡 **Medium** | Opportunity identified, engagement gap | Collapsed, yellow dot |
| ⚪ **Low** | FYI, general suggestions | Hidden until requested |

**Rule: Maximum 3 critical/high items visible at once.** Others queue in "More insights" drawer.

### Context-Aware Surfacing

Show insights ONLY when relevant to the current step:

| Step | Visible Insights | Hidden Until Relevant |
|------|------------------|----------------------|
| 1. Context | Priority client suggestions | Everything else |
| 2. Targets | Coverage gaps, target suggestions | Opportunity details, risks |
| 3. Pipeline | Opportunity suggestions, deal health, news/tenders | Risk details |
| 4. Risks | Risk alerts, churn predictions, mitigation actions | Opportunity details |
| 5. Review | Executive summary, forecast bands, approval blockers | Granular details |

### ChaSen AI Panel: Single Point of Intelligence

Instead of scattered alerts, ONE collapsible AI panel per step:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🤖 ChaSen Insights (3)                                    [−]      │
├─────────────────────────────────────────────────────────────────────┤
│  🔴 URGENT: Barwon Health renewal in 28 days - no meeting scheduled │
│     [Schedule Meeting] [Dismiss] [Snooze 7 days]                    │
│                                                                      │
│  🟠 Opportunity: WA Health tender matches Analytics ($180K)         │
│     [Add to Pipeline] [View Tender] [Not Relevant]                  │
│                                                                      │
│  🟡 Suggestion: MEDDPICC score could improve with CFO access        │
│     [Show Me How] [Already Done] [Later]                            │
├─────────────────────────────────────────────────────────────────────┤
│  📊 12 more insights available                        [View All →]  │
└─────────────────────────────────────────────────────────────────────┘
```

### Notification Fatigue Prevention

| Mechanism | Implementation |
|-----------|----------------|
| **Daily digest** | Batch low-priority insights into morning summary email |
| **Snooze** | "Remind me in 7 days" for non-urgent items |
| **Dismiss with learning** | "Not relevant" trains ChaSen to reduce similar suggestions |
| **Quiet hours** | No push notifications outside work hours |
| **Smart grouping** | "3 clients need QBR scheduling" instead of 3 separate alerts |
| **Threshold tuning** | User can adjust sensitivity ("Show me only critical items") |

### Visual Hierarchy: Calm by Default

```
┌─────────────────────────────────────────────────────────────────────┐
│  HEADER: Clean metrics bar (no alerts unless critical)              │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ Target: $2.5M  │  Forecast: $2.1M  │  Coverage: 2.4x  │ ●●●○○ │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  MAIN: Current step content (focused workspace)                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                                                                │   │
│  │  [Step content here - opportunities, risks, etc.]             │   │
│  │                                                                │   │
│  │  No distracting badges or alerts in the main workspace        │   │
│  │                                                                │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  SIDEBAR: ChaSen panel (collapsible, right side)                    │
│  ┌────────────────┐                                                 │
│  │ 🤖 Insights (3) │ ← Badge shows count, panel collapses          │
│  │    ...          │                                                │
│  └────────────────┘                                                 │
└─────────────────────────────────────────────────────────────────────┘
```

### Action-Oriented, Not Information-Oriented

Every insight MUST have a clear action button:

| ❌ Information Dump | ✅ Actionable Insight |
|--------------------|----------------------|
| "Client health is 42/100" | "Health dropped 15pts. **[View Causes]** **[Create Recovery Plan]**" |
| "Tender available for WA Health" | "Tender matches Analytics. **[Add to Pipeline]** **[View Details]**" |
| "Champion hasn't responded" | "Champion silent 14 days. **[Draft Follow-up]** **[Try Another Contact]**" |

### Personalisation: User Control

Users can configure their experience:

```
┌─────────────────────────────────────────────────────────────────────┐
│  ⚙️ ChaSen Preferences                                              │
├─────────────────────────────────────────────────────────────────────┤
│  Alert Sensitivity:     [Less] ────●──── [More]                     │
│                                                                      │
│  Show me:               ☑️ Revenue alerts                            │
│                         ☑️ Churn predictions                         │
│                         ☑️ News & tender matches                     │
│                         ☐ Meeting suggestions (disabled)             │
│                         ☑️ MEDDPICC coaching                         │
│                                                                      │
│  Notification style:    ○ Real-time  ● Daily digest  ○ Weekly       │
│                                                                      │
│  AI assistance level:   ○ Minimal    ● Balanced      ○ Proactive    │
└─────────────────────────────────────────────────────────────────────┘
```

### Cognitive Load Limits

| Element | Maximum | Rationale | Override |
|---------|---------|-----------|----------|
| Visible alerts | 3 | Miller's Law: 7±2 chunks, leave room for content | "View all insights" drawer |
| Suggested actions per step | 5 | Decision fatigue prevention | "More suggestions" expandable |
| Pipeline opportunities shown | 10 | Scrolling discouraged, pagination available | **"Show All"** button expands full table |
| Metrics in header | 4 | Glanceable dashboard | Click metric for breakdown |
| Steps in wizard | 5 | Already at cognitive limit | N/A |

**Pipeline "Show All" Implementation:**
```
┌─────────────────────────────────────────────────────────────────────┐
│  📊 Pipeline & Forecast                          [+ Add Opportunity] │
├─────────────────────────────────────────────────────────────────────┤
│  Showing 10 of 24 opportunities                     [🔽 Show All]   │
│                                                                      │
│  [Opportunity cards 1-10...]                                        │
│                                                                      │
│  ──────────────────────────────────────────────────────────────────  │
│  [Show All 24 Opportunities]  │  [Export to Excel]                  │
└─────────────────────────────────────────────────────────────────────┘
```
- Clicking "Show All" expands to full scrollable table view
- Table view includes sorting by: Value, Stage, Close Date, MEDDPICC Score
- Filtering by: Stage, Client, Products, Date Range
- Bulk actions: Update stage, Assign owner, Delete selected

### Empty States: Guide, Don't Overwhelm

When no data exists, provide ONE clear next step:

```
┌─────────────────────────────────────────────────────────────────────┐
│                                                                      │
│  📋 No opportunities yet                                            │
│                                                                      │
│  ChaSen found 2 potential opportunities from recent meetings.       │
│                                                                      │
│  [Review Suggestions]  or  [Add Manually]                           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Summary: UX Principles

1. **Show 3, hide 100** - Surface top priorities, details on demand
2. **Context-aware** - Right insight, right step, right time
3. **Single AI panel** - One place for all intelligence
4. **Always actionable** - Every insight has a button
5. **User control** - Sensitivity sliders, not binary switches
6. **Calm by default** - Alerts are exceptions, not the norm
7. **Learn from feedback** - Dismissed items inform future ranking

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

### Existing Collaboration Features Summary

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Real-time Presence** | See who's viewing/editing the plan | Supabase Realtime + `plan_presence` table |
| **In-Context Comments** | Threaded comments on any element | `plan_comments` table with entity linking |
| **@Mentions** | Tag team members for attention | Notification system integration |
| **Activity Log** | Full audit trail of changes | `plan_activity_log` table |
| **Approval Workflow** | Submit → Review → Approve states | `status` field with workflow triggers |
| **Version History** | Track all edits over time | JSONB `activity_log` column |

---

## Next-Level Collaboration Features

### Async Handoffs (CAM ↔ CSE)

Structured handoff workflow when ownership transitions:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🔄 Handoff Request                                                  │
├─────────────────────────────────────────────────────────────────────┤
│  From: Anu Pradhan (CAM)  →  To: Tracey Bland (CSE)                 │
│                                                                      │
│  📋 Handoff Summary (AI-generated):                                 │
│  • Barwon Health renewal due Mar 15                                 │
│  • Key risk: CFO engagement (MEDDPICC E: 2/5)                       │
│  • Suggested action: QBR before renewal                             │
│                                                                      │
│  📝 CAM Notes:                                                      │
│  "Need CSE to run technical discovery. CFO prefers ROI focus."     │
│                                                                      │
│  [Accept Handoff]  [Request Clarification]  [Decline]               │
└─────────────────────────────────────────────────────────────────────┘
```

### Shared Playbooks & Templates

| Playbook | Trigger | Auto-Actions |
|----------|---------|--------------|
| **Renewal Kickoff** | 90 days before renewal | Create meeting, pre-fill deck, assign owner |
| **Churn Recovery** | Health drops below 40 | Alert CAM, generate Accusation Audit, suggest Story Matrix |
| **Expansion Discovery** | Positive NPS + high engagement | Create opportunity, suggest products, draft outreach |
| **QBR Preparation** | 30 days before QBR | Generate slides, pull metrics, schedule prep call |

### Team Dashboard View

```
┌─────────────────────────────────────────────────────────────────────┐
│  👥 Team Planning Overview                           FY26 Q1        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Territory Coverage                                                  │
│  ├── Tracey Bland: $2.1M / $2.5M (84%) ████████████████░░░░        │
│  ├── Anu Pradhan:  $1.8M / $2.0M (90%) ██████████████████░░        │
│  └── Team Total:   $3.9M / $4.5M (87%) █████████████████░░░        │
│                                                                      │
│  Plans Requiring Attention                                          │
│  ├── 🔴 3 plans overdue for review                                  │
│  ├── 🟠 5 plans awaiting approval                                   │
│  └── 🟡 2 plans with unresolved comments                            │
│                                                                      │
│  [View All Plans]  [Export Team Report]  [Schedule Team Review]     │
└─────────────────────────────────────────────────────────────────────┘
```

### Review Scheduling & Reminders

| Event | Auto-Reminder | Suggested Prep |
|-------|---------------|----------------|
| **Plan Review Due** | 7 days before, 1 day before | ChaSen generates "changes since last review" summary |
| **Approval Pending** | Daily until resolved | Highlight blockers, suggest resolution |
| **Comment Unresolved** | 3 days after posting | Escalate to plan owner |
| **Handoff Pending** | 2 days, then escalate | Notify manager if unacknowledged |

---

## Operating Rhythm Alignment

### CS Operating Rhythm Events (Existing)

From `segmentation_events` table:

| Event | Month | Description |
|-------|-------|-------------|
| **APAC Compass / Annual Account Planning** | January | Full year planning and target setting |
| **Q1 Account Plan Update** | ~April | First quarterly refresh |
| **Q2 Account Plans (updated)** | ~July | Mid-year update |
| **2H Account Plan Review** | ~July/August | Half-year strategic review |
| **Q4 Account Plan Update** | ~October | Final quarterly refresh before year-end |

### Auto-Triggered Plan Reviews

Strategic Planning automatically integrates with Operating Rhythm:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📅 Operating Rhythm: Automatic Plan Scheduling                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  JANUARY: Annual Planning                                            │
│  ├── 🔔 "Annual planning starts in 2 weeks"                         │
│  ├── ChaSen pre-populates: Prior year performance, renewals,        │
│  │    pipeline carried forward, health trends                       │
│  ├── Auto-creates draft plans for all accounts in territory         │
│  └── Deadline: Submit by Jan 31                                     │
│                                                                      │
│  QUARTERLY: Q1/Q2/Q4 Updates                                        │
│  ├── 🔔 "Quarterly review due in 1 week"                            │
│  ├── ChaSen generates: Delta since last review                      │
│  │    - Pipeline changes (+$X / -$Y)                                │
│  │    - Health movements (▲3 improved, ▼2 declined)                 │
│  │    - New risks/opportunities identified                          │
│  ├── User task: Review AI summary, update as needed                 │
│  └── Target: 15 min per account (vs 45 min fresh start)            │
│                                                                      │
│  2H REVIEW: Mid-Year Strategic Check                                │
│  ├── 🔔 "Half-year review scheduled"                                │
│  ├── ChaSen generates: H1 performance report                        │
│  │    - Target vs Actual (by client)                                │
│  │    - Win/loss analysis                                           │
│  │    - Forecast accuracy assessment                                │
│  ├── Suggested: Adjust H2 targets if >10% variance                  │
│  └── Team review meeting auto-scheduled                             │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### ChaSen "Changes Since Last Review" (Minimal User Effort)

When a review is due, ChaSen auto-generates a summary requiring minimal user input:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🤖 ChaSen: Q2 Account Plan Review - Barwon Health                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  📊 CHANGES SINCE Q1 REVIEW (Apr 15, 2026)                          │
│                                                                      │
│  PIPELINE                                                            │
│  ├── ✅ Won: EMR Upgrade ($250K) - Closed May 2                     │
│  ├── ➕ Added: Analytics Module ($180K) - Discovery stage           │
│  ├── 📉 Slipped: Mobile App ($90K) - Moved from Q2 to Q3           │
│  └── Net Change: +$160K pipeline                                    │
│                                                                      │
│  HEALTH & ENGAGEMENT                                                 │
│  ├── Health Score: 72 → 78 (+6)                                     │
│  ├── NPS: +32 → +45 (+13)                                           │
│  ├── Meetings: 4 (vs 3 in Q1)                                       │
│  └── Support: 2 P1 tickets (resolved)                               │
│                                                                      │
│  RISKS                                                               │
│  ├── 🟢 Resolved: CFO engagement (met twice, strong relationship)   │
│  ├── 🟡 New: IT Director retiring in Aug (succession planning)      │
│  └── 🔴 Unchanged: Integration concerns (needs technical session)   │
│                                                                      │
│  AI RECOMMENDATIONS                                                  │
│  ├── Celebrate EMR win in next QBR (Story Matrix match ready)       │
│  ├── Accelerate Analytics opportunity (high MEDDPICC: 32/40)        │
│  └── Schedule succession intro meeting before Aug                   │
│                                                                      │
│  ─────────────────────────────────────────────────────────────────  │
│  ✅ Looks good - no changes needed      [Approve & Submit]          │
│  ✏️  Make edits                          [Edit Plan]                 │
│  💬 Add comments                         [Add Notes]                 │
└─────────────────────────────────────────────────────────────────────┘
```

### Effort Reduction: Annual vs Quarterly

| Review Type | Without ChaSen | With ChaSen | User Action |
|-------------|----------------|-------------|-------------|
| **Annual Planning** | 2-3 hours/account | 45 min/account | Review AI draft, validate targets, add strategy |
| **Quarterly Update** | 45 min/account | 10-15 min/account | Review delta summary, confirm or edit |
| **2H Strategic Review** | 1-2 hours/account | 30 min/account | Review H1 performance, adjust H2 forecast |

**Key Principle:** ChaSen does the data gathering; user provides judgement and strategy.

### Auto-Scheduling Database Schema

```sql
-- Plan review schedule (auto-created from Operating Rhythm)
CREATE TABLE plan_review_schedule (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID REFERENCES strategic_plans(id) ON DELETE CASCADE,
  review_type TEXT CHECK (review_type IN ('annual', 'quarterly', '2h_review')),
  fiscal_year INTEGER NOT NULL,
  quarter TEXT,  -- 'Q1', 'Q2', 'Q3', 'Q4', '2H'
  due_date DATE NOT NULL,
  reminder_sent_at TIMESTAMPTZ,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'skipped')),
  completed_at TIMESTAMPTZ,
  completed_by TEXT,
  ai_summary JSONB,  -- ChaSen-generated delta summary
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Link to Operating Rhythm events
CREATE TABLE plan_rhythm_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID REFERENCES strategic_plans(id) ON DELETE CASCADE,
  event_id UUID REFERENCES segmentation_events(id),
  event_name TEXT,
  event_date DATE,
  auto_created BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_plan_review_due ON plan_review_schedule(due_date) WHERE status = 'pending';
CREATE INDEX idx_plan_review_plan ON plan_review_schedule(plan_id);
```

### Implementation: Rhythm Integration

```
Phase 3 Addition: Operating Rhythm Integration
- [ ] Create `plan_review_schedule` table
- [ ] Build review scheduling service (auto-creates reviews from `segmentation_events`)
- [ ] Implement ChaSen "delta since last review" generator
- [ ] Add review reminder notifications (7 days, 1 day before)
- [ ] Build one-click "Approve & Submit" for quick reviews
- [ ] Create team calendar view showing all upcoming reviews
- [ ] Add "Skip with reason" for non-applicable reviews
```

---

## Plan Approval Workflow

### Design Principles

| Aspect | Decision | Rationale |
|--------|----------|-----------|
| **Approver model** | Single approver (manager), auto-assigned | Clear accountability, simple chain |
| **Feedback loop** | Collaborative editing — no rejection state | Removes friction, faster iteration |
| **Transparency** | Team-visible status & comments | Everyone informed, not overwhelmed |
| **Flexibility** | Strict assignment only | Maintains accountability |
| **Deadlines** | Reminder-based, no hard enforcement | Low friction, trust-based |

### Workflow States & Transitions

```
draft → in_review → approved → archived
          ↑    ↓
          └────┘  (collaborative edits, no rejection state)
```

**State Definitions:**

| State | Description | Who can edit |
|-------|-------------|--------------|
| **Draft** | Work in progress, not visible to approvers | Owner + collaborators |
| **In Review** | Submitted for approval, both parties can refine | Owner + approver (tracked) |
| **Approved** | Official plan, locked for edits | No one (clone for changes) |
| **Archived** | Historical record, hidden from active views | No one |

**Transition Rules:**

| From | To | Who can trigger |
|------|-----|-----------------|
| draft | in_review | Plan owner (submits) |
| in_review | draft | Plan owner (withdraws) |
| in_review | approved | Assigned approver only |
| approved | archived | System (next FY) or owner |

### Collaborative Editing During Review

When a plan is "in review", both submitter and approver can edit with full change tracking:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📝 Plan: Barwon Health FY26                    Status: In Review   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Pipeline Target: $500,000                                          │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ 📝 Edited by Sarah Chen (Manager) - 2 hours ago                 ││
│  │ Changed from $450,000 → $500,000                                ││
│  │ "Aligned with regional target increase"                         ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  [View All Changes (3)]                              [Approve Plan] │
└─────────────────────────────────────────────────────────────────────┘
```

**Change tracking includes:**
- Who edited, when
- Field-level diff (old → new value)
- Optional comment explaining the change
- Grouped by editing session (not every keystroke)

**Conflict handling:**
- Real-time presence shows who's viewing/editing
- Last-write-wins for simultaneous edits
- Trust-based collaboration (no formal locking)

### Team Visibility

```
┌─────────────────────────────────────────────────────────────────────┐
│  👥 Team Plans                                          FY26 Q1     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─ Tracey Bland ────────────────────────────────────────────────┐  │
│  │  Barwon Health        ● Approved     Sarah Chen, Jan 28       │  │
│  │  WA Health            ○ In Review    Awaiting Sarah Chen      │  │
│  │  Gippsland Health     ◐ Draft        Not submitted            │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Visibility Matrix:**

| Role | Can see | Can edit | Can approve |
|------|---------|----------|-------------|
| **Plan owner** | Everything | Always (draft), tracked (in review) | No |
| **Assigned approver** | Everything | Tracked edits (in review only) | Yes |
| **Team members** | Status, approver, comments | No | No |
| **Other managers** | Status only | No | No |

### Submission UI

```
┌─────────────────────────────────────────────────────────────────────┐
│  Submit Plan for Approval                                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Plan: Barwon Health FY26 Account Plan                              │
│  Completion: ●●●●● 100% (all steps complete)                        │
│                                                                      │
│  Approver: Sarah Chen (Manager)           [Auto-assigned]           │
│                                                                      │
│  📝 Note to approver (optional):                                    │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ Increased pipeline target based on Q4 momentum. See step 3.    ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  ⚠️  ChaSen flagged 1 item to review before submitting:             │
│      • MEDDPICC score below 20 for "Analytics Module" opportunity   │
│                                                                      │
│  [Cancel]                                      [Submit for Approval] │
└─────────────────────────────────────────────────────────────────────┘
```

### Approver UI

```
┌─────────────────────────────────────────────────────────────────────┐
│  📋 Pending Approval                                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Barwon Health FY26 — submitted by Tracey Bland, 2 days ago         │
│  "Increased pipeline target based on Q4 momentum. See step 3."     │
│                                                                      │
│  [View Full Plan]   [View Changes Since Last Approval]              │
│                                                                      │
│  ─────────────────────────────────────────────────────────────────  │
│                                                                      │
│  [Approve Plan ✓]                                                   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Notifications

| Event | Recipient | Timing |
|-------|-----------|--------|
| Plan submitted | Submitter | Immediate confirmation |
| New plan awaiting approval | Approver | Immediate |
| Reminder: plans awaiting approval | Approver | Weekly digest |
| Plan approved | Submitter | Immediate |
| Edit made during review | Other party | Real-time (if online) or next visit |

### Approval Workflow Schema

```sql
-- Additional columns for strategic_plans table
ALTER TABLE strategic_plans ADD COLUMN IF NOT EXISTS
  approver TEXT,                    -- Assigned approver (manager name)
  approver_role TEXT,               -- 'manager', for future flexibility
  submission_note TEXT,             -- Note from submitter
  approval_note TEXT;               -- Note from approver (if any)

-- Change tracking for collaborative editing
CREATE TABLE plan_change_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID REFERENCES strategic_plans(id) ON DELETE CASCADE,
  user_name TEXT NOT NULL,
  user_role TEXT,                   -- 'owner' or 'approver'
  field_path TEXT NOT NULL,         -- e.g., 'targets_data.quota'
  old_value JSONB,
  new_value JSONB,
  change_note TEXT,                 -- Optional explanation
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_plan_changes ON plan_change_log(plan_id, created_at DESC);

-- Activity log actions for approval workflow:
-- 'submitted' — plan submitted for approval
-- 'approved' — plan approved
-- 'withdrawn' — plan withdrawn from review
-- 'edited_in_review' — changes made during review
```

### Implementation: Approval Workflow

```
Phase 3 Addition: Approval Workflow
- [ ] Add approval columns to strategic_plans table
- [ ] Create plan_change_log table for edit tracking
- [ ] Build submission modal with ChaSen pre-flight checks
- [ ] Build approver dashboard (pending approvals list)
- [ ] Implement collaborative editing with change tracking
- [ ] Add approval/withdrawal actions with activity logging
- [ ] Build team visibility view (status board)
- [ ] Implement notification system (immediate + digest)
```

---

## Competitive Intelligence Integration

### Overview

Comprehensive competitive intelligence embedded throughout account plans, combining **static product assets** with **live market intelligence**.

**Intelligence Types:**
1. **Competitor Presence Tracking** — Which competitors are active at each client
2. **Win/Loss Intelligence** — Patterns from competitive deals
3. **Market Movement Alerts** — Real-time news on competitor activity
4. **Competitive Positioning Playbooks** — Pre-built responses and battlecards

### Two-Layer Intelligence Model

| Layer | Source | Content | Update Frequency |
|-------|--------|---------|------------------|
| **Static Assets** | `product_catalog` table | Battlecards, objection handling, positioning statements | Manual (product team) |
| **Live Intelligence** | Web sources, internal data | News, tenders, hiring signals, meeting mentions | Hourly to weekly |

**Static Assets (from `product_catalog`):**
```typescript
// Already exists in product_catalog table
competitive_analysis: Array<{ competitor: string; our_advantage: string }>
objection_handling: Array<{ objection: string; response: string }>
```

**How they combine in the UI:**
```
┌─────────────────────────────────────────────────────────────────────┐
│  ⚔️ vs Oracle Health                                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  📋 BATTLECARD (from product_catalog — static)                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ When competing on Analytics:                                    ││
│  │ "Oracle Analytics requires Cerner backend. Ours works with any  ││
│  │ EMR — client can keep Epic and add our analytics layer."        ││
│  │                                                                  ││
│  │ Objection: "Oracle is the industry standard"                    ││
│  │ Response: "For US maybe. In APAC, local support and faster     ││
│  │ implementation win. See St Vincent's case study."               ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  📰 LIVE INTEL (from web sources — dynamic)                         │
│  ├── 🏆 Won WA Health tender ($2M) - 3 days ago [AusTender]        │
│  ├── 💼 Hiring 15 APAC sales roles [LinkedIn Jobs]                 │
│  ├── 📉 Glassdoor rating: 3.1/5 (↓0.3) [Glassdoor]                 │
│  ├── ⚠️ 2-hour US outage reported [News RSS]                       │
│  └── 💬 Mentioned in Barwon CFO meeting Jan 22 [Internal]          │
│                                                                      │
│  🎯 CONTEXTUAL INSIGHT (AI-generated)                               │
│  "Oracle is actively competing for Barwon's Analytics deal.        │
│  Their recent WA Health win gives them momentum. Counter with      │
│  our EMR-agnostic advantage and local support SLA."                │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Data Sources

**Static Product Assets (from `product_catalog`):**

| Field | Content | Used For |
|-------|---------|----------|
| `competitive_analysis` | `[{ competitor, our_advantage }]` | Battlecard positioning statements |
| `objection_handling` | `[{ objection, response }]` | Pre-built objection responses |
| `value_propositions` | `[{ title, description }]` | Differentiation points |
| `target_triggers` | `string[]` | When to use this product competitively |

**Live Intelligence Sources (web + internal):**

| Source | Data Captured | Update Frequency |
|--------|---------------|------------------|
| **News RSS** | Competitor announcements, wins, product launches, outages | Hourly |
| **AusTender** | Contract awards, government deal wins | Daily |
| **Competitor Press Releases** | Official announcements, partnerships | Daily |
| **LinkedIn Company Pages** | Headcount trends, new hires, job postings | Weekly |
| **LinkedIn People** | Executive movements, champion job changes | Weekly |
| **Job Postings** | Product direction hints (hiring signals) | Weekly |
| **Glassdoor** | Employee sentiment, internal issues | Monthly |
| **Financial Filings** | Revenue, strategy from earnings calls | Quarterly |
| **Meeting Mentions** | Competitor references in `unified_meetings` | Real-time |
| **NPS Feedback** | Competitor mentions in `nps_responses` | Per survey |
| **Win/Loss Records** | Historical outcomes from `competitive_outcomes` | On recording |

### Embedded Competitive Context (Per Step)

**Step 2: Portfolio & Targets**
```
│  ⚔️ Competitive Landscape:                                          │
│  ├── Epic (Incumbent - Ambulatory)     Threat: 🟠 Medium            │
│  └── Oracle Health (Evaluating)        Threat: 🔴 High              │
│                                                                      │
│  📰 Recent: "Oracle Health shortlisted for radiology" - 3 days ago  │
```

**Step 3: Pipeline & Opportunities**
```
│  ⚔️ Competition on this deal:                                       │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ Oracle Health Analytics — actively bidding                      ││
│  │ Last mention: CFO meeting Jan 15 ("comparing Oracle pricing")   ││
│  │ 🏆 Our win rate vs Oracle Analytics: 3-1 (75%)                  ││
│  │ [View Battlecard] [See Similar Wins]                            ││
│  └─────────────────────────────────────────────────────────────────┘│
```

**Step 4: Risks & Actions**
```
│  🔴 RISK: Competitive Displacement                    Severity: High │
│                                                                      │
│  Evidence:                                                           │
│  • Mentioned in 3 meetings (Jan 8, 15, 22)                          │
│  • CFO requested Oracle pricing comparison                          │
│  • Oracle won similar deal at WA Health last quarter               │
│                                                                      │
│  🤖 ChaSen Suggested Actions:                                       │
│  ├── Schedule executive alignment meeting (Voss: Accusation Audit)  │
│  ├── Prepare ROI comparison using client's actual data              │
│  └── Reference St Vincent's win story (similar situation)           │
```

### Competitive Intelligence Panel

Collapsible panel available on every step:

```
┌─────────────────────────────────────────────────────────────────────┐
│  ⚔️ Competitive Intelligence                                   [−]  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  COMPETITORS AT THIS ACCOUNT                                        │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ [Oracle Logo] Oracle Health                    Threat: 🔴 High  ││
│  │ Status: Actively Evaluating                                     ││
│  │ Products: Analytics, Radiology                                  ││
│  │ Last Activity: CFO meeting, Jan 22                              ││
│  │ Our Record vs Oracle: 3W - 1L (75%)                             ││
│  │ [View Dossier] [Battlecard] [Similar Wins]                      ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  RECENT INTEL (Last 30 days)                                        │
│  ├── 📰 Oracle wins $2M deal at WA Health (competitor intel)       │
│  ├── 💼 Epic hiring 50 APAC developers (job posting signal)        │
│  ├── 📉 Cerner Glassdoor drops to 3.1 (employee sentiment)         │
│  └── 🏛️ Oracle awarded Vic Health tender (government source)       │
│                                                                      │
│  [View All Intel (12)]                                              │
└─────────────────────────────────────────────────────────────────────┘
```

### Competitor Dossier (Full View)

The dossier combines **static product assets** with **live intelligence**:

```
┌─────────────────────────────────────────────────────────────────────┐
│  ⚔️ Competitor Dossier: Oracle Health                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  OVERVIEW (from competitors table)                                  │
│  Headquarters: Austin, TX │ Employees: ~30,000 │ APAC Presence: Yes │
│  Key Products: Oracle Health EHR, Cerner Millennium, Analytics      │
│                                                                      │
│  AT THIS ACCOUNT (from account_competitors + live mentions)         │
│  ├── Status: Actively Evaluating                                    │
│  ├── First detected: Nov 2025 (meeting mention)                     │
│  ├── Products in play: Analytics, Radiology                         │
│  ├── Key contact using them: CFO (pricing comparison requested)     │
│  └── Threat level: 🔴 High                                          │
│                                                                      │
│  OUR TRACK RECORD (from competitive_outcomes)                       │
│  ├── Overall: 12W - 4L (75%)                                        │
│  ├── Analytics deals: 5W - 1L (83%)                                 │
│  ├── Last win: St Vincent's Analytics ($200K) - Oct 2025            │
│  └── Last loss: WA Health Radiology ($180K) - Dec 2025              │
│                                                                      │
│  WHY WE WIN / LOSE (from competitive_outcomes.win_reasons/loss_reasons)
│  WHY WE WIN                          WHY WE LOSE                    │
│  ├── Local support team              ├── Price perception           │
│  ├── Integration flexibility         ├── Brand recognition          │
│  ├── Healthcare-specific focus       └── Bundled deals              │
│  └── Faster implementation                                          │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  📋 BATTLECARD (from product_catalog.competitive_analysis — STATIC) │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ vs Oracle Analytics:                                            ││
│  │ "Their analytics requires Cerner backend. Ours works with any   ││
│  │ EMR. Client can keep Epic and add our analytics layer."         ││
│  │                                                                  ││
│  │ Objection: "Oracle is the industry standard"                    ││
│  │ Response: "In APAC, local support and faster implementation     ││
│  │ matter more. See St Vincent's case study."                      ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  📰 LIVE MARKET INTEL (from competitive_intel — DYNAMIC)            │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  ├── 🏆 Won $2M WA Health deal (3 days ago) [AusTender]            │
│  ├── 💼 Hiring APAC sales team - 15 roles [LinkedIn Jobs]          │
│  ├── 📊 Q3 earnings: Healthcare up 12% YoY [Financial Filing]      │
│  ├── ⚠️ Outage reported in US (2 hours, Jan 18) [News RSS]         │
│  └── 💬 Mentioned by Barwon CFO (Jan 22) [Meeting Transcript]      │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  🤖 CHASEN INSIGHT (AI-generated from static + live)                │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│  "Oracle is actively competing for Barwon's Analytics deal. Their   │
│  recent WA Health win gives them momentum, but that deal was        │
│  greenfield — Barwon already has Epic. Use our EMR-agnostic        │
│  advantage (from battlecard) and reference the St Vincent's win.    │
│  Note: Oracle's US outage is a fresh proof point for our local     │
│  support SLA advantage."                                            │
│                                                                      │
│  [Export Dossier]  [Share with Team]  [Add Note]  [Edit Battlecard] │
└─────────────────────────────────────────────────────────────────────┘
```

**Data Source Mapping:**

| Section | Source | Type |
|---------|--------|------|
| Overview | `competitors` table | Static |
| At This Account | `account_competitors` + `unified_meetings` | Mixed |
| Track Record | `competitive_outcomes` | Internal |
| Battlecard | `product_catalog.competitive_analysis` | Static |
| Live Intel | `competitive_intel` (news, tenders, LinkedIn, etc.) | Dynamic |
| ChaSen Insight | AI combining all sources | Generated |

### Competitive Intelligence Schema

```sql
-- Global competitor registry
CREATE TABLE competitors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  aliases TEXT[] DEFAULT '{}',
  website TEXT,
  hq_location TEXT,
  employee_count INTEGER,
  products TEXT[],
  strengths TEXT[],
  weaknesses TEXT[],
  logo_url TEXT,
  last_intel_update TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Per-account competitive presence
CREATE TABLE account_competitors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES clients(id),
  competitor_id UUID REFERENCES competitors(id),
  status TEXT CHECK (status IN ('incumbent', 'evaluating', 'displaced', 'rumoured', 'unknown')),
  products_in_use TEXT[],
  contract_end_date DATE,
  threat_level TEXT CHECK (threat_level IN ('high', 'medium', 'low')),
  threat_rationale TEXT,
  first_detected_at TIMESTAMPTZ,
  last_activity_at TIMESTAMPTZ,
  source TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(client_id, competitor_id)
);

-- Win/loss tracking
CREATE TABLE competitive_outcomes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES clients(id),
  competitor_id UUID REFERENCES competitors(id),
  outcome TEXT CHECK (outcome IN ('won', 'lost', 'no_decision', 'displaced')),
  outcome_date DATE,
  deal_value DECIMAL(12,2),
  products_involved TEXT[],
  win_reasons TEXT[],
  loss_reasons TEXT[],
  lessons_learned TEXT,
  source_opportunity_id UUID,
  recorded_by TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Raw intelligence from sources
CREATE TABLE competitive_intel (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  competitor_id UUID REFERENCES competitors(id),
  client_id UUID REFERENCES clients(id),
  source_type TEXT CHECK (source_type IN (
    'news', 'tender', 'press_release', 'linkedin_company',
    'linkedin_person', 'job_posting', 'glassdoor', 'financial_filing',
    'meeting_mention', 'nps_mention', 'manual'
  )),
  source_url TEXT,
  title TEXT,
  content TEXT,
  summary TEXT,
  intel_type TEXT CHECK (intel_type IN (
    'win', 'loss', 'product_launch', 'outage', 'leadership_change',
    'partnership', 'acquisition', 'hiring_signal', 'sentiment', 'general'
  )),
  relevance_score INTEGER,
  published_at TIMESTAMPTZ,
  captured_at TIMESTAMPTZ DEFAULT NOW(),
  reviewed BOOLEAN DEFAULT FALSE,
  reviewed_by TEXT
);

CREATE INDEX idx_intel_competitor ON competitive_intel(competitor_id, captured_at DESC);
CREATE INDEX idx_intel_client ON competitive_intel(client_id, captured_at DESC);
CREATE INDEX idx_account_competitors ON account_competitors(client_id);
```

### File Structure

```
src/components/planning/competitive/
├── CompetitivePanel.tsx           # Collapsible panel for all steps
├── CompetitorCard.tsx             # Single competitor summary
├── CompetitorDossier.tsx          # Full competitor profile modal
├── CompetitiveRiskCard.tsx        # Risk card with competitor context
├── IntelFeed.tsx                  # Recent intelligence stream
├── BattlecardViewer.tsx           # Positioning playbook display
└── WinLossAnalysis.tsx            # Track record visualisation

src/app/api/competitive/
├── competitors/route.ts           # CRUD for competitor registry
├── account/[clientId]/route.ts    # Competitors at specific account
├── intel/route.ts                 # Intelligence feed
├── outcomes/route.ts              # Win/loss recording
└── dossier/[competitorId]/route.ts # Full competitor dossier

src/lib/competitive-intelligence/
├── news-enricher.ts               # Tag news with competitor mentions
├── tender-analyzer.ts             # Extract competitor wins from tenders
├── linkedin-fetcher.ts            # Company/people tracking
├── glassdoor-fetcher.ts           # Employee sentiment
└── job-posting-analyzer.ts        # Hiring signals
```

### Implementation: Competitive Intelligence

```
Phase 5: Competitive Intelligence (2-3 weeks)
- [ ] Create competitor registry tables
- [ ] Build CompetitivePanel component (collapsible, all steps)
- [ ] Implement CompetitorDossier modal with full profile
- [ ] Add competitor tagging to existing news intelligence
- [ ] Build win/loss recording UI in opportunities
- [ ] Create battlecard management system
- [ ] Integrate competitor mentions from meeting transcripts
- [ ] Add threat level indicators to account summaries
- [ ] Build competitive risk auto-detection for Step 4
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
  risks_data JSONB DEFAULT '[]',         -- Risk assessment
  actions_data JSONB DEFAULT '[]',       -- Action plans
  value_data JSONB DEFAULT '{}',         -- Outcomes & value realisation

  -- Sales Targets & Pipeline (JSONB)
  targets_data JSONB DEFAULT '{}',       -- Quota, committed, gap, coverage
  /*
    targets_data schema:
    {
      "quota": 2500000,
      "committed": 1200000,
      "gap": 500000,
      "coverage_ratio": 2.4,
      "target_coverage": 3.0,
      "by_client": [
        { "client_id": "uuid", "arr_target": 500000, "current_arr": 400000 }
      ]
    }
  */
  opportunities_data JSONB DEFAULT '[]', -- Pipeline opportunities
  /*
    opportunities_data schema:
    [
      {
        "id": "uuid",
        "name": "EMR Upgrade",
        "client_id": "uuid",
        "value": 250000,
        "stage": "proposal",
        "probability": 65,
        "close_date": "2026-03-15",
        "meddpicc_score": 28,
        "meddpicc_details": { "M": 4, "E": 3, ... },
        "products": ["product_uuid"],
        "stakeholders": ["stakeholder_uuid"],
        "ai_suggestions": ["string"],
        "created_at": "timestamp",
        "updated_at": "timestamp"
      }
    ]
  */
  forecast_data JSONB DEFAULT '{}',      -- Calculated forecast snapshots
  /*
    forecast_data schema:
    {
      "weighted_forecast": 800000,
      "best_case": 1500000,
      "likely_case": 1000000,
      "worst_case": 600000,
      "last_calculated": "timestamp",
      "history": [
        { "date": "2026-01-15", "forecast": 750000 }
      ]
    }
  */

  -- Sales Methodology Data (JSONB)
  methodology_data JSONB DEFAULT '{}',   -- A.C.T.I.O.N. Framework progress
  checkpoints_data JSONB DEFAULT '[]',   -- Voss conversation checkpoints
  hero_journey_data JSONB DEFAULT '{}',  -- StoryBrand client transformation
  meddpicc_data JSONB DEFAULT '{}',      -- MEDDPICC scores with evidence
  gap_analysis_data JSONB DEFAULT '{}',  -- Current→Future state analysis
  story_matrix_data JSONB DEFAULT '[]',  -- Wortmann reference stories

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

## Groundbreaking UI/UX Features

### Revolutionary Wizard Experience

#### Spatial Navigation with Context Persistence

Instead of a traditional linear stepper, a **spatial/orbital interface** where all 5 steps exist as interconnected nodes visible simultaneously. This mirrors how strategists actually think—hopping between context and actions, not linearly.

| Feature | Description |
|---------|-------------|
| **Minimap Navigation** | Persistent mini-view showing all steps as connected nodes. Click any node to jump directly. Current position pulses. Incomplete sections show warning indicators. |
| **Split-Screen Continuity** | When editing Step 4 (Risks), pin Step 2 (Portfolio) data to a sidebar. No more "let me go back to check that figure." |
| **Semantic Breadcrumbs** | Instead of "Step 1 → Step 2", show: "Barwon Health → $2.5M Target → 3 Opportunities → 2 Risks". Users see their story, not just position. |
| **Gesture-Based Transitions** | Swipe between steps on touch devices. Keyboard shortcuts (Ctrl+1-5) for power users. Transitions animate data relationships. |
| **Smart Step Skipping** | If ChaSen detects no risks worth documenting, allow skipping: "No risks detected. Skip to Review?" |

#### Immersive Interactions

| Feature | Description |
|---------|-------------|
| **Live Data Pulse** | Numbers that update in real-time pulse briefly when they change. When you add an opportunity, watch the coverage bar animate upward. |
| **Drag-to-Prioritise** | Drag opportunities vertically to reorder by priority. Drag risks to reorder severity. Physical interaction creates ownership. |
| **Inline Expansion** | Click any metric to expand context without leaving the step. Click "$2.5M ARR" and see the breakdown inline. |
| **Progress Celebration** | Subtle confetti on step completion. More substantial celebration on plan submission. Gamification without being childish. |
| **Undo Timeline** | Timeline scrubber at bottom showing all changes in session. Drag backward to undo multiple steps at once. |
| **Keyboard-First Design** | Every action achievable without mouse. Tab navigation with visible focus rings. Shortcuts displayed on hover. |
| **Reduced Motion Mode** | Respects `prefers-reduced-motion`. All animations become instant transitions. |

### Responsive Design - Complete Device Matrix

#### Breakpoint Strategy

| Device Category | Resolution | CSS Width | Layout Approach |
|-----------------|------------|-----------|-----------------|
| **5K Ultra-wide** | 5120×2160 | 5120px | 5-panel workspace, mission control view |
| **Super Ultra-wide** | 3440×1440 | 3440px | 4-panel with generous spacing |
| **Scaled Ultra-wide** | 3360×1418, 3328×1404 | ~3350px | 4-panel workspace, comfortable density |
| **Standard Ultra-wide** | 2560×1080/1440 | 2560px | 3-column + floating panels |
| **Wide Monitor** | 1920×1080/1200 | 1920px | 3-column layout |
| **16" Laptop** | 1728×1117 (scaled) | 1536-1728px | 2-column + overlay panels |
| **14" Laptop** | 1512×982 (scaled) | 1280-1535px | 2-column, compact |
| **iPad Pro/Air** | 1024-1279px | 1024-1279px | Touch-optimised 2-column |
| **iPad Mini** | 768-1023px | 768-1023px | Single column, bottom nav |
| **Phone (Pro Max/Galaxy Note)** | 428-767px | 428-767px | Mobile stack, bottom sheets |
| **Phone (Standard)** | 320-427px | 320-427px | Compact mobile |

#### 5K Ultra-wide (5120px) - "Mission Control"

```
┌──────────┬────────────┬──────────────────────────┬─────────────┬─────────────┐
│ Client   │ Step Nav   │      Main Content        │  ChaSen AI  │  Activity   │
│ List     │ + Minimap  │      (~2000px+)          │   Panel     │   Feed      │
│ (300px)  │ (250px)    │                          │  (450px)    │  (350px)    │
└──────────┴────────────┴──────────────────────────┴─────────────┴─────────────┘
```

- **Multi-Plan View**: Display 3 client plans side-by-side for territory reviews
- **Persistent Dashboards**: Pin live charts while working on plan details

#### Scaled Ultra-wide (3360×1418 / 3328×1404)

```
┌──────────┬──────────────────────────────┬─────────────┬─────────────┐
│ Nav Rail │        Main Content          │  ChaSen AI  │  Context    │
│ (200px)  │        (~1800px)             │   (400px)   │  (350px)    │
└──────────┴──────────────────────────────┴─────────────┴─────────────┘
```

- **Picture-in-Picture**: Drag any chart into floating PiP window
- **Zen Mode**: Double-click main content to expand full-width, hiding sidebars

#### 14"/16" Laptop Features

- **Adaptive Sidebar**: ChaSen collapses to floating button on 14". Stays pinned on 16" if preferred
- **Keyboard-Centric**: `Cmd+K` command palette, `Cmd+1-5` steps, `Cmd+N` new opportunity
- **Trackpad Gestures**: Two-finger swipe between steps, pinch to zoom visualisations

#### Mobile Features (iPhone/Android)

- **Bottom Navigation Bar**: 5 steps as persistent bottom nav, thumb-reachable
- **Sheet-Based Interactions**: Adding opportunity opens bottom sheet, dismissed with swipe-down
- **Card Stacks**: Swipeable opportunity cards—swipe right to prioritise, left to archive
- **Collapsible Sections**: Start collapsed with summary, tap to expand

#### Tablet Features (iPad)

- **Split View Support**: Works in 50/50 or 70/30 split alongside email/calendar
- **Apple Pencil**: Handwritten notes that convert to text, sketch stakeholder maps
- **Landscape/Portrait**: Automatic layout adaptation

#### Cross-Device Features

- **Layout Memory**: System remembers preferred layout per device
- **State Sync**: Start on desktop, continue on iPad, finish on phone via Supabase Realtime
- **Offline Mode**: Cache current plan for offline editing, sync with conflict resolution

---

## ChaSen AI Integration - Advanced Features

### From Reactive to Proactive Intelligence

| Feature | Description |
|---------|-------------|
| **Ambient Intelligence** | ChaSen watches cursor/scroll position. Hovering over low MEDDPICC score? Surfaces suggestions without prompt. |
| **Predictive Field Population** | As you type "Barwon EMR...", auto-suggests Value, Close Date, Products. Accept with Tab. |
| **Confidence Indicators** | Every suggestion shows confidence: "87% confidence based on 4 similar deals" vs "42% confidence—limited data" |
| **"Why This?" Explainability** | Click any suggestion to see full reasoning chain. Complete transparency. |
| **Learning from Dismissals** | When dismissing suggestions, optional feedback improves future recommendations. |

### Multi-Modal Interaction

| Feature | Description |
|---------|-------------|
| **Voice Input** | Tap-and-hold to dictate: "Add a risk for Barwon Health—CFO retiring next quarter." |
| **Screenshot Intelligence** | Paste competitor pricing screenshot. ChaSen extracts and adds to competitive intelligence. |
| **Document Ingestion** | Drag PDF (RFP, contract). ChaSen extracts requirements → opportunities, names → stakeholders, dates → timeline. |

### Contextual Conversation Threading

| Feature | Description |
|---------|-------------|
| **Per-Entity Chat** | Each opportunity, risk, stakeholder has its own ChaSen thread with preserved context. |
| **Cross-Reference Detection** | Mention "Sarah" in a risk, ChaSen links: "Is this Sarah Chen, CFO at Barwon Health?" |
| **Meeting Prep Mode** | "Prep me for tomorrow's Barwon QBR" → talking points, NPS themes, open actions, Voss techniques. |

### Proactive Nudges

| Feature | Description |
|---------|-------------|
| **Timing-Aware** | "You have a Barwon meeting in 2 hours—their support health dropped yesterday. Want talking points?" |
| **Threshold Alerts** | Set personal thresholds: "Alert when NPS < +20" or "Notify when coverage < 2.5x" |
| **Weekly Digest** | Monday briefing: renewals approaching, stalled opportunities, suggested priorities. |

### Predictive Simulation Engine

| Feature | Description |
|---------|-------------|
| **"What If" Modelling** | "What happens if we lose Barwon Health?" → ARR impact, coverage drop, cascading risks visualised as decision tree. |
| **Monte Carlo Forecasting** | 10,000 simulations → "73% probability of hitting quota. 90% confidence range: $2.1M - $2.8M." |
| **Optimal Path Recommendation** | "To hit $3M: Close Barwon EMR (highest MEDDPICC), accelerate GHA Analytics, add 2 whitespace opportunities. 68% success probability." |

### Multi-Agent AI Orchestra

```
                    ┌─────────────────────────────────────┐
                    │           ChaSen (Coordinator)       │
                    └─────────────────────────────────────┘
                                      │
          ┌───────────────┬───────────┼───────────┬───────────────┐
          ▼               ▼           ▼           ▼               ▼
    ┌──────────┐   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
    │  Scout   │   │ Analyst  │ │  Coach   │ │  Scribe  │ │ Guardian │
    │ (Intel)  │   │ (Numbers)│ │(Tactics) │ │(Summaries│ │ (Privacy)│
    └──────────┘   └──────────┘ └──────────┘ └──────────┘ └──────────┘
```

- **Scout**: Monitors news, tenders, LinkedIn for intel
- **Analyst**: Crunches numbers, spots trends, validates forecasts
- **Coach**: Suggests Voss/Gap Selling techniques contextually
- **Scribe**: Auto-generates summaries, executive briefs, handoff notes
- **Guardian**: Ensures privacy compliance, audit trails

### Generative Strategy

| Feature | Description |
|---------|-------------|
| **Auto-Generate Plan Draft** | One click: "Generate Q2 plan for my territory." Complete first draft from data. |
| **Competitive War Room** | "Build battlecard for Oracle Health" → weaknesses, our strengths, displacement playbook, pricing intel. |
| **Deal Autopsy** | Post-loss analysis: contributing factors, comparison to successful deals, lessons learned. |

### Natural Language Actions

```
User: "Move the Barwon EMR close date to April"
ChaSen: ✓ Updated close date to April 2026

User: "Why is WA Health health score dropping?"
ChaSen: Support tickets up 40% (5 P1s), NPS mentioned 'response times',
        no CSE meeting in 45 days. Suggested: Schedule support review call.

User: "Show me all stalled deals across my territory"
ChaSen: [Displays filtered view of 4 opportunities stalled >30 days]
```

### Temporal Intelligence

| Feature | Description |
|---------|-------------|
| **Time-Travel View** | "Show me this plan 90 days ago." Compare past vs present, see what changed. |
| **Future State Projection** | "Show me this territory in 6 months if trends continue." Animated timeline. |
| **Pattern Recognition** | "Deals stalling in Proposal >30 days have 23% win rate vs 67% for <14 days. Barwon at day 28. Recommend intervention." |

### Real-Time Meeting Intelligence

| Feature | Description |
|---------|-------------|
| **Live Call Co-Pilot** | During Teams/Zoom, private sidebar shows: sentiment analysis, suggested responses, live fact-checking. |
| **Talk Ratio Monitor** | Live indicator of you vs client talk time. Alert when exceeding 60%. |
| **Commitment Tracker** | Detects verbal commitments: "Client said 'review by Friday.' Capture as action?" |

### Relationship Graph Intelligence

| Feature | Description |
|---------|-------------|
| **Influence Network Mapping** | AI-generated org chart showing who influences whom based on meeting patterns. |
| **Relationship Decay Alerts** | "Your relationship with Barwon CIO is cooling: No 1:1 in 60 days, excluded from meetings." |
| **Six Degrees Connection** | "Warm introduction path to new CEO identified through 2 intermediaries." |
| **Political Risk Mapping** | Detect internal politics: "Sarah and David have opposing views. Separate alignment sessions suggested." |

### Autonomous Agent Actions

| Feature | Description |
|---------|-------------|
| **Auto-Draft Communications** | "Draft follow-up email to Sarah" → Generated in your historical tone and style. |
| **Calendar Intelligence** | "Find time for Barwon QBR" → Checks calendars, suggests optimal slots, drafts invite. |
| **Auto-Escalation Triggers** | Rules-based: "If Giant client health < 40, auto-notify manager with briefing." |
| **Delegated Research** | "Research Barwon's strategic initiatives" → ChaSen compiles briefing asynchronously. |

### Emotional & Behavioural Intelligence

| Feature | Description |
|---------|-------------|
| **Sentiment Trajectory** | Track emotional tone across touchpoints: enthusiastic → frustrated → disengaged. |
| **Communication Style Matching** | "Sarah prefers data-heavy formal. David likes brief casual. Tailoring accordingly." |
| **Stress Detection** | Detect when stakeholders are under pressure from communication pattern changes. |

### Gamification & Motivation

| Badge | Criteria |
|-------|----------|
| **Pipeline Pro** | Maintained 3x coverage for 90 days |
| **Relationship Builder** | Multi-threaded across 5+ stakeholders |
| **Fortune Teller** | 80% forecast accuracy over 4 quarters |
| **Comeback Kid** | Rescued 3 at-risk accounts |
| **Methodology Master** | Applied all 6 A.C.T.I.O.N. stages in single deal |

- **Streak Tracking**: "12 consecutive weeks of plan updates. Keep the streak!"
- **Progress Celebrations**: Deal closure celebrated with quota progress update

### Collaborative Intelligence

| Feature | Description |
|---------|-------------|
| **Team Pattern Learning** | "CSEs who log notes within 24 hours have 34% higher health scores. You're averaging 3.2 days." |
| **Cross-Territory Insights** | "Sarah in ANZ closed similar deal with this tactic. Connect with Sarah?" (Opt-in sharing) |
| **Institutional Memory** | When CSE leaves, ChaSen preserves all context. New CSE gets "Everything about Barwon in 5 minutes." |

### Privacy-Preserving Intelligence

| Feature | Description |
|---------|-------------|
| **On-Device Processing** | Sensitive calculations run locally. Client names never leave device. |
| **Explainable Audit Trail** | Every AI decision logged with full reasoning chain. Compliance-friendly. |
| **Consent-Based Intelligence** | Clients opt into shared insights programs for improved recommendations. |

---

## Experimental Features - High Risk, Massive Payoff

> **⚠️ Innovation Tier**: These features represent cutting-edge capabilities that push beyond current industry standards. They require significant R&D investment but offer transformational competitive advantages.

### Digital Twin Simulation

Create AI-powered simulations of client organisations for practice, prediction, and strategy testing.

#### Client Organisation Digital Twin

AI creates a simulated version of the client organisation based on:
- Historical meeting transcripts and communication patterns
- Stakeholder personality profiles from interaction data
- Industry benchmarks and typical decision-making patterns
- Known organisational structure and politics

**Use Cases:**
```
┌─────────────────────────────────────────────────────────────────────┐
│  🧬 Digital Twin: Barwon Health                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Simulated Stakeholders:                                            │
│  ├── Sarah Chen (CFO) - Risk-averse, data-driven, budget-focused   │
│  ├── David Wong (CIO) - Innovation champion, politically savvy     │
│  └── James Miller (CEO) - Big-picture thinker, legacy concerns     │
│                                                                      │
│  [Run Simulation: "Propose 15% price increase"]                     │
│                                                                      │
│  Predicted Response:                                                │
│  • Sarah: "Need ROI justification. Will push back on timing."      │
│  • David: "Open if tied to new capabilities. Ally potential."      │
│  • James: "Concerned about board optics. Needs industry context."  │
│                                                                      │
│  Recommended Approach: Lead with David, build coalition, present   │
│  to Sarah with ROI model, escalate to James only if needed.        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Deal Negotiation Sandbox

Practice difficult conversations before real meetings:

| Scenario | Simulation |
|----------|------------|
| **Pricing Objection** | "Simulate Sarah pushing back on 10% increase" |
| **Competitive Threat** | "Simulate David mentioning Oracle evaluation" |
| **Executive Escalation** | "Simulate presenting renewal risk to James" |
| **Multi-Stakeholder** | "Simulate joint meeting with conflicting priorities" |

**Feedback Provided:**
- Talk ratio analysis (did you listen enough?)
- Voss technique usage (did you mirror, label, use calibrated questions?)
- Missed opportunities (where could you have probed deeper?)
- Alternative approaches (here's how a top performer would handle this)

#### Territory Digital Twin

Simulate entire territory 12 months forward under different strategies:

```
Strategy A: Focus 80% on Giant clients
├── Projected ARR: $4.2M (+18%)
├── Risk: 3 Medium clients likely to churn from neglect
└── Confidence: 72%

Strategy B: Balanced distribution
├── Projected ARR: $3.8M (+12%)
├── Risk: Giant clients may feel under-served
└── Confidence: 81%

Strategy C: Aggressive expansion focus
├── Projected ARR: $4.8M (+28%)
├── Risk: Existing client health drops, higher churn
└── Confidence: 54%

ChaSen Recommendation: Strategy A with mitigation—automate Medium
client touchpoints to maintain baseline engagement.
```

### Autonomous Prospecting

ChaSen identifies, qualifies, and nurtures prospects autonomously.

#### Whitespace Identification Engine

```
┌─────────────────────────────────────────────────────────────────────┐
│  🎯 Autonomous Prospecting Pipeline                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Stage 1: IDENTIFY (Fully Autonomous)                               │
│  ├── Scan news for healthcare IT initiatives                        │
│  ├── Monitor tender portals for relevant RFPs                       │
│  ├── Analyse NPS/meeting data for expansion signals                 │
│  └── Cross-reference product gaps with client needs                 │
│                                                                      │
│  Stage 2: QUALIFY (Fully Autonomous)                                │
│  ├── Score opportunity against ICP (Ideal Customer Profile)        │
│  ├── Estimate deal size from similar wins                          │
│  ├── Assess timing based on budget cycles                          │
│  └── Identify entry point stakeholders                              │
│                                                                      │
│  Stage 3: OUTREACH (Autonomous with Templates)                      │
│  ├── Generate personalised email/LinkedIn message                   │
│  ├── Send via approved channels (CSE CC'd)                         │
│  ├── Follow up based on engagement signals                         │
│  └── Book discovery call when interest detected                     │
│                                                                      │
│  Stage 4: HANDOFF (Human Takes Over)                                │
│  ├── CSE joins discovery call with full context briefing           │
│  ├── All autonomous activity logged and visible                    │
│  └── Qualification notes and suggested approach provided           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Autonomous Actions Available

| Action | Trigger | Human Oversight |
|--------|---------|-----------------|
| Send initial outreach | Qualified prospect identified | Template approval, CC on all |
| Follow-up email (1) | No response in 5 days | Auto-send, CSE notified |
| Follow-up email (2) | No response in 12 days | Auto-send, CSE notified |
| Book discovery call | Positive response detected | CSE confirms availability |
| Add to nurture sequence | Not ready to engage | Auto-enrol, quarterly review |
| Create opportunity | Discovery call completed | CSE reviews and approves |

### Predictive Neuroscience Features

#### Optimal Timing Prediction

AI analyses stakeholder behaviour patterns to predict ideal engagement windows:

```
┌─────────────────────────────────────────────────────────────────────┐
│  ⏰ Optimal Timing: Sarah Chen (CFO, Barwon Health)                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Email Response Patterns:                                           │
│  ├── Peak responsiveness: Tuesday 10:00-11:30 AEST                 │
│  ├── Secondary window: Thursday 14:00-15:30 AEST                   │
│  ├── Avoid: Monday mornings (backlog clearing)                      │
│  └── Avoid: Friday afternoons (early sign-off pattern)             │
│                                                                      │
│  Meeting Engagement Patterns:                                       │
│  ├── Most engaged: Mid-week, pre-lunch slots                       │
│  ├── Decision-making: More likely to commit in PM meetings         │
│  └── Attention span: Drops after 45 minutes in video calls         │
│                                                                      │
│  Calendar Intelligence:                                             │
│  ├── Board meetings: Last Thursday of month (avoid week before)    │
│  ├── Budget cycle: Reviews in March, September (pitch before)      │
│  └── Holiday patterns: Usually offline last 2 weeks December       │
│                                                                      │
│  [Schedule Proposal Delivery] → Suggested: Tue 10 Feb, 10:15 AEST  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Biometric Feedback Integration

Integration with wearables (Apple Watch, Fitbit, Garmin) for real-time physiological insights:

| Signal | Detection | Intervention |
|--------|-----------|--------------|
| **Elevated heart rate** | Stress during call | "Take a breath. Pause before responding." |
| **Voice stress analysis** | Tension in your voice | "Your tone is rising. Try lowering pitch." |
| **Client voice analysis** | Uncertainty detected | "They sound hesitant. Probe with 'What concerns you most?'" |
| **Fatigue patterns** | HRV indicating tiredness | "Cognitive performance declining. Consider rescheduling complex discussion." |
| **Optimal state detected** | In flow state | "You're performing well. Good time for difficult conversations." |

**Privacy Controls:**
- All biometric data processed on-device only
- No biometric data stored or transmitted
- User can disable at any time
- Coaching suggestions are optional

#### Cognitive Load Monitoring

Track mental capacity to optimise performance:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🧠 Cognitive Load Monitor                                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Today's Cognitive Budget: ████████░░░░░░░░ 52% remaining          │
│                                                                      │
│  Activities Logged:                                                  │
│  ├── 09:00-10:30  Complex negotiation (Barwon)     -25% ██████      │
│  ├── 10:30-11:00  Admin/email                       -5% █           │
│  ├── 11:00-12:00  Discovery call (new prospect)   -12% ███         │
│  └── 12:00-13:00  Lunch break                      +8% ██ (recovery)│
│                                                                      │
│  Upcoming:                                                          │
│  ├── 14:00  Territory review with manager          Est: -15%       │
│  └── 15:30  Proposal presentation (WA Health)      Est: -20%       │
│                                                                      │
│  ⚠️  Warning: WA Health presentation is high-stakes.               │
│      Current trajectory: 17% cognitive capacity remaining.          │
│      Suggestion: Reschedule to tomorrow AM or take 30-min break.   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Network Intelligence

#### Industry Movement Tracking

Track key stakeholders across company changes:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🔄 Industry Movement Alert                                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Sarah Chen has changed roles                                       │
│                                                                      │
│  Previous: CFO, Barwon Health (Your Champion - 3 years)            │
│  New: CEO, Metro Health (Not currently Altera client)              │
│  Effective: 1 March 2026                                            │
│                                                                      │
│  Implications:                                                       │
│  ├── Barwon Health: Champion risk - identify successor             │
│  └── Metro Health: Warm introduction opportunity                    │
│                                                                      │
│  Suggested Actions:                                                  │
│  1. Schedule farewell/congratulations call with Sarah               │
│  2. Ask Sarah for introduction to her successor at Barwon          │
│  3. Discuss Altera opportunities at Metro Health                    │
│  4. Add Metro Health to prospecting pipeline                        │
│                                                                      │
│  [Create Actions] [Schedule Call] [Add to Pipeline]                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Tracking Sources:**
- LinkedIn profile changes (with consent)
- News announcements
- Company press releases
- Industry publication mentions
- Conference speaker lists

#### Predictive Industry Trends

Aggregate signals across all clients to predict market movements:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📊 ANZ Healthcare IT Trend Forecast (FY27)                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Based on: 47 client meetings, 23 tender analyses, 156 news items  │
│                                                                      │
│  Emerging Priorities:                                                │
│  ┌──────────────────────────────────────┬────────────┬────────────┐ │
│  │ Trend                                │ Confidence │ Timing     │ │
│  ├──────────────────────────────────────┼────────────┼────────────┤ │
│  │ Mobile-first patient engagement      │ 87%        │ Q1-Q2 FY27 │ │
│  │ AI-assisted clinical documentation   │ 76%        │ Q2-Q3 FY27 │ │
│  │ Interoperability compliance push     │ 91%        │ Q1 FY27    │ │
│  │ Cybersecurity infrastructure upgrade │ 82%        │ Ongoing    │ │
│  │ Cloud migration acceleration         │ 68%        │ Q3-Q4 FY27 │ │
│  └──────────────────────────────────────┴────────────┴────────────┘ │
│                                                                      │
│  Budget Indicators:                                                  │
│  ├── 67% of clients mentioned increased IT budgets for FY27        │
│  ├── Average expected increase: 12-18%                             │
│  └── Primary driver: Government digital health incentives          │
│                                                                      │
│  Competitive Landscape Shifts:                                       │
│  ├── Oracle Health: Aggressive pricing in public sector            │
│  ├── Epic: Expanding ANZ presence, hired 3 local executives        │
│  └── Cerner: Reduced activity, possible market exit signals        │
│                                                                      │
│  Recommended Portfolio Positioning:                                  │
│  "Prioritise mobile health and interoperability messaging.          │
│   Develop AI documentation story for Q2. Prepare competitive        │
│   response to Oracle's public sector push."                         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Privacy-First AI Innovation

#### Federated Learning Across Clients

AI improves from patterns across all Altera clients without any data leaving client environments:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🔒 Federated Learning Architecture                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐            │
│  │ Barwon  │   │  GHA    │   │SA Health│   │ WA DOH  │            │
│  │  Data   │   │  Data   │   │  Data   │   │  Data   │            │
│  └────┬────┘   └────┬────┘   └────┬────┘   └────┬────┘            │
│       │             │             │             │                   │
│       ▼             ▼             ▼             ▼                   │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐            │
│  │ Local   │   │ Local   │   │ Local   │   │ Local   │            │
│  │ Model   │   │ Model   │   │ Model   │   │ Model   │            │
│  └────┬────┘   └────┬────┘   └────┬────┘   └────┬────┘            │
│       │             │             │             │                   │
│       └─────────────┴──────┬──────┴─────────────┘                   │
│                            │                                        │
│                    ┌───────▼───────┐                                │
│                    │   Aggregate   │  Only model weights shared,   │
│                    │   Patterns    │  never raw data               │
│                    │   (No Data)   │                                │
│                    └───────┬───────┘                                │
│                            │                                        │
│                    ┌───────▼───────┐                                │
│                    │   Improved    │                                │
│                    │   Global      │                                │
│                    │   Model       │                                │
│                    └───────────────┘                                │
│                                                                      │
│  Learnings (examples):                                              │
│  • "Deals with 3+ stakeholder touchpoints close 2.3x faster"       │
│  • "MEDDPICC score >30 correlates with 78% win rate"               │
│  • "Renewals engaged 90+ days out have 94% retention"              │
│                                                                      │
│  Privacy Guarantee: No client names, deal values, or identifying   │
│  information ever leaves the local environment.                     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Synthetic Training Data

Generate realistic but entirely fictional scenarios for CSE training:

| Training Module | Synthetic Scenario |
|-----------------|-------------------|
| **New CSE Onboarding** | "Synthetic Hospital A" - Behaves like a typical Giant client with complex stakeholder dynamics |
| **Difficult Negotiations** | AI-generated CFO persona trained to push back on pricing |
| **Competitive Displacement** | Simulated scenario where Oracle is incumbent |
| **Crisis Management** | Synthetic support escalation with angry CIO |
| **Executive Engagement** | Practice board presentation with synthetic C-suite |

**Benefits:**
- New hires practice on realistic scenarios without risking real relationships
- Mistakes are learning opportunities, not career risks
- Scenarios can be customised to specific skill gaps
- No real client data exposed during training

### Generative Content Engine

#### AI-Generated Proposals, Tenders & RFIs

One-click generation of complete business documents:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📄 Document Generator                                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Document Type: [Proposal ▼]                                        │
│  ├── Proposal (Sales)                                               │
│  ├── Tender Response                                                │
│  ├── RFI Response                                                   │
│  ├── Statement of Work                                              │
│  ├── Business Case                                                  │
│  └── Executive Summary                                              │
│                                                                      │
│  Client: [Barwon Health ▼]                                          │
│  Opportunity: [EMR Upgrade - $180K ▼]                               │
│                                                                      │
│  [Generate Document]                                                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Generated Proposal Structure:**
1. **Executive Summary** - Auto-generated from opportunity data and client context
2. **Understanding Your Needs** - Pulled from NPS themes, meeting notes, pain points
3. **Proposed Solution** - Matched products with benefits mapped to stated needs
4. **Implementation Approach** - Based on similar successful implementations
5. **Investment Summary** - Pricing with ROI calculations
6. **Case Studies** - Auto-selected relevant references from Story Matrix
7. **Why Altera** - Competitive positioning based on known competitors
8. **Terms & Conditions** - Standard terms with client-specific modifications
9. **Appendices** - Technical specifications, team bios, certifications

**Tender/RFI Response Features:**
- Auto-parse tender documents to extract requirements
- Map requirements to Altera capabilities with compliance matrix
- Flag gaps requiring attention or partner involvement
- Generate pricing schedules from product catalog
- Include mandatory certifications and compliance statements
- Format to tender submission requirements

#### Personalised Video & Voicemail Messages

AI generates personalised multimedia communications:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🎬 Personalised Message Generator                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Message Type: [Video Message ▼]                                    │
│  ├── Video Message (1-2 min)                                        │
│  ├── Voicemail Drop (30-60 sec)                                     │
│  └── Audio Message (for email embed)                                │
│                                                                      │
│  Purpose: [Renewal Reminder ▼]                                      │
│  ├── Renewal Reminder                                               │
│  ├── QBR Invitation                                                 │
│  ├── Thank You / Congratulations                                    │
│  ├── Check-in                                                       │
│  ├── New Feature Announcement                                       │
│  └── Custom Script                                                  │
│                                                                      │
│  Recipients:                                                         │
│  ☑ Sarah Chen (Barwon Health) - Renewal in 45 days                 │
│  ☑ David Wong (GHA) - Renewal in 52 days                           │
│  ☑ James Miller (WA Health) - Renewal in 60 days                   │
│  ☐ Select all 12 upcoming renewals                                  │
│                                                                      │
│  Voice: [Your Recorded Voice ▼]  Avatar: [Your Approved Likeness ▼]│
│                                                                      │
│  [Preview Sample] [Generate All] [Send for Review]                  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**How It Works:**
1. CSE records 5-minute voice sample and approves AI likeness (one-time setup)
2. AI generates personalised script for each recipient using their context
3. Video/audio rendered with natural speech patterns and expressions
4. CSE reviews and approves before sending
5. Delivery tracked with engagement analytics

**Personalisation Elements:**
- Recipient's name and title
- Specific renewal date and contract details
- Recent interaction references ("Great catching up at the QBR last month")
- Relevant achievements ("Congratulations on the go-live")
- Next steps specific to their situation

#### Dynamic Presentation Generation

One-click QBR and presentation decks with Altera branding:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📊 Presentation Generator                                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Template: [Quarterly Business Review ▼]                            │
│  ├── Quarterly Business Review (QBR)                                │
│  ├── Executive Briefing                                             │
│  ├── Renewal Proposal                                               │
│  ├── Product Demo Deck                                              │
│  ├── Implementation Kickoff                                         │
│  └── Annual Review                                                  │
│                                                                      │
│  Client: [Barwon Health ▼]                                          │
│  Period: [Q3 FY26 ▼]                                                │
│                                                                      │
│  Branding: ☑ Altera Corporate  ☐ Co-branded with Client Logo       │
│                                                                      │
│  Include Sections:                                                   │
│  ☑ Relationship Summary & Health Score                              │
│  ☑ Support Performance & SLA Metrics                                │
│  ☑ NPS Trends & Feedback Themes                                     │
│  ☑ Product Usage & Adoption                                         │
│  ☑ Achievements & Value Delivered                                   │
│  ☑ Roadmap & Upcoming Releases                                      │
│  ☑ Recommendations & Next Steps                                     │
│  ☐ Competitive Positioning (if relevant)                            │
│  ☐ Expansion Opportunities                                          │
│                                                                      │
│  [Generate Preview] [Download PPTX] [Open in Google Slides]         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Generated QBR Deck Contents:**
1. **Title Slide** - Altera branding, client logo, meeting date, attendees
2. **Agenda** - Auto-generated from selected sections
3. **Relationship Summary** - Health score, key contacts, engagement timeline
4. **Support Performance** - SLA %, ticket trends, CSAT, response times (charts)
5. **NPS Analysis** - Score trend, promoter/detractor breakdown, key themes
6. **Value Delivered** - Achievements, ROI metrics, success stories
7. **Product Roadmap** - Relevant upcoming features for their stack
8. **Recommendations** - AI-suggested improvements, expansion opportunities
9. **Action Items** - Open actions, agreed next steps with owners
10. **Appendix** - Detailed data tables, technical metrics

**Speaker Notes Auto-Generated:**
- Talking points for each slide
- Anticipated questions and answers
- Transition phrases between sections
- Risk areas to address proactively

### Customer-Visible Planning

#### Transparent Account Plans

Clients can access a read-only view of their strategic plan:

```
┌─────────────────────────────────────────────────────────────────────┐
│  👁️ Customer Portal: Barwon Health                                 │
│  Strategic Partnership View                                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Your Altera Team:                                                  │
│  ├── CSE: Michael Thompson (michael.t@altera.com)                  │
│  ├── CAM: Jennifer Wu (jennifer.w@altera.com)                      │
│  └── Support Lead: David Park (david.p@altera.com)                 │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  📋 Shared Objectives (FY26)                                        │
│  ├── 1. Achieve 98% system uptime (Current: 97.2%)                 │
│  ├── 2. Complete mobile rollout to 500 clinicians (Progress: 340)  │
│  ├── 3. Reduce average ticket resolution to <4 hours (Current: 5.2)│
│  └── 4. Launch patient portal integration (Status: In Planning)    │
│                                                                      │
│  📈 Partnership Health                                               │
│  ├── Overall Health Score: 72/100 (Good)                           │
│  ├── NPS: +34 (Last survey: Nov 2025)                              │
│  ├── Support SLA: 94% (Target: 95%)                                │
│  └── Engagement: 12 meetings in last 90 days                       │
│                                                                      │
│  📅 Upcoming Activities                                              │
│  ├── QBR Meeting: 15 Feb 2026, 10:00 AEST                         │
│  ├── Mobile Training Session: 22 Feb 2026                          │
│  └── Renewal Discussion: March 2026                                 │
│                                                                      │
│  📊 Reports & Resources                                              │
│  ├── [Monthly Support Summary - January 2026]                       │
│  ├── [NPS Detailed Report - Q4 2025]                               │
│  ├── [System Performance Dashboard]                                 │
│  ├── [Product Roadmap - Healthcare Suite]                          │
│  ├── [Training Resources Library]                                   │
│  └── [Submit Feature Request]                                       │
│                                                                      │
│  💬 Direct Communication                                             │
│  ├── [Schedule Meeting with Your CSE]                              │
│  ├── [Submit Support Ticket]                                        │
│  └── [Provide Feedback]                                             │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Customer Portal Features:**

| Section | Contents | Update Frequency |
|---------|----------|------------------|
| **Shared Objectives** | Mutually agreed goals with progress tracking | Real-time |
| **Partnership Health** | Health score, NPS, SLA—transparent metrics | Daily |
| **Activity Calendar** | Upcoming meetings, training, milestones | Real-time |
| **Support Dashboard** | Open tickets, SLA performance, CSAT | Real-time |
| **Reports Library** | Monthly summaries, NPS reports, usage analytics | Monthly |
| **Product Roadmap** | Relevant upcoming features for their products | Quarterly |
| **Training Resources** | Self-service guides, videos, documentation | Ongoing |
| **Communication Tools** | Schedule meetings, submit tickets, feedback | Always available |

**What Customers DON'T See:**
- Internal health score calculations
- Revenue and commercial details
- Risk assessments and churn predictions
- Internal notes and strategy discussions
- Competitive intelligence
- Pricing and negotiation notes

### Performance Transparency

#### Real-Time NPS Correlation

Show CSEs exactly how their actions correlate with NPS outcomes:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📊 Your NPS Impact Analysis                                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Based on your last 12 months of client interactions:               │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Action                          │ NPS When Done │ NPS When Not │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │ Email response <4 hours         │ +45 avg       │ +28 avg      │ │
│  │ Monthly check-in calls          │ +52 avg       │ +31 avg      │ │
│  │ QBR within 2 weeks of schedule  │ +48 avg       │ +35 avg      │ │
│  │ Meeting notes shared same-day   │ +44 avg       │ +38 avg      │ │
│  │ Proactive issue notification    │ +56 avg       │ +29 avg      │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Your Patterns:                                                      │
│  ├── Average email response: 6.2 hours (Target: <4 hours) ⚠️       │
│  ├── Check-in frequency: 85% of clients monthly ✓                  │
│  ├── QBR punctuality: 70% on-time (Target: 90%) ⚠️                 │
│  └── Same-day meeting notes: 45% (Target: 80%) ⚠️                  │
│                                                                      │
│  Estimated NPS Impact of Improvements:                              │
│  "If you improved email response to <4 hours, your portfolio NPS   │
│   would likely increase from +38 to +45 (+7 points)"               │
│                                                                      │
│  Suggested Focus: Email response time (highest impact opportunity) │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Open Book Forecasting

Public forecast accuracy tracking within the organisation:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🎯 Forecast Accuracy Leaderboard - ANZ Region                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Ranking (Last 4 Quarters)                                          │
│  ┌─────┬──────────────────┬───────────┬───────────┬──────────────┐ │
│  │Rank │ CSE/CAM          │ Accuracy  │ Trend     │ Methodology  │ │
│  ├─────┼──────────────────┼───────────┼───────────┼──────────────┤ │
│  │ 1   │ Sarah Thompson   │ 94%       │ ↑ (+3%)   │ Conservative │ │
│  │ 2   │ Michael Chen     │ 91%       │ → (0%)    │ Balanced     │ │
│  │ 3   │ Jennifer Wu      │ 88%       │ ↑ (+5%)   │ Conservative │ │
│  │ 4   │ David Park       │ 85%       │ ↓ (-2%)   │ Aggressive   │ │
│  │ 5   │ Emma Wilson      │ 82%       │ ↑ (+8%)   │ Balanced     │ │
│  └─────┴──────────────────┴───────────┴───────────┴──────────────┘ │
│                                                                      │
│  Your Performance: #3 (88% accuracy)                                │
│                                                                      │
│  Accuracy Breakdown:                                                 │
│  ├── Committed deals: 98% accurate (high confidence)               │
│  ├── Forecast deals: 82% accurate (room for improvement)           │
│  └── Upside deals: 65% accurate (typically over-optimistic)        │
│                                                                      │
│  Insight: "You tend to over-estimate close dates by 3 weeks on     │
│  average. Deals you mark for Q1 often close in Q2."                │
│                                                                      │
│  Calibration Suggestion: "Add 3 weeks to your estimated close      │
│  dates, or use 'Likely Q2' instead of 'Commit Q1' for uncertain."  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Benefits of Open Book Forecasting:**
- Creates accountability for realistic forecasting
- Rewards accuracy over optimism
- Enables peer learning from high performers
- Identifies coaching opportunities
- Improves overall forecast reliability for leadership

---

## Moonshot Features - Transformational Innovation

> **🚀 Innovation Tier: Moonshot** - These features represent 3-5 year horizon capabilities that could fundamentally transform how strategic planning and customer success operates. High investment, potentially industry-defining outcomes.

### Predictive Deal Intelligence

#### Deal Genome Mapping

Every won and lost deal has a unique "genome"—a fingerprint of 200+ attributes that AI analyses to predict outcomes and prescribe interventions.

```
┌─────────────────────────────────────────────────────────────────────┐
│  🧬 Deal Genome Analysis: Barwon EMR Upgrade ($180K)               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Genome Match Analysis (vs 847 historical deals):                   │
│                                                                      │
│  Similar Deals Found: 23                                            │
│  ├── Won: 14 (61%)                                                  │
│  ├── Lost: 9 (39%)                                                  │
│  └── Avg Deal Size: $165K                                           │
│                                                                      │
│  Genome Fingerprint:                                                │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Attribute              │ This Deal │ Won Avg │ Lost Avg │ Risk │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │ Days in Discovery      │ 45        │ 28      │ 52       │ ⚠️   │ │
│  │ Stakeholders engaged   │ 3         │ 5       │ 2        │ ⚠️   │ │
│  │ Exec sponsor access    │ No        │ 78% Yes │ 23% Yes  │ 🔴   │ │
│  │ MEDDPICC score         │ 28        │ 32      │ 24       │ ✓    │ │
│  │ Competitor mentioned   │ Yes       │ 45%     │ 67%      │ ⚠️   │ │
│  │ Champion strength      │ 4/5       │ 4.2     │ 2.8      │ ✓    │ │
│  │ Meeting frequency      │ Bi-weekly │ Weekly  │ Monthly  │ ⚠️   │ │
│  │ Decision timeline      │ 90 days   │ 75 days │ 120 days │ ✓    │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  ⚠️ PATTERN ALERT: 89% similarity to 4 deals you lost              │
│                                                                      │
│  Common Failure Point: Stakeholder engagement dropped in month 2    │
│  Your Current Status: Day 38, engagement declining last 2 weeks     │
│                                                                      │
│  Prescribed Interventions:                                          │
│  1. Request executive sponsor meeting this week (highest impact)    │
│  2. Expand stakeholder map—identify 2 more influencers             │
│  3. Increase meeting cadence to weekly                              │
│  4. Develop competitive counter-positioning                         │
│                                                                      │
│  Predicted Outcome (current trajectory): 42% win probability        │
│  Predicted Outcome (with interventions): 68% win probability        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Genome Attributes Tracked (200+):**

| Category | Example Attributes |
|----------|-------------------|
| **Timing** | Days in each stage, time since last meeting, decision timeline |
| **Engagement** | Meeting frequency, email response time, stakeholder count |
| **Qualification** | MEDDPICC scores, champion strength, economic buyer access |
| **Competitive** | Competitors mentioned, displacement vs greenfield, incumbent strength |
| **Financial** | Deal size, discount requested, payment terms |
| **Relationship** | Prior relationship length, NPS history, support satisfaction |
| **Behavioural** | Response patterns, meeting attendance, document downloads |
| **External** | Industry trends, budget cycles, regulatory changes |

#### Competitor Move Prediction

AI predicts competitor actions before they happen based on observable signals:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🎯 Competitive Threat Prediction                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ⚠️ HIGH PROBABILITY: Oracle Health targeting WA Health            │
│                                                                      │
│  Confidence: 78%                                                    │
│  Predicted Timeframe: Within 6 months                               │
│                                                                      │
│  Evidence Signals:                                                   │
│  ├── Hiring: 3 ANZ sales reps with public sector experience (Q4)   │
│  ├── Job Postings: "Public Health Account Executive - Perth" (Dec) │
│  ├── News: Oracle exec quoted on "ANZ public sector focus" (Nov)   │
│  ├── LinkedIn: 2 Oracle reps connected with WA Health employees    │
│  ├── Events: Oracle sponsoring WA Health IT conference (Feb)       │
│  └── Tender: Oracle pre-qualified for WA Government panel (Oct)    │
│                                                                      │
│  Historical Pattern Match:                                          │
│  "Oracle entered VIC market in 2024 with identical signal pattern. │
│   They won 2 of 5 targeted accounts within 8 months."              │
│                                                                      │
│  Pre-emptive Actions Recommended:                                    │
│  1. Schedule executive relationship meeting with WA Health CIO      │
│  2. Accelerate roadmap discussion for Q2 features they've requested │
│  3. Propose multi-year renewal with incentive (lock in before RFP) │
│  4. Prepare competitive battlecard specific to WA Health context   │
│  5. Identify internal champion to alert us to competitive meetings  │
│                                                                      │
│  [Create Pre-emptive Action Plan] [Set Monitoring Alert]            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Competitor Signals Monitored:**

| Signal Type | Source | Predictive Value |
|-------------|--------|------------------|
| **Hiring Patterns** | LinkedIn, job boards | High - indicates expansion plans |
| **Job Postings** | Seek, LinkedIn, company sites | High - reveals target markets |
| **Executive Statements** | News, earnings calls, conferences | Medium - strategic intent |
| **Event Sponsorship** | Industry conferences, client events | Medium - relationship building |
| **Social Connections** | LinkedIn connections to your clients | High - active prospecting |
| **Tender Activity** | Government panels, RFP responses | High - committed pursuit |
| **Product Launches** | Press releases, analyst reports | Medium - capability gaps closing |
| **Pricing Moves** | Win/loss feedback, market intel | High - competitive pressure |

#### Economic Indicator Integration

Connect macroeconomic signals to account-level strategy:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📈 Economic Intelligence Dashboard                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  🔔 ALERT: Federal Budget Announcement (12 May 2026)               │
│                                                                      │
│  Healthcare IT Impact Analysis:                                     │
│  ├── Digital Health Fund: $2.1B allocated (+15% vs prior year)     │
│  ├── Cybersecurity Mandate: All health orgs must comply by FY28    │
│  ├── Interoperability Standards: New requirements effective Jul 27 │
│  └── Regional Health Investment: $450M for rural telehealth        │
│                                                                      │
│  Your Portfolio Impact:                                              │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Client          │ Likely Impact │ Opportunity │ Action Window │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │ WA Health       │ +$500K budget │ EMR Upgrade │ 2 weeks       │ │
│  │ SA Health       │ +$800K budget │ Analytics   │ 2 weeks       │ │
│  │ Barwon Health   │ +$200K budget │ Mobile      │ 4 weeks       │ │
│  │ GHA             │ +$150K budget │ Security    │ 2 weeks       │ │
│  │ Metro Health    │ Neutral       │ Maintain    │ N/A           │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Recommended Response:                                               │
│  "Budget announcements create 2-4 week window of receptivity.       │
│   Clients are reviewing priorities and allocating new funds.        │
│   Proactive outreach to 4 high-impact clients recommended NOW."    │
│                                                                      │
│  [Generate Outreach Campaign] [Create Talking Points]               │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  Other Active Indicators:                                            │
│  ├── RBA Interest Rate: 4.25% (stable) - No immediate impact       │
│  ├── AUD/USD: 0.68 (-2% MTD) - Import cost pressure for HW deals   │
│  ├── Healthcare Employment: +3.2% YoY - Capacity for new projects  │
│  └── Tech Sector Sentiment: Cautious optimism (Gartner Q1 report)  │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Economic Indicators Monitored:**

| Indicator | Source | Relevance |
|-----------|--------|-----------|
| Federal/State Budgets | Treasury announcements | Direct funding for health IT |
| Interest Rates | RBA | Affects capital expenditure appetite |
| Currency Rates | Forex markets | Import costs for hardware/licenses |
| Healthcare Workforce | ABS | Capacity to absorb new technology |
| Industry Sentiment | Gartner, Forrester | Overall spending outlook |
| Regulatory Changes | Government gazettes | Compliance-driven demand |
| Grant Programs | Business.gov.au | Funding opportunities for clients |

### Autonomous Relationship Maintenance

#### Relationship Autopilot

For stable, healthy accounts, ChaSen maintains relationships autonomously with human oversight:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🤖 Relationship Autopilot: Metro Health (Health Score: 85)        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Autopilot Status: ACTIVE ✓                                         │
│  Mode: Maintenance (Low-touch healthy account)                      │
│  Human Intervention Required: No                                    │
│                                                                      │
│  Autonomous Activities (Last 30 Days):                              │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Date     │ Action                        │ Status    │ Response│ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │ 28 Jan   │ Monthly check-in email        │ Sent ✓    │ Replied │ │
│  │ 22 Jan   │ Industry news share           │ Sent ✓    │ Liked   │ │
│  │ 15 Jan   │ Product update notification   │ Sent ✓    │ Opened  │ │
│  │ 10 Jan   │ NPS survey invitation         │ Sent ✓    │ +42 NPS │ │
│  │ 05 Jan   │ Happy New Year message        │ Sent ✓    │ Replied │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Scheduled Activities (Next 30 Days):                               │
│  ├── 05 Feb: Share relevant case study (auto-selected)             │
│  ├── 12 Feb: Monthly check-in email                                │
│  ├── 18 Feb: Sarah's work anniversary (5 years) - Card scheduled   │
│  └── 28 Feb: QBR scheduling reminder                               │
│                                                                      │
│  Autopilot Rules Active:                                            │
│  ├── ✓ Monthly relationship touchpoint                              │
│  ├── ✓ Share relevant industry news (max 2/month)                  │
│  ├── ✓ Product update notifications                                 │
│  ├── ✓ Birthday/anniversary recognition                             │
│  ├── ✓ NPS survey scheduling                                        │
│  └── ✓ Escalate if health drops below 70                           │
│                                                                      │
│  [Adjust Rules] [Take Manual Control] [View All Communications]     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Autopilot Modes:**

| Mode | Health Score | Automation Level | Human Involvement |
|------|--------------|------------------|-------------------|
| **Maintenance** | 75+ | Full automation | Monthly review only |
| **Nurture** | 60-74 | Partial automation | Bi-weekly review |
| **Watch** | 50-59 | Alerts only | Weekly engagement |
| **Intervention** | <50 | Disabled | Full human control |

**Autopilot Can:**
- Send templated check-in emails (pre-approved by CSE)
- Share relevant industry news and content
- Schedule routine meetings
- Send birthday/anniversary messages
- Distribute product updates
- Invite to NPS surveys
- Log all activities for audit

**Autopilot Cannot:**
- Discuss pricing or contracts
- Make commitments
- Handle complaints
- Engage in complex conversations
- Send without logging
- Override human instructions

#### Predictive Gift & Recognition

AI identifies meaningful recognition opportunities:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🎁 Recognition Opportunities                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Upcoming (Next 30 Days):                                           │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ 🏆 Sarah Chen - 10 Year Work Anniversary (18 Feb)              ││
│  │    Barwon Health | CFO | Your Champion                          ││
│  │                                                                  ││
│  │    Relationship Value: High (Champion on $450K pipeline)        ││
│  │    Personal Intel: Mentioned coffee 3x, runs marathons          ││
│  │                                                                  ││
│  │    Suggested Recognition:                                        ││
│  │    ├── Option A: Premium coffee subscription (3 months) - $150  ││
│  │    ├── Option B: Charity donation in her name (cancer) - $200   ││
│  │    └── Option C: Personalised thank you video + flowers - $80   ││
│  │                                                                  ││
│  │    ChaSen Recommendation: Option A (matches interests)          ││
│  │                                                                  ││
│  │    [Approve Option A] [Modify] [Skip] [Schedule Call Instead]   ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ 🎂 David Wong - Birthday (25 Feb)                               ││
│  │    GHA | CIO | Economic Buyer                                   ││
│  │                                                                  ││
│  │    Relationship Value: Medium (renewal in 90 days)              ││
│  │    Personal Intel: Golf enthusiast, supports Carlton FC         ││
│  │                                                                  ││
│  │    Suggested Recognition:                                        ││
│  │    ├── Option A: Personalised birthday message - $0             ││
│  │    └── Option B: Golf accessories gift - $100                   ││
│  │                                                                  ││
│  │    ChaSen Recommendation: Option A (standard relationship)      ││
│  │                                                                  ││
│  │    [Send Message] [Upgrade Gift] [Skip]                         ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Recognition Triggers:**
- Work anniversaries (5, 10, 15, 20 years)
- Birthdays
- Promotions
- Company awards
- Personal achievements mentioned in meetings
- Life events (if shared)

**Gift Budget Guidelines:**

| Relationship Tier | Annual Budget | Approval |
|-------------------|---------------|----------|
| **Champion/Exec Sponsor** | $500 | Manager approval >$200 |
| **Key Stakeholder** | $200 | Self-approval |
| **General Contact** | $50 | Self-approval |
| **Prospect** | $0 | Message only |

#### Event Trigger Response

Automated response drafts when clients appear in news:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📰 Event Trigger: Barwon Health                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Event Detected: Healthcare Innovation Award Winner                 │
│  Source: Australian Healthcare Week (3 Feb 2026)                    │
│  Confidence: 98%                                                    │
│                                                                      │
│  Article Summary:                                                    │
│  "Barwon Health recognised for digital transformation initiative,   │
│   including EMR modernisation and patient portal deployment.        │
│   CFO Sarah Chen accepted the award, citing 'exceptional vendor     │
│   partnerships' as key to success."                                 │
│                                                                      │
│  Altera Mentions: "EMR modernisation" (our product referenced)      │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  Draft Response (Ready for Review):                                 │
│                                                                      │
│  To: Sarah Chen <sarah.chen@barwonhealth.org.au>                   │
│  Subject: Congratulations on the Healthcare Innovation Award! 🏆    │
│                                                                      │
│  Dear Sarah,                                                        │
│                                                                      │
│  I just saw the wonderful news about Barwon Health winning the      │
│  Healthcare Innovation Award—congratulations to you and the entire  │
│  team! It's incredibly well-deserved recognition for the            │
│  transformational work you've led over the past two years.          │
│                                                                      │
│  It's been a privilege to partner with you on this journey, and     │
│  we're proud to have played a small part in Barwon's success.       │
│                                                                      │
│  Would love to catch up over coffee to celebrate and hear more      │
│  about what's next. Let me know if you have time in the coming      │
│  weeks.                                                              │
│                                                                      │
│  Warm regards,                                                       │
│  Michael                                                             │
│                                                                      │
│  [Send Now] [Edit] [Schedule for Tomorrow AM] [Dismiss]             │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  Additional Suggestions:                                             │
│  ├── Share on LinkedIn with congratulations tag                     │
│  ├── Request case study participation                               │
│  └── Add to reference customer list                                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Event Types Monitored:**

| Event Type | Response Template | Urgency |
|------------|-------------------|---------|
| **Award/Recognition** | Congratulations | Within 24 hours |
| **Funding/Investment** | Opportunity discussion | Within 48 hours |
| **Leadership Change** | Relationship maintenance | Within 24 hours |
| **Expansion/Merger** | Growth opportunity | Within 48 hours |
| **Product Launch** | Partnership discussion | Within 1 week |
| **Negative News** | Support outreach | Within 4 hours |
| **Go-Live/Milestone** | Celebration | Same day |

### Immersive & Ambient Experiences

#### Spatial Audio Briefings

Transform commute time into productive territory review with 3D audio:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🎧 Spatial Audio Briefing                                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Mode: Commute Briefing (15 minutes)                                │
│  Device: AirPods Pro (Spatial Audio enabled)                        │
│                                                                      │
│  Audio Landscape:                                                    │
│                                                                      │
│           [High Priority]                                           │
│                 ↑                                                    │
│                 │                                                    │
│                 │     🔴 Barwon (Urgent)                            │
│                 │                                                    │
│  [At Risk] ←────┼────→ [Healthy]                                   │
│                 │                                                    │
│        🟡 GHA   │         🟢 Metro                                  │
│                 │              🟢 SA Health                          │
│                 │                                                    │
│                 ↓                                                    │
│           [Low Priority]                                            │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  How It Works:                                                       │
│                                                                      │
│  • Clients positioned in 3D audio space based on priority/health   │
│  • High priority = front and centre                                 │
│  • At risk = left side                                              │
│  • Healthy = right side                                             │
│                                                                      │
│  Head Gestures (with AirPods motion detection):                     │
│  • Look LEFT: Hear more about at-risk accounts                      │
│  • Look RIGHT: Hear about healthy accounts                          │
│  • Look UP: Skip to next client                                     │
│  • Nod DOWN: "Tell me more" about current client                   │
│                                                                      │
│  Voice Commands:                                                     │
│  • "Focus on Barwon" - Deep dive on specific client                │
│  • "What's urgent?" - Jump to action items                          │
│  • "Skip" - Move to next client                                     │
│  • "Remind me" - Create reminder for later                          │
│                                                                      │
│  Sample Briefing Script:                                            │
│  "Good morning. Starting your territory briefing.                   │
│   [Front, urgent tone] Barwon Health needs attention—                │
│   support health dropped to 45% yesterday with 3 P1 tickets.        │
│   [Look left gesture detected]                                       │
│   Diving deeper: The P1s relate to reporting module outages.        │
│   Sarah Chen escalated to your manager this morning.                │
│   Suggested action: Call Sarah before 10am to acknowledge.          │
│   [Nod detected - creating reminder]                                 │
│   Reminder set: Call Sarah Chen, 9:30am."                           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Haptic Pipeline

Apple Watch tactile notifications for ambient awareness:

```
┌─────────────────────────────────────────────────────────────────────┐
│  ⌚ Haptic Pipeline Configuration                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Device: Apple Watch Series 9                                       │
│  Mode: Ambient Awareness (Non-intrusive)                            │
│                                                                      │
│  Haptic Patterns:                                                    │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Pattern         │ Meaning                    │ Urgency         │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │ ∙∙ (2 quick)    │ New opportunity added      │ Low - FYI      │ │
│  │ ∙∙∙ (3 quick)   │ Deal stage advanced        │ Low - Positive │ │
│  │ ━━━ (1 long)    │ Deal at risk               │ High - Urgent  │ │
│  │ ∙━∙ (short-long)│ Approaching quota          │ Med - Positive │ │
│  │ ━━━━ (2 long)   │ Client health drop >10pts  │ High - Action  │ │
│  │ ∙∙∙∙ (4 quick)  │ Meeting starting in 5 min  │ Med - Reminder │ │
│  │ ━∙━ (long-short)│ NPS response received      │ Low - FYI      │ │
│  │ ∙━━∙ (pattern)  │ Competitor alert           │ High - Intel   │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Quiet Hours: 7pm - 7am (weekdays), All day (weekends)             │
│  Do Not Disturb: Respects system DND settings                       │
│                                                                      │
│  Glanceable Watch Face Complication:                                │
│  ┌─────────────────────┐                                            │
│  │  📊 Pipeline        │                                            │
│  │  $2.1M | 2.4x      │  ← Value & coverage at a glance            │
│  │  ▲ $50K today      │  ← Change indicator                        │
│  └─────────────────────┘                                            │
│                                                                      │
│  Benefits:                                                           │
│  • Stay informed without looking at phone                           │
│  • Learn patterns—urgent feels different from positive              │
│  • Peripheral awareness during meetings                             │
│  • No context switching required                                    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### AI-Human Hybrid Operations

#### Meeting Co-Host

AI joins video calls as a disclosed assistant:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🤖 Meeting Co-Host: Active                                         │
│  Meeting: Barwon Health QBR | Participants: 5 | Duration: 47 min   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Co-Host Sidebar (Visible only to you):                             │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ 🎯 Meeting Objectives (Auto-detected from agenda)               ││
│  │ ☑ Review Q3 performance metrics                                 ││
│  │ ☐ Discuss FY27 priorities                                       ││
│  │ ☐ Address support concerns                                      ││
│  │ ☐ Confirm renewal timeline                                      ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ 📝 Live Notes (Auto-generated)                                  ││
│  │                                                                  ││
│  │ [10:03] Sarah: Pleased with uptime improvements                 ││
│  │ [10:07] David: Concerned about reporting performance            ││
│  │ [10:12] Sarah: Budget confirmed for mobile rollout              ││
│  │ [10:18] ACTION: Send reporting optimisation proposal by Fri     ││
│  │ [10:23] COMMITMENT: David to schedule technical review          ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ 💡 Real-time Suggestions                                        ││
│  │                                                                  ││
│  │ ⚠️ David's tone shifted negative on reporting topic.           ││
│  │    Suggested response: "I hear your frustration, David.         ││
│  │    Help me understand the specific scenarios causing issues."   ││
│  │                                                                  ││
│  │ 📊 Fact Check: Sarah mentioned "15% improvement"                ││
│  │    Actual data: 18% improvement. Opportunity to reinforce.      ││
│  │                                                                  ││
│  │ ❓ Knowledge Base: "What's our roadmap for reporting?"          ││
│  │    Answer ready: "Q2 release includes 3 reporting enhancements" ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ ✅ Action Items Captured                                        ││
│  │                                                                  ││
│  │ 1. [You] Send reporting optimisation proposal - Due: Friday     ││
│  │ 2. [David] Schedule technical review - Due: Next week           ││
│  │ 3. [Sarah] Confirm mobile rollout budget allocation - Due: EOW  ││
│  │                                                                  ││
│  │ [Confirm & Create Actions]                                      ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  Post-Meeting (Auto-generated):                                     │
│  • Meeting summary email draft ready                                │
│  • Action items created in system                                  │
│  • Calendar invites drafted for follow-ups                          │
│  • CRM notes updated                                                │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Co-Host Capabilities:**

| Function | How It Works | Human Oversight |
|----------|--------------|-----------------|
| **Note-Taking** | Transcribes and summarises in real-time | Review before distribution |
| **Action Capture** | Detects commitments and deadlines | Confirm before creating |
| **Sentiment Analysis** | Monitors tone and flags concerns | Private notification only |
| **Fact Checking** | Compares statements to data | Private sidebar display |
| **Knowledge Assist** | Answers questions from knowledge base | Human decides to share |
| **Time Management** | Tracks agenda progress | Private alerts |
| **Follow-up Drafts** | Prepares summary email | Human reviews and sends |

**Disclosure:** Meeting invites include: "Note: AI meeting assistant will be present to assist with note-taking. No recording without separate consent."

#### Parallel Deal Processing

AI works on multiple deals simultaneously while human focuses on one:

```
┌─────────────────────────────────────────────────────────────────────┐
│  ⚡ Parallel Processing Dashboard                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Your Focus: Barwon EMR Upgrade (Human-led negotiation)             │
│                                                                      │
│  AI Processing in Background (10 deals):                            │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Deal              │ AI Activity              │ Status │ Review │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │ GHA Analytics     │ Drafting proposal        │ 85%    │ Soon   │ │
│  │ WA Health Mobile  │ Researching stakeholders │ 60%    │ -      │ │
│  │ SA Health Renewal │ Preparing QBR deck       │ 100%   │ Ready  │ │
│  │ Metro Security    │ Competitive analysis     │ 45%    │ -      │ │
│  │ Alpine Health EMR │ MEDDPICC assessment      │ 100%   │ Ready  │ │
│  │ Peninsula Upgrade │ Pricing model            │ 70%    │ -      │ │
│  │ Eastern Health    │ ROI calculation          │ 100%   │ Ready  │ │
│  │ Northern Hosp     │ Reference matching       │ 90%    │ Soon   │ │
│  │ Western Health    │ Risk assessment          │ 55%    │ -      │ │
│  │ Southern IMS      │ Contract review          │ 30%    │ -      │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Ready for Review (3):                                               │
│  ├── SA Health Renewal: QBR deck complete [Review Now]             │
│  ├── Alpine Health: MEDDPICC assessment ready [Review Now]         │
│  └── Eastern Health: ROI model complete [Review Now]               │
│                                                                      │
│  Time Saved Today: ~4.5 hours                                       │
│  Deals Advanced: 3 (pending your review)                            │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  AI Work Queue (Upcoming):                                          │
│  • Draft 5 follow-up emails (queued)                               │
│  • Research 3 new prospects (queued)                               │
│  • Update 8 opportunity records (queued)                           │
│  • Generate 2 competitive battlecards (queued)                     │
│                                                                      │
│  [Prioritise Queue] [Add Task] [Pause All]                          │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Parallel Processing Rules:**

| Task Type | AI Can Complete | Human Review Required |
|-----------|-----------------|----------------------|
| **Research** | Stakeholder profiles, competitive intel | Optional |
| **Analysis** | MEDDPICC assessment, ROI models | Required before use |
| **Drafts** | Proposals, emails, presentations | Required before send |
| **Data Entry** | CRM updates, meeting logs | Optional spot-check |
| **Scheduling** | Meeting requests, reminders | Approval before send |
| **Strategy** | Deal recommendations, next steps | Required discussion |

**Throughput Multiplier:**
- Without AI: ~3 deals actively progressed per day
- With Parallel Processing: ~15 deals progressed per day (human reviews 3-5 AI outputs)

---

## Data Visualisation - Next-Generation Features

> **Design Philosophy:** Data visualisation should tell stories, enable exploration, and surface insights—not just display numbers. Every chart should answer "so what?" not just "what."

### Storytelling with Data

#### Narrative Dashboards

Dashboards that tell a story with context, not just display metrics:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📖 Territory Story: Q3 FY26                                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Chapter 1: The Strong Start                                        │
│  ──────────────────────────────────────────────────────────────────  │
│  "July opened with momentum. Three renewals closed in the first    │
│   week, pushing committed revenue to $1.8M—ahead of plan."         │
│                                                                      │
│  [Animated chart showing July spike]                                │
│                                                                      │
│  Chapter 2: The Challenge                                           │
│  ──────────────────────────────────────────────────────────────────  │
│  "August brought headwinds. Barwon Health's support issues          │
│   triggered a health score drop from 72 to 48, putting $450K        │
│   renewal at risk. Portfolio average fell 8 points."                │
│                                                                      │
│  [Chart highlighting Barwon's decline, with annotation]             │
│                                                                      │
│  Chapter 3: The Recovery                                            │
│  ──────────────────────────────────────────────────────────────────  │
│  "Your QBR intervention on September 15 turned the tide.            │
│   Support escalation resolved 5 P1 tickets. Health recovered        │
│   to 71 by month end. Renewal confirmed October 3."                 │
│                                                                      │
│  [Before/after slider showing health recovery]                      │
│                                                                      │
│  Chapter 4: The Outcome                                             │
│  ──────────────────────────────────────────────────────────────────  │
│  "Q3 closed at $2.4M—104% of target. Key driver: Barwon            │
│   not only renewed but expanded by $80K. Your intervention          │
│   directly contributed $530K in protected + new revenue."           │
│                                                                      │
│  [Final summary visualisation with your impact highlighted]         │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  [◀ Previous Quarter] [Play Animation] [Next Quarter ▶]             │
│  [Export as PDF] [Share with Manager] [Add to QBR Deck]            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Annotated Timelines

Every data point can carry context that persists for future viewers:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📈 Barwon Health - Health Score Timeline                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  100 ┤                                                               │
│   90 ┤                                                               │
│   80 ┤──●────●                                          ●────●      │
│   70 ┤        ╲                                        ╱            │
│   60 ┤         ╲                              ●───────●             │
│   50 ┤          ╲            📝              ╱                      │
│   40 ┤           ●──────────●───────●───────●                       │
│   30 ┤                                                               │
│      └──┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬── │
│        Jan  Feb  Mar  Apr  May  Jun  Jul  Aug  Sep  Oct  Nov  Dec   │
│                                                                      │
│  Annotations (click any point to add):                              │
│                                                                      │
│  📝 Mar 15: "System outage - 3 days downtime. Client escalated."   │
│             Added by: Michael T. | Impact: -15 points               │
│                                                                      │
│  📝 Jun 22: "New CIO started. Initial relationship building phase." │
│             Added by: Michael T. | Impact: Neutral                  │
│                                                                      │
│  📝 Sep 15: "QBR intervention. Support escalation resolved."       │
│             Added by: Michael T. | Impact: +23 points recovery      │
│                                                                      │
│  [+ Add Annotation] [Show/Hide Annotations] [Export with Context]   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Before/After Comparisons

Drag slider to visualise intervention impact:

```
┌─────────────────────────────────────────────────────────────────────┐
│  ⚖️ Impact Comparison: Support Escalation Intervention              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Drag slider to compare before vs after:                            │
│                                                                      │
│  BEFORE ◀━━━━━━━━━━━━━━━━━━━━●━━━━━━━━━━━━━━━━━━━━▶ AFTER          │
│                                                                      │
│  ┌─────────────────────────┬─────────────────────────┐              │
│  │      BEFORE (Aug 15)    │      AFTER (Oct 15)     │              │
│  ├─────────────────────────┼─────────────────────────┤              │
│  │  Support SLA: 45%       │  Support SLA: 92%       │  ↑ +47%     │
│  │  Open P1 Tickets: 5     │  Open P1 Tickets: 0     │  ↓ -5       │
│  │  CSAT Score: 2.1/5      │  CSAT Score: 4.3/5      │  ↑ +2.2     │
│  │  Health Score: 48       │  Health Score: 71       │  ↑ +23      │
│  │  NPS: +12               │  NPS: +34               │  ↑ +22      │
│  │  Renewal Risk: HIGH     │  Renewal Risk: LOW      │  ✓ Mitigated│
│  └─────────────────────────┴─────────────────────────┘              │
│                                                                      │
│  Revenue Impact:                                                     │
│  ├── At-risk revenue protected: $450,000                           │
│  ├── Expansion unlocked: $80,000                                   │
│  └── Total value of intervention: $530,000                         │
│                                                                      │
│  [Add to Value Ledger] [Share as Success Story] [Export]           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Interactive Exploration

#### Drill-Anywhere Architecture

Click any number to explore deeper—infinite depth, instant navigation:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🔍 Drill-Down Navigation                                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Breadcrumb: Territory > ARR > Barwon Health > EMR Suite > Sunrise │
│                                                                      │
│  Current View: Sunrise EMR Contract Details                         │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │                                                                  ││
│  │  Drill Path Taken:                                              ││
│  │                                                                  ││
│  │  $4.2M Territory ARR                                            ││
│  │       ↓ clicked                                                 ││
│  │  ├── Barwon Health: $850K ← clicked                            ││
│  │  │       ↓                                                      ││
│  │  │   ├── EMR Suite: $520K ← clicked                            ││
│  │  │   │       ↓                                                  ││
│  │  │   │   ├── Sunrise EMR: $380K ← current                      ││
│  │  │   │   ├── Sunrise Surgical: $90K                            ││
│  │  │   │   └── Sunrise Ambulatory: $50K                          ││
│  │  │   ├── Analytics: $180K                                      ││
│  │  │   └── Mobile: $150K                                         ││
│  │  ├── GHA: $620K                                                ││
│  │  ├── SA Health: $1.2M                                          ││
│  │  └── [12 more clients...]                                      ││
│  │                                                                  ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  Sunrise EMR Contract:                                              │
│  ├── Contract Value: $380,000/year                                 │
│  ├── Start Date: 1 Jul 2023                                        │
│  ├── Renewal Date: 30 Jun 2026 (147 days)                         │
│  ├── Term: 3 years                                                 │
│  ├── Auto-Renew: Yes (90-day notice)                              │
│  └── Price Escalation: 3% annually                                 │
│                                                                      │
│  [◀ Back to EMR Suite] [View Contract PDF] [Renewal Actions]        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Natural Language Queries on Charts

Ask questions directly on any visualisation:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📊 Pipeline Trend                               🔍 Ask a question  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  $3M ┤                                    ●                         │
│      │                              ●────●                          │
│  $2M ┤                  ●──────────●                                │
│      │            ●────●                                            │
│  $1M ┤      ●────●                                                  │
│      │  ●──●                                                        │
│   $0 └──┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬── │
│        Jul  Aug  Sep  Oct  Nov  Dec  Jan  Feb  Mar  Apr  May  Jun   │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  💬 Your Question: "Why did pipeline jump in March?"                │
│                                                                      │
│  🤖 ChaSen Analysis:                                                │
│                                                                      │
│  "The March spike (+$800K) was driven by 3 factors:                │
│                                                                      │
│   1. Barwon EMR Upgrade added ($250K) - Triggered by Q2 budget     │
│      approval mentioned in Feb QBR                                  │
│                                                                      │
│   2. WA Health Analytics ($350K) - Tender response submitted,      │
│      moved from prospect to qualified                               │
│                                                                      │
│   3. GHA Mobile expansion ($200K) - NPS feedback about mobile      │
│      access led to discovery call on March 8                        │
│                                                                      │
│   All three originated from existing client signals—strong          │
│   indicator that your listening activities are generating leads."   │
│                                                                      │
│  [Ask Follow-up] [Show These Deals] [Export Analysis]               │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Comparative Overlays

Overlay any metric against any other to discover correlations:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📈 Metric Overlay Analysis                                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Primary Metric: [NPS Score ▼]                                      │
│  Overlay With: [Support Ticket Volume ▼]                            │
│                                                                      │
│  100 ┤━━━━━ NPS                                                     │
│      │- - - - Tickets                                               │
│   80 ┤                                                               │
│      │        ╱╲           ╱──────                                  │
│   60 ┤━━━━━━━╱━━╲━━━━━━━━╱━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│      │      ╱    ╲      ╱                                           │
│   40 ┤     ╱      ╲    ╱                                            │
│      │- -╱- - - - -╲--╱- - - - - - - - - - - - - - - - - - - - - - -│
│   20 ┤  ╱          ╲╱                                               │
│      │ ╱                                                            │
│    0 └──┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬── │
│        Jan  Feb  Mar  Apr  May  Jun  Jul  Aug  Sep  Oct  Nov  Dec   │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  🔬 Correlation Analysis:                                           │
│                                                                      │
│  Correlation Coefficient: -0.78 (Strong Negative)                   │
│  Lag Analysis: Ticket spikes precede NPS drops by ~3 weeks         │
│                                                                      │
│  Insight: "When support tickets exceed 15/month, NPS drops an      │
│  average of 12 points within 3 weeks. Consider proactive outreach  │
│  when ticket volume exceeds 10/month to prevent NPS decline."       │
│                                                                      │
│  [Save as Alert Rule] [Add More Metrics] [Export Correlation]       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Advanced Visualisation Types

#### Sankey Flow Diagrams

Visualise how revenue flows through your business:

```
┌─────────────────────────────────────────────────────────────────────┐
│  💰 Revenue Flow Analysis - FY26                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  SOURCES          PRODUCTS           SEGMENTS         OUTCOMES      │
│                                                                      │
│  ┌─────────┐                                         ┌─────────┐   │
│  │Renewals ├──────────┐      ┌─────────────────────►│Renewed  │   │
│  │ $2.8M   │          │      │                      │ $3.1M   │   │
│  └─────────┘    ┌─────▼─────┐│    ┌──────────┐      └─────────┘   │
│                 │   EMR     ├┼───►│  Giant   │                     │
│  ┌─────────┐    │  $1.9M    ││    │  $2.1M   ├────►┌─────────┐   │
│  │Expansion├───►└───────────┘│    └──────────┘     │Expanded │   │
│  │ $800K   │                 │                      │ $650K   │   │
│  └─────────┘    ┌───────────┐│    ┌──────────┐     └─────────┘   │
│                 │ Analytics ├┼───►│  Large   │                     │
│  ┌─────────┐    │  $650K    ││    │  $1.2M   ├────►┌─────────┐   │
│  │New Logo ├───►└───────────┘│    └──────────┘     │Churned  │   │
│  │ $400K   │                 │                      │ $180K   │   │
│  └─────────┘    ┌───────────┐│    ┌──────────┐     └─────────┘   │
│                 │  Mobile   ├┴───►│  Medium  │                     │
│                 │  $450K    │     │  $700K   ├────►┌─────────┐   │
│                 └───────────┘     └──────────┘     │Pipeline │   │
│                                                     │ $800K   │   │
│                                                     └─────────┘   │
│                                                                      │
│  Flow Insights:                                                      │
│  • 89% of Giant segment revenue came from EMR renewals              │
│  • Churn concentrated in Medium segment (85% of total churn)        │
│  • Expansion strongest in Large segment (+$420K)                    │
│                                                                      │
│  [Hover for Details] [Filter by Segment] [Compare to Last Year]     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Radar/Spider Charts for Multi-Dimensional Health

See all health dimensions at once:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🕸️ Client Health Radar: Barwon Health                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│                         NPS (+34)                                   │
│                            ●                                        │
│                           ╱│╲                                       │
│                          ╱ │ ╲                                      │
│                         ╱  │  ╲                                     │
│           Engagement   ●───┼───●   Support                         │
│              (82%)    ╱    │    ╲   (71%)                          │
│                      ╱     │     ╲                                  │
│                     ╱      │      ╲                                 │
│                    ╱       │       ╲                                │
│                   ●────────┼────────●                               │
│           Adoption         │         Financial                      │
│             (68%)          │          (85%)                         │
│                            │                                        │
│                            ●                                        │
│                     Product Fit                                     │
│                        (76%)                                        │
│                                                                      │
│  ━━━━━ Current    - - - - Target    ░░░░░ Industry Avg             │
│                                                                      │
│  Dimension Analysis:                                                 │
│  ├── Strongest: Financial (85%) - On-time payments, growing ARR    │
│  ├── Weakest: Adoption (68%) - Only using 4 of 7 licensed modules  │
│  └── Biggest Gap: Adoption is 12 points below target               │
│                                                                      │
│  Recommended Focus: "Drive adoption of Analytics and Mobile        │
│  modules to improve overall health and unlock expansion."           │
│                                                                      │
│  [Compare to Other Clients] [Track Over Time] [Set Targets]         │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Temporal Heat Maps

Spot patterns across clients and time:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🌡️ Portfolio Health Heatmap - FY26                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│               Jul  Aug  Sep  Oct  Nov  Dec  Jan  Feb  Mar  Apr     │
│             ┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┐    │
│  Barwon    │ 72 │ 48 │ 52 │ 71 │ 74 │ 68 │ 75 │ 78 │ 80 │ 82 │    │
│             ├────┼────┼────┼────┼────┼────┼────┼────┼────┼────┤    │
│  GHA       │ 65 │ 68 │ 70 │ 72 │ 71 │ 65 │ 68 │ 70 │ 72 │ 74 │    │
│             ├────┼────┼────┼────┼────┼────┼────┼────┼────┼────┤    │
│  SA Health │ 85 │ 86 │ 84 │ 82 │ 80 │ 75 │ 78 │ 80 │ 82 │ 84 │    │
│             ├────┼────┼────┼────┼────┼────┼────┼────┼────┼────┤    │
│  WA Health │ 58 │ 55 │ 52 │ 50 │ 48 │ 45 │ 42 │ 40 │ 45 │ 52 │    │
│             ├────┼────┼────┼────┼────┼────┼────┼────┼────┼────┤    │
│  Metro     │ 78 │ 80 │ 82 │ 84 │ 85 │ 82 │ 84 │ 86 │ 88 │ 90 │    │
│             └────┴────┴────┴────┴────┴────┴────┴────┴────┴────┘    │
│                                                                      │
│  Legend: ████ >80 (Healthy)  ████ 60-80 (Watch)  ████ <60 (Risk)   │
│                                                                      │
│  Pattern Detection:                                                  │
│  ⚠️ WA Health: Declining for 8 consecutive months (58→40)          │
│  ⚠️ December Dip: 4 of 5 clients dropped in Dec (holiday effect?)  │
│  ✓ Metro: Steady improvement trend (+12 points over period)        │
│  ⚠️ Barwon Aug: Sudden drop (-24 points) - investigate             │
│                                                                      │
│  [Click Any Cell for Details] [Export] [Set Alert Thresholds]       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Network Graphs for Relationships

Visualise stakeholder dynamics:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🔗 Stakeholder Network: Barwon Health                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│                        ┌─────────────┐                              │
│                        │   James     │                              │
│                        │    CEO      │                              │
│                        │  ●●●●○      │ (Influence: 4/5)             │
│                        └──────┬──────┘                              │
│                               │ reports to                          │
│               ┌───────────────┼───────────────┐                     │
│               │               │               │                     │
│        ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐             │
│        │   Sarah     │ │   David     │ │   Emma      │             │
│        │    CFO      │ │    CIO      │ │    COO      │             │
│        │  ●●●●●      │ │  ●●●○○      │ │  ●●○○○      │             │
│        │ [CHAMPION]  │ │ [SKEPTIC]   │ │ [NEUTRAL]   │             │
│        └──────┬──────┘ └──────┬──────┘ └──────┬──────┘             │
│               │               │               │                     │
│       ════════╪═══════════════╪═══════════════╪═══════             │
│       strong  │    weak       │    none       │                     │
│       ally    │    connection │    connection │                     │
│               │               │               │                     │
│        ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐             │
│        │   Tom       │ │   Lisa      │ │   Mark      │             │
│        │ Finance Mgr │ │  IT Director│ │ Ops Manager │             │
│        │  ●●●○○      │ │  ●●○○○      │ │  ●○○○○      │             │
│        │ [SUPPORTER] │ │ [BLOCKER]   │ │ [UNKNOWN]   │             │
│        └─────────────┘ └─────────────┘ └─────────────┘             │
│                                                                      │
│  Legend:                                                             │
│  ●●●●● = Very High Influence    [CHAMPION] = Strong supporter       │
│  ━━━━━ = Strong relationship    [BLOCKER] = Active resistance       │
│  - - - = Weak relationship      [NEUTRAL] = No strong opinion       │
│                                                                      │
│  Network Analysis:                                                   │
│  ⚠️ Single-threaded: Only strong connection is through Sarah       │
│  ⚠️ Blocker present: Lisa (IT Director) has concerns               │
│  💡 Opportunity: Emma (COO) is neutral—potential ally if engaged   │
│                                                                      │
│  Recommended Actions:                                                │
│  1. Ask Sarah to introduce you to Emma                              │
│  2. Address Lisa's concerns directly (schedule 1:1)                 │
│  3. Multi-thread: Build direct relationship with Tom                │
│                                                                      │
│  [Expand Network] [Add Stakeholder] [Export Org Chart]              │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Real-Time & Animated Visualisations

#### Live Pipeline Waterfall

Watch pipeline changes in real-time:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📊 Live Pipeline Waterfall - Today's Changes                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Yesterday ─────────────────────────────────────────────────► Today │
│                                                                      │
│  $2.1M    +$180K     -$50K      +$250K    -$80K     = $2.4M        │
│    │      (Won)    (Lost)      (Added)   (Pushed)      │           │
│    │        │         │           │         │          │           │
│  ┌─┴─┐   ┌──┴──┐   ┌──┴──┐   ┌───┴───┐  ┌──┴──┐   ┌──┴──┐        │
│  │   │   │ +++ │   │ --- │   │ +++++ │  │ --- │   │     │        │
│  │   │   │ +++ │   │     │   │ +++++ │  │     │   │     │        │
│  │   │   │ +++ │   │     │   │ +++++ │  │     │   │     │        │
│  │   │   │     │   │     │   │       │  │     │   │     │        │
│  │   │   │     │   │     │   │       │  │     │   │     │        │
│  └───┘   └─────┘   └─────┘   └───────┘  └─────┘   └─────┘        │
│                                                                      │
│  Today's Activity Feed (Live):                                      │
│  ├── 14:32 ✓ Barwon EMR moved to Closed Won (+$180K)               │
│  ├── 11:15 ✗ Metro Security lost to competitor (-$50K)             │
│  ├── 09:45 + SA Health Mobile added to pipeline (+$250K)           │
│  └── 08:30 → GHA Analytics pushed to Q3 (-$80K from Q2)            │
│                                                                      │
│  Net Change: +$300K (+14.3%)                                        │
│  Coverage Impact: 2.1x → 2.4x                                       │
│                                                                      │
│  [View Full History] [Set Change Alerts] [Celebrate Wins 🎉]        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Animated Forecast Scenarios

Watch different scenarios play out:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🎬 Forecast Scenario Animator                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Scenario: [Best Case ▼]  Speed: [Normal ▼]  [▶ Play] [⏸ Pause]   │
│                                                                      │
│  $4M ┤                                               ╭─────────────│
│      │                                          ╭────╯ Best: $3.8M │
│  $3M ┤                                     ╭────╯                   │
│      │                                ╭────╯─ ─ ─ ─ ─ Likely: $3.2M│
│  $2M ┤                           ╭────╯                             │
│      │                      ╭────╯                                  │
│  $1M ┤                 ╭────╯                        Worst: $2.4M   │
│      │            ╭────╯─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│
│   $0 └────────────┴────┬────┬────┬────┬────┬────┬────┬────┬────┬──│
│       Committed    Q1   Q2   Q3   Q4   Q1   Q2   Q3   Q4   Q1     │
│        Now        └──────── FY26 ────────┘└─────── FY27 ────────┘ │
│                                                                      │
│  Scenario Assumptions (Best Case):                                  │
│  ├── All committed deals close as expected (100%)                  │
│  ├── Forecast deals close at stage probability + 10%               │
│  ├── Upside deals included at 50% probability                      │
│  └── 2 whitespace opportunities discovered ($200K)                 │
│                                                                      │
│  Key Swing Deals:                                                    │
│  ├── Barwon EMR ($250K) - Moves outcome by ±8%                     │
│  ├── WA Health Analytics ($350K) - Moves outcome by ±11%           │
│  └── SA Health Renewal ($450K) - Moves outcome by ±14%             │
│                                                                      │
│  [Compare Scenarios] [Export Model] [Share with Manager]            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Predictive & Prescriptive Visualisations

#### Churn Probability Distribution

See which clients are at risk and why:

```
┌─────────────────────────────────────────────────────────────────────┐
│  ⚠️ Churn Risk Distribution - Portfolio View                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  12 │                                                               │
│     │  ████                                                         │
│  10 │  ████                                                         │
│     │  ████                                                         │
│   8 │  ████  ████                                                   │
│     │  ████  ████                                                   │
│   6 │  ████  ████  ████                                             │
│     │  ████  ████  ████                                             │
│   4 │  ████  ████  ████  ████                                       │
│     │  ████  ████  ████  ████  ████                                 │
│   2 │  ████  ████  ████  ████  ████  ████                           │
│     │  ████  ████  ████  ████  ████  ████  ████  ████              │
│   0 └──┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────          │
│       0-10 10-20 20-30 30-40 40-50 50-60 60-70 70-80 80-90 90-100  │
│                      Churn Probability (%)                          │
│                                                                      │
│       LOW RISK ◄──────────────────────────────────► HIGH RISK       │
│                                                                      │
│  High Risk Clients (>50% churn probability):                        │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │ Client      │ Prob │ ARR    │ Top Risk Factors              │  │ │
│  ├────────────────────────────────────────────────────────────────┤ │
│  │ WA Health   │ 72%  │ $380K  │ NPS -15, Support SLA 45%      │  │ │
│  │ Alpine Hosp │ 58%  │ $120K  │ No meeting in 90 days         │  │ │
│  │ Peninsula   │ 54%  │ $95K   │ Champion left, no replacement │  │ │
│  └────────────────────────────────────────────────────────────────┘ │
│                                                                      │
│  Total ARR at Risk: $595,000                                        │
│  Recommended: Immediate outreach to WA Health (highest value risk) │
│                                                                      │
│  [View Mitigation Actions] [Export Risk Report] [Set Alerts]        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

#### Opportunity Scoring Breakdown

Understand why deals are scored the way they are:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🎯 Opportunity Score Breakdown: Barwon EMR Upgrade                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Overall Win Probability: 68%                                       │
│                                                                      │
│  Score Components:                                                   │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │                                                                  ││
│  │  MEDDPICC Score (28/40)                    ████████████████░░░░ ││
│  │  ├── Metrics: 4/5 ████████░░                                   ││
│  │  ├── Economic Buyer: 3/5 ██████░░░░   ← Needs improvement      ││
│  │  ├── Decision Criteria: 4/5 ████████░░                         ││
│  │  ├── Decision Process: 3/5 ██████░░░░                          ││
│  │  ├── Paper Process: 4/5 ████████░░                             ││
│  │  ├── Identify Pain: 5/5 ██████████                             ││
│  │  ├── Champion: 4/5 ████████░░                                  ││
│  │  └── Competition: 1/5 ██░░░░░░░░       ← Critical gap          ││
│  │                                                                  ││
│  │  Engagement Score (75/100)                ████████████████████░ ││
│  │  ├── Meeting Frequency: 85%                                     ││
│  │  ├── Response Time: 70%                                         ││
│  │  ├── Stakeholder Coverage: 60%            ← Needs improvement   ││
│  │  └── Content Engagement: 85%                                    ││
│  │                                                                  ││
│  │  Historical Pattern Match (72%)           ████████████████░░░░░ ││
│  │  ├── Similar to 14 won deals (avg 78%)                         ││
│  │  └── Similar to 6 lost deals (avg 35%)                         ││
│  │                                                                  ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  To Improve Win Probability:                                        │
│  1. Competition gap: Research Oracle's position (+8% if addressed) │
│  2. Economic Buyer: Request CFO meeting (+5% if engaged)           │
│  3. Stakeholder Coverage: Add 2 more contacts (+4% if expanded)    │
│                                                                      │
│  Potential Score with Actions: 68% → 85% (+17%)                    │
│                                                                      │
│  [Create Actions] [View Similar Deals] [Update MEDDPICC]            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Predictive Trend Visualisations

#### Confidence Cone Forecasts

Instead of single trend lines, show expanding confidence cones that widen into the future—communicating uncertainty honestly:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📈 Health Score Forecast: Barwon Health                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  100 ┤                                                               │
│      │                                         ╭─────── 90% conf    │
│   90 ┤                                    ╭────┤                     │
│      │                               ╭────┤    │                     │
│   80 ┤                          ╭────┤    │    ├─────── Best: 82    │
│      │                     ╭────┤    │    │    │                     │
│   70 ┤──●────●────●───●────┤    │    ├────┼────┤─────── Likely: 71  │
│      │                     │    │    │    │    │                     │
│   60 ┤                     │    ├────┤    │    ├─────── Worst: 58   │
│      │                     ├────┤    │    │    │                     │
│   50 ┤                     │    │    │    ╰────┤                     │
│      │                     │    │    ╰─────────┤                     │
│   40 ┤                     │    ╰──────────────╯                     │
│      │                     ╰─────────────────────────── 90% conf    │
│   30 └──┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬── │
│        Now  +2w  +4w  +6w  +8w +10w +12w                            │
│         ◄── Actual ──►◄────────── Forecast ──────────►              │
│                                                                      │
│  Confidence Interpretation:                                          │
│  ├── Narrow cone (now to +4w): High confidence, stable signals     │
│  ├── Widening cone (+4w to +8w): Renewal outcome uncertain         │
│  └── Wide cone (+8w to +12w): Multiple scenarios possible          │
│                                                                      │
│  Key Uncertainty Drivers:                                            │
│  1. Renewal decision (Feb 28) - binary outcome affects trajectory  │
│  2. New CIO starting (Mar 15) - relationship unknown               │
│  3. Support improvement initiative - results pending                │
│                                                                      │
│  [Narrow Range with Actions] [View Scenarios] [Set Alert at 60]     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Confidence Cone Logic:**

| Timeframe | Cone Width | Confidence | Basis |
|-----------|------------|------------|-------|
| 0-2 weeks | ±3 points | 95% | Recent trajectory, no known events |
| 2-4 weeks | ±8 points | 85% | Short-term momentum, minor uncertainty |
| 4-8 weeks | ±15 points | 75% | Medium-term, event-dependent |
| 8-12 weeks | ±25 points | 60% | Long-term, multiple variables |

#### Anomaly Highlighting

AI automatically highlights data points that deviate from expected patterns:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🔍 Anomaly Detection: NPS Responses                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Recent NPS Responses - Barwon Health                               │
│                                                                      │
│  10 ┤  ●     ●        ●     ●                                       │
│   9 ┤     ●     ●  ●           ●  ●                                 │
│   8 ┤        ●           ●              ●                           │
│   7 ┤                                         ●                     │
│   6 ┤                                                               │
│   5 ┤                                                               │
│   4 ┤                                                               │
│   3 ┤                                              ⚠️ ●              │
│   2 ┤                                              │ANOMALY│        │
│   1 ┤                                              └──────┘         │
│   0 └──┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬── │
│       Jan  Feb  Mar  Apr  May  Jun  Jul  Aug  Sep  Oct  Nov  Dec   │
│                                                                      │
│  ⚠️ ANOMALY DETECTED                                                │
│                                                                      │
│  Response from: David Wong (CIO)                                    │
│  Score: 3 (Detractor)                                               │
│  Expected Range: 7-9 based on historical pattern                    │
│  Deviation: 3.2 standard deviations below client average            │
│                                                                      │
│  Verbatim Feedback:                                                  │
│  "Extremely frustrated with reporting performance. Three months     │
│   of complaints and no resolution. Considering alternatives."       │
│                                                                      │
│  AI Analysis:                                                        │
│  • First detractor response from this client in 18 months           │
│  • David is a key stakeholder (CIO, Economic Buyer on 2 deals)     │
│  • "Considering alternatives" = competitive risk signal             │
│  • Correlates with 5 support tickets on reporting this quarter     │
│                                                                      │
│  Recommended Actions:                                                │
│  1. [URGENT] Schedule call with David within 24 hours               │
│  2. Escalate reporting issues to product team                       │
│  3. Prepare recovery plan with specific timeline                    │
│                                                                      │
│  [Create Urgent Action] [View David's History] [Escalate to Manager]│
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Anomaly Detection Types:**

| Anomaly Type | Detection Method | Alert Level |
|--------------|------------------|-------------|
| **Point Anomaly** | >2 std dev from mean | Medium |
| **Contextual Anomaly** | Unusual for that stakeholder/time | High |
| **Collective Anomaly** | Pattern break across multiple signals | Critical |
| **Trend Break** | Sudden direction change | High |
| **Missing Data** | Expected input not received | Medium |

#### Leading Indicator Alerts

Surface predictive relationships before outcomes occur:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🔮 Leading Indicator Alert                                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ⚠️ PREDICTIVE ALERT: Barwon Health NPS Likely to Drop             │
│                                                                      │
│  Confidence: 78%                                                    │
│  Predicted Impact: NPS likely to drop 8-15 points                   │
│  Timeframe: Next NPS survey (in 10 days)                            │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  Leading Indicator Pattern Detected:                                │
│                                                                      │
│      Support Tickets                    NPS Score                   │
│           (Leading)                    (Lagging)                    │
│                                                                      │
│  20 ┤      ╭──●                    +50 ┤────●                       │
│  15 ┤   ╭──╯                       +40 ┤     ╲                      │
│  10 ┤───╯                          +30 ┤      ╲──●                  │
│   5 ┤                              +20 ┤         ╲                  │
│   0 └─────────────                 +10 └──────────╲──?              │
│      -4w  -2w  Now                      -4w  -2w  Now  +2w          │
│                                                                      │
│      Tickets: +50% ▲                    NPS: Predicted to follow   │
│                                                                      │
│  Historical Pattern Evidence:                                       │
│  "In 23 similar cases across your portfolio, when support tickets  │
│   increased >40% in the 2 weeks before an NPS survey, NPS dropped  │
│   by an average of 12 points (range: 5-22 points)."                │
│                                                                      │
│  Current Situation:                                                  │
│  ├── Support tickets: Up 50% (12 → 18 in last 2 weeks)            │
│  ├── P1 tickets: 3 open (vs 0 normally)                            │
│  ├── Avg resolution time: 8.5 days (vs 3 days SLA)                 │
│  └── Next NPS survey: 10 days away                                 │
│                                                                      │
│  Intervention Opportunity:                                           │
│  "If you resolve the 3 P1 tickets before the survey, historical    │
│   data suggests NPS impact can be reduced by 60-70%."              │
│                                                                      │
│  Recommended Actions:                                                │
│  1. Escalate P1 tickets to priority resolution (today)              │
│  2. Proactive call to affected users to acknowledge issues          │
│  3. Consider delaying survey by 1 week if issues not resolved       │
│                                                                      │
│  [Create Escalation] [Call Affected Users] [Delay Survey]           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Leading Indicator Relationships Tracked:**

| Leading Indicator | Lagging Outcome | Typical Lag | Correlation |
|-------------------|-----------------|-------------|-------------|
| Support ticket volume | NPS score | 2-3 weeks | -0.72 |
| Meeting frequency drop | Health score decline | 4-6 weeks | -0.65 |
| Email response time increase | Relationship decay | 2-4 weeks | -0.58 |
| Champion engagement drop | Deal stall | 1-2 weeks | -0.81 |
| Competitor mentions | Churn risk | 8-12 weeks | +0.67 |
| Executive access gained | Deal advancement | 1-2 weeks | +0.74 |
| Product usage decline | Renewal risk | 6-8 weeks | -0.69 |

### Collaborative Visualisation Features

#### Shared Cursors

When collaborating on dashboards in real-time, see where teammates are focusing:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📊 Territory Dashboard - Collaborative View                        │
│  👥 3 viewers: You, Sarah T., Michael C.                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Revenue by Client                     Health Distribution          │
│  ┌─────────────────────────┐          ┌─────────────────────────┐  │
│  │ Barwon    ████████ $850K│          │ 90-100 ██████ 4        │  │
│  │ SA Health ████████████  │          │ 80-89  ████████ 6      │  │
│  │           🔵 Sarah      │          │ 70-79  ██████ 4        │  │
│  │ GHA       ██████ $620K  │          │ 60-69  ████ 3          │  │
│  │ WA Health ████ $380K    │          │ 🟢 Michael              │  │
│  │ Metro     ████ $350K    │          │ <60    ██ 2 ⚠️         │  │
│  └─────────────────────────┘          └─────────────────────────┘  │
│                                                                      │
│  Pipeline Trend                        Activity Feed               │
│  ┌─────────────────────────┐          ┌─────────────────────────┐  │
│  │     ●───────●           │          │ Sarah is viewing        │  │
│  │    ╱         ╲          │          │ "SA Health revenue"     │  │
│  │   ●           ●         │          │                         │  │
│  │  🟡 You                 │          │ Michael is viewing      │  │
│  │                         │          │ "Health <60 clients"    │  │
│  └─────────────────────────┘          └─────────────────────────┘  │
│                                                                      │
│  Cursor Legend:                                                      │
│  🔵 Sarah T. (Manager) - Reviewing SA Health performance           │
│  🟢 Michael C. (CAM) - Examining at-risk clients                   │
│  🟡 You - Analysing pipeline trend                                 │
│                                                                      │
│  [Start Screen Share] [Open Chat] [Leave Collaborative Mode]        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Collaborative Features:**

| Feature | Description |
|---------|-------------|
| **Cursor Visibility** | See teammate cursors with name labels in real-time |
| **Focus Indicators** | System announces when someone focuses on specific chart |
| **Follow Mode** | Click teammate's avatar to follow their view |
| **Pointer Mode** | Hold key to make your cursor visible to others for pointing |
| **Private Mode** | Toggle to hide your cursor from others |

#### Annotation Threads

Start discussions attached to specific data points:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📈 Health Score Timeline - Barwon Health                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  100 ┤                                                               │
│   80 ┤──●────●                                          ●────●      │
│   60 ┤        ╲                  💬3                   ╱            │
│   40 ┤         ●──────────●─────●───────●───────●───────●           │
│   20 ┤                    💬5                                       │
│      └──┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬── │
│        Jan  Feb  Mar  Apr  May  Jun  Jul  Aug  Sep  Oct  Nov  Dec   │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  💬 Thread on March Dip (5 comments)                    [Resolved ✓]│
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ Michael T. (Mar 16):                                            ││
│  │ "Why did we drop 25 points in one month? @Sarah can you check  ││
│  │  if there were support issues?"                                 ││
│  │                                                                  ││
│  │    Sarah T. (Mar 16):                                           ││
│  │    "Yes - major outage on Mar 12-14. 3 days downtime.          ││
│  │     Client escalated to exec level."                            ││
│  │                                                                  ││
│  │    Michael T. (Mar 17):                                         ││
│  │    "Got it. I've scheduled a recovery meeting for Mar 22.      ││
│  │     Adding this context as annotation."                         ││
│  │                                                                  ││
│  │    Jennifer W. (Mar 18):                                        ││
│  │    "FYI - similar issue at GHA last quarter. Recovery took     ││
│  │     6 weeks. Here's what worked: [link to playbook]"           ││
│  │                                                                  ││
│  │    Michael T. (Apr 5):                                          ││
│  │    "Marking resolved - health back to 72 after recovery plan.  ││
│  │     Thanks team!"                                               ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  💬 Thread on June Plateau (3 comments)                    [Active] │
│  └── Click to expand...                                             │
│                                                                      │
│  [+ New Thread] [Show All Threads] [Filter: Active Only]            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Annotation Thread Features:**

| Feature | Description |
|---------|-------------|
| **Point Attachment** | Threads attached to specific data points, persist over time |
| **@Mentions** | Tag teammates to notify them |
| **Status Tracking** | Mark threads as Active, Investigating, Resolved |
| **Link Sharing** | Share direct link to specific thread |
| **Search** | Find threads by keyword, author, or status |
| **Export** | Include thread context when exporting charts |

#### Presentation Mode

Transform any dashboard into a guided presentation:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🎬 Presentation Mode: Q3 Territory Review                          │
│  Slide 3 of 8 │ ◀ ● ● ● ● ○ ○ ○ ○ ▶ │ [Exit Presentation]         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│                    ┌─────────────────────────────────┐              │
│                    │                                 │              │
│                    │   📊 Pipeline Growth            │              │
│                    │                                 │              │
│                    │      $2.8M                      │              │
│                    │        │  ╭──●                  │              │
│                    │   $2M ─┼──╯                     │              │
│                    │        │                        │              │
│                    │   $1M ─┼──●                     │   ← FOCUS   │
│                    │        │                        │     HIGHLIGHT│
│                    │      ──┴────────────            │              │
│                    │       Q1    Q2    Q3            │              │
│                    │                                 │              │
│                    └─────────────────────────────────┘              │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ 🎤 Presenter Notes:                                             ││
│  │                                                                  ││
│  │ "Pipeline grew 40% from Q1 to Q3. Key drivers:                 ││
│  │  • Barwon EMR upgrade ($250K) - highlighted in yellow          ││
│  │  • Three new whitespace opportunities from NPS feedback         ││
│  │  • [CLICK] Let's drill into the Q3 spike..."                   ││
│  │                                                                  ││
│  │ Suggested talking time: 90 seconds                              ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  Animation Queue:                                                    │
│  1. ✓ Fade in chart                                                │
│  2. ✓ Highlight Q1→Q3 growth line                                  │
│  3. ○ [Click] Zoom to Q3 and show breakdown                        │
│  4. ○ [Click] Advance to next slide                                │
│                                                                      │
│  [◀ Previous] [▶ Next/Animate] [⏸ Pause] [🔗 Share Live Link]      │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Presentation Mode Features:**

| Feature | Description |
|---------|-------------|
| **Auto-Slide Creation** | AI suggests logical slide sequence from dashboard |
| **Focus Highlights** | Spotlight specific elements, dim others |
| **Animated Transitions** | Smooth animations between data states |
| **Presenter Notes** | AI-generated talking points for each slide |
| **Timing Guides** | Suggested duration per slide |
| **Live Sharing** | Attendees follow along in real-time via link |
| **Q&A Mode** | Pause to explore data based on audience questions |
| **Recording** | Record presentation with narration for async viewing |
| **Export** | Generate PowerPoint/PDF from presentation |

**Presentation Templates:**

| Template | Use Case | Auto-Generated Content |
|----------|----------|------------------------|
| **QBR Deck** | Client quarterly review | Health trend, support metrics, achievements, roadmap |
| **Territory Review** | Manager 1:1 | Pipeline status, forecast, wins/losses, risks |
| **Executive Summary** | Leadership update | Key metrics, trends, highlights, asks |
| **Deal Review** | Opportunity deep-dive | MEDDPICC, stakeholders, timeline, risks |
| **Win Story** | Team celebration | Journey, challenges overcome, impact |

### Immersive & Temporal Visualisations

#### Time-Lapse Replay

Watch your territory evolve over time in fast-forward—spot patterns invisible in static views:

```
┌─────────────────────────────────────────────────────────────────────┐
│  ⏱️ Time-Lapse Replay: FY26 Territory Evolution                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ◀◀  ◀  [▶ PLAYING]  ▶▶  │  Speed: [2x ▼]  │  Jul 2025 ━━●━━ Jun 2026│
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │                                                                  ││
│  │   Pipeline & Revenue - October 2025                             ││
│  │                                                                  ││
│  │   $3M ┤                    ╭─●                                  ││
│  │       │               ╭────╯    ← Pipeline growing              ││
│  │   $2M ┤          ╭────╯                                         ││
│  │       │     ╭────╯                                              ││
│  │   $1M ┤─────╯                                                   ││
│  │       │━━━━━━━━━━━━━━━━━━━━●  ← Committed (steady)             ││
│  │    $0 └──┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬──││
│  │         Jul  Aug  Sep  Oct  Nov  Dec  Jan  Feb  Mar  Apr  May  ││
│  │                        ▲                                        ││
│  │                    CURRENT                                      ││
│  │                                                                  ││
│  │   Client Health Bubbles:                                        ││
│  │   ┌─────────────────────────────────────────────────────────┐  ││
│  │   │  🟢 Metro    🟢 SA Health    🟡 GHA    🟡 Barwon  🔴 WA  │  ││
│  │   │    (85)         (82)         (68)       (65)     (48)   │  ││
│  │   │                                                          │  ││
│  │   │  [Bubbles animate: size=ARR, color=health, position=time]│  ││
│  │   └─────────────────────────────────────────────────────────┘  ││
│  │                                                                  ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  Events Timeline (synced with playback):                            │
│  ├── Jul 5: 🟢 Metro renewed (+$350K committed)                    │
│  ├── Aug 12: 🔴 WA Health support escalation (health -15)          │
│  ├── Sep 3: 🟡 Barwon EMR opportunity added (+$250K pipeline)      │
│  ├── Oct 15: 🟢 GHA expansion closed (+$180K committed) ◀ NOW      │
│  └── [Future events fade in as playback continues...]              │
│                                                                      │
│  Patterns Detected:                                                  │
│  ⚠️ Q2 Dip: Health scores dropped across 4 clients in Dec-Jan      │
│     (Possible cause: Holiday period reduced engagement)             │
│  ✓ Recovery Pattern: Clients who received Jan QBRs recovered faster│
│  ⚠️ WA Health: Continuous decline for 5 months—intervention needed │
│                                                                      │
│  [Pause at Key Moments] [Export as Video] [Share Replay Link]       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Time-Lapse Features:**

| Feature | Description |
|---------|-------------|
| **Speed Control** | 0.5x, 1x, 2x, 5x, 10x playback speed |
| **Scrubbing** | Drag timeline to jump to any point |
| **Event Markers** | Key events highlighted on timeline |
| **Pause Points** | Auto-pause at significant changes |
| **Split Screen** | Compare two time periods side-by-side |
| **Pattern Detection** | AI highlights recurring patterns |
| **Export** | Save as video for presentations |

### AI-Generated Visualisations

#### Natural Language to Chart

Describe what you want to see—AI creates the perfect visualisation:

```
┌─────────────────────────────────────────────────────────────────────┐
│  💬 Natural Language Visualisation                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Ask anything about your data:                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ "Show me clients with declining NPS but increasing support     ││
│  │  tickets over the last 6 months"                                ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  🤖 ChaSen: "I found 3 clients matching that pattern. Here's a     │
│  scatter plot showing the correlation, with trend arrows."          │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │                                                                  ││
│  │  NPS Change (6 months)                                          ││
│  │       +20 ┤                                                      ││
│  │       +10 ┤                                                      ││
│  │         0 ┤─────────────────────────────────────────────────    ││
│  │       -10 ┤                              🔴 GHA                  ││
│  │           │                              ╲                       ││
│  │       -20 ┤         🔴 Barwon            trend                  ││
│  │           │         ╲                                           ││
│  │       -30 ┤         trend    🔴 WA Health                       ││
│  │           │                   ╲                                  ││
│  │       -40 ┤                   trend                             ││
│  │           └──┬────┬────┬────┬────┬────┬────┬────┬────┬────┬──  ││
│  │             -20   0   +20  +40  +60  +80  +100 +120 +140 +160   ││
│  │                   Support Ticket Change (%)                      ││
│  │                                                                  ││
│  │  Bubble size = ARR at risk                                      ││
│  │  Arrow direction = trajectory over period                        ││
│  │                                                                  ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  Quick Queries (click to run):                                      │
│  ├── "Which deals have stalled longest?"                           │
│  ├── "Compare my win rate to team average"                         │
│  ├── "Show revenue concentration risk"                             │
│  └── "What's driving health score changes?"                        │
│                                                                      │
│  [Refine Query] [Save This Chart] [Schedule as Report]              │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Natural Language Capabilities:**

| Query Type | Example | Generated Visualisation |
|------------|---------|------------------------|
| **Comparison** | "Compare Q1 vs Q2 performance" | Side-by-side bar charts |
| **Trend** | "Show health score trends for at-risk clients" | Multi-line chart with annotations |
| **Distribution** | "How is ARR distributed across segments?" | Pie/donut or treemap |
| **Correlation** | "Is there a relationship between meeting frequency and NPS?" | Scatter plot with regression |
| **Ranking** | "Top 5 opportunities by MEDDPICC score" | Horizontal bar chart |
| **Time Series** | "Pipeline changes week over week" | Area chart with change indicators |
| **Composition** | "Break down revenue by product and client" | Stacked bar or Sankey |

#### Auto-Insight Generation

Every chart automatically comes with AI-generated insights:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📊 Portfolio Health Distribution                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  12 │  ████                                                         │
│  10 │  ████  ████                                                   │
│   8 │  ████  ████  ████                                             │
│   6 │  ████  ████  ████  ████                                       │
│   4 │  ████  ████  ████  ████  ████                                 │
│   2 │  ████  ████  ████  ████  ████  ████                           │
│   0 └──┬────┬────┬────┬────┬────┬────                               │
│       90+  80-89 70-79 60-69 50-59  <50                             │
│              Health Score Range                                      │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  🤖 AI-Generated Insights:                                          │
│                                                                      │
│  1. 📈 POSITIVE: "78% of your clients are in 'healthy' range       │
│     (70+), up from 65% last quarter. Your QBR initiative is        │
│     showing results."                                               │
│                                                                      │
│  2. ⚠️ CONCERN: "The 2 clients below 50 (WA Health, Alpine)        │
│     represent $500K ARR (12% of portfolio). Both have been         │
│     declining for 3+ months."                                       │
│                                                                      │
│  3. 💡 OPPORTUNITY: "Clients in the 70-79 range have highest       │
│     expansion potential. Historical data shows 45% expand within   │
│     6 months when engaged with upsell conversations."              │
│                                                                      │
│  4. 🔍 PATTERN: "Your 'healthy' clients share common traits:       │
│     monthly meetings, <48hr email response, NPS survey response    │
│     rate >80%. Consider applying this playbook to at-risk clients."│
│                                                                      │
│  [Deep Dive on Insight 2] [Create Action from Insight 3]            │
│  [Dismiss] [Rate Insights: 👍 👎]                                   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Auto-Insight Categories:**

| Category | Icon | Description | Example |
|----------|------|-------------|---------|
| **Positive Trend** | 📈 | Something improving | "Win rate up 12% vs last quarter" |
| **Concern** | ⚠️ | Issue needing attention | "3 clients showing churn signals" |
| **Opportunity** | 💡 | Actionable growth potential | "Whitespace identified in 5 accounts" |
| **Pattern** | 🔍 | Recurring behaviour | "Deals with exec sponsor close 2x faster" |
| **Anomaly** | 🚨 | Unexpected deviation | "This month's pipeline drop is unusual" |
| **Benchmark** | 📊 | Comparison to peers/history | "Your NPS is 15 points above team avg" |

#### Comparative Benchmarking

Understand your performance in context:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📊 Performance Benchmarking: Your Territory vs ANZ Average         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Compare against: [ANZ Average ▼]  Period: [FY26 YTD ▼]            │
│                                                                      │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │                                                                  ││
│  │  Metric              You      ANZ Avg    Diff     Significance  ││
│  │  ─────────────────────────────────────────────────────────────  ││
│  │  Pipeline Coverage   2.8x     2.3x      +0.5x    ✓ Sig. better ││
│  │  Win Rate            42%      38%       +4%      ~ Comparable   ││
│  │  Avg Deal Size       $185K    $165K     +$20K    ✓ Sig. better ││
│  │  Sales Cycle         68 days  72 days   -4 days  ~ Comparable   ││
│  │  Client Health Avg   74       71        +3       ~ Comparable   ││
│  │  NPS Average         +38      +32       +6       ✓ Sig. better ││
│  │  Forecast Accuracy   88%      82%       +6%      ✓ Sig. better ││
│  │  Churn Rate          4%       7%        -3%      ✓ Sig. better ││
│  │                                                                  ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  Visual Comparison:                                                  │
│                                                                      │
│  Pipeline Coverage    ████████████████████████████░░ 2.8x (You)    │
│                       ████████████████████░░░░░░░░░░ 2.3x (ANZ)    │
│                                                                      │
│  Win Rate             ████████████████████░░░░░░░░░░ 42% (You)     │
│                       ███████████████░░░░░░░░░░░░░░░ 38% (ANZ)     │
│                                                                      │
│  Churn Rate           ████░░░░░░░░░░░░░░░░░░░░░░░░░░ 4% (You) ✓    │
│                       ███████░░░░░░░░░░░░░░░░░░░░░░░ 7% (ANZ)      │
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  🤖 Benchmark Analysis:                                             │
│                                                                      │
│  "You're outperforming ANZ average in 5 of 8 key metrics.          │
│   Standout strengths: Pipeline coverage (+22%) and churn rate      │
│   (43% lower than average).                                         │
│                                                                      │
│   Opportunity area: Win rate is only slightly above average.        │
│   Top performers achieve 48%+. Consider MEDDPICC discipline—        │
│   your qualification scores average 24 vs 28 for top quartile."    │
│                                                                      │
│  Compare to: [Top Performer] [Bottom Quartile] [Same Segment]       │
│  [Historical Self] [Industry Benchmark]                             │
│                                                                      │
│  [Export Benchmark Report] [Set Improvement Goals] [Share]          │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Benchmarking Options:**

| Benchmark | Description | Use Case |
|-----------|-------------|----------|
| **Team Average** | Average across your team | Daily performance tracking |
| **Top Performer** | Best performer in team | Aspirational target |
| **Top Quartile** | Top 25% performers | Realistic stretch goal |
| **Same Segment** | Others with similar portfolio mix | Fair comparison |
| **Historical Self** | Your own past performance | Personal improvement |
| **Industry Benchmark** | Published industry standards | External validation |

### Real-Time Data Streams

#### News Sentiment Stream

Live feed of news about your clients with sentiment analysis:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📰 Client News Sentiment Stream                          [Live 🔴] │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Filter: [All Clients ▼] [All Sentiment ▼] [Last 7 Days ▼]         │
│                                                                      │
│  Sentiment Overview (Last 7 Days):                                  │
│  ██████████████████████░░░░░░░░░░░░  Positive: 18 │ Neutral: 12 │ Negative: 4│
│                                                                      │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                                      │
│  🟢 POSITIVE │ 2 minutes ago                                        │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ Barwon Health Wins Healthcare Innovation Award                  ││
│  │ Source: Australian Healthcare Week │ Relevance: 98%             ││
│  │                                                                  ││
│  │ "Barwon Health has been recognised for outstanding digital      ││
│  │  transformation, including EMR modernisation..."                ││
│  │                                                                  ││
│  │ Sentiment: Highly Positive (+0.92)                              ││
│  │ Altera Mention: Yes (EMR referenced)                            ││
│  │ Opportunity: Reference story, case study request                ││
│  │                                                                  ││
│  │ [Draft Congratulations] [Add to Success Stories] [Share]        ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  🟡 NEUTRAL │ 45 minutes ago                                        │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ SA Health Announces New CIO Appointment                         ││
│  │ Source: Government Gazette │ Relevance: 95%                     ││
│  │                                                                  ││
│  │ "Jennifer Walsh appointed as Chief Information Officer,         ││
│  │  effective March 1, 2026..."                                    ││
│  │                                                                  ││
│  │ Sentiment: Neutral (0.12)                                       ││
│  │ Impact: Stakeholder change - relationship action needed         ││
│  │ Risk: Current CIO (David) was our champion                      ││
│  │                                                                  ││
│  │ [Research Jennifer Walsh] [Update Stakeholder Map] [Alert CSE]  ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  🔴 NEGATIVE │ 3 hours ago                                          │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ WA Health Faces Budget Cuts Amid State Review                   ││
│  │ Source: The West Australian │ Relevance: 92%                    ││
│  │                                                                  ││
│  │ "WA Health to reduce operational spending by 8% following       ││
│  │  state treasury review. IT projects under scrutiny..."          ││
│  │                                                                  ││
│  │ Sentiment: Negative (-0.67)                                     ││
│  │ Impact: Budget pressure - pipeline at risk                      ││
│  │ Affected Pipeline: $350K Analytics opportunity                  ││
│  │                                                                  ││
│  │ [Add Risk to Plan] [Prepare Value Justification] [Call Client]  ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  🔴 URGENT │ Yesterday                                              │
│  ┌─────────────────────────────────────────────────────────────────┐│
│  │ ⚠️ Competitor Alert: Oracle Health Wins Metro Hospital Contract ││
│  │ Source: Oracle Press Release │ Relevance: 88%                   ││
│  │                                                                  ││
│  │ "Oracle Health announces 5-year contract with Metro Hospital    ││
│  │  for comprehensive EMR replacement..."                          ││
│  │                                                                  ││
│  │ Sentiment: Negative for Altera (-0.81)                          ││
│  │ Impact: Competitive loss in your territory                      ││
│  │ Learning: Metro was in early pipeline - what happened?          ││
│  │                                                                  ││
│  │ [Log Competitive Loss] [Request Win/Loss Analysis] [Debrief]    ││
│  └─────────────────────────────────────────────────────────────────┘│
│                                                                      │
│  [Load More] [Set Alert Rules] [Export News Digest]                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

**Sentiment Stream Features:**

| Feature | Description |
|---------|-------------|
| **Real-Time Updates** | News appears within minutes of publication |
| **Sentiment Scoring** | -1.0 (very negative) to +1.0 (very positive) |
| **Relevance Scoring** | How relevant to your clients (0-100%) |
| **Auto-Categorisation** | Awards, Leadership, Financial, Competitive, etc. |
| **Impact Assessment** | AI evaluates business impact on your relationship |
| **Action Suggestions** | Recommended responses based on news type |
| **Alert Rules** | Custom notifications for specific triggers |
| **Digest Mode** | Daily/weekly email summary option |

**Sentiment Alert Thresholds:**

| Sentiment | Score Range | Alert Level | Auto-Action |
|-----------|-------------|-------------|-------------|
| **Highly Positive** | +0.7 to +1.0 | Opportunity | Draft congratulations |
| **Positive** | +0.3 to +0.7 | FYI | Add to digest |
| **Neutral** | -0.3 to +0.3 | Monitor | Log only |
| **Negative** | -0.7 to -0.3 | Attention | Alert CSE |
| **Highly Negative** | -1.0 to -0.7 | Urgent | Alert CSE + Manager |

---

## Implementation Phases

### Phase 1: Foundation (2-3 weeks)
- [ ] Create unified `strategic_plans` database table
- [ ] Build shared component library:
  - [ ] MEDDPICC scoring component (8 criteria with evidence fields)
  - [ ] Risk assessment component (with Accusation Audit prompts)
  - [ ] Action plan component (linked to methodology stages)
  - [ ] Client selector component
  - [ ] Checkpoint recorder component (Voss milestones)
  - [ ] Hero Journey tracker component
- [ ] Implement plan type toggle with role-based defaults
- [ ] Create API routes for CRUD operations

### Phase 2: Core Workflow (3-4 weeks)
- [ ] Build 5-step wizard with progressive disclosure
- [ ] Implement role-based views (same data, different UI)
- [ ] Add auto-population from existing data sources:
  - [ ] Client health summary
  - [ ] NPS scores
  - [ ] Support metrics
  - [ ] CSE/CAM targets from BURC
- [ ] **Pipeline & Opportunity Management:**
  - [ ] Add/Edit/Remove opportunity UI
  - [ ] Opportunity form: Value, Stage, Close Date, Products
  - [ ] MEDDPICC scoring inline per opportunity
  - [ ] Stakeholder linking per opportunity
  - [ ] Pipeline table/card views with sorting/filtering
- [ ] **Dynamic Forecasting:**
  - [ ] Real-time forecast recalculation on opportunity change
  - [ ] Coverage ratio calculator (Pipeline ÷ Gap)
  - [ ] Forecast confidence bands (best/likely/worst)
  - [ ] What-if modelling ("If we lose X, forecast drops to...")
  - [ ] Forecast history tracking
- [ ] Port existing Territory/Account logic to unified workflow

### Phase 3: Collaboration & Operating Rhythm (3-4 weeks)
- [ ] **Core Collaboration:**
  - [ ] Real-time presence indicators (Supabase Realtime)
  - [ ] In-context commenting system
  - [ ] Activity log and version history
  - [ ] @mentions and notifications
- [ ] **Approval Workflow:**
  - [ ] Add approval columns to `strategic_plans` table
  - [ ] Create `plan_change_log` table for edit tracking
  - [ ] Build submission modal with ChaSen pre-flight checks
  - [ ] Build approver dashboard (pending approvals list)
  - [ ] Implement collaborative editing with change tracking
  - [ ] Add approval/withdrawal actions with activity logging
  - [ ] Build team visibility view (status board)
  - [ ] Implement notification system (immediate + weekly digest)
- [ ] **Next-Level Collaboration:**
  - [ ] Async handoff workflow (CAM ↔ CSE with AI summary)
  - [ ] Shared playbooks & templates library
  - [ ] Team dashboard view (territory coverage, attention alerts)
  - [ ] Review scheduling with auto-reminders
- [ ] **Operating Rhythm Integration:**
  - [ ] Create `plan_review_schedule` table
  - [ ] Auto-create reviews from `segmentation_events` calendar
  - [ ] Implement ChaSen "delta since last review" generator
  - [ ] Add review reminder notifications (7 days, 1 day before)
  - [ ] Build one-click "Approve & Submit" for quick reviews
  - [ ] Create team calendar view showing all upcoming reviews
  - [ ] Add "Skip with reason" for non-applicable reviews

### Phase 4: AI Enhancement (2-3 weeks)
- [ ] **ChaSen AI integration per step (reduce cognitive burden):**
  - [ ] Step 1: Priority client suggestion on load
  - [ ] Step 2: Target allocation suggestions based on segment/history
  - [ ] Step 3: Opportunity auto-discovery from NPS/meetings
  - [ ] Step 3: MEDDPICC auto-fill from existing data
  - [ ] Step 4: Risk auto-generation with Accusation Audit scripts
  - [ ] Step 5: Executive summary auto-generation
- [ ] **Pipeline AI features:**
  - [ ] Opportunity suggestions from NPS themes and meeting notes
  - [ ] Value estimation from similar deals
  - [ ] Win probability refinement using MEDDPICC + engagement signals
  - [ ] Stalled deal detection with suggested actions
  - [ ] Whitespace identification per client
- [ ] **Methodology coaching integration:**
  - [ ] MEDDPICC scoring suggestions with evidence
  - [ ] Gap Selling: Auto-generate current/future state analysis
  - [ ] Voss: Next Best Conversation scripts (opening, objection handling)
  - [ ] StoryBrand: Auto-generate SB7 narrative per client
  - [ ] Wortmann: Match relevant success stories from Story Matrix
  - [ ] Checkpoint prompts: Suggest which Voss milestone to target next
  - [ ] Hero Journey: AI recommendation for stage advancement actions
- [ ] Predictive risk indicators
- [ ] Auto-stakeholder detection from meeting transcripts

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
│   ├── pipeline/                       # Pipeline & Forecasting
│   │   ├── OpportunityForm.tsx         # Add/Edit opportunity modal
│   │   ├── OpportunityCard.tsx         # Single opportunity display
│   │   ├── PipelineTable.tsx           # Sortable opportunity list
│   │   ├── ForecastSummary.tsx         # Target/Committed/Forecast/Gap
│   │   ├── CoverageGauge.tsx           # Visual coverage ratio
│   │   ├── ForecastBands.tsx           # Best/Likely/Worst chart
│   │   ├── WhatIfModeller.tsx          # Scenario modelling
│   │   └── PipelineSuggestions.tsx     # ChaSen opportunity suggestions
│   ├── methodology/                   # Sales methodology components
│   │   ├── MethodologyCoach.tsx       # A.C.T.I.O.N. Framework guidance
│   │   ├── MethodologyQuestionnaire.tsx
│   │   ├── CheckpointRecorder.tsx     # Voss milestone tracking
│   │   ├── HeroJourneyTracker.tsx     # StoryBrand client transformation
│   │   ├── ValueVelocityMatrix.tsx    # Quadrant visualisation
│   │   ├── NextBestConversation.tsx   # AI-generated talk tracks
│   │   ├── AIPrePopulation.tsx        # Auto-fill from client data
│   │   └── QuestionnaireSection.tsx
│   ├── approval/                       # Approval workflow components
│   │   ├── SubmitForApprovalModal.tsx  # Submission modal with pre-flight checks
│   │   ├── ApproverDashboard.tsx       # Pending approvals list
│   │   ├── ChangeLogPanel.tsx          # View changes during review
│   │   ├── ChangeLogEntry.tsx          # Single change display
│   │   ├── TeamStatusBoard.tsx         # Team visibility view
│   │   └── ApprovalNotifications.tsx   # Notification preferences
│   └── index.ts
├── hooks/
│   ├── useStrategicPlan.ts
│   ├── usePlanPresence.ts
│   ├── usePlanComments.ts
│   ├── usePlanApproval.ts              # Approval workflow state & actions
│   ├── usePlanChangeLog.ts             # Change tracking during review
│   └── usePlanAI.ts
├── lib/
│   ├── planning/
│   │   ├── types.ts
│   │   ├── validation.ts
│   │   └── calculations.ts
│   └── unified-sales-methodology.ts    # A.C.T.I.O.N. Framework types & logic
├── app/api/planning/
│   ├── strategic/
│   │   ├── route.ts                  # GET/POST plans
│   │   └── [id]/
│   │       ├── route.ts              # GET/PUT/DELETE plan
│   │       ├── comments/route.ts
│   │       ├── presence/route.ts
│   │       ├── ai/route.ts
│   │       ├── submit/route.ts       # POST submit for approval
│   │       ├── approve/route.ts      # POST approve plan
│   │       ├── withdraw/route.ts     # POST withdraw from review
│   │       └── changes/route.ts      # GET change log for plan
│   ├── shared/
│   │   ├── portfolio/route.ts
│   │   ├── targets/route.ts
│   │   └── forecast/route.ts           # Forecast calculation & history
│   └── opportunities/
│       ├── route.ts                    # GET/POST opportunities
│       ├── [id]/route.ts               # GET/PUT/DELETE single opportunity
│       ├── suggest/route.ts            # AI opportunity suggestions
│       └── what-if/route.ts            # Scenario modelling
└── app/api/chasen/
    └── methodology/route.ts          # AI methodology coaching API
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

### Industry & Platform
- [Gainsight Success Planning](https://www.gainsight.com/customer-success/success-planning/)
- [ChurnZero AI Features](https://churnzero.com/features/)
- [Totango Outcome Success Plans](https://www.totango.com/product-features/outcome-success-plans)
- [PatternFly Wizard Guidelines](https://www.patternfly.org/components/wizard/design-guidelines/)
- [2026 Customer Success Planning Guide](https://advocacymaven.com/2026-customer-success-planning-guide/)

### Sales Methodologies (Integrated)
- **Gap Selling** - Keenan (2018) - Problem-centric selling, current→future state analysis
- **Never Split the Difference** - Chris Voss (2016) - Tactical empathy, calibrated questions, Black Swans
- **Building a StoryBrand** - Donald Miller (2017) - SB7 Framework, hero's journey narrative
- **What's Your Story** - Craig Wortmann (2006) - Story Matrix, reference selling
- **MEDDPICC** - Jack Napoli, Dick Dunkel - Opportunity qualification framework
