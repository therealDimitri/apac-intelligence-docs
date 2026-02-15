# Goals Dashboard Drill-Down Design

**Date:** 2026-02-13
**Status:** Approved
**Approach:** Slide-Out Drawer (Approach A)

## Problem

The Goals & Projects Dashboard tab has 8 widgets and 4 KPI cards but zero drill-down capability. All content is read-only with filter-only interactivity. Users cannot inspect individual goals, take quick actions, or navigate to detail pages from the dashboard.

## Design

### Trigger Map

| Widget | Trigger | Drawer Shows |
|--------|---------|-------------|
| **KPI Cards** (top row) | Click "Total Goals (12)" | All goals |
| | Click "Completed (3)" | Goals with status `completed` |
| | Click "At Risk (4)" | Goals with status `at_risk` |
| | Click "Overdue (2)" | Goals past target_date, not completed |
| **Status Distribution** | Click pie wedge | Goals matching that status |
| **Goals by Owner** | Click owner bar segment | Goals for that owner + status |
| **Overdue Goals** | Click a goal row | Single goal detail in drawer |
| **Check-In Freshness** | Click a freshness card | Single goal detail in drawer |
| **Recent Activity** | Click an activity entry | Single goal detail in drawer |
| **Linked Actions** | Click "Open (5)" or "Overdue (2)" | Linked actions filtered by status |
| **Progress Timeline** | No drill-down | Tooltip only |
| **Financial Alignment** | No drill-down | Empty state, skip |

### Drawer Component

Single reusable `GoalDrillDownDrawer` with three modes:

```ts
type DrillContext =
  | { mode: 'list'; title: string; filter: { status?: GoalStatus; type?: GoalType; owner?: string; overdue?: boolean } }
  | { mode: 'single'; goalId: string; goalType: GoalType }
  | { mode: 'actions'; title: string; filter: { actionStatus: string } }
```

**Drawer shell:**
- Width: 480px desktop, full-width mobile (< md)
- Slides from right: `translateX(100%) → translateX(0)`, 300ms ease-out
- Semi-transparent scrim (`bg-black/20`), click to close
- Escape closes, focus trapped inside

**Layout:**
```
┌─────────────────────────────────┐
│ Header                          │
│  Title: "At Risk Goals (4)"     │
│  Subtitle: context breadcrumb   │
│  [X] close button               │
├─────────────────────────────────┤
│ Quick Stats Bar (optional)      │
│  ● 2 overdue  ● 1 no owner     │
├─────────────────────────────────┤
│ Goal List (scrollable)          │
│  ┌────────────────────────────┐ │
│  │ ● Goal title               │ │
│  │ BU Goal · Owner · Due 30/6│ │
│  │ ████████░░ 65%             │ │
│  │ [Status ▾]      [Open →]  │ │
│  └────────────────────────────┘ │
├─────────────────────────────────┤
│ Footer                          │
│  "View all in Goals & Projects" │
│  → navigates to filtered tab    │
└─────────────────────────────────┘
```

### Goal Row Card

Each goal in list mode:
- **Status dot** — coloured circle left of title
- **Title** — bold, 2-line truncation
- **Meta line** — type label, owner (or "Unassigned"), due date (red if overdue with "X days overdue")
- **Progress bar** — thin bar, status colour, percentage right-aligned
- **Quick actions:** status dropdown (PATCH on change, optimistic update) + "Open →" button (navigates to detail page)

**Sorting:** overdue context → days overdue desc; status context → progress asc; owner context → alphabetical.

**Empty state:** checkmark icon + "No goals match this filter"

### Single Goal Mode

For clicks on individual overdue rows, freshness cards, or activity entries:
- Title, description, status, owner, progress, due date, last check-in, child goals count, recent activity
- "Open Full Detail →" button

### Actions Mode

For clicks on Linked Actions stat counts:
- Filters from already-loaded `useActions()` data (no extra fetch)
- Shows action title, status, owner, due date, linked goal name

### Click Affordance

- KPI cards: `cursor-pointer`, `hover:ring-2 ring-purple-200`, `active:scale-[0.98]`
- Pie wedges: click handler added (hover highlighting already exists)
- Owner bar segments: same as pie
- Overdue/freshness/activity rows: `cursor-pointer`, `hover:bg-gray-50`

### Accessibility

- `role="dialog"`, `aria-label` = header title, `aria-modal="true"`
- Focus trap: tab cycles within drawer only
- `aria-hidden="true"` on dashboard content behind scrim
- Escape closes, focus returns to trigger element
- Status dropdown is native `<select>` — standard keyboard handling
- `Enter` on goal row opens detail page

### Mobile (< md)

- Full-width overlay (no scrim, full takeover)
- Close button in header
- Footer "View all" link remains

### URL State

No URL params for the drawer — transient UI. Footer "View all" link navigates with query params (`?status=at_risk`) for shareability.

## Files

**New:**
| File | Purpose |
|------|---------|
| `src/components/goals/GoalDrillDownDrawer.tsx` | Drawer shell + list/single/actions modes |
| `src/components/goals/GoalDrillDownRow.tsx` | Goal row card with quick actions |

**Modified:**
| File | Change |
|------|--------|
| `src/components/goals/GoalsDashboard.tsx` | Add `drillContext` state, click handlers on all triggers, render drawer |

**No new API routes** — existing endpoints support all required filters.

## State Flow

```
GoalsDashboard
  ├─ drillContext: DrillContext | null
  ├─ setDrillContext()
  │
  ├─ MetricCard onClick → setDrillContext({ mode:'list', filter:{status}, title })
  ├─ Pie wedge onClick → setDrillContext({ mode:'list', filter:{status}, title })
  ├─ Owner bar onClick → setDrillContext({ mode:'list', filter:{owner, status}, title })
  ├─ Overdue row onClick → setDrillContext({ mode:'single', goalId, goalType })
  ├─ Freshness card onClick → setDrillContext({ mode:'single', goalId, goalType })
  ├─ Activity entry onClick → setDrillContext({ mode:'single', goalId, goalType })
  ├─ Actions stat onClick → setDrillContext({ mode:'actions', filter:{actionStatus}, title })
  │
  └─ <GoalDrillDownDrawer
       context={drillContext}
       onClose={() => setDrillContext(null)}
       onStatusChange={handleStatusChange}
       onNavigate={(type, id) => router.push(`/goals-initiatives/${type}/${id}`)}
     />
```
