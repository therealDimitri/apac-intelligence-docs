# Debt/Polish: Deferred P5 Items + NPS DataTable Migration

**Date:** 2026-02-15
**Status:** Approved
**Scope:** 3 deferred items — NPS DataTable migration, LayoutTokens.card adoption, component consolidation

## 1. NPS DataTable Migration

### Current State
The NPS "Client Scores & Trends" section (`src/app/(dashboard)/nps/page.tsx`, lines 1155-1398, ~240 lines) renders each client as a stacked card with logo, name, segment/ownership badges, NPS score, trend icon, sparkline chart, and expandable AI insight panel. Right-click opens a custom context menu (lines 1476-1548).

### Target State
Replace card layout with the existing `DataTable` component (`src/components/ui/enhanced/DataTable.tsx`), adding expandable row details for AI insights.

### Column Design

| Column | Width | Content |
|--------|-------|---------|
| Client | 200px | `ClientLogoDisplay` + display name + "My Client" / segment badges |
| NPS Score | 100px | Score value colour-coded (green >= 70, yellow >= 0, red < 0) + trend arrow |
| Trend | 140px | `SparklineChart` inline (height 32px) |
| Responses | 90px | Response count |
| Risk Level | 110px | AI risk badge (Critical/High/Medium/Low) from `clientInsights` map |
| Actions | 50px | `RowAction` dropdown replacing context menu |

### Row Actions (replacing context menu)
- View NPS Feedback → opens existing `ClientNPSTrendsModal`
- View Client Profile → navigates to `/client-profiles?search=`
- Create Action → navigates to `/actions?client=`
- View Meetings → navigates to `/meetings?client=`
- Export Report → calls `handleExportReport()`

### Expandable Row Details
Clicking a row expands to show the AI insights panel:
- Risk level + confidence badges
- Summary text
- Key factors (bullet list, max 3)
- Recommended actions (pill badges)

### DataTable Enhancement Required
Add `renderExpandedRow?: (row: T) => React.ReactNode` prop to `DataTable.tsx` — renders a full-width detail panel below the row when expanded. Toggle via row click or chevron column.

### Unchanged Sections
- Summary cards at top (NPS score, promoter/passive/detractor breakdown)
- Global benchmark comparison (`GlobalNPSBenchmark`)
- Top Topics by Client Segment panel (`TopTopicsBySegment`)
- Feedback modal (`ClientNPSTrendsModal`)
- Floating comments
- Segment filter buttons (moved to above DataTable)
- Search input (moved to DataTable toolbar area)

## 2. LayoutTokens.card / CardContainer Adoption

### Current State
`CardContainer` (`src/components/ui/CardContainer.tsx`) wraps `LayoutTokens.card` with configurable padding (`standard`/`compact`/`none`) and optional elevation. Built in P13 but only ~30% adopted.

### Migration Targets

| Category | File(s) | ~Count | Approach |
|----------|---------|--------|----------|
| Skeleton components | `src/components/ui/skeletons/index.tsx` | 10 | Replace `bg-white rounded-lg border border-gray-200` with `CardContainer padding="none"` |
| NPS summary cards | `src/app/(dashboard)/nps/page.tsx` | 5 | Wrap summary card, stats grid, client scores section header, topics section |
| Widget dropdown | `src/components/dashboard/WidgetContainer.tsx` | 1 | Replace inline menu styling |
| Employee search | `src/components/ui/employee-search.tsx` | 1 | Dropdown overlay |

### Explicitly Excluded
- **Dashboard gradient widgets** (`BURCExecutiveWidgets.tsx`, `DataInsightsWidgets.tsx`) — use status-coloured gradients intentionally different from neutral `LayoutTokens.card`
- **Form field borders** (`EditMeetingModal.tsx`) — input borders, not card containers
- **Domain cards** (GoalCard, DealCard, etc.) — specialised layouts with hover states, drag handles, status borders

### Net Impact
~17 instances converted. Remaining ad-hoc patterns are either intentionally different or inside complex domain components.

## 3. Component Consolidation

### Targets

| Item | File(s) | Action |
|------|---------|--------|
| Local StatusBadge duplicate | `src/components/goals/MeetingBriefPanel.tsx:89` | Delete local, import from `@/components/ui/StatusBadge` |
| Local StatusBadge duplicate | `src/components/team-performance/CSEPerformanceTable.tsx:74` | Delete local, import from `@/components/ui/StatusBadge` |
| TrendBadge extraction | Inline in `LeadingIndicatorsPanel.tsx:50`, also in NPS page | Extract to `src/components/ui/TrendBadge.tsx` — reusable up/down/flat indicator with colour coding |
| NPS context menu removal | `nps/page.tsx:1476-1548` | Eliminated by DataTable migration (replaced by RowAction dropdown) |

### Explicitly Excluded
- Gamification badges (RankBadge, StreakBadge) — domain-specific, single-use
- `DataFreshnessBadge` — specialised sync status indicator
- `PendingApprovalsBadge` / `OverdueCheckInBadge` — goal-specific with sidebar variants

## Execution Order

1. **NPS DataTable migration** — biggest item, also eliminates NPS card instances + context menu
2. **CardContainer adoption sweep** — skeletons, NPS summary sections, widget dropdowns
3. **Component consolidation** — StatusBadge dedup + TrendBadge extraction

Items 2 and 3 overlap with NPS since the NPS page gets CardContainer wrappers and TrendBadge in the same pass.
