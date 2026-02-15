# Redesign: Aging Accounts Compliance Dashboard

**Date:** 21 December 2025
**Status:** Design Complete - Ready for Implementation
**Component:** `/aging-accounts/compliance`
**Research Sources:** Stripe, Linear, Figma, Notion, Mercury, Ramp, Carta, Datadog, Amplitude

---

## Executive Summary

Complete redesign of the Aging Accounts Compliance Dashboard, incorporating best practices from industry-leading companies and 2025 design trends. The new design focuses on **progressive disclosure**, **AI-powered insights**, and **role-based views** to provide actionable intelligence for financial health management.

---

## Current State Analysis

### Existing Features

- Summary cards (Total Outstanding, CSEs Meeting Goals, % Under 60/90 Days)
- Bar chart for Compliance by CSE
- Donut chart for Goals Achievement
- Historical trend line chart
- Detailed metrics table
- Basic filters (CSE, time range)
- CSV export

### Pain Points Identified

1. **Information Overload**: All data presented equally without hierarchy
2. **Limited AI Integration**: No predictive insights or recommendations
3. **Static Visualisations**: No interactive drill-down capabilities
4. **Single View Only**: No role-based customisation
5. **Weak Alert System**: No proactive risk flagging
6. **Poor Progressive Disclosure**: All complexity visible at once

---

## Design Philosophy

### Core Principles (Inspired by Research)

1. **Linear's Minimalism**: Reduce visual noise, keyboard-first interactions, sub-200ms response times
2. **Stripe's Accessibility**: 4.5:1 colour contrast, intentional colour use for status only
3. **Notion's Flexibility**: Three-zone layout with pinned, grouped, and panel sections
4. **Mercury's Meaning Layer**: Don't just display data - interpret and contextualise
5. **Ramp's Automation**: AI-powered flagging and recommended actions
6. **Datadog's Multi-View**: Same data visualised in multiple complementary ways
7. **Amplitude's Storytelling**: Narrative flow from problem to action

---

## New Design Structure

### Three-Dashboard Approach

```
┌─────────────────────────────────────────────────────────────────┐
│  DASHBOARD TABS                                                  │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐            │
│  │ AR Health    │ │ Operations   │ │ Compliance   │            │
│  │ (Executive)  │ │ (Manager)    │ │ (Audit)      │            │
│  └──────────────┘ └──────────────┘ └──────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

---

## Dashboard 1: AR Health (Executive View)

**Target Audience:** CFO, Finance Director, Leadership

### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│ CRITICAL ALERTS BANNER (if any)                                  │
│ ⚠ 3 accounts moved to 120+ days totalling $85,000              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ AI INSIGHTS SUMMARY                                              │
│ "AR health declined 2.3% this week. Healthcare sector accounts  │
│ represent 65% of aging movement. Recommend prioritising ABC     │
│ Corp ($45K) and XYZ Ltd ($32K) for immediate follow-up."        │
│                                          [View Recommendations →]│
└─────────────────────────────────────────────────────────────────┘

┌─────────────┬─────────────┬─────────────┬─────────────┐
│  TOTAL AR   │    DSO      │  AT RISK    │ COLLECTION  │
│             │             │             │   RATE      │
│ $2,345,678  │  45 days    │   15%       │    87%      │
│  ▲ 3.2%     │  ▲ 2 days   │  ▲ 2%       │  ▼ 3%       │
│ [sparkline] │ [sparkline] │ [sparkline] │ [sparkline] │
└─────────────┴─────────────┴─────────────┴─────────────┘

┌─────────────────────────────┬───────────────────────────────────┐
│  AGING DISTRIBUTION         │  CSE PERFORMANCE OVERVIEW         │
│                             │                                   │
│  [Stacked Bar Chart]        │  Meeting Goals: 8/10 CSEs         │
│   - 0-30 days (green)       │  ━━━━━━━━━━━━━━━━━━━━━━          │
│   - 31-60 days (yellow)     │  At Risk: Sarah, Michael          │
│   - 61-90 days (orange)     │                                   │
│   - 90+ days (red)          │  [CSE Ranking List]               │
│                             │                                   │
│  Click bucket to drill →    │  Click CSE to view details →     │
└─────────────────────────────┴───────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  TREND ANALYSIS (12 Months)                                      │
│                                                                  │
│  [Line Chart: DSO + Aging Buckets + Goal Line]                  │
│                                                                  │
│  Period Selector: [1M] [3M] [6M] [12M] [Custom]                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  TOP AT-RISK ACCOUNTS                                            │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Rank │ Client      │ Amount   │ Days │ CSE    │ Risk │ Act │ │
│  │ 1    │ ABC Corp    │ $45,000  │ 95   │ Sarah  │ ████ │ [→] │ │
│  │ 2    │ XYZ Ltd     │ $32,000  │ 87   │ Michael│ ███  │ [→] │ │
│  │ 3    │ DEF Inc     │ $28,500  │ 72   │ Emma   │ ██   │ [→] │ │
│  └────────────────────────────────────────────────────────────┘ │
│  [View All At-Risk Accounts →]                                   │
└─────────────────────────────────────────────────────────────────┘
```

### KPI Card Design Specification

```tsx
// KPI Card Component Specification
interface KPICard {
  title: string // "Total AR Outstanding"
  value: string // "$2,345,678"
  comparison: {
    value: number // 3.2
    direction: 'up' | 'down' | 'stable'
    period: string // "vs last month"
    isPositive: boolean // false (increase is bad for AR)
  }
  sparklineData: number[] // 12 data points for trend
  onClick: () => void // Expand to detailed view
  status: 'healthy' | 'warning' | 'critical'
}
```

### Colour System

| Status           | Colour | Hex       | Usage                                      |
| ---------------- | ------ | --------- | ------------------------------------------ |
| Healthy/On Track | Green  | `#16A34A` | Meeting goals, improving metrics           |
| Warning          | Amber  | `#F59E0B` | Trending negatively, approaching threshold |
| Critical         | Red    | `#DC2626` | Below threshold, immediate action needed   |
| Neutral/Info     | Blue   | `#2563EB` | Informational, clickable elements          |
| Primary Brand    | Purple | `#7C3AED` | Headers, accents                           |

---

## Dashboard 2: Operations (Manager View)

**Target Audience:** Collections Manager, Team Leads, CSEs

### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│ TODAY'S PRIORITIES (AI-Generated)                                │
│ ┌────────────────────────────────────────────────────────────┐  │
│ │ 🔴 Call ABC Corp - $45K at 95 days, payment promised 2 wks  │  │
│ │ 🟡 Follow up XYZ Ltd - No response to last 2 emails         │  │
│ │ 🟢 Confirm DEF Inc payment plan - Due today                  │  │
│ └────────────────────────────────────────────────────────────┘  │
│ [View All Priorities →]                     [Mark Complete ✓]   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────┬───────────────────────────────────┐
│  CSE PERFORMANCE            │  DAILY ACTIVITY                   │
│                             │                                   │
│  [Heatmap: CSE x Bucket]    │  Today: 45 calls, 23 emails       │
│                             │  Promises Secured: 8 ($125K)      │
│  Sarah     ████████░░       │  Payments Received: 12 ($89K)     │
│  Michael   ██████░░░░       │                                   │
│  Emma      █████████░       │  [Activity Feed]                  │
│  David     ████████░░       │  • 10:32 - Sarah called ABC Corp  │
│                             │  • 10:15 - Payment received $5K   │
│  Legend: █ = Goals Met      │  • 09:45 - Michael email to XYZ   │
└─────────────────────────────┴───────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  ACCOUNT WORKLOAD                                                │
│                                                                  │
│  Filter: [All CSEs ▼] [All Buckets ▼] [Risk: High+ ▼]           │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Client      │ Amount   │ Bucket   │ CSE    │ Status │ Next │ │
│  │ ABC Corp    │ $45,000  │ 91-120   │ Sarah  │ ⚠ Due  │ Call │ │
│  │ XYZ Ltd     │ $32,000  │ 61-90    │ Michael│ 🔔 New │ Email│ │
│  │ DEF Inc     │ $28,500  │ 61-90    │ Emma   │ ✓ Plan │ Conf │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  Bulk Actions: [Assign →] [Email →] [Export →]                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  BUCKET MOVEMENT TRACKER                                         │
│                                                                  │
│  [Sankey Diagram showing flow between aging buckets]            │
│                                                                  │
│  This Week:                                                      │
│  • 15 accounts moved to worse bucket (+$245K)                   │
│  • 23 accounts improved bucket (-$312K)                         │
│  • 8 accounts paid in full ($156K collected)                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Dashboard 3: Compliance & Audit

**Target Audience:** Compliance Officer, Internal Audit, CFO

### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│ COMPLIANCE STATUS                                                │
│ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐             │
│ │   90% < 60   │ │  98% < 90    │ │  8/10 CSEs   │             │
│ │    DAYS      │ │    DAYS      │ │ MEETING GOAL │             │
│ │   ✓ Met      │ │   ✗ Below    │ │   ⚠ 2 At Risk│             │
│ └──────────────┘ └──────────────┘ └──────────────┘             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────┬───────────────────────────────────┐
│  RED FLAGS                  │  WRITE-OFF ANALYSIS               │
│                             │                                   │
│  🔴 5 accounts >180 days    │  This Quarter: $45,000            │
│  🔴 3 accounts no contact   │  vs Last Quarter: $38,000 (+18%)  │
│     in 30+ days             │                                   │
│  🟡 Credit limits exceeded  │  [Pie Chart: Write-off by Reason] │
│     for 2 accounts          │  • Bad debt: 65%                  │
│                             │  • Dispute: 20%                   │
│  [View All Red Flags →]     │  • Bankruptcy: 15%                │
└─────────────────────────────┴───────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  AUDIT TRAIL                                                     │
│                                                                  │
│  Filter: [Date Range] [Actor] [Event Type] [Account]            │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │ Timestamp       │ Actor  │ Event            │ Details       │ │
│  │ 21/12 10:32    │ Sarah  │ Payment Plan     │ ABC Corp $45K │ │
│  │ 21/12 09:15    │ System │ Bucket Change    │ XYZ → 61-90   │ │
│  │ 20/12 16:45    │ Admin  │ Write-off        │ DEF Inc $5K   │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  [Export Audit Log →]                                           │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  POLICY COMPLIANCE                                               │
│                                                                  │
│  Contact Frequency: ████████░░ 82% compliant                    │
│  Documentation:     █████████░ 91% complete                     │
│  Escalation Rules:  ██████████ 100% followed                    │
│                                                                  │
│  [View Policy Violations →]                                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## AI Insights Integration

### 1. Daily AI Summary

```tsx
interface AIInsight {
  id: string
  type: 'summary' | 'alert' | 'recommendation' | 'prediction'
  severity: 'info' | 'warning' | 'critical'
  title: string
  description: string
  context: {
    metric: string
    change: number
    affectedAccounts: string[]
    totalValue: number
  }
  actions: AIAction[]
  createdAt: Date
}

interface AIAction {
  label: string
  type: 'primary' | 'secondary'
  onClick: () => void
}
```

### 2. Natural Language Query

```
┌─────────────────────────────────────────────────────────────────┐
│ ASK CHASEN                                                       │
│ ┌─────────────────────────────────────────────────────────────┐ │
│ │ "Show me healthcare accounts over 60 days assigned to Sarah"│ │
│ └─────────────────────────────────────────────────────────────┘ │
│                                                                  │
│ Example queries:                                                 │
│ • "Why did DSO increase this month?"                            │
│ • "Which CSE has the best collection rate for 90+ accounts?"   │
│ • "Predict which accounts will move to 90+ next week"          │
└─────────────────────────────────────────────────────────────────┘
```

### 3. Predictive Alerts

```tsx
interface PredictiveAlert {
  accountId: string
  clientName: string
  currentBucket: string
  predictedBucket: string
  probability: number // 0-100
  timeframe: string // "within 14 days"
  riskFactors: string[]
  recommendedActions: string[]
}
```

### 4. AI-Powered Recommendations

| Trigger                       | AI Action                 | User Benefit            |
| ----------------------------- | ------------------------- | ----------------------- |
| Account hits 60 days          | Suggest contact template  | Faster outreach         |
| Payment pattern change        | Flag for review           | Early intervention      |
| CSE workload imbalance        | Suggest redistribution    | Optimised capacity      |
| High-risk cluster detected    | Prioritised action list   | Focus on biggest impact |
| Successful collection pattern | Apply to similar accounts | Replicate success       |

---

## Progressive Disclosure Implementation

### Layer 1: Summary View (Default)

- 4 KPI cards with sparklines
- Aging distribution chart (simplified)
- Top 5 at-risk accounts
- AI insights summary (collapsed)
- Critical alerts only

### Layer 2: Detailed View (Click to Expand)

**KPI Card Expansion:**

```
┌─────────────────────────────────────────────────────────────────┐
│ TOTAL AR OUTSTANDING - DETAILED VIEW                             │
│                                                                  │
│ Current: $2,345,678                                              │
│                                                                  │
│ Trend (12 Months):                                              │
│ [Full Line Chart with annotations for significant events]       │
│                                                                  │
│ Breakdown by Bucket:                                            │
│ ┌──────────────────────────────────────────────────────────────┐│
│ │ 0-30 days   │ $1,245,000 │ 53% │ ▼ 2% │                      ││
│ │ 31-60 days  │ $678,000   │ 29% │ → 0% │                      ││
│ │ 61-90 days  │ $298,000   │ 13% │ ▲ 5% │                      ││
│ │ 90+ days    │ $124,678   │ 5%  │ ▲ 1% │                      ││
│ └──────────────────────────────────────────────────────────────┘│
│                                                                  │
│ Top Contributors to Change:                                      │
│ • ABC Corp: +$45K (moved from 60 to 90+ days)                   │
│ • XYZ Ltd: +$32K (new invoice aging)                            │
│                                                                  │
│ [View All Accounts →]                      [Close ✕]            │
└─────────────────────────────────────────────────────────────────┘
```

### Layer 3: Full Detail (Side Panel)

**Account Detail Panel:**

```
┌─────────────────────────────────────────────────────────────────┐
│ ABC CORPORATION                                    [✕ Close]    │
├─────────────────────────────────────────────────────────────────┤
│ QUICK STATS                                                      │
│ Outstanding: $45,000 │ Days: 95 │ Risk: HIGH │ CSE: Sarah       │
├─────────────────────────────────────────────────────────────────┤
│ AGING BREAKDOWN                                                  │
│ [Horizontal stacked bar showing bucket distribution]            │
├─────────────────────────────────────────────────────────────────┤
│ PAYMENT HISTORY                                                  │
│ [Timeline of last 12 months payments with amounts]              │
├─────────────────────────────────────────────────────────────────┤
│ CONTACT LOG                                                      │
│ 15/12 - Email sent (no response)                                │
│ 10/12 - Phone call - promised payment by 20/12                  │
│ 01/12 - Invoice sent                                            │
├─────────────────────────────────────────────────────────────────┤
│ AI RECOMMENDATION                                                │
│ "Based on payment history, escalate to senior contact.          │
│ Similar accounts have 72% success rate with this approach."     │
│                                                                  │
│ [Call] [Email] [Create Payment Plan] [Escalate]                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Keyboard Shortcuts

| Shortcut      | Action                            |
| ------------- | --------------------------------- |
| `Alt + 1/2/3` | Switch between dashboards         |
| `Alt + F`     | Open filter panel                 |
| `Alt + S`     | Focus search/query                |
| `Alt + R`     | Refresh data                      |
| `Alt + E`     | Export current view               |
| `Esc`         | Close panels/modals               |
| `Enter`       | Expand selected item              |
| `↑/↓`         | Navigate table rows               |
| `Tab`         | Move between interactive elements |

---

## Responsive Design

### Desktop (1920x1080+)

- Full three-column layout for Operations dashboard
- Side panel for detail views
- All charts at full size

### Tablet (768-1024px)

- Two-column layout
- Collapsible side panel
- Touch-optimised controls (44x44px minimum)

### Mobile (375-767px)

- Single column, card-based
- Bottom navigation for dashboard switching
- Simplified charts (horizontal bars)
- Swipe gestures for actions

---

## Technical Implementation

### Component Architecture

```
src/
├── app/(dashboard)/aging-accounts/
│   ├── page.tsx                    # Detailed client view (existing)
│   └── compliance/
│       ├── page.tsx                # Main dashboard with tab navigation
│       ├── components/
│       │   ├── DashboardTabs.tsx   # Tab navigation component
│       │   ├── ExecutiveView.tsx   # AR Health dashboard
│       │   ├── OperationsView.tsx  # Operations dashboard
│       │   ├── ComplianceView.tsx  # Audit dashboard
│       │   ├── KPICard.tsx         # Expandable KPI card
│       │   ├── AIInsightsSummary.tsx
│       │   ├── NaturalLanguageQuery.tsx
│       │   ├── AlertBanner.tsx
│       │   ├── AgingDistributionChart.tsx
│       │   ├── CSEPerformanceHeatmap.tsx
│       │   ├── BucketMovementSankey.tsx
│       │   ├── AccountDetailPanel.tsx
│       │   └── AuditTrailTable.tsx
│       └── hooks/
│           ├── useARMetrics.ts     # Computed metrics
│           ├── useAIInsights.ts    # AI integration
│           └── usePredictiveAlerts.ts
├── hooks/
│   └── useAgingAccounts.ts         # Existing - data fetching
└── components/
    └── aged-accounts/              # Shared components
```

### Data Flow

```
Invoice Tracker API → useAgingAccounts hook → Computed Metrics → Dashboard Views
                                            ↓
                                     AI Analysis API → Insights/Predictions
```

### API Endpoints Required

| Endpoint                                | Purpose                               |
| --------------------------------------- | ------------------------------------- |
| `GET /api/aging-accounts/compliance`    | Historical compliance data (existing) |
| `GET /api/invoice-tracker/aging-by-cse` | Live aging data (existing)            |
| `POST /api/chasen/ar-insights`          | NEW: AI-powered insights              |
| `POST /api/chasen/ar-query`             | NEW: Natural language query           |
| `GET /api/aging-accounts/audit-log`     | NEW: Audit trail data                 |
| `GET /api/aging-accounts/predictions`   | NEW: Predictive alerts                |

---

## Implementation Phases

### Phase 1: Foundation (Week 1)

- [ ] Create new component structure
- [ ] Implement DashboardTabs with three views
- [ ] Build KPICard component with expansion
- [ ] Set up colour system and design tokens

### Phase 2: Executive View (Week 2)

- [ ] KPI cards with sparklines
- [ ] Aging distribution chart (Tremor)
- [ ] CSE performance overview
- [ ] Top at-risk accounts table
- [ ] Trend analysis chart

### Phase 3: Operations View (Week 3)

- [ ] Today's priorities section
- [ ] CSE performance heatmap
- [ ] Activity feed
- [ ] Account workload table with bulk actions
- [ ] Bucket movement visualisation

### Phase 4: Compliance View (Week 4)

- [ ] Compliance status cards
- [ ] Red flags section
- [ ] Write-off analysis
- [ ] Audit trail table with filters
- [ ] Policy compliance indicators

### Phase 5: AI Integration (Week 5)

- [ ] AI insights summary component
- [ ] Natural language query (Chasen integration)
- [ ] Predictive alerts
- [ ] Recommendation engine

### Phase 6: Polish & Testing (Week 6)

- [ ] Responsive design implementation
- [ ] Keyboard navigation
- [ ] Accessibility audit
- [ ] Performance optimisation
- [ ] User testing

---

## Success Metrics

| Metric                            | Current    | Target              |
| --------------------------------- | ---------- | ------------------- |
| Time to identify at-risk accounts | 5+ minutes | < 30 seconds        |
| Clicks to access account details  | 3-4 clicks | 1-2 clicks          |
| Dashboard load time               | ~3 seconds | < 2 seconds         |
| User satisfaction score           | TBD        | > 4.5/5             |
| Collection rate improvement       | Baseline   | +5% within 3 months |

---

## Appendix: Design Inspirations

### From Stripe

- Consistent platform integration
- Accessibility-first colour choices
- Real-time status indicators

### From Linear

- Keyboard-first interactions
- Sub-200ms response times
- Minimal visual noise

### From Notion

- Three-zone layout (pinned, grouped, panel)
- Flexible view customisation
- Drag-and-drop reordering

### From Mercury

- Meaning layer over raw data
- Mobile-first responsive design
- Micro-celebrations for positive outcomes

### From Ramp

- AI-powered auto-flagging
- Audit trail capabilities
- Natural language queries

### From Carta

- Sticky headers for tables
- Custom grouping and tagging
- One-click comprehensive reports

### From Datadog

- Multiple visualisations of same data
- Template variables for filtering
- Anomaly detection

### From Amplitude

- Narrative flow in dashboards
- Data storytelling approach
- AI-assisted analysis

---

_This redesign document serves as the source of truth for the Aging Accounts Compliance Dashboard enhancement. All implementation should reference this document for design decisions and specifications._
