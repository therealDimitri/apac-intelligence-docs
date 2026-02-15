# P3 UX Bug Fixes & Enhancements Sprint

**Date:** 10 February 2026
**Type:** Bug Fixes + UI/UX Enhancements
**Status:** Complete

## Summary

Shipped 25 bug fixes and enhancements across 8 domains: Command Centre/Audio, Daily Digest, Goals page layout, Timeline/Gantt, Strategy Map, Kanban, Goal Detail, and Actions navigation. Brought UX coherence score to 7.5/10 and all 44 features remain LIVE.

**Commits:**
- `52c39a8f` — Main implementation (all 25 items)
- `6c53a249` — Timeline drill sync fix (browser back/forward)
- `032c3c4d` — Knowledge base documentation updates

## Groups Delivered

### Group A: Command Centre / Audio (2 items)

| # | Type | Fix |
|---|------|-----|
| A1 | BUG | ElevenLabs API `Accept: audio/mpeg` header — was returning 400. Combined error messages across providers |
| A2 | ENHANCEMENT | Removed voice selector dropdown, hardcoded 'charlie' voice |

**Files:** `audio-briefing-generator.ts`, `AudioPlayer.tsx`

### Group B: Daily Digest (2 items)

| # | Type | Fix |
|---|------|-----|
| B1 | ENHANCEMENT | Alerts grouped by category (Churn Risk, Health Trajectory, etc.) with collapsible sections using `@radix-ui/react-collapsible` |
| B2 | BUG | Stale meeting dates — `new Date('2026-02-09')` parsed as UTC midnight = Feb 8 in AEST. Fixed with `parseLocalDate()` using `new Date(y, m-1, d)` |

**Files:** `ActionableIntelligenceDashboard.tsx`

### Group C: Goals Page Layout (3 items)

| # | Type | Fix |
|---|------|-----|
| C1 | ENHANCEMENT | Tab reorder (9 tabs: Overview → Dashboard → Strategy Map → Pillar → BU Goals → Team → Projects → Timeline → Workload), FolderKanban icon for Projects, removed Automations tab |
| C2 | ENHANCEMENT | Gear icon → Zap for automations button (top-right) |
| C3 | ENHANCEMENT | Consistent full-width layout for all goal-type tabs + timeline + strategy map + workload |

**Files:** `goals-initiatives/page.tsx`

### Group D: Strategy Map (1 item)

| # | Type | Fix |
|---|------|-----|
| D1 | BUG | Zoom controls cut off — moved XYFlow `<Controls>` to `position="bottom-right"` with shadow/border styling |

**Files:** `StrategyMap.tsx`

### Group E: Timeline / Gantt (4 items)

| # | Type | Fix |
|---|------|-----|
| E1 | BUG | Default all collapsed — changed `expandedIds` init from all parents to empty `Set()` |
| E2 | BUG | Children appearing at bottom instead of under parent — added hierarchical DFS sort (`sortHierarchically()`) |
| E3 | BUG | Day view showing just "10" — changed to "Mon 10" format with thicker Monday borders |
| E4 | BUG | Browser Back skipping drill states — split `router.push()` (user drills) vs `router.replace()` (mount sync). Second fix (`6c53a249`): added `searchParams` to useEffect dependency so URL changes from browser Back trigger state updates |

**Files:** `useGanttData.ts`, `GanttView.tsx`, `gantt/TimeHeader.tsx`

### Group F: Kanban (1 item)

| # | Type | Fix |
|---|------|-----|
| F1 | BUG | Hard black divider on column headers — added `border-white/50` for softer appearance |

**Files:** `GoalKanbanBoard.tsx`

### Group G: Goal Detail (3 items)

| # | Type | Fix |
|---|------|-----|
| G1 | BUG | AI Suggest popover overflowing viewport — changed `left-0` to `right-0` with `max-w-[calc(100vw-2rem)]` |
| G2 | BUG | Linked Actions badge misalignment — added `flex-shrink-0`, tightened gap |
| G3 | ENHANCEMENT | Reduced wasted space: auto-sizing description with `line-clamp-3` + "Show more", tighter `gap-4` spacing, compact single-row metadata bar (progress% | status | date range | owner) |

**Files:** `CheckInSuggestButton.tsx`, `goals-initiatives/[type]/[id]/page.tsx`

### Group H: Actions from Goals (3 items)

| # | Type | Fix |
|---|------|-----|
| H1 | BUG | Notes rendering raw HTML — added `DOMPurify.sanitize()` + `dangerouslySetInnerHTML` with prose styling |
| H2 | BUG | "Back to Actions" always going to /actions — added `?from=` and `?title=` query params for contextual breadcrumbs ("Back to Revenue Growth Target") |
| H3 | ENHANCEMENT | Action editing from goal detail — reused `ActionSlideOutEdit` component with auto-linked `linkedInitiativeId`, kebab menu with Edit/Delete options |

**Files:** `actions/[id]/page.tsx`, `goals-initiatives/[type]/[id]/page.tsx`

### Group I: Goals Dashboard (1 item)

| # | Type | Fix |
|---|------|-----|
| I1 | ENHANCEMENT | Actions reporting widget (status breakdown, overdue count) + recent activity widget + scope-sensitive filtering by goal type |

**Files:** `GoalsDashboard.tsx`, `api/goals/dashboard/activity/route.ts`

## UX Research Applied

- **Timeline drill navigation**: Jira, ClickUp, Monday.com, Linear all use `pushState` for user drills, `replaceState` for mount sync only
- **Day view format**: Industry standard "Mon 10" format (Jira, ClickUp, Monday.com)
- **Goal detail layout**: Baymard Institute 27% content miss rate for horizontal tabs vs 8% for vertical sections — Phase 1 quick wins shipped, Phase 2 accordion refactor deferred
- **Context-aware navigation**: Query parameter pattern (`?from=`) preferred over `router.back()` — survives new tabs and bookmarks

## Verification

- `tsc --noEmit` — passed
- `npm run build` — passed
- Playwright browser testing at localhost:3001 — 23/25 items verified visually (A1 needs API key, G2 needs linked action test data)
- Knowledge base updated (5 files in docs submodule)

## Key Patterns Established

1. **`parseLocalDate()`** — Use for any date-only string comparison to avoid UTC midnight timezone shift
2. **`?from=` + `?title=`** — Context-aware back navigation pattern for cross-page links
3. **`ActionSlideOutEdit` reuse** — Single editor component shared between Actions page and Goal detail
4. **`router.push()` vs `router.replace()`** — Push for user actions (browser history), replace for state restoration only
