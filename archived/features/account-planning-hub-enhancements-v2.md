# Account Planning Hub Enhancement Proposal v2

**Document Version:** 2.0
**Date:** 9 January 2026
**Author:** AI Research & Analysis
**Status:** Proposal for Review

---

## Executive Summary

This document outlines comprehensive enhancements to the Account Planning Hub, informed by research into industry-leading platforms (Gong, Salesforce Einstein, ChurnZero, Gainsight, DemandFarm) and modern AI/digital-first approaches to account planning. The recommendations leverage existing Supabase data while proposing strategic new tables to unlock AI-powered insights for CSEs and CAMs.

**Key Themes:**
- 🧠 **AI-First Intelligence** - Automated insights, predictions, and recommendations
- 🎯 **Next Best Action** - Proactive guidance for account engagement
- 📊 **Predictive Health Scoring** - ML-driven churn and expansion prediction
- 🗺️ **Visual Relationship Intelligence** - Dynamic stakeholder mapping
- ⚡ **Automation & Efficiency** - Reduce manual data entry, increase selling time

---

## Part 1: Current State Analysis

### Existing Capabilities

| Feature | Status | Gap Analysis |
|---------|--------|--------------|
| Territory Strategy Plans | ✅ Implemented | Static data entry, no AI insights |
| Account Plans | ✅ Implemented | Manual stakeholder mapping, no automation |
| MEDDPICC Scoring | ✅ Basic | No AI scoring suggestions or gap analysis |
| Risk Assessment | ✅ Manual | No predictive risk modelling |
| Comments/Collaboration | ✅ Basic | No @mentions, threading, or notifications |
| Export (PDF/PPTX/DOCX/XLSX) | ✅ Implemented | Good coverage |
| Auto-save | ⚠️ Partial | Only account plans, not territory |
| Status Workflow | ✅ Implemented | Could add SLA tracking |
| Data Visualisation | ❌ Missing | No charts, graphs, or visual dashboards |
| AI Integration | ❌ Missing | No ChaSen integration |
| Health Score Integration | ⚠️ Partial | Display only, no trending/prediction |
| Meeting History Integration | ❌ Missing | Rich data available but not surfaced |
| NPS Integration | ⚠️ Partial | Score shown, feedback not analysed |
| Action Item Integration | ❌ Missing | No linking to open actions |

### Available Data Assets (Supabase)

Rich data exists that is **not currently leveraged**:

| Data Source | Records | Untapped Value |
|-------------|---------|----------------|
| `unified_meetings` | 204 | AI summaries, sentiment, effectiveness scores, decisions, risks, next steps |
| `client_health_history` | 594 | Health trajectories, component breakdowns, risk indicators |
| `nps_responses` | 199 | Verbatim feedback, topic classifications, sentiment |
| `actions` | 159 | AI context, urgency indicators, completion patterns |
| `aging_accounts` | 11 | Financial health, payment patterns |
| `portfolio_initiatives` | 6 | Strategic initiatives linkage |

---

## Part 2: Industry Best Practices Research

### Key Insights from Leading Platforms

#### Gong Revenue Intelligence
- **AI-powered deal insights** from conversation analysis
- **Pipeline risk visibility** across CRM stages
- **Automated activity capture** (emails, calls, meetings)
- **Next best action** recommendations based on winning patterns

#### Salesforce Einstein
- **Predictive lead/opportunity scoring** with conversion likelihood
- **Next-best-action recommendations** surfaced contextually
- **Automated relationship mapping** from email/calendar data
- **93% of IT leaders** plan autonomous agents within 2 years

#### ChurnZero Customer Success AI
- **Engagement AI** - Comprehensive relationship scores from interactions
- **Account Intelligence** - Executive-ready snapshots with outcomes, risks, next steps
- **AI Meeting Follow-ups** - Auto-generated from meeting notes
- **Success Plans** - AI-generated tailored paths to value
- **Sentiment tracking** over time to recognise shifts

#### Gainsight
- **Predictive analytics** with highest accuracy (requires technical expertise)
- **Forecasting & organisational mapping**
- **Sponsor tracking** for champion identification
- **Journey orchestration** at scale

#### MEDDPICC App & Plan2Close
- **Visual radar charts** and dashboards for deal qualification
- **Auto-generated actions** when gaps identified (answer "No" → create action)
- **Real-time scoring** with instant visual summaries
- **Native CRM integration** without leaving workflow

#### DemandFarm
- **AI-powered org charts** auto-generated from CRM data
- **Influence flow mapping** between decision-makers
- **Buying committee visualisation** for opportunities
- **80% automation** in relationship management (Slalom case study)
- **32% forecast accuracy improvement**, 28% win rate increase

### Modern Health Score Best Practices

From research on predictive analytics:

- **Multi-dimensional scoring** combining usage, engagement, financial, sentiment
- **Trajectory-based** (trend direction) not just point-in-time snapshots
- **3-6 month churn prediction** with 85%+ accuracy achievable
- **Automated interventions** triggered by score changes
- **Explainable AI** - show *why* a score changed, not just the number

---

## Part 3: Recommended Enhancements

### Enhancement 1: AI-Powered Account Intelligence

**Concept:** Integrate ChaSen AI to provide contextual insights, recommendations, and auto-generated content throughout the planning workflow.

#### Features:

| Feature | Description | Data Sources |
|---------|-------------|--------------|
| **Account Summary Generator** | One-click executive summary combining health, NPS, meetings, actions | `client_health_history`, `nps_responses`, `unified_meetings`, `actions` |
| **Risk Analysis AI** | Automatic risk identification with severity scoring | Meeting sentiments, NPS trends, action completion rates, aging data |
| **Opportunity Suggestions** | AI-recommended expansion opportunities based on patterns | Product adoption, health trends, peer comparisons |
| **MEDDPICC Gap Analyser** | Automated scoring suggestions with specific actions to close gaps | Meeting attendees (for Champion/EB), decision mentions, timeline discussions |
| **Meeting Insight Summary** | Last 90 days of engagement distilled into key themes | `unified_meetings` AI summaries, topics, decisions |
| **Stakeholder Recommendations** | Suggest missing roles based on MEDDPICC requirements | Meeting attendees vs stakeholder map |

#### UI Integration:

```
┌─────────────────────────────────────────────────────────────┐
│  🧠 ChaSen Account Intelligence                    [Refresh] │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📊 Account Health Trajectory                               │
│  ┌──────────────────────────────────────┐                  │
│  │  Score: 72 → 68 → 65 (↓ declining)   │                  │
│  │  [====================--------]       │                  │
│  │  ⚠️ 3-month downward trend detected   │                  │
│  └──────────────────────────────────────┘                  │
│                                                             │
│  🎯 Recommended Next Actions                                │
│  ┌──────────────────────────────────────┐                  │
│  │ 1. Schedule QBR - last meeting 47 days ago              │
│  │ 2. Address NPS detractor feedback from Sarah Chen       │
│  │ 3. Follow up on 3 overdue action items                  │
│  │ 4. Identify Economic Buyer (missing from stakeholders)  │
│  └──────────────────────────────────────┘                  │
│                                                             │
│  💡 Key Insights from Recent Meetings                       │
│  • Budget concerns mentioned 3x in last 2 meetings         │
│  • Champion (Jane Doe) sentiment shifted negative          │
│  • Competitor evaluation mentioned on 15 Dec               │
│                                                             │
│  [Generate Full Summary]  [Add to Plan]  [Ask ChaSen]      │
└─────────────────────────────────────────────────────────────┘
```

---

### Enhancement 2: Visual Stakeholder Relationship Map

**Concept:** Replace static stakeholder lists with interactive visual org charts showing influence flows, relationship strength, and MEDDPICC role coverage.

#### Features:

| Feature | Description |
|---------|-------------|
| **Interactive Org Chart** | Drag-and-drop visual hierarchy with role badges |
| **Influence Arrows** | Show who influences whom (direction + strength) |
| **Relationship Strength** | Based on meeting frequency, sentiment, engagement |
| **Role Coverage Indicators** | Visual MEDDPICC gap highlighting |
| **Auto-Population** | Suggest stakeholders from meeting attendees |
| **Engagement Timeline** | Last interaction date per stakeholder |
| **Risk Indicators** | Flag stakeholders with negative sentiment or disengagement |

#### Visual Design:

```
┌─────────────────────────────────────────────────────────────┐
│  🗺️ Stakeholder Relationship Map                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                    ┌─────────────┐                         │
│                    │ CEO         │                         │
│                    │ John Smith  │                         │
│                    │ [EB] 🟢     │                         │
│                    └──────┬──────┘                         │
│                           │                                 │
│              ┌────────────┴────────────┐                   │
│              │                         │                    │
│       ┌──────┴──────┐          ┌──────┴──────┐            │
│       │ CFO         │          │ CIO         │            │
│       │ Mary Jones  │ ←─────── │ Bob Lee     │            │
│       │ [EB] 🟢     │ influence│ [Champion]🟡│            │
│       └─────────────┘          └──────┬──────┘            │
│                                       │                    │
│                          ┌────────────┴────────────┐       │
│                          │                         │       │
│                   ┌──────┴──────┐          ┌──────┴──────┐ │
│                   │ IT Manager  │          │ Analyst     │ │
│                   │ Sarah Chen  │          │ Tim Wu      │ │
│                   │ [User] 🔴   │          │ [User] 🟢   │ │
│                   │ ⚠️ Detractor │          │ Promoter    │ │
│                   └─────────────┘          └─────────────┘ │
│                                                             │
│  Legend: 🟢 Engaged  🟡 Neutral  🔴 At Risk  [EB] Economic │
│          Buyer  ── Reporting  ← Influence                  │
│                                                             │
│  Coverage: ✅ EB  ✅ Champion  ❌ Coach  ✅ User            │
│                                                             │
│  [Add Stakeholder]  [Auto-Detect from Meetings]  [Export]  │
└─────────────────────────────────────────────────────────────┘
```

---

### Enhancement 3: Predictive Health & Risk Scoring

**Concept:** Move from static health display to AI-powered predictive analytics with explainable scoring and automated alerts.

#### Health Score Evolution:

| Current | Enhanced |
|---------|----------|
| Single point-in-time score | Trajectory with trend direction |
| Manual risk assessment | ML-predicted risk probability |
| No explanation | Explainable factors driving score |
| No alerts | Automated alerts on significant changes |
| No benchmarking | Peer comparison within tier/segment |

#### Predictive Models:

1. **Churn Risk Score (0-100)**
   - Inputs: Health trajectory, NPS trend, meeting frequency decline, action completion rate, aging balance, stakeholder engagement
   - Output: Probability of churn in next 90/180 days
   - Threshold alerts: >70 = Critical, 50-70 = Warning

2. **Expansion Probability (0-100)**
   - Inputs: Health improvement, promoter NPS, product adoption, positive sentiment, engagement increase
   - Output: Likelihood of expansion opportunity

3. **Engagement Velocity**
   - Meetings per quarter trend
   - Response time to actions
   - Stakeholder participation breadth

#### Risk Factors Dashboard:

```
┌─────────────────────────────────────────────────────────────┐
│  📈 Predictive Health Dashboard                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Health Score: 65/100     Trend: ↓ Declining (-7 pts/90d)  │
│  ┌──────────────────────────────────────────────────┐      │
│  │     80 ─┐                                        │      │
│  │         └──┐                                     │      │
│  │     70 ────└──┐                                  │      │
│  │               └──┐                               │      │
│  │     60 ──────────└──● 65                         │      │
│  │         Oct    Nov    Dec    Jan                 │      │
│  └──────────────────────────────────────────────────┘      │
│                                                             │
│  🚨 Churn Risk: 67% (Medium-High)                          │
│  📈 Expansion Probability: 12% (Low)                        │
│                                                             │
│  Risk Factors Contributing:                                 │
│  ├─ 📉 NPS dropped from 8 to 5 (-18 pts)                   │
│  ├─ 📅 No meetings in 45 days (-12 pts)                    │
│  ├─ ⏰ 4 overdue actions (-8 pts)                          │
│  └─ 💰 $45K in 90+ day aging (-5 pts)                      │
│                                                             │
│  Peer Comparison (Tier 1 accounts):                        │
│  Your account: 65  |  Tier avg: 74  |  Top quartile: 82   │
│                                                             │
│  [View Full Analysis]  [Set Alert Threshold]  [Export]     │
└─────────────────────────────────────────────────────────────┘
```

---

### Enhancement 4: Next Best Action Engine

**Concept:** AI-driven recommendations for what CSEs/CAMs should do next, prioritised by impact and urgency.

#### Action Categories:

| Category | Trigger Conditions | Example Actions |
|----------|-------------------|-----------------|
| **Engagement** | Meeting gap >30 days | "Schedule check-in with {client}" |
| **NPS Follow-up** | Detractor or score drop | "Address feedback from {contact}" |
| **Risk Mitigation** | Health decline, churn signals | "Escalate to leadership review" |
| **Relationship** | Missing MEDDPICC roles | "Identify Economic Buyer" |
| **Financial** | Aging balance >60 days | "Coordinate with finance on AR" |
| **Expansion** | High health + engagement | "Propose QBR with growth agenda" |
| **Action Completion** | Overdue items | "Complete 3 overdue actions" |

#### Prioritisation Algorithm:

```
Priority Score = (Impact Weight × Urgency Multiplier × Confidence)

Where:
- Impact: Potential revenue/health impact (1-10)
- Urgency: Time sensitivity (1-5, higher = more urgent)
- Confidence: AI confidence in recommendation (0-1)
```

#### UI Implementation:

```
┌─────────────────────────────────────────────────────────────┐
│  🎯 Next Best Actions for Acme Corp                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Priority │ Action                          │ Impact │ Due  │
│  ─────────┼─────────────────────────────────┼────────┼──────│
│  🔴 HIGH  │ Address NPS detractor feedback  │ +8 pts │ ASAP │
│           │ from Sarah Chen (IT Manager)    │        │      │
│           │ [Create Action] [View Feedback] │        │      │
│  ─────────┼─────────────────────────────────┼────────┼──────│
│  🟠 MED   │ Schedule QBR - 47 days since    │ +5 pts │ 7d   │
│           │ last meeting (avg: 21 days)     │        │      │
│           │ [Schedule Meeting] [View History]│       │      │
│  ─────────┼─────────────────────────────────┼────────┼──────│
│  🟠 MED   │ Identify Economic Buyer for     │ MEDDPICC│ 14d │
│           │ renewal discussion              │ gap    │      │
│           │ [Add Stakeholder] [View Org]    │        │      │
│  ─────────┼─────────────────────────────────┼────────┼──────│
│  🟡 LOW   │ Complete 3 overdue actions      │ +3 pts │ 21d  │
│           │ [View Actions]                  │        │      │
│  ─────────┴─────────────────────────────────┴────────┴──────│
│                                                             │
│  💡 AI Insight: Accounts with similar patterns that         │
│     addressed NPS feedback within 7 days saw 23% higher     │
│     renewal rates.                                          │
│                                                             │
│  [Accept All]  [Dismiss]  [Customise Priorities]           │
└─────────────────────────────────────────────────────────────┘
```

---

### Enhancement 5: Intelligent MEDDPICC Scoring

**Concept:** AI-assisted MEDDPICC scoring with auto-detection, gap analysis, and actionable recommendations.

#### Auto-Detection Sources:

| MEDDPICC Element | Detection Method |
|------------------|-----------------|
| **Metrics** | Meeting transcripts mentioning KPIs, ROI, success metrics |
| **Economic Buyer** | Meeting attendees with C-level/VP titles, decision mentions |
| **Decision Criteria** | Requirements, evaluation criteria in meeting notes |
| **Decision Process** | Timeline discussions, approval workflow mentions |
| **Paper Process** | Contract, legal, procurement mentions |
| **Identify Pain** | Problem statements, challenges in NPS feedback/meetings |
| **Champion** | High-engagement contacts, positive sentiment, internal advocacy |
| **Competition** | Competitor mentions in meetings or NPS feedback |

#### Visual Scoring:

```
┌─────────────────────────────────────────────────────────────┐
│  🎯 MEDDPICC Analysis - Acme Corp Renewal                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Overall Score: 62/100  [██████████░░░░░░░░░░]              │
│                                                             │
│       Metrics ████████████░░░░ 75%  ✅ ROI documented       │
│  Economic Buyer ████░░░░░░░░░░░░ 25%  ⚠️ Not identified    │
│  Decision Crit. ██████████████░░ 85%  ✅ Requirements clear │
│  Decision Proc. ████████░░░░░░░░ 50%  🔍 Timeline unclear  │
│  Paper Process  ██░░░░░░░░░░░░░░ 15%  ❌ Unknown           │
│   Identify Pain █████████████░░░ 80%  ✅ Pain documented   │
│       Champion  ████████████░░░░ 70%  🔍 Engagement dropping│
│     Competition ██████░░░░░░░░░░ 40%  ⚠️ Competitor active │
│                                                             │
│  🤖 AI-Detected Signals:                                    │
│  ├─ "Budget approval needed from CFO" → EB likely CFO      │
│  ├─ "Evaluating alternatives" (15 Dec) → Competition risk  │
│  └─ Champion (Bob Lee) hasn't attended last 2 meetings     │
│                                                             │
│  📋 Recommended Actions to Improve Score:                   │
│  1. Request intro to CFO (Economic Buyer) via Bob Lee      │
│  2. Clarify procurement/legal process timeline             │
│  3. Re-engage champion - schedule 1:1                      │
│  4. Gather competitive intelligence                        │
│                                                             │
│  [Apply AI Suggestions]  [Manual Override]  [View History] │
└─────────────────────────────────────────────────────────────┘
```

---

### Enhancement 6: Meeting & Engagement Timeline

**Concept:** Visual timeline showing all engagement touchpoints with sentiment indicators and key outcomes.

#### Timeline View:

```
┌─────────────────────────────────────────────────────────────┐
│  📅 Engagement Timeline - Acme Corp (Last 6 Months)         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Jan 2026                                                   │
│  ────────────────────────────────────────────────────       │
│       No meetings scheduled ⚠️                              │
│                                                             │
│  Dec 2025                                                   │
│  ────────────────────────────────────────────────────       │
│  15 │ 📞 QBR Review                           Sentiment: 😐 │
│     │    Attendees: Bob Lee, Sarah Chen                    │
│     │    Key Topics: Budget concerns, competitor eval      │
│     │    Decisions: Defer expansion discussion             │
│     │    [View Summary] [View Actions]                     │
│     │                                                       │
│  03 │ 📧 NPS Response - Sarah Chen            Score: 5 😞  │
│     │    "Support response times have degraded..."         │
│     │    [View Full Response] [Create Follow-up]           │
│                                                             │
│  Nov 2025                                                   │
│  ────────────────────────────────────────────────────       │
│  22 │ 📞 Monthly Check-in                     Sentiment: 🙂 │
│     │    Attendees: Bob Lee, Tim Wu                        │
│     │    Key Topics: Product roadmap, training needs       │
│     │    [View Summary]                                     │
│     │                                                       │
│  10 │ ✅ Action Completed: Security review    On Time      │
│     │                                                       │
│  05 │ 📞 Technical Deep Dive                  Sentiment: 🙂 │
│     │    Attendees: Sarah Chen, Tim Wu, IT Team            │
│     │    [View Summary]                                     │
│                                                             │
│  Engagement Velocity: 2.3 meetings/month (↓ from 3.1)      │
│  Sentiment Trend: Declining over 3 months                   │
│                                                             │
│  [Filter by Type]  [Export Timeline]  [Compare to Peers]   │
└─────────────────────────────────────────────────────────────┘
```

---

### Enhancement 7: Automated Plan Generation

**Concept:** AI-generated draft plans that CSEs/CAMs can review and refine, dramatically reducing manual data entry.

#### Auto-Generation Capabilities:

| Section | Auto-Generated From |
|---------|-------------------|
| Account Snapshot | `client_health_history`, `client_segmentation`, calculated ARR |
| Stakeholder Map | `unified_meetings` attendees + role inference |
| Engagement Summary | `unified_meetings` AI summaries, topics, sentiment |
| Risk Assessment | Health trends, NPS decline, action completion, aging |
| Opportunities | Expansion signals, positive sentiment, adoption patterns |
| Action Plan | `actions` open items + AI-recommended next steps |
| MEDDPICC Scores | Meeting transcript analysis + stakeholder coverage |

#### Generation Flow:

```
┌─────────────────────────────────────────────────────────────┐
│  🪄 Generate Account Plan - Acme Corp                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ChaSen AI will analyse available data and generate a      │
│  draft account plan for your review.                        │
│                                                             │
│  Data Sources to Analyse:                                   │
│  ☑️ Health History (12 monthly snapshots)                   │
│  ☑️ Meeting Records (8 meetings in last 6 months)          │
│  ☑️ NPS Responses (3 responses, latest: Dec 2025)          │
│  ☑️ Open Actions (4 items, 2 overdue)                       │
│  ☑️ Aging Balance ($45,230 outstanding)                     │
│  ☑️ Segmentation & Tier Data                                │
│                                                             │
│  Sections to Generate:                                      │
│  ☑️ Account Snapshot & Health Analysis                      │
│  ☑️ Stakeholder Map (from meeting attendees)               │
│  ☑️ Engagement & Adoption Summary                           │
│  ☑️ Risk Assessment with Mitigation                         │
│  ☑️ MEDDPICC Scoring (AI-assisted)                         │
│  ☑️ Recommended Action Plan                                 │
│                                                             │
│  ⏱️ Estimated generation time: 15-30 seconds               │
│                                                             │
│  [Generate Draft Plan]  [Customise Sections]  [Cancel]     │
└─────────────────────────────────────────────────────────────┘
```

---

### Enhancement 8: Portfolio Analytics Dashboard

**Concept:** Visual dashboard for territory-level insights with drill-down capabilities.

#### Dashboard Components:

```
┌─────────────────────────────────────────────────────────────┐
│  📊 Portfolio Analytics - Victoria Territory                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐        │
│  │ Total ARR    │ │ Avg Health   │ │ At-Risk      │        │
│  │ $4.2M        │ │ 71/100       │ │ 3 accounts   │        │
│  │ ↑ 12% YoY    │ │ ↓ -3 pts     │ │ $890K ARR    │        │
│  └──────────────┘ └──────────────┘ └──────────────┘        │
│                                                             │
│  Health Distribution          Engagement Velocity           │
│  ┌────────────────────┐      ┌────────────────────┐        │
│  │ ████ Healthy (8)   │      │ Q1  ████████ 3.2   │        │
│  │ ██ Warning (4)     │      │ Q2  ██████ 2.8     │        │
│  │ █ Critical (3)     │      │ Q3  █████ 2.4      │        │
│  └────────────────────┘      │ Q4  ████ 2.1       │        │
│                              └────────────────────┘        │
│                                                             │
│  Accounts Requiring Attention:                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Client          │ Health │ Risk   │ Days Since │ NPS │   │
│  │─────────────────┼────────┼────────┼────────────┼─────│   │
│  │ Acme Corp       │ 65 ↓   │ 67%    │ 47         │ 5   │   │
│  │ Beta Industries │ 58 ↓   │ 72%    │ 31         │ 4   │   │
│  │ Gamma Health    │ 61 →   │ 54%    │ 22         │ 6   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  [View All Accounts]  [Export Report]  [Set Alerts]        │
└─────────────────────────────────────────────────────────────┘
```

---

## Part 4: Proposed Database Schema Changes

### New Tables

#### 1. `account_plan_ai_insights`
Stores AI-generated insights for account plans.

```sql
CREATE TABLE account_plan_ai_insights (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES clients(id),
  client_name TEXT NOT NULL,
  insight_type TEXT NOT NULL, -- 'risk', 'opportunity', 'action', 'stakeholder', 'meddpicc'
  insight_category TEXT, -- 'engagement', 'financial', 'sentiment', 'relationship'
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  confidence_score DECIMAL(3,2), -- 0.00 to 1.00
  priority TEXT, -- 'critical', 'high', 'medium', 'low'
  impact_score INTEGER, -- 1-10
  data_sources JSONB, -- Array of source references
  recommended_actions JSONB, -- Array of suggested actions
  is_dismissed BOOLEAN DEFAULT FALSE,
  dismissed_by TEXT,
  dismissed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ -- Insights can expire
);
```

#### 2. `next_best_actions`
Stores AI-recommended actions for CSEs/CAMs.

```sql
CREATE TABLE next_best_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID REFERENCES clients(id),
  client_name TEXT NOT NULL,
  cse_name TEXT,
  cam_name TEXT,
  action_type TEXT NOT NULL, -- 'engagement', 'nps_followup', 'risk_mitigation', etc.
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  priority_score DECIMAL(5,2), -- Calculated priority
  impact_category TEXT, -- 'health', 'revenue', 'relationship', 'meddpicc'
  estimated_impact INTEGER, -- Points improvement or risk reduction
  urgency_level TEXT, -- 'immediate', 'this_week', 'this_month'
  trigger_reason TEXT, -- Why this action was recommended
  trigger_data JSONB, -- Supporting data
  status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'completed', 'dismissed'
  accepted_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  dismissed_at TIMESTAMPTZ,
  dismissed_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ
);
```

#### 3. `stakeholder_relationships`
Stores relationship mapping data.

```sql
CREATE TABLE stakeholder_relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID, -- References account_plans
  client_id UUID,
  client_name TEXT NOT NULL,
  stakeholder_name TEXT NOT NULL,
  stakeholder_email TEXT,
  stakeholder_title TEXT,
  stakeholder_role TEXT, -- 'economic_buyer', 'champion', 'influencer', 'user', 'blocker', 'coach'
  meddpicc_role TEXT, -- Specific MEDDPICC mapping
  department TEXT,
  reports_to UUID, -- Self-reference for org hierarchy
  influence_level INTEGER, -- 1-10
  engagement_score INTEGER, -- Calculated from meetings
  sentiment TEXT, -- 'positive', 'neutral', 'negative'
  last_interaction_date DATE,
  interaction_count INTEGER DEFAULT 0,
  relationship_strength TEXT, -- 'strong', 'moderate', 'weak', 'unknown'
  notes TEXT,
  is_primary_contact BOOLEAN DEFAULT FALSE,
  is_decision_maker BOOLEAN DEFAULT FALSE,
  auto_detected BOOLEAN DEFAULT FALSE, -- True if detected from meetings
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 4. `stakeholder_influences`
Stores influence relationships between stakeholders.

```sql
CREATE TABLE stakeholder_influences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_stakeholder_id UUID REFERENCES stakeholder_relationships(id),
  to_stakeholder_id UUID REFERENCES stakeholder_relationships(id),
  influence_type TEXT, -- 'reports_to', 'influences', 'blocks', 'champions'
  influence_strength INTEGER, -- 1-10
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 5. `predictive_health_scores`
Stores ML-predicted health and risk scores.

```sql
CREATE TABLE predictive_health_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID,
  client_name TEXT NOT NULL,
  calculation_date DATE NOT NULL,
  current_health_score INTEGER,
  predicted_health_30d INTEGER,
  predicted_health_90d INTEGER,
  churn_risk_score DECIMAL(5,2), -- 0-100
  expansion_probability DECIMAL(5,2), -- 0-100
  engagement_velocity DECIMAL(5,2),
  risk_factors JSONB, -- Array of contributing factors
  opportunity_signals JSONB, -- Array of positive signals
  model_version TEXT,
  confidence_score DECIMAL(3,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 6. `meddpicc_scores`
Stores detailed MEDDPICC scoring with AI assistance.

```sql
CREATE TABLE meddpicc_scores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID, -- References account_plans or territory_strategies
  plan_type TEXT, -- 'account' or 'territory'
  client_id UUID,
  client_name TEXT,
  opportunity_name TEXT,

  -- Individual scores (0-100)
  metrics_score INTEGER,
  metrics_evidence TEXT,
  metrics_ai_detected JSONB,

  economic_buyer_score INTEGER,
  economic_buyer_evidence TEXT,
  economic_buyer_ai_detected JSONB,

  decision_criteria_score INTEGER,
  decision_criteria_evidence TEXT,
  decision_criteria_ai_detected JSONB,

  decision_process_score INTEGER,
  decision_process_evidence TEXT,
  decision_process_ai_detected JSONB,

  paper_process_score INTEGER,
  paper_process_evidence TEXT,
  paper_process_ai_detected JSONB,

  identify_pain_score INTEGER,
  identify_pain_evidence TEXT,
  identify_pain_ai_detected JSONB,

  champion_score INTEGER,
  champion_evidence TEXT,
  champion_ai_detected JSONB,

  competition_score INTEGER,
  competition_evidence TEXT,
  competition_ai_detected JSONB,

  overall_score INTEGER, -- Weighted average
  gap_analysis JSONB, -- AI-identified gaps
  recommended_actions JSONB, -- AI-recommended actions

  last_ai_analysis TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### 7. `engagement_timeline`
Denormalised view of all client touchpoints.

```sql
CREATE TABLE engagement_timeline (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id UUID,
  client_name TEXT NOT NULL,
  event_type TEXT NOT NULL, -- 'meeting', 'nps', 'action', 'health_change', 'note'
  event_date TIMESTAMPTZ NOT NULL,
  event_title TEXT,
  event_summary TEXT,
  sentiment TEXT,
  participants JSONB,
  key_topics JSONB,
  outcomes JSONB,
  source_id UUID, -- Reference to source record
  source_table TEXT, -- 'unified_meetings', 'nps_responses', 'actions', etc.
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Indexes for Performance

```sql
-- Insights lookup
CREATE INDEX idx_insights_client ON account_plan_ai_insights(client_id, insight_type);
CREATE INDEX idx_insights_active ON account_plan_ai_insights(client_id) WHERE NOT is_dismissed AND expires_at > NOW();

-- Next best actions
CREATE INDEX idx_nba_cse ON next_best_actions(cse_name, status);
CREATE INDEX idx_nba_client ON next_best_actions(client_id, status);
CREATE INDEX idx_nba_priority ON next_best_actions(priority_score DESC) WHERE status = 'pending';

-- Stakeholders
CREATE INDEX idx_stakeholders_client ON stakeholder_relationships(client_id);
CREATE INDEX idx_stakeholders_plan ON stakeholder_relationships(plan_id);
CREATE INDEX idx_stakeholders_role ON stakeholder_relationships(stakeholder_role);

-- Predictive scores
CREATE INDEX idx_predictive_client ON predictive_health_scores(client_id, calculation_date DESC);
CREATE INDEX idx_predictive_risk ON predictive_health_scores(churn_risk_score DESC) WHERE calculation_date = CURRENT_DATE;

-- MEDDPICC
CREATE INDEX idx_meddpicc_plan ON meddpicc_scores(plan_id, plan_type);

-- Timeline
CREATE INDEX idx_timeline_client ON engagement_timeline(client_id, event_date DESC);
CREATE INDEX idx_timeline_type ON engagement_timeline(client_id, event_type, event_date DESC);
```

---

## Part 5: Implementation Roadmap

### Phase 1: Foundation (Weeks 1-3)
- [ ] Create new database tables and indexes
- [ ] Build engagement timeline aggregation job
- [ ] Implement stakeholder relationship data model
- [ ] Add auto-save to territory strategy forms
- [ ] Basic data visualisation components (charts, graphs)

### Phase 2: AI Integration (Weeks 4-6)
- [ ] ChaSen API endpoint for account intelligence
- [ ] AI insight generation pipeline
- [ ] MEDDPICC auto-detection from meeting transcripts
- [ ] Stakeholder auto-population from meetings
- [ ] Risk factor analysis engine

### Phase 3: Predictive Analytics (Weeks 7-9)
- [ ] Churn risk prediction model
- [ ] Expansion probability model
- [ ] Engagement velocity calculations
- [ ] Health score trajectory analysis
- [ ] Peer benchmarking system

### Phase 4: Next Best Action Engine (Weeks 10-12)
- [ ] Action recommendation algorithm
- [ ] Priority scoring system
- [ ] UI integration for recommendations
- [ ] Action tracking and feedback loop
- [ ] Notification integration

### Phase 5: Advanced Features (Weeks 13-16)
- [ ] Visual stakeholder mapping UI
- [ ] Automated plan generation
- [ ] Portfolio analytics dashboard
- [ ] Advanced MEDDPICC visualisation
- [ ] Mobile-responsive enhancements

---

## Part 6: Success Metrics

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| Plan completion rate | ~60% | 90% | Plans reaching 100% completion |
| Time to create plan | ~2 hours | 30 mins | With AI auto-generation |
| CSE/CAM adoption | Unknown | 80% | Weekly active users |
| At-risk accounts identified early | Manual | Automated | AI detection vs manual |
| Action completion rate | Unknown | 75% | NBA acceptance and completion |
| Health score accuracy | N/A | 85% | Predicted vs actual outcomes |

---

## Part 7: Technical Considerations

### ChaSen Integration Points

```typescript
// New ChaSen capabilities needed
interface AccountPlanningAI {
  generateAccountSummary(clientId: string): Promise<AccountSummary>;
  analyseRisks(clientId: string): Promise<RiskAnalysis>;
  detectMEDDPICC(clientId: string, meetings: Meeting[]): Promise<MEDDPICCScores>;
  suggestStakeholders(clientId: string, meetings: Meeting[]): Promise<Stakeholder[]>;
  generateNextBestActions(clientId: string): Promise<NextBestAction[]>;
  generateDraftPlan(clientId: string, options: PlanOptions): Promise<DraftPlan>;
}
```

### API Routes Required

```
POST /api/planning/ai/generate-insights
POST /api/planning/ai/generate-plan
POST /api/planning/ai/analyse-meddpicc
POST /api/planning/ai/suggest-stakeholders
GET  /api/planning/ai/next-best-actions
POST /api/planning/ai/accept-action
POST /api/planning/ai/dismiss-action
GET  /api/planning/predictive/health
GET  /api/planning/predictive/churn-risk
GET  /api/planning/timeline/:clientId
GET  /api/planning/stakeholders/:clientId
POST /api/planning/stakeholders/influence
GET  /api/planning/portfolio/analytics
```

### Real-time Updates

- Use Supabase real-time for collaborative editing
- Push notifications for plan status changes
- Live update of AI insights as new data arrives

---

## Sources & References

### Industry Research
- [Gong Salesforce Integration](https://www.oliv.ai/blog/gong-salesforce-integrations)
- [AI Sales Task Prioritisation - Gong](https://www.gong.io/blog/ai-sales-task-prioritization)
- [Salesforce AI Features 2025-26](https://closeloop.com/blog/salesforce-ai-what-enterprise-leaders-need-to-know/)
- [MEDDPICC App by MEDDIC Academy](https://meddic.academy/meddpicc-app/)
- [Plan2Close MEDDPICC for Salesforce](https://fox59.com/business/press-releases/ein-presswire/808394637/plan2close-meddpicc-brings-meddpicc-into-salesforce/)
- [DemandFarm Opportunity Planner](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N4V00000IhHWdUAN)
- [ChurnZero Customer Success AI](https://churnzero.com/features/customer-success-ai/)
- [ChurnZero Q1 2025 Release Notes](https://churnzero.com/blog/churnzero-product-release-notes-q1-2025-engagement-ai-synthesia-integration-success-plans/)
- [ChurnZero vs Gainsight Comparison](https://www.velaris.io/comparison/churnzero-vs-gainsight)
- [Customer Health Score Guide 2025](https://www.everafter.ai/glossary/customer-health-score)
- [Building Customer Health Scores](https://secondary.ai/blog/it-software/customer-health-score-churn-prediction-expansion)
- [Stakeholder Mapping in B2B Sales](https://inaccord.com/blog-posts/5-important-elements-of-stakeholder-mapping-in-b2b-sales)
- [Relationship Intelligence Tools 2025](https://nektar.ai/top-10-relationship-intelligence-tools-for-2025/)
- [AI Account Management Tools 2025](https://salesmotion.io/blog/top-ai-account-intelligence-tools)
- [Must-Have AI Sales Pipeline Tools](https://www.outreach.io/resources/blog/best-ai-sales-pipeline-tools)

---

## Part 8: Segmentation Events Integration

### Overview

The Segmentation Events system tracks tier-based compliance requirements (12 event types across 6 segments). Integrating this with Account Planning creates a **proactive engagement framework** that ensures CSEs/CAMs plan for required touchpoints.

### Current Segmentation Data Available

| Table | Purpose | Integration Value |
|-------|---------|-------------------|
| `segmentation_event_types` | 12 official event types | Event planning templates |
| `tier_event_requirements` | Segment-specific frequencies | Auto-calculate required events per client |
| `segmentation_events` | Individual event tracking | Historical engagement + upcoming schedule |
| `segmentation_event_compliance` | Per-event-type compliance | Gap identification for planning |
| `segmentation_compliance_scores` | Overall client compliance | Health score component |
| `client_segmentation` | Tier assignments + history | Plan based on segment requirements |

### Segment-Based Event Requirements

```
┌─────────────────────────────────────────────────────────────────────┐
│  Tier-Based Annual Requirements                                     │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  GIANT (Highest Touch)                                              │
│  ├─ Health Check (Opal): 4/year (quarterly)                        │
│  ├─ Insight Touch Point: 4/year (quarterly)                        │
│  ├─ Strategic Ops Review: 2/year (bi-annual)                       │
│  ├─ President/EVP Engagement: 1/year (annual)                      │
│  └─ Total Required Events: ~15-18/year                             │
│                                                                     │
│  COLLABORATION                                                      │
│  ├─ Health Check: 3/year (tri-annual)                              │
│  ├─ Insight Touch: 3/year (tri-annual)                             │
│  ├─ Strategic Review: 1/year (annual)                              │
│  └─ Total Required Events: ~10-12/year                             │
│                                                                     │
│  LEVERAGE / MAINTAIN / NURTURE                                      │
│  ├─ Health Check: 2/year (bi-annual)                               │
│  ├─ Insight Touch: 1/year (annual)                                 │
│  └─ Total Required Events: ~4-6/year                               │
│                                                                     │
│  SLEEPING GIANT (Minimal)                                           │
│  └─ Total Required Events: ~1-2/year                               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Enhancement 9: Segmentation Events in Account Plans

**Concept:** Embed compliance requirements and event scheduling directly into Account Plans.

#### Account Plan - Compliance Section:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📅 Engagement Compliance - Acme Corp (Giant Segment)               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Overall Compliance: 67% ⚠️ AT-RISK                                │
│  ┌──────────────────────────────────────────────────────────┐      │
│  │ [████████████████████░░░░░░░░░░] 67%                     │      │
│  │ 10 of 15 required events completed (FY26)                │      │
│  └──────────────────────────────────────────────────────────┘      │
│                                                                     │
│  Event Type Breakdown:                                              │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Event Type          │ Req │ Done │ Status    │ Next Due     │   │
│  │─────────────────────┼─────┼──────┼───────────┼──────────────│   │
│  │ Health Check (Opal) │ 4   │ 3    │ 🟢 On Track│ Mar 2026    │   │
│  │ Insight Touch Point │ 4   │ 2    │ 🟠 Behind │ OVERDUE     │   │
│  │ Strategic Ops Review│ 2   │ 1    │ 🟢 On Track│ Jun 2026    │   │
│  │ EVP Engagement      │ 1   │ 0    │ 🔴 Missing │ Q2 2026     │   │
│  │ SLA Review          │ 2   │ 2    │ ✅ Complete│ —           │   │
│  │ Release Planning    │ 2   │ 2    │ ✅ Complete│ —           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  🤖 AI Recommendations:                                             │
│  ├─ Schedule Insight Touch Point immediately (45 days overdue)     │
│  ├─ Plan EVP engagement for Q2 - suggest combining with QBR        │
│  └─ Current trajectory predicts 80% compliance by year-end         │
│                                                                     │
│  Upcoming Scheduled Events:                                         │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ 15 Feb │ Health Check (Opal)     │ Bob Lee, Sarah Chen     │   │
│  │ 01 Mar │ Strategic Ops Review    │ Pending confirmation    │   │
│  │ TBD    │ Insight Touch Point     │ ⚠️ NEEDS SCHEDULING     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  [Schedule Event]  [View Full Calendar]  [Link to Meeting]         │
└─────────────────────────────────────────────────────────────────────┘
```

#### Features:

| Feature | Description |
|---------|-------------|
| **Auto-Requirements Loading** | Pull required events from `tier_event_requirements` based on client segment |
| **Compliance Progress** | Real-time tracking from `segmentation_event_compliance` |
| **Gap Identification** | Highlight missing/overdue events with urgency indicators |
| **AI Scheduling Suggestions** | Optimal timing recommendations based on patterns |
| **Meeting Linking** | Connect scheduled events to Briefing Room meetings |
| **Deadline Awareness** | Factor in segment change timelines (15-month window) |
| **Historical View** | Show past compliance trends to identify patterns |

### Enhancement 10: Territory Strategy - Segment Distribution

**Concept:** Territory Strategies should show segment distribution and aggregate compliance across the portfolio.

#### Territory Strategy - Compliance Overview:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📊 Portfolio Compliance Overview - Victoria Territory              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Segment Distribution:                                              │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Giant          ██████ 3 clients    │ $2.1M ARR  │ 72% comp │   │
│  │ Collaboration  ████████ 4 clients  │ $1.4M ARR  │ 85% comp │   │
│  │ Leverage       ██████████ 5 clients│ $890K ARR  │ 91% comp │   │
│  │ Maintain       ████ 2 clients      │ $320K ARR  │ 100% comp│   │
│  │ Nurture        ██ 1 client         │ $95K ARR   │ 100% comp│   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Territory Compliance: 84%                                          │
│  Required Events (FY26): 156  │  Completed: 131  │  Remaining: 25  │
│                                                                     │
│  At-Risk Clients (Compliance <70%):                                │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Client          │ Segment │ Compliance │ Gap      │ Action  │   │
│  │─────────────────┼─────────┼────────────┼──────────┼─────────│   │
│  │ Acme Corp       │ Giant   │ 67%        │ 5 events │ [Plan]  │   │
│  │ Beta Industries │ Collab  │ 58%        │ 4 events │ [Plan]  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Monthly Event Capacity Planning:                                   │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │      Jan  Feb  Mar  Apr  May  Jun                           │   │
│  │ Req   8    6    7    5    4    3                            │   │
│  │ Cap  10   10   10   10   10   10                            │   │
│  │      ▓▓▓  ▓▓   ▓▓▓  ▓▓   ▓    ▓                            │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  [View All Events]  [Bulk Schedule]  [Export Calendar]             │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Part 9: BURC Performance Data Integration

### Overview

BURC (Business Unit Review Committee) data provides comprehensive financial metrics across 67+ tables. Integrating this creates a **revenue-aligned planning framework** that connects individual account plans to APAC business goals.

### BURC Data Hierarchy

```
┌─────────────────────────────────────────────────────────────────────┐
│                     BURC Data Rollup Hierarchy                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────┐       │
│  │                    APAC LEVEL                           │       │
│  │  Total ARR: $48.2M  │  NRR: 104%  │  EBITA: 18%        │       │
│  │  FY26 Target: $52M  │  Growth: 8%                       │       │
│  └────────────────────────────┬────────────────────────────┘       │
│                               │                                     │
│         ┌─────────────────────┼─────────────────────┐               │
│         │                     │                     │               │
│  ┌──────▼──────┐      ┌──────▼──────┐      ┌──────▼──────┐         │
│  │ ANZ BU      │      │ SEA BU      │      │ Greater     │         │
│  │ $28.4M ARR  │      │ $12.1M ARR  │      │ China BU    │         │
│  │ Target: $31M│      │ Target: $13M│      │ $7.7M ARR   │         │
│  └──────┬──────┘      └──────┬──────┘      └─────────────┘         │
│         │                    │                                      │
│    ┌────┴────┐          ┌────┴────┐                                │
│    │         │          │         │                                 │
│  ┌─▼───┐  ┌──▼──┐    ┌──▼──┐  ┌──▼──┐                              │
│  │ VIC │  │ NZ  │    │ SG  │  │ MY  │    ... Territories           │
│  │$12M │  │$8M  │    │$6M  │  │$4M  │                              │
│  └──┬──┘  └─────┘    └─────┘  └─────┘                              │
│     │                                                               │
│  ┌──▼──────────────────────────────────────────────┐               │
│  │              CLIENT/ACCOUNT LEVEL               │               │
│  │  Acme Corp: $1.2M ARR  │  Beta: $890K ARR      │               │
│  │  Gamma: $650K ARR      │  Delta: $420K ARR     │               │
│  └─────────────────────────────────────────────────┘               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Available BURC Metrics for Planning

| Category | Key Metrics | Planning Use |
|----------|-------------|--------------|
| **Revenue** | ARR, MRR, Net Revenue, Revenue by Type (SW/PS/Maint/HW) | Account revenue targets |
| **Retention** | NRR, GRR, Churn Rate, Attrition Risk | Renewal planning |
| **Growth** | Pipeline Value, Bookings, Expansion Rate | Opportunity planning |
| **Profitability** | EBITA, EBITA Margin, Gross Margin, Rule of 40 | Value contribution |
| **Financial Health** | AR Aging, DSO, Collections | Risk assessment |
| **Renewals** | Renewal Pipeline, Contract Risk | Timing and approach |
| **Customer** | Customer Health, Lifetime Value | Investment prioritisation |

### Enhancement 11: Account Plan - Revenue Alignment

**Concept:** Embed BURC financial data into Account Plans to show revenue contribution and targets.

#### Account Plan - Financial Performance Section:

```
┌─────────────────────────────────────────────────────────────────────┐
│  💰 Financial Performance - Acme Corp                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Revenue Overview:                                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Current ARR          │ $1,245,000                           │   │
│  │ FY26 Target          │ $1,370,000 (+10%)                    │   │
│  │ Renewal Value        │ $1,180,000 (due: Sep 2026)           │   │
│  │ Expansion Pipeline   │ $125,000 (2 opportunities)           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Revenue Composition:                                               │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Software Licence    ████████████████ $820K (66%)            │   │
│  │ Maintenance         ██████████ $310K (25%)                  │   │
│  │ Prof. Services      ███ $95K (8%)                           │   │
│  │ Hardware            █ $20K (1%)                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Retention Metrics:                                                 │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ NRR (3-year)        │ 108%  🟢 Expanding                    │   │
│  │ GRR (3-year)        │ 98%   🟢 Stable                       │   │
│  │ Lifetime Value      │ $4.2M (5.2 years avg tenure)          │   │
│  │ Revenue Trend       │ ↑ +12% YoY                            │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Financial Health:                                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ AR Balance          │ $145,230                              │   │
│  │ Overdue (>60 days)  │ $45,230 ⚠️                            │   │
│  │ DSO                 │ 52 days (target: 45)                  │   │
│  │ Collection Risk     │ Medium                                │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Contribution to Goals:                                             │
│  ├─ Territory (VIC): 10.4% of $12M target                         │
│  ├─ Business Unit (ANZ): 4.4% of $28.4M target                    │
│  └─ APAC: 2.6% of $48.2M total ARR                                │
│                                                                     │
│  [View BURC Detail]  [Update Forecast]  [View Contract]            │
└─────────────────────────────────────────────────────────────────────┘
```

### Enhancement 12: Territory Strategy - Financial Rollup

**Concept:** Territory Strategies aggregate BURC data to show portfolio financial health and contribution to business unit goals.

#### Territory Strategy - Financial Dashboard:

```
┌─────────────────────────────────────────────────────────────────────┐
│  📊 Financial Dashboard - Victoria Territory                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Portfolio Summary:                                                 │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌────────────┐ │
│  │ Total ARR    │ │ FY26 Target  │ │ NRR          │ │ Pipeline   │ │
│  │ $12.1M       │ │ $13.3M       │ │ 106%         │ │ $2.4M      │ │
│  │ ↑ 8% YoY     │ │ Gap: $1.2M   │ │ 🟢 Healthy   │ │ 1.8x cover │ │
│  └──────────────┘ └──────────────┘ └──────────────┘ └────────────┘ │
│                                                                     │
│  Revenue by Category:                                               │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Runrate (Contracted)  ████████████████████ $10.8M (89%)     │   │
│  │ Business Cases        ███ $850K (7%)                        │   │
│  │ Pipeline (Weighted)   █ $450K (4%)                          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Quarterly Targets vs Actuals:                                      │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │         Q1        Q2        Q3        Q4        FY26        │   │
│  │ Target  $3.1M     $3.2M     $3.4M     $3.6M     $13.3M      │   │
│  │ Actual  $3.2M     —         —         —         —           │   │
│  │ Status  ✅ +3%    🔵 TBD    🔵 TBD    🔵 TBD    🔵 TBD      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Client Revenue Distribution:                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Client          │ ARR      │ % Port │ NRR   │ Risk   │ Plan │   │
│  │─────────────────┼──────────┼────────┼───────┼────────┼──────│   │
│  │ Acme Corp       │ $1.24M   │ 10.2%  │ 108%  │ Low    │ ✅   │   │
│  │ Beta Industries │ $890K    │ 7.4%   │ 95%   │ Med    │ ✅   │   │
│  │ Gamma Health    │ $650K    │ 5.4%   │ 112%  │ Low    │ 🔲   │   │
│  │ [Top 10...]     │ $6.2M    │ 51.2%  │ —     │ —      │ —    │   │
│  │ [Others...]     │ $5.9M    │ 48.8%  │ —     │ —      │ —    │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Contribution to ANZ Business Unit ($28.4M):                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Victoria    ███████████████████████ 42.6% ($12.1M)          │   │
│  │ NZ          ██████████████████ 28.2% ($8.0M)                │   │
│  │ WA          █████████ 15.8% ($4.5M)                         │   │
│  │ SA/NT       █████ 9.5% ($2.7M)                              │   │
│  │ QLD         ███ 3.9% ($1.1M)                                │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Renewal Calendar:                                                  │
│  ├─ Q1: 3 renewals ($1.8M) - 2 secured, 1 at risk                 │
│  ├─ Q2: 4 renewals ($2.1M) - 1 secured, 3 pending                 │
│  ├─ Q3: 2 renewals ($1.2M) - All pending                          │
│  └─ Q4: 5 renewals ($3.4M) - All pending                          │
│                                                                     │
│  [View All Clients]  [BURC Dashboard]  [Export Financials]         │
└─────────────────────────────────────────────────────────────────────┘
```

### Enhancement 13: Business Unit Planning View (NEW)

**Concept:** New Business Unit-level view that aggregates Territory Strategies to show contribution to APAC goals.

#### Business Unit Planning Dashboard:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🏢 Business Unit Planning - ANZ                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  APAC Goal Contribution:                                            │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                     APAC FY26 Target: $52M                  │   │
│  │ ┌─────────────────────────────────────────────────────────┐│   │
│  │ │ ANZ        █████████████████████████████ 59.6% ($31M)  ││   │
│  │ │ SEA        █████████████████ 25.0% ($13M)              ││   │
│  │ │ Greater CN ██████████ 15.4% ($8M)                      ││   │
│  │ └─────────────────────────────────────────────────────────┘│   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ANZ Business Unit Summary:                                         │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌────────────┐ │
│  │ Current ARR  │ │ FY26 Target  │ │ Gap to Close │ │ Progress   │ │
│  │ $28.4M       │ │ $31.0M       │ │ $2.6M        │ │ 91.6%      │ │
│  └──────────────┘ └──────────────┘ └──────────────┘ └────────────┘ │
│                                                                     │
│  Territory Rollup:                                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Territory  │ ARR     │ Target  │ Gap     │ Plans │ Status   │   │
│  │────────────┼─────────┼─────────┼─────────┼───────┼──────────│   │
│  │ Victoria   │ $12.1M  │ $13.3M  │ -$1.2M  │ 12/15 │ 🟡 80%   │   │
│  │ NZ         │ $8.0M   │ $8.8M   │ -$800K  │ 8/10  │ 🟡 80%   │   │
│  │ WA         │ $4.5M   │ $5.0M   │ -$500K  │ 6/6   │ 🟢 100%  │   │
│  │ SA/NT      │ $2.7M   │ $2.8M   │ -$100K  │ 4/4   │ 🟢 100%  │   │
│  │ QLD        │ $1.1M   │ $1.1M   │ $0      │ 2/2   │ 🟢 100%  │   │
│  │────────────┼─────────┼─────────┼─────────┼───────┼──────────│   │
│  │ TOTAL      │ $28.4M  │ $31.0M  │ -$2.6M  │ 32/37 │ 86%      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Key Performance Indicators:                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Metric              │ Actual  │ Target │ Status │ Trend    │   │
│  │─────────────────────┼─────────┼────────┼────────┼──────────│   │
│  │ Net Revenue Retention│ 106%   │ 105%   │ 🟢     │ ↑ +2%    │   │
│  │ Gross Revenue Ret.  │ 97%    │ 95%    │ 🟢     │ → 0%     │   │
│  │ EBITA Margin        │ 19.2%  │ 18%    │ 🟢     │ ↑ +1.2%  │   │
│  │ Rule of 40          │ 27.2   │ 26     │ 🟢     │ ↑ +1.2   │   │
│  │ Compliance Score    │ 84%    │ 90%    │ 🟡     │ ↓ -3%    │   │
│  │ Health Score (Avg)  │ 72     │ 75     │ 🟡     │ → 0      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Segment Distribution (ANZ):                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Segment      │ Clients │ ARR     │ % BU   │ Compliance      │   │
│  │──────────────┼─────────┼─────────┼────────┼─────────────────│   │
│  │ Giant        │ 8       │ $14.2M  │ 50%    │ 78% ⚠️          │   │
│  │ Collaboration│ 12      │ $8.4M   │ 30%    │ 85%             │   │
│  │ Leverage     │ 15      │ $4.1M   │ 14%    │ 92%             │   │
│  │ Maintain     │ 8       │ $1.2M   │ 4%     │ 95%             │   │
│  │ Nurture      │ 5       │ $350K   │ 1%     │ 100%            │   │
│  │ Sleep. Giant │ 3       │ $150K   │ 1%     │ 100%            │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Strategic Initiatives Impact:                                      │
│  ├─ Expansion Program: $1.2M pipeline (45% of gap)                │
│  ├─ Churn Prevention: $890K at-risk, 3 accounts targeted          │
│  └─ New Logo: $650K pipeline (25% of gap)                         │
│                                                                     │
│  [View Territories]  [Export BU Report]  [BURC Dashboard]          │
└─────────────────────────────────────────────────────────────────────┘
```

### Enhancement 14: APAC Goals Alignment Dashboard (NEW)

**Concept:** Top-level view showing how all plans roll up to APAC business objectives.

#### APAC Planning Command Centre:

```
┌─────────────────────────────────────────────────────────────────────┐
│  🌏 APAC Goals Alignment - FY26 Planning Command Centre             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  FY26 Revenue Targets:                                              │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │              Current: $48.2M  →  Target: $52.0M             │   │
│  │              ████████████████████████████░░░░ 92.7%         │   │
│  │              Gap: $3.8M   │   Growth Required: 7.9%         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Business Unit Contributions:                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │         │ Current │ Target │ Gap     │ Plans  │ Progress    │   │
│  │─────────┼─────────┼────────┼─────────┼────────┼─────────────│   │
│  │ ANZ     │ $28.4M  │ $31.0M │ -$2.6M  │ 32/37  │ ███████░ 86%│   │
│  │ SEA     │ $12.1M  │ $13.0M │ -$900K  │ 18/22  │ ██████░░ 82%│   │
│  │ Gr. CN  │ $7.7M   │ $8.0M  │ -$300K  │ 10/12  │ ███████░ 83%│   │
│  │─────────┼─────────┼────────┼─────────┼────────┼─────────────│   │
│  │ APAC    │ $48.2M  │ $52.0M │ -$3.8M  │ 60/71  │ ██████░░ 85%│   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Gap Closure Analysis:                                              │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Source              │ Pipeline │ Weighted │ % of Gap        │   │
│  │─────────────────────┼──────────┼──────────┼─────────────────│   │
│  │ Expansion (Existing)│ $4.2M    │ $2.5M    │ 66% ████████░░ │   │
│  │ New Logo            │ $1.8M    │ $720K    │ 19% ████░░░░░░ │   │
│  │ Churn Prevention    │ $2.1M    │ $1.6M    │ 42% ██████░░░░ │   │
│  │─────────────────────┼──────────┼──────────┼─────────────────│   │
│  │ Total Coverage      │ $8.1M    │ $4.8M    │ 127% ✅         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  APAC KPI Scorecard:                                                │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ KPI                 │ Target  │ Actual  │ Status │ Trend   │   │
│  │─────────────────────┼─────────┼─────────┼────────┼─────────│   │
│  │ Revenue Growth      │ 8%      │ 7.2%    │ 🟡     │ ↑       │   │
│  │ NRR                 │ 105%    │ 104%    │ 🟡     │ ↑       │   │
│  │ GRR                 │ 95%     │ 96%     │ 🟢     │ →       │   │
│  │ EBITA Margin        │ 18%     │ 18.5%   │ 🟢     │ ↑       │   │
│  │ Rule of 40          │ 26      │ 25.7    │ 🟡     │ ↑       │   │
│  │ Customer Health     │ 75      │ 71      │ 🟠     │ ↓       │   │
│  │ Compliance Score    │ 90%     │ 84%     │ 🟠     │ ↓       │   │
│  │ Plan Coverage       │ 100%    │ 85%     │ 🟠     │ ↑       │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  Risk Summary:                                                      │
│  ├─ 🔴 12 accounts at high churn risk ($3.2M ARR)                  │
│  ├─ 🟠 8 accounts with declining health ($2.1M ARR)                │
│  ├─ 🟡 15 accounts below compliance threshold ($4.8M ARR)          │
│  └─ 🔵 23 accounts identified for expansion ($1.8M pipeline)       │
│                                                                     │
│  Planning Status:                                                   │
│  ├─ Account Plans: 60 approved / 71 required (85%)                 │
│  ├─ Territory Strategies: 12 approved / 14 required (86%)          │
│  └─ Deadline: 17 January 2026 (8 days remaining)                   │
│                                                                     │
│  [View All Plans]  [BU Drill-Down]  [Export APAC Report]           │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Part 10: New Database Tables for Integration

### Segmentation-Planning Link Tables

```sql
-- Link account plans to required segmentation events
CREATE TABLE account_plan_event_requirements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID REFERENCES account_plans(id),
  client_id UUID,
  client_name TEXT NOT NULL,
  segment TEXT NOT NULL,
  fiscal_year INTEGER NOT NULL,
  event_type_id UUID REFERENCES segmentation_event_types(id),
  event_type_name TEXT NOT NULL,
  required_count INTEGER NOT NULL,
  completed_count INTEGER DEFAULT 0,
  scheduled_count INTEGER DEFAULT 0,
  compliance_percentage DECIMAL(5,2),
  status TEXT, -- 'compliant', 'at_risk', 'critical', 'exceeded'
  next_due_date DATE,
  ai_recommended_dates JSONB, -- Array of suggested dates
  linked_event_ids JSONB, -- Array of segmentation_events.id
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Aggregate compliance at territory level
CREATE TABLE territory_compliance_summary (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  territory_strategy_id UUID REFERENCES territory_strategies(id),
  territory TEXT NOT NULL,
  cse_name TEXT NOT NULL,
  fiscal_year INTEGER NOT NULL,
  total_clients INTEGER,
  total_required_events INTEGER,
  total_completed_events INTEGER,
  overall_compliance_percentage DECIMAL(5,2),
  clients_at_risk INTEGER,
  clients_critical INTEGER,
  segment_breakdown JSONB, -- { "Giant": { clients: 3, compliance: 72% }, ... }
  monthly_capacity JSONB, -- { "Jan": { required: 8, capacity: 10 }, ... }
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### BURC-Planning Link Tables

```sql
-- Link account plans to BURC financial data
CREATE TABLE account_plan_financials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID REFERENCES account_plans(id),
  client_id UUID,
  client_name TEXT NOT NULL,
  fiscal_year INTEGER NOT NULL,

  -- Current State
  current_arr DECIMAL(15,2),
  current_mrr DECIMAL(15,2),
  revenue_software DECIMAL(15,2),
  revenue_ps DECIMAL(15,2),
  revenue_maintenance DECIMAL(15,2),
  revenue_hardware DECIMAL(15,2),

  -- Targets
  target_arr DECIMAL(15,2),
  target_growth_percentage DECIMAL(5,2),
  expansion_pipeline DECIMAL(15,2),
  expansion_pipeline_weighted DECIMAL(15,2),

  -- Retention Metrics
  nrr_3year DECIMAL(5,2),
  grr_3year DECIMAL(5,2),
  lifetime_value DECIMAL(15,2),
  tenure_years DECIMAL(5,2),

  -- Financial Health
  ar_balance DECIMAL(15,2),
  ar_overdue DECIMAL(15,2),
  dso_days INTEGER,
  collection_risk TEXT,

  -- Renewal Info
  renewal_date DATE,
  renewal_value DECIMAL(15,2),
  renewal_risk TEXT,

  -- Contribution
  territory_percentage DECIMAL(5,2),
  bu_percentage DECIMAL(5,2),
  apac_percentage DECIMAL(5,2),

  -- Sync metadata
  burc_sync_date TIMESTAMPTZ,
  data_source TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Territory-level BURC rollup
CREATE TABLE territory_strategy_financials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  territory_strategy_id UUID REFERENCES territory_strategies(id),
  territory TEXT NOT NULL,
  cse_name TEXT NOT NULL,
  fiscal_year INTEGER NOT NULL,

  -- Aggregated Metrics
  total_arr DECIMAL(15,2),
  target_arr DECIMAL(15,2),
  gap_to_target DECIMAL(15,2),
  yoy_growth_percentage DECIMAL(5,2),

  -- Revenue Breakdown
  revenue_runrate DECIMAL(15,2),
  revenue_business_cases DECIMAL(15,2),
  revenue_pipeline_weighted DECIMAL(15,2),

  -- Retention
  portfolio_nrr DECIMAL(5,2),
  portfolio_grr DECIMAL(5,2),

  -- Quarterly Targets
  q1_target DECIMAL(15,2),
  q1_actual DECIMAL(15,2),
  q2_target DECIMAL(15,2),
  q2_actual DECIMAL(15,2),
  q3_target DECIMAL(15,2),
  q3_actual DECIMAL(15,2),
  q4_target DECIMAL(15,2),
  q4_actual DECIMAL(15,2),

  -- Client Distribution
  client_count INTEGER,
  top_10_arr DECIMAL(15,2),
  top_10_percentage DECIMAL(5,2),
  concentration_risk TEXT,

  -- BU Contribution
  bu_name TEXT,
  bu_contribution_percentage DECIMAL(5,2),

  -- Renewal Pipeline
  renewal_q1_value DECIMAL(15,2),
  renewal_q1_secured DECIMAL(15,2),
  renewal_q2_value DECIMAL(15,2),
  renewal_q2_secured DECIMAL(15,2),
  renewal_q3_value DECIMAL(15,2),
  renewal_q3_secured DECIMAL(15,2),
  renewal_q4_value DECIMAL(15,2),
  renewal_q4_secured DECIMAL(15,2),

  burc_sync_date TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Business Unit planning rollup
CREATE TABLE business_unit_planning (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bu_name TEXT NOT NULL, -- 'ANZ', 'SEA', 'Greater China'
  fiscal_year INTEGER NOT NULL,

  -- Targets
  target_arr DECIMAL(15,2),
  current_arr DECIMAL(15,2),
  gap_to_target DECIMAL(15,2),
  apac_contribution_percentage DECIMAL(5,2),

  -- Territory Breakdown
  territory_count INTEGER,
  territory_data JSONB, -- Array of territory summaries

  -- KPIs
  nrr DECIMAL(5,2),
  grr DECIMAL(5,2),
  ebita_margin DECIMAL(5,2),
  rule_of_40 DECIMAL(5,2),

  -- Segment Distribution
  segment_distribution JSONB, -- { "Giant": { clients: 8, arr: 14.2M }, ... }

  -- Planning Status
  total_plans_required INTEGER,
  total_plans_approved INTEGER,
  planning_coverage_percentage DECIMAL(5,2),

  -- Compliance
  overall_compliance_percentage DECIMAL(5,2),
  clients_below_compliance INTEGER,

  -- Health
  avg_health_score INTEGER,
  accounts_at_risk INTEGER,
  at_risk_arr DECIMAL(15,2),

  -- Gap Analysis
  expansion_pipeline DECIMAL(15,2),
  expansion_weighted DECIMAL(15,2),
  new_logo_pipeline DECIMAL(15,2),
  churn_at_risk DECIMAL(15,2),

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- APAC goals tracking
CREATE TABLE apac_planning_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fiscal_year INTEGER NOT NULL,

  -- Revenue Goals
  target_revenue DECIMAL(15,2),
  current_revenue DECIMAL(15,2),
  gap DECIMAL(15,2),
  growth_target_percentage DECIMAL(5,2),
  growth_actual_percentage DECIMAL(5,2),

  -- BU Contributions
  bu_contributions JSONB, -- Array of BU summaries

  -- KPI Targets
  target_nrr DECIMAL(5,2),
  actual_nrr DECIMAL(5,2),
  target_grr DECIMAL(5,2),
  actual_grr DECIMAL(5,2),
  target_ebita_margin DECIMAL(5,2),
  actual_ebita_margin DECIMAL(5,2),
  target_rule_of_40 DECIMAL(5,2),
  actual_rule_of_40 DECIMAL(5,2),
  target_health_score INTEGER,
  actual_health_score INTEGER,
  target_compliance DECIMAL(5,2),
  actual_compliance DECIMAL(5,2),

  -- Gap Closure
  expansion_pipeline DECIMAL(15,2),
  expansion_weighted DECIMAL(15,2),
  new_logo_pipeline DECIMAL(15,2),
  new_logo_weighted DECIMAL(15,2),
  churn_prevention_target DECIMAL(15,2),
  total_coverage_percentage DECIMAL(5,2),

  -- Risk Summary
  high_churn_risk_accounts INTEGER,
  high_churn_risk_arr DECIMAL(15,2),
  declining_health_accounts INTEGER,
  declining_health_arr DECIMAL(15,2),
  below_compliance_accounts INTEGER,
  below_compliance_arr DECIMAL(15,2),

  -- Planning Status
  total_account_plans_required INTEGER,
  total_account_plans_approved INTEGER,
  total_territory_strategies_required INTEGER,
  total_territory_strategies_approved INTEGER,
  planning_deadline DATE,
  days_to_deadline INTEGER,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Indexes for New Tables

```sql
-- Account plan event requirements
CREATE INDEX idx_plan_events_plan ON account_plan_event_requirements(plan_id);
CREATE INDEX idx_plan_events_client ON account_plan_event_requirements(client_id, fiscal_year);
CREATE INDEX idx_plan_events_status ON account_plan_event_requirements(status) WHERE status IN ('at_risk', 'critical');

-- Territory compliance
CREATE INDEX idx_territory_compliance ON territory_compliance_summary(territory, fiscal_year);
CREATE INDEX idx_territory_compliance_strategy ON territory_compliance_summary(territory_strategy_id);

-- Account plan financials
CREATE INDEX idx_plan_financials_plan ON account_plan_financials(plan_id);
CREATE INDEX idx_plan_financials_client ON account_plan_financials(client_id, fiscal_year);

-- Territory financials
CREATE INDEX idx_territory_financials_strategy ON territory_strategy_financials(territory_strategy_id);
CREATE INDEX idx_territory_financials_territory ON territory_strategy_financials(territory, fiscal_year);

-- Business unit planning
CREATE INDEX idx_bu_planning_year ON business_unit_planning(fiscal_year);
CREATE INDEX idx_bu_planning_name ON business_unit_planning(bu_name, fiscal_year);

-- APAC goals
CREATE INDEX idx_apac_goals_year ON apac_planning_goals(fiscal_year);
```

---

## Part 11: Updated Implementation Roadmap

### Phase 1: Foundation (Weeks 1-3)
- [ ] Create all new database tables (original + segmentation + BURC)
- [ ] Build engagement timeline aggregation job
- [ ] Implement stakeholder relationship data model
- [ ] Add auto-save to territory strategy forms
- [ ] Basic data visualisation components (charts, graphs)
- [ ] **NEW:** Create BURC-to-Planning sync jobs
- [ ] **NEW:** Create Segmentation-to-Planning sync jobs

### Phase 2: Segmentation Integration (Weeks 4-5)
- [ ] Account Plan compliance section UI
- [ ] Territory Strategy compliance overview UI
- [ ] Event scheduling from within plans
- [ ] Compliance gap identification
- [ ] Link events to Briefing Room meetings
- [ ] AI scheduling recommendations

### Phase 3: BURC Integration (Weeks 6-8)
- [ ] Account Plan financial section UI
- [ ] Territory Strategy financial dashboard UI
- [ ] **NEW:** Business Unit Planning dashboard
- [ ] **NEW:** APAC Goals Alignment dashboard
- [ ] Quarterly target tracking
- [ ] Renewal calendar integration
- [ ] Gap closure analysis

### Phase 4: AI Integration (Weeks 9-11)
- [ ] ChaSen API endpoint for account intelligence
- [ ] AI insight generation pipeline
- [ ] MEDDPICC auto-detection from meeting transcripts
- [ ] Stakeholder auto-population from meetings
- [ ] Risk factor analysis engine
- [ ] **NEW:** AI compliance predictions
- [ ] **NEW:** AI revenue forecasting

### Phase 5: Predictive Analytics (Weeks 12-14)
- [ ] Churn risk prediction model
- [ ] Expansion probability model
- [ ] Engagement velocity calculations
- [ ] Health score trajectory analysis
- [ ] Peer benchmarking system
- [ ] **NEW:** Compliance trajectory prediction
- [ ] **NEW:** Revenue trajectory prediction

### Phase 6: Next Best Action & Advanced Features (Weeks 15-18)
- [ ] Action recommendation algorithm
- [ ] Priority scoring system
- [ ] UI integration for recommendations
- [ ] Action tracking and feedback loop
- [ ] Notification integration
- [ ] Visual stakeholder mapping UI
- [ ] Automated plan generation
- [ ] Portfolio analytics dashboard
- [ ] Advanced MEDDPICC visualisation
- [ ] Mobile-responsive enhancements

---

## Part 12: Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Planning Hub Data Flow                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  External Sources                                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                 │
│  │ BURC Excel  │  │ Outlook     │  │ NPS Survey  │                 │
│  │ (Financial) │  │ (Meetings)  │  │ (Feedback)  │                 │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘                 │
│         │                │                │                         │
│         ▼                ▼                ▼                         │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    SUPABASE DATABASE                        │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │   │
│  │  │ burc_*      │ │ unified_    │ │ nps_        │           │   │
│  │  │ (67 tables) │ │ meetings    │ │ responses   │           │   │
│  │  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘           │   │
│  │         │               │               │                   │   │
│  │  ┌──────┴───────────────┴───────────────┴──────┐           │   │
│  │  │         AGGREGATION LAYER                   │           │   │
│  │  │  ┌─────────────────────────────────────┐   │           │   │
│  │  │  │ - Client Health History             │   │           │   │
│  │  │  │ - Segmentation Compliance           │   │           │   │
│  │  │  │ - Engagement Timeline               │   │           │   │
│  │  │  │ - Predictive Health Scores          │   │           │   │
│  │  │  └─────────────────────────────────────┘   │           │   │
│  │  └─────────────────────┬───────────────────────┘           │   │
│  │                        │                                    │   │
│  │  ┌─────────────────────┴───────────────────────┐           │   │
│  │  │           PLANNING LAYER                    │           │   │
│  │  │  ┌───────────────┐ ┌───────────────┐       │           │   │
│  │  │  │ Account Plans │ │ Territory     │       │           │   │
│  │  │  │ (+ financials)│ │ Strategies    │       │           │   │
│  │  │  │ (+ compliance)│ │ (+ rollups)   │       │           │   │
│  │  │  └───────┬───────┘ └───────┬───────┘       │           │   │
│  │  │          │                 │                │           │   │
│  │  │          └────────┬────────┘                │           │   │
│  │  │                   │                         │           │   │
│  │  │  ┌────────────────┴────────────────┐       │           │   │
│  │  │  │    Business Unit Planning       │       │           │   │
│  │  │  └────────────────┬────────────────┘       │           │   │
│  │  │                   │                         │           │   │
│  │  │  ┌────────────────┴────────────────┐       │           │   │
│  │  │  │    APAC Planning Goals          │       │           │   │
│  │  │  └─────────────────────────────────┘       │           │   │
│  │  └─────────────────────────────────────────────┘           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                        │                                           │
│                        ▼                                           │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    AI LAYER (ChaSen)                        │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │   │
│  │  │ Insights    │ │ Predictions │ │ Next Best   │           │   │
│  │  │ Generation  │ │ (Churn/Exp) │ │ Actions     │           │   │
│  │  └─────────────┘ └─────────────┘ └─────────────┘           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                        │                                           │
│                        ▼                                           │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    UI LAYER                                 │   │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐           │   │
│  │  │ Account     │ │ Territory   │ │ BU & APAC   │           │   │
│  │  │ Plan View   │ │ Strategy    │ │ Dashboards  │           │   │
│  │  └─────────────┘ └─────────────┘ └─────────────┘           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

**Document End**

*This proposal is ready for review and prioritisation. The integration of Segmentation Events and BURC data creates a comprehensive planning framework that aligns individual account activities with APAC business goals.*
