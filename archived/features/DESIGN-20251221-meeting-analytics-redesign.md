# Meeting Analytics Redesign Proposal

**Date:** 21 December 2025
**Status:** Proposal
**Focus:** Meeting-only analytics with AI insights (NPS removed)

---

## Executive Summary

Redesign the Briefing Room Analytics tab to focus exclusively on **meeting intelligence**, removing NPS analytics and delivering AI-powered insights that help CSEs understand engagement patterns, identify at-risk clients, and optimise their meeting cadence.

---

## Design Principles (2025 Trends)

### 1. **AI-First Insights**

- Lead with natural language summaries, not raw numbers
- Proactive recommendations, not just data display
- Anomaly detection and pattern recognition

### 2. **Progressive Disclosure**

- High-level overview first
- Drill-down details on demand
- Reduce cognitive load

### 3. **Hyper-Minimalism**

- Ample white space
- Limited colour palette (semantic colours only)
- Clean typography
- Every element must serve a purpose

### 4. **Real-Time Interactivity**

- Live filtering
- Responsive to user context
- Immediate visual feedback

---

## Proposed Layout

```
┌─────────────────────────────────────────────────────────────────────┐
│  AI INSIGHT HERO                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ "Your meeting cadence is strong with 47 meetings this month.  │  │
│  │  3 clients haven't been contacted in 30+ days. Barwon Health  │  │
│  │  shows declining engagement - consider scheduling a check-in." │  │
│  └───────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │
│  │ MEETINGS    │ │ AVG DURATION│ │ CLIENTS     │ │ FOLLOW-UPS  │   │
│  │    47       │ │   42 min    │ │   12/18     │ │   85%       │   │
│  │ ↑12% vs last│ │ ↓5min trend │ │  touched    │ │ action rate │   │
│  └─────────────┘ └─────────────┘ └─────────────┘ └─────────────┘   │
│                                                                      │
│  ┌────────────────────────────────┐ ┌────────────────────────────┐  │
│  │ MEETING VELOCITY               │ │ ENGAGEMENT GAPS            │  │
│  │ [Sparkline trend chart]        │ │ ⚠ Barwon Health - 32 days  │  │
│  │                                │ │ ⚠ WA Health - 28 days      │  │
│  │ Weekly avg: 12 meetings        │ │ ⚠ Epworth - 25 days        │  │
│  └────────────────────────────────┘ └────────────────────────────┘  │
│                                                                      │
│  ┌────────────────────────────────┐ ┌────────────────────────────┐  │
│  │ MEETING MIX                    │ │ TOP CLIENTS                │  │
│  │ [Donut chart by type]          │ │ 1. SingHealth (8 meetings) │  │
│  │                                │ │ 2. SA Health (6 meetings)  │  │
│  │ QBR: 15% | Check-in: 60%      │ │ 3. Grampians (5 meetings)  │  │
│  │ Escalation: 5% | Other: 20%   │ │                            │  │
│  └────────────────────────────────┘ └────────────────────────────┘  │
│                                                                      │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ AI RECOMMENDATIONS                                             │  │
│  │ ┌─────────────────────────────────────────────────────────┐   │  │
│  │ │ 🎯 Schedule QBR with Barwon Health (32 days since last) │   │  │
│  │ └─────────────────────────────────────────────────────────┘   │  │
│  │ ┌─────────────────────────────────────────────────────────┐   │  │
│  │ │ 📊 WA Health meetings are 20% shorter than average      │   │  │
│  │ └─────────────────────────────────────────────────────────┘   │  │
│  │ ┌─────────────────────────────────────────────────────────┐   │  │
│  │ │ ✨ Your Thursday meetings have highest follow-up rate   │   │  │
│  │ └─────────────────────────────────────────────────────────┘   │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

---

## New Meeting-Focused Insights

### Tier 1: Core Metrics (Always Visible)

| Metric              | Description                     | Why It Matters     |
| ------------------- | ------------------------------- | ------------------ |
| **Meeting Count**   | Total meetings in period        | Volume indicator   |
| **Avg Duration**    | Mean meeting length             | Efficiency metric  |
| **Client Coverage** | Clients touched / Total clients | Engagement breadth |
| **Follow-up Rate**  | Meetings with actions created   | Outcome tracking   |

### Tier 2: Engagement Intelligence

| Insight               | Logic                                              | Visual                             |
| --------------------- | -------------------------------------------------- | ---------------------------------- |
| **Engagement Gaps**   | Clients with no meeting in 21+ days                | Alert list with days since contact |
| **Meeting Velocity**  | Weekly meeting trend                               | Sparkline with direction indicator |
| **Peak Days**         | Best days for meetings (by follow-up success)      | Heatmap or simple callout          |
| **Duration Outliers** | Meetings significantly longer/shorter than average | Flagged in insights                |

### Tier 3: AI-Powered Recommendations

| Recommendation Type       | Example                                                             |
| ------------------------- | ------------------------------------------------------------------- |
| **Scheduling Suggestion** | "Consider a check-in with Barwon Health - last QBR was 45 days ago" |
| **Pattern Recognition**   | "Your Tuesday meetings have 40% higher action completion rate"      |
| **Workload Balancing**    | "You have 8 meetings scheduled next week vs. 3 this week"           |
| **Outcome Correlation**   | "Clients with monthly QBRs have 25% higher engagement scores"       |

### Tier 4: Deep Dive (On Demand)

| Analysis                      | Description                                             |
| ----------------------------- | ------------------------------------------------------- |
| **Meeting Type Distribution** | Breakdown by QBR, Check-in, Escalation, Training, Other |
| **Client Engagement Ranking** | Sorted by meeting frequency, recency, duration          |
| **CSE Workload View**         | Meetings per CSE (for managers)                         |
| **Scheduling Patterns**       | Day of week and time of day heatmap                     |
| **Meeting Notes Analysis**    | AI summary of common themes across meetings             |

---

## Removed Components

| Current Component                             | Reason for Removal            |
| --------------------------------------------- | ----------------------------- |
| NPS Score KPI                                 | Not meeting-specific          |
| NPS Trend Chart                               | Belongs in dedicated NPS page |
| NPS Breakdown (Promoters/Passives/Detractors) | Not meeting-related           |
| Actions Completed KPI                         | Replaced with Follow-up Rate  |
| Overdue Actions KPI                           | Belongs in Actions page       |
| Compliance Metrics                            | Not meeting-specific          |

---

## Visual Design Specifications

### Colour Palette

```css
/* Semantic colours only */
--insight-positive: #10b981; /* Green - good trends */
--insight-warning: #f59e0b; /* Amber - attention needed */
--insight-critical: #ef4444; /* Red - urgent */
--insight-neutral: #6b7280; /* Grey - informational */
--background-primary: #ffffff;
--background-secondary: #f9fafb;
--text-primary: #111827;
--text-secondary: #6b7280;
```

### Typography

```css
/* Clean hierarchy */
--font-hero: 600 24px/32px Inter; /* AI summary */
--font-metric: 700 32px/40px Inter; /* Big numbers */
--font-label: 500 14px/20px Inter; /* KPI labels */
--font-body: 400 14px/20px Inter; /* Descriptions */
--font-caption: 400 12px/16px Inter; /* Secondary info */
```

### Spacing

```css
/* Generous white space */
--section-gap: 24px;
--card-padding: 20px;
--kpi-gap: 16px;
```

---

## Component Architecture

### New Components to Create

```
src/components/meeting-analytics/
├── MeetingInsightHero.tsx      # AI-powered narrative summary
├── MeetingKPIGrid.tsx          # 4 core metric cards
├── EngagementGapsList.tsx      # At-risk clients alert
├── MeetingVelocityChart.tsx    # Trend sparkline
├── MeetingMixDonut.tsx         # Type distribution
├── ClientEngagementRank.tsx    # Top clients list
├── AIRecommendationCards.tsx   # Actionable suggestions
└── index.ts                    # Barrel export
```

### API Updates

```typescript
// New endpoint: /api/analytics/meetings
GET /api/analytics/meetings?timeframe=30

Response:
{
  summary: {
    totalMeetings: number
    avgDuration: number
    clientsCovered: number
    totalClients: number
    followUpRate: number
  },
  velocity: {
    weeklyTrend: Array<{week: string, count: number}>
    direction: 'up' | 'down' | 'stable'
    changePercent: number
  },
  engagementGaps: Array<{
    clientName: string
    daysSinceLastMeeting: number
    lastMeetingType: string
    tier: string
  }>,
  meetingMix: {
    QBR: number
    'Check-in': number
    Escalation: number
    Training: number
    Other: number
  },
  topClients: Array<{
    clientName: string
    meetingCount: number
    avgDuration: number
  }>,
  aiInsights: Array<{
    type: 'scheduling' | 'pattern' | 'workload' | 'outcome'
    priority: 'high' | 'medium' | 'low'
    title: string
    description: string
    action?: {
      label: string
      href: string
    }
  }>,
  generatedAt: string
}
```

---

## Implementation Options

### Option A: Minimal Refresh

- Update `BentoAnalyticsDashboard` to remove NPS components
- Add engagement gaps and meeting velocity
- Keep existing layout structure
- **Effort:** Low (1-2 days)

### Option B: Component Refactor

- Create new `MeetingAnalyticsDashboard` component
- New dedicated API endpoint
- Progressive disclosure with expandable sections
- **Effort:** Medium (3-5 days)

### Option C: Full Redesign

- Complete new component architecture
- AI recommendation engine integration
- Natural language query support
- Interactive drill-down capabilities
- **Effort:** High (1-2 weeks)

---

## Recommended Approach

**Option B (Component Refactor)** provides the best balance of:

- Modern, focused design
- AI-powered insights
- Reasonable implementation effort
- Room for future enhancement

---

## Success Metrics

| Metric            | Target                                |
| ----------------- | ------------------------------------- |
| Time to insight   | < 3 seconds to understand key metrics |
| Cognitive load    | Max 4 KPIs visible at once            |
| Actionability     | Every insight has a clear next step   |
| White space ratio | 40%+ of visible area                  |

---

## References

- [Dashboard Design Trends 2025](https://fuselabcreative.com/top-dashboard-design-trends-2025/)
- [AI Dashboard Design](https://fuselabcreative.com/ai-dashboard-future-proofing-business-analytics/)
- [UX Pin Dashboard Principles](https://www.uxpin.com/studio/blog/dashboard-design-principles/)
- Linear, Stripe, Vercel design systems (inspiration)
