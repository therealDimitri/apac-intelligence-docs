# Analytics Page Redesign Proposal

**Date:** 2025-12-20
**Status:** Draft
**Author:** Claude Code

---

## Executive Summary

This document proposes a redesign of the Briefing Room Analytics page, inspired by top tech companies (Linear, Stripe, Vercel, Notion) and focused on making AI insights the hero of the experience. The goal is to create a clean, scannable dashboard that delivers actionable intelligence within 5 seconds.

---

## Current State Analysis

### What Works Well

- KPI cards provide at-a-glance metrics
- TrendAnalysisChart components show temporal patterns
- AIInsightsPanel has good filtering and categorisation
- Timeframe selector (30D/90D/1Y) is intuitive

### Opportunities for Improvement

| Issue                     | Current State                                | Impact                                  |
| ------------------------- | -------------------------------------------- | --------------------------------------- |
| **Information hierarchy** | All sections have equal visual weight        | Users can't identify priorities quickly |
| **AI insights buried**    | AIInsightsPanel appears after trend charts   | AI value proposition is hidden          |
| **Dense presentation**    | Multiple chart types competing for attention | Cognitive overload                      |
| **Loading states**        | Generic spinner                              | Feels slow, lacks polish                |
| **No dark mode**          | Light only                                   | Eye strain, lacks modern feel           |
| **Static feel**           | Minimal animations                           | Feels dated vs. competitors             |

---

## Design Options

### Option A: "AI-First Hero Dashboard" (Recommended)

**Concept:** Lead with AI insights as the primary content, with supporting metrics below.

```
┌─────────────────────────────────────────────────────────────────────┐
│  Analytics                                          [30D] [90D] [1Y]│
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ ✨ AI SUMMARY                                                │   │
│  │                                                              │   │
│  │ "Client engagement is up 12% this month, driven by          │   │
│  │  increased meeting frequency with SA Health. However,       │   │
│  │  3 actions are overdue and require immediate attention."    │   │
│  │                                                              │   │
│  │ [View Critical Items →]                                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐                   │
│  │ 76      │ │ 85%     │ │ +42     │ │ 3       │                   │
│  │ Meetings│ │ Actions │ │ NPS     │ │ Overdue │                   │
│  │ ↑ 12%   │ │ ↑ 5%    │ │ ↑ 8pts  │ │ ↓ 2     │                   │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘                   │
│                                                                     │
│  ┌────────────────────────────────┐ ┌────────────────────────────┐ │
│  │ HEALTH TREND                   │ │ TOP INSIGHTS               │ │
│  │ [Sparkline chart]              │ │ ⚠️ SA Health compliance    │ │
│  │                                │ │    dropped to 72%          │ │
│  │                                │ │ 💡 Schedule Q1 reviews     │ │
│  │                                │ │    with detractors         │ │
│  │                                │ │ ✅ SingHealth NPS up 15pts │ │
│  └────────────────────────────────┘ └────────────────────────────┘ │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │ DETAILED INSIGHTS                              [Filter ▼]    │  │
│  │ ─────────────────────────────────────────────────────────────│  │
│  │ [Expandable insight cards...]                                │  │
│  └──────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Features:**

- Natural language AI summary as hero element
- Compact KPI cards with trend indicators
- Top 3 insights visible without scrolling
- Progressive disclosure for detailed analysis

---

### Option B: "Split-View Command Centre"

**Concept:** Fixed left panel for navigation/filters, scrollable right panel for content.

```
┌────────────────────┬────────────────────────────────────────────────┐
│ ANALYTICS          │                                                │
│                    │  AI SUMMARY                                    │
│ ┌────────────────┐ │  "Your portfolio health score is 78/100..."   │
│ │ Overview       │ │                                                │
│ │ ● Active       │ │  ┌─────────┐ ┌─────────┐ ┌─────────┐          │
│ └────────────────┘ │  │ 76      │ │ +42     │ │ 85%     │          │
│ ┌────────────────┐ │  │ Meetings│ │ NPS     │ │ Actions │          │
│ │ NPS Deep Dive  │ │  └─────────┘ └─────────┘ └─────────┘          │
│ └────────────────┘ │                                                │
│ ┌────────────────┐ │  TREND ANALYSIS                               │
│ │ Meeting Trends │ │  [Combined multi-line chart]                  │
│ └────────────────┘ │                                                │
│ ┌────────────────┐ │  INSIGHTS FEED                                │
│ │ Action Tracker │ │  [Chronological insight cards]                │
│ └────────────────┘ │                                                │
│                    │                                                │
│ FILTERS            │                                                │
│ [30D] [90D] [1Y]   │                                                │
│ Department [All ▼] │                                                │
│ Client [All ▼]     │                                                │
└────────────────────┴────────────────────────────────────────────────┘
```

**Key Features:**

- Persistent navigation for multi-view exploration
- Filters always visible
- Deep-dive views for each metric category
- Good for power users who analyse frequently

---

### Option C: "Bento Grid" (Modern / Notion-inspired)

**Concept:** Asymmetric grid of cards with varying sizes based on importance.

```
┌─────────────────────────────────────────────────────────────────────┐
│  Analytics                                          [30D] [90D] [1Y]│
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌───────────────────────────────────┐ ┌────────────┐ ┌────────────┐│
│  │                                   │ │ 76         │ │ +42        ││
│  │  ✨ AI INSIGHTS                   │ │ Meetings   │ │ NPS Score  ││
│  │                                   │ │ ↑ 12%      │ │ ↑ 8 pts    ││
│  │  "3 clients need attention..."    │ └────────────┘ └────────────┘│
│  │                                   │ ┌────────────┐ ┌────────────┐│
│  │  [Critical] SA Health compliance  │ │ 85%        │ │ 3          ││
│  │  [Warning] Q4 targets at risk     │ │ Completion │ │ Overdue    ││
│  │  [Opportunity] NPS momentum       │ │ ↑ 5%       │ │ ↓ 2        ││
│  │                                   │ └────────────┘ └────────────┘│
│  └───────────────────────────────────┘                              │
│                                                                     │
│  ┌──────────────────────┐ ┌──────────────────────┐ ┌──────────────┐ │
│  │ PORTFOLIO HEALTH     │ │ MEETING ACTIVITY     │ │ TOP CLIENTS  │ │
│  │ [Area chart]         │ │ [Bar chart]          │ │ 1. SA Health │ │
│  │                      │ │                      │ │ 2. SingHealth│ │
│  │                      │ │                      │ │ 3. GHA       │ │
│  └──────────────────────┘ └──────────────────────┘ └──────────────┘ │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │ NPS DISTRIBUTION                                              │  │
│  │ ████████████████████░░░░░░ Promoters 68%                      │  │
│  │ ███████░░░░░░░░░░░░░░░░░░░ Passives  22%                      │  │
│  │ ███░░░░░░░░░░░░░░░░░░░░░░░ Detractors 10%                     │  │
│  └───────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Features:**

- Visual hierarchy through card sizing
- AI insights prominently placed but not overwhelming
- Efficient use of horizontal space
- Modern, magazine-style layout

---

## Recommendation: Option A with Bento Elements

Combine the AI-first approach of Option A with the visual interest of Option C's bento grid.

### Key Design Principles

1. **5-Second Rule:** Main insight visible immediately
2. **Progressive Disclosure:** Summary → Details → Deep Dive
3. **Action-Oriented:** Every insight suggests a next step
4. **Breathing Room:** Generous whitespace, avoid cramming

---

## Detailed Component Specifications

### 1. AI Summary Hero Card

**Purpose:** Immediate value delivery - what should I pay attention to today?

```tsx
// Proposed component structure
<AIHeroSummary>
  <GradientBackground /> {/* Subtle purple-blue gradient */}
  <SparklesIcon />
  <NaturalLanguageSummary>
    "Your portfolio is performing well this month. Client engagement increased 12%, and NPS improved
    8 points. However, 3 actions need immediate attention before Friday."
  </NaturalLanguageSummary>
  <QuickActions>
    <Button variant="ghost">View Overdue Actions →</Button>
    <Button variant="ghost">See NPS Details →</Button>
  </QuickActions>
</AIHeroSummary>
```

**Design Specs:**

- Background: Linear gradient `from-purple-50 to-blue-50` (light) / `from-purple-950 to-blue-950` (dark)
- Border: 1px `purple-200` / `purple-800`
- Padding: 24px
- Typography: 16px body, 1.6 line-height for readability
- Animation: Subtle shimmer effect on "AI" badge

---

### 2. Compact KPI Cards

**Purpose:** At-a-glance metrics with trend context

```
┌─────────────────────┐
│ ↑ 12%               │  ← Trend indicator (green up, red down)
│                     │
│ 76                  │  ← Primary metric (32px, bold)
│ Total Meetings      │  ← Label (12px, gray)
│                     │
│ ▁▂▃▄▅▆▇█▇▆         │  ← Sparkline (optional)
└─────────────────────┘
```

**Design Specs:**

- Width: Flexible, min 160px
- Height: Fixed 120px
- Border radius: 12px
- Shadow: `shadow-sm` on hover → `shadow-md`
- Transition: 200ms ease-out

---

### 3. Insight Cards (Redesigned)

**Current:** Dense cards with multiple badges
**Proposed:** Clean cards with visual hierarchy

```
┌─────────────────────────────────────────────────────────────────┐
│ ⚠️                                                              │
│                                                                 │
│ SA Health compliance dropped to 72%                             │
│                                                                 │
│ Meeting frequency decreased 23% month-over-month. Consider      │
│ scheduling a partnership review to address engagement gaps.     │
│                                                                 │
│ [Schedule Meeting →]                          85% confidence    │
└─────────────────────────────────────────────────────────────────┘
```

**Changes:**

- Single icon (no badge overload)
- Title as headline (bold, 16px)
- Description as body text (14px, gray-700)
- Single primary action button
- Confidence as subtle footer text

---

### 4. Colour Palette Update

**Current:** Multiple competing colours
**Proposed:** Refined palette with brand purple as primary

| Token      | Light Mode | Dark Mode | Usage                      |
| ---------- | ---------- | --------- | -------------------------- |
| `primary`  | `#7C3AED`  | `#A78BFA` | Actions, highlights, brand |
| `success`  | `#10B981`  | `#34D399` | Positive trends, completed |
| `warning`  | `#F59E0B`  | `#FBBF24` | Attention needed           |
| `critical` | `#EF4444`  | `#F87171` | Urgent, overdue            |
| `surface`  | `#FFFFFF`  | `#1F2937` | Card backgrounds           |
| `muted`    | `#F9FAFB`  | `#111827` | Page background            |
| `border`   | `#E5E7EB`  | `#374151` | Card borders               |

---

### 5. Loading States

**Current:** Generic spinner
**Proposed:** Skeleton screens with shimmer

```tsx
// Skeleton for KPI card
<div className="animate-pulse">
  <div className="h-4 w-12 bg-gray-200 rounded mb-2" />
  <div className="h-8 w-16 bg-gray-200 rounded mb-1" />
  <div className="h-3 w-20 bg-gray-200 rounded" />
</div>
```

**Animation Specs:**

- Duration: 1.5s
- Timing: ease-in-out
- Shimmer: Left to right gradient sweep

---

### 6. Empty State

**When no data is available:**

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                      [Illustration]                             │
│                                                                 │
│               No analytics data yet                             │
│                                                                 │
│    Start by syncing meetings from Outlook or creating           │
│    meetings manually. Analytics will appear once you            │
│    have data to analyse.                                        │
│                                                                 │
│                   [Sync Outlook →]                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Micro-Interactions

### Hover Effects

- KPI cards: Subtle lift (translateY -2px) + shadow increase
- Insight cards: Border colour intensifies
- Buttons: Background opacity change + scale 1.02

### Transitions

- Tab switches: 200ms fade
- Data refresh: Skeleton shimmer → content fade-in
- Filter changes: 150ms content opacity transition

### Click Feedback

- Buttons: Scale down 0.98 on active
- Cards: Brief highlight flash

---

## Responsive Behaviour

| Breakpoint          | KPI Grid  | Trend Charts     | Insights   |
| ------------------- | --------- | ---------------- | ---------- |
| Mobile (<640px)     | 2 columns | Stack vertically | Full width |
| Tablet (640-1024px) | 4 columns | 2 columns        | Full width |
| Desktop (>1024px)   | 4 columns | 2 columns        | 2 columns  |

---

## Implementation Phases

### Phase 1: Foundation (Week 1)

- [ ] Create new colour token system
- [ ] Build skeleton loading components
- [ ] Implement AI Hero Summary component
- [ ] Redesign KPI cards with sparklines

### Phase 2: AI Insights (Week 2)

- [ ] Redesign insight cards (simplified)
- [ ] Add natural language summary generation
- [ ] Implement progressive disclosure
- [ ] Add quick action buttons

### Phase 3: Polish (Week 3)

- [ ] Add micro-interactions
- [ ] Implement dark mode
- [ ] Responsive optimisation
- [ ] Performance testing

---

## Success Metrics

| Metric                          | Target              |
| ------------------------------- | ------------------- |
| Time to first insight           | < 3 seconds         |
| User engagement with AI summary | > 60% click-through |
| Page load (Lighthouse)          | > 90 score          |
| Accessibility (Lighthouse)      | 100 score           |

---

## Next Steps

1. **Review this proposal** - Gather feedback on direction
2. **Create Figma mockups** - Visual design exploration
3. **Prototype AI summary** - Test natural language generation
4. **Implement Phase 1** - Foundation components

---

## Appendix: Inspiration Sources

- **Linear:** Clean typography, intentional dashboards
- **Stripe:** Card-based layout, restrained colour use
- **Vercel:** Developer-centric, fast interactions
- **Notion:** Bento grid, playful empty states
- **Datadog:** AI insights presentation, confidence indicators
