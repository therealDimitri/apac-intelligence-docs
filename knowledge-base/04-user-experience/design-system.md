# Design System

## Tech Stack
- **CSS Framework**: Tailwind CSS (utility-first)
- **Component Library**: shadcn/ui (~24 base components)
- **Icons**: Lucide React (consistent 24px)
- **Charts**: Recharts (primary), D3 (network graph), Three.js (3D pipeline)
- **Fonts**: System fonts in UI; Montserrat in PDF exports only

## Colour Palette

### UI Colours (Tailwind)
| Role | Tailwind Class | Usage |
|------|---------------|-------|
| Primary | `purple-600`, `purple-700`, `purple-900` | Sidebar, CTAs, branding |
| Secondary | `gray-100` through `gray-900` | Text, backgrounds, borders |
| Active accent | `emerald-400` | Active states, AI indicators |
| AI accent | `teal-500` | AI components |
| Success | `green-500` | Positive states |
| Warning | `amber-500` | Warnings |
| Error | `red-500` | Errors, critical |

### Brand Colours (PDF/PPTX exports only)
```
Purple primary: #383392
Purple light: #4c47c3
Coral: #F56E7B
Teal: #00BBBA
Blue: #0076A2
```
Defined in `src/lib/pdf/altera-branding.ts`.

## Layout Architecture

### Dashboard Shell
```
<DashboardLayout>
  SessionProvider → ClientProvider → SidebarProvider → TooltipProvider
  └── DashboardLayoutContent
      ├── Desktop Sidebar (hidden <768px) — purple gradient, 256px wide
      ├── Main Content Area — bg-gray-50, overflow-y-auto
      ├── Mobile Bottom Nav (hidden >=768px)
      ├── Mobile Drawer (slides from left)
      ├── FloatingChaSenAI (dynamic import, ssr: false)
      ├── ContextualHelpWidget
      ├── UnifiedSidebar (right-side panel)
      └── ExplainThisPopover
```

### Responsive Breakpoints
- **Mobile**: `<768px` — Full-width, bottom nav, drawer sidebar
- **Desktop**: `>=768px` — Persistent sidebar, full layout, floating AI

### Key Layout Components
| Component | File | Purpose |
|-----------|------|---------|
| Sidebar | `src/components/layout/Sidebar.tsx` | Purple gradient navigation (530 lines) |
| MobileBottomNav | Layout component | Mobile tab bar |
| MobileDrawer | Layout component | Left-slide navigation |
| FloatingChaSenAI | Dynamic import | AI chat widget (1157 lines) |
| UnifiedSidebar | Layout component | Right detail panel |

## Component Inventory

### Base UI (`src/components/ui/`) — 61 files
| Type | Examples |
|------|---------|
| shadcn/ui | Button, Card, Dialog, DropdownMenu, Input, Badge, Checkbox, Collapsible, AlertDialog |
| Custom | AudioPlayer, AnimatedNumber, ExpandableMetric, LazyChart, ChartSkeleton, LiveDataPulse, glass-panel, BottomSheet, MobileFilterSheet |
| Shared tokens | StatusBadge, EmptyState, CardContainer |

### Shared Token Components (P13)

| Component | File | Purpose |
|-----------|------|---------|
| `StatusBadge` | `src/components/ui/StatusBadge.tsx` | Unified badge for status, priority, health, NPS sentiment. Wraps `BadgeStyles` + colour token functions. Props: `status`, `priority`, `health`, `sentiment`, `label`, `variant` |
| `EmptyState` | `src/components/ui/EmptyState.tsx` | Standard + compact empty states with icon, title, description, optional CTA. Use `compact` for sidebars/cards |
| `CardContainer` | `src/components/ui/CardContainer.tsx` | Thin wrapper applying `LayoutTokens.card` + configurable padding (`standard`/`compact`/`none`) + `elevated` option |

### Specialised Components
| Directory | Purpose |
|-----------|---------|
| `src/components/dashboard/` | DashboardHeader, KPIHeroRow (expandable bento cards), BURCExecutiveWidgets, DataInsightsWidgets, DashboardGrid, WidgetContainer |
| `src/components/dashboard/tabs/` | OverviewTab, ActionsTab, FinancialPerformanceTab, PipelineRenewalsTab, AnalyticsTab |
| `src/components/financials/` | MetricCard, PipelineSectionView, RenewalsTable, TeamActionCards, EbitaGauge, WaterfallChart, MonthlyEbitaTrend, ClientRevenueBreakdown, PsPipelineSummary, NetRevenueImpactBar |
| `src/components/ai/` | PredictiveInput, LeadingIndicatorAlerts, AnomalyHighlight, ExplainThisPopover |
| `src/components/charts/` | CoverageGauge, ForecastChart, HealthRadar, NarrativeDashboard |
| `src/components/layout/` | Sidebar, navigation components |
| `src/components/meetings/` | TranscriptionPanel, SentimentGauge, CoHostSuggestionCard |
| `src/components/goals/` | GoalCard, ProgressBar, CheckInTimeline |
| `src/components/twins/` | TwinProfileCard, SimulationChat |
| `src/components/sandbox/` | DealSandbox, TermsSlider |
| `src/components/visualisation/` | NetworkGraph, PipelineLandscape |
| `src/components/sentiment/` | SentimentSparkline, SentimentTrendChart |
| `src/components/planning/` | AutopilotDashboard, RecognitionDashboard |

## Typography

Centralised in `TypographyClasses` from `@/lib/design-tokens`:
| Token | Classes | Usage |
|-------|---------|-------|
| `pageTitle` | `text-2xl font-bold text-gray-900` | `<h1>` page headings |
| `sectionTitle` | `text-lg font-semibold text-gray-900` | `<h2>`/`<h3>` sections |
| `cardTitle` | `text-base font-semibold text-gray-900` | Card-level headings |
| `body` | `text-sm text-gray-600` | Body text |
| `caption` | `text-xs text-gray-500` | Captions, timestamps |
| `label` | `text-sm font-medium text-gray-700` | Form labels |
| Sidebar labels | `text-sm font-medium text-white/80` | Sidebar nav items |

**Rule:** Import `TypographyClasses` for neutral grey headings. Coloured metrics (green/red/amber numbers) keep inline classes.

## Modal & Dialog Conventions

Use the correct component for each overlay pattern:

| Component | Import | Use For | Example |
|-----------|--------|---------|---------|
| `Dialog` | `@/components/ui/Dialog` | Confirmation prompts, forms, settings | "Reassign CSE", "Edit action" |
| `Sheet` | `@/components/ui/Sheet` | Detail panels, side drawers, filters | Client detail sidebar, filter panel |
| `AlertDialog` | `@/components/ui/AlertDialog` | Destructive confirmations requiring explicit user action | "Delete action?", "Remove assignment?" |
| `BottomSheet` | `@/components/ui/BottomSheet` | Mobile-only overlays from bottom | Mobile filters, mobile actions menu |

**Rules:**
- `Dialog` for create/edit forms and non-destructive confirmations
- `AlertDialog` for any destructive action (delete, remove, cancel) — forces explicit confirm/cancel
- `Sheet` for content panels that don't block workflow (client details, sidebar info)
- `BottomSheet` only on mobile viewports
- Never nest dialogs — use a multi-step form within a single Dialog instead
- All overlays must have keyboard dismiss (Escape) and click-outside-to-close
- New modals follow this convention; existing modals refactored only when touched for other work

## Data Table Conventions

Use the enhanced `DataTable` (`@/components/ui/enhanced/DataTable`) for all data tables. Internally powered by TanStack React Table (`@tanstack/react-table`) with draggable column resizing:

```tsx
import { DataTable, type DataTableColumn } from '@/components/ui/enhanced/DataTable'

const columns: DataTableColumn<MyType>[] = [
  { key: 'name', header: 'Name', width: 200, sortable: true, truncate: true },
  { key: 'status', header: 'Status', width: 120, cell: (row) => <Badge>{row.status}</Badge> },
]

<DataTable
  data={items}
  columns={columns}
  getRowKey={(row) => row.id}
  onRowClick={handleRowClick}
  sortBy={sortState}
  onSortChange={handleSort}
  rowActions={[{ label: 'Edit', onClick: handleEdit }]}
/>
```

**Column resizing**: Users can drag the right edge of any column header to resize. Flex columns (`flex` prop) switch to pixel width on first manual resize. Actions column is fixed at 60px and non-resizable. Sorting remains external — consumers manage `sortBy`/`onSortChange` as before.

**Features:** Virtual scrolling, sortable columns, row actions dropdown, tooltips for truncated text, sticky header, striped/hoverable rows.

### Resizable Columns for Raw HTML Tables

For tables not using the enhanced `DataTable` (e.g. inline `<table>` elements), use the `useResizableColumns` hook:

```tsx
import { useResizableColumns } from '@/hooks/useResizableColumns'

const resize = useResizableColumns({ storageKey: 'my-table' })

<th className="relative" style={resize.getColumnStyle(0)}>
  Column Name
  <div {...resize.getHandleProps(0)} />
</th>
```

- **`storageKey`**: Unique identifier — widths persist to `localStorage` as `col-resize-{storageKey}`
- **Handle styling**: Invisible 4px strip on right edge of `<th>`, purple highlight on hover/drag
- **Each `<th>`** needs `className="relative"`, `style={resize.getColumnStyle(colIndex)}`, and a child `<div {...resize.getHandleProps(colIndex)} />`
- **Column indices** are 0-based, assigned left-to-right across the header row
- **`resetWidths()`**: Clears all saved widths back to auto
- **40 tables** across the dashboard use this pattern (team performance, BURC, planning, compliance, pipeline, admin, client pages)
- For TanStack-based tables (GoalTableView, compliance views, email analytics), use native `enableColumnResizing: true` + `columnResizeMode: 'onChange'` instead

## KPI Bento Card Pattern

The `KPIHeroRow` (`src/components/dashboard/KPIHeroRow.tsx`) uses expandable bento cards for the 6 headline metrics. This pattern is shared with `BURCExecutiveDashboard`.

**Card anatomy:**
- Status-coloured container: entire card `bg-*`, `border-*`, `text-*` changes based on metric health (emerald=on-target, amber=at-risk, red=critical)
- Large metric number + target comparison + variance text
- Expandable drill-down section (toggle button with `e.stopPropagation()` to prevent card's `onTabChange`)
- YoY trend indicator with prior period comparison
- `role="button"` on outer `<div>` to avoid nested `<button>` hydration errors

**Data sources (3 concurrent fetches):**
- `burc_executive_summary` — primary KPI metrics
- `burc_annual_financials` — prior year for YoY trends
- `burc_revenue_detail` — ARR by client breakdown

**Drill-downs per card:**
| Card | Drill-Down Content |
|------|-------------------|
| Gross Revenue | GRR breakdown: Base ARR → Churn → Retained Revenue + formula |
| Net Revenue | NRR breakdown: Base + Expansion − Churn + formula |
| Rule of 40 | Growth % + EBITA Margin % progress bars |
| Total ARR | Client list with friendly names sorted by revenue |
| Pipeline Value | Total vs Weighted pipeline + coverage ratio |
| Revenue at Risk | At-risk revenue, % of ARR, affected client count |

## Loading State Conventions

Three-tier loading strategy, from coarsest to finest grain:

### 1. Route-level `loading.tsx` — First paint on navigation
Every user-facing route has a `loading.tsx` file (24 routes covered). Next.js App Router renders this instantly while the page component streams.

```tsx
import { PageShellSkeleton, TableSkeleton } from '@/components/ui/skeletons'

export default function MyPageLoading() {
  return (
    <PageShellSkeleton>
      <TableSkeleton />
    </PageShellSkeleton>
  )
}
```

**Rules:**
- Always wrap content in `PageShellSkeleton` (mirrors `PageShell` header layout)
- Compose domain skeletons to match the page's real layout (stats row + table, filter bar + cards, etc.)
- Keep files concise (10–40 lines) — no `'use client'` directive needed
- Available primitives: `PageShellSkeleton`, `StatsRowSkeleton`, `FilterBarSkeleton`, `TableSkeleton`, `ListSkeleton`, `ChartCardSkeleton`, `MeetingCardSkeleton`, `ClientCardSkeleton`, `ActionCardSkeleton`, `Shimmer`

### 2. Suspense with skeleton fallback — Lazy-loaded sections
For components loaded with `React.lazy()` or `next/dynamic` within an already-rendered page:

```tsx
<Suspense fallback={<ChartCardSkeleton />}>
  <HeavyChart data={data} />
</Suspense>
```

**Rule:** Never use `fallback={null}` for visible content — always show a skeleton.

### 3. Inline `isLoading` — Data refresh within a rendered component
For in-place data updates (re-fetch, polling, optimistic UI):

```tsx
{isLoading ? <Spinner /> : <DataDisplay data={data} />}
```

**Rule:** Only use spinners/disabled states here — skeletons are for initial paint only.

## Known Fragmentation Areas

| Area | Score | Issue |
|------|-------|-------|
| Layout consistency | 9/10 | PageShell on 25+ pages, Goals page full-width consistency across all tabs |
| Component system | 9/10 | StatusBadge, EmptyState, CardContainer shared components; 12 duplicate colour functions removed |
| Typography | 9/10 | TypographyClasses adopted in 52 files including SheetTitle/AlertDialogTitle primitives |
| Form patterns | 9/10 | FormRenderer + ModalFormDialog; focus rings unified to `focus-visible:ring-purple-500` (192 files) |
| Data tables | 9/10 | Enhanced DataTable on 7 pages; all 40 tables have resizable columns (useResizableColumns hook or TanStack native) |
| Modal/Dialog | 8/10 | ModalFormDialog added, overlays barrel with decision matrix, convention well-documented |
| Loading states | 9/10 | 24 route-level loading.tsx files, three-tier convention documented above |
| Brand consistency | 9/10 | Design tokens centralised; sidebar colours migrated; all focus rings brand purple |
| Mobile UX | 8/10 | Responsive well-implemented |
| Navigation | 8/10 | Well-structured sidebar |

## Recommendations

1. ~~Create `src/lib/design-tokens.ts`~~ — **DONE** (822 lines, centralised tokens + CSS @theme)
2. ~~Build `<PageShell>` component~~ — **DONE** (`src/components/layout/PageShell.tsx`)
3. ~~Adopt PageShell across dashboard~~ — **DONE** (25+ pages, only planning + client-profiles remain custom)
4. ~~Adopt TypographyClasses in components~~ — **DONE** (6 planning/goals components, dark mode consistent)
5. ~~Unify data tables~~ — **DONE** (Enhanced DataTable + convention documented above)
6. ~~Standardise modals~~ — **DONE** (Convention documented above: Dialog/Sheet/AlertDialog/BottomSheet)
7. ~~Create ModalFormDialog~~ — **DONE** (Dialog + FormRenderer composition, imperative ref handle)
8. ~~Create form wrapper~~ — **DONE** (`FormFieldWrapper` + `FormRenderer` with `forwardRef`)
9. ~~Hide internal pages (`/test-*`, `/chasen-icons`) from production~~ — **DONE** (notFound() guard)
10. ~~Adopt `LayoutTokens.card` for card patterns~~ — **DONE** (CardContainer component wraps LayoutTokens.card)
11. ~~Create StatusBadge component~~ — **DONE** (replaces 50+ inline badge patterns)
12. ~~Create EmptyState component~~ — **DONE** (standard + compact variants, 7 pages migrated)
13. ~~Unify focus rings~~ — **DONE** (192 files, `focus-visible:ring-2 focus-visible:ring-purple-500 focus-visible:ring-offset-2`)
14. ~~Typography token sweep~~ — **DONE** (52 files migrated to TypographyClasses)
11. ~~Migrate hand-rolled tables to DataTable (batch 1)~~ — **DONE** (4 pages: knowledge, sales-hub, news-intelligence, operating-rhythm). 8+ pages remain for future sprints.
