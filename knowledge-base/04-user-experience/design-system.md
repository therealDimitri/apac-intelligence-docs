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

### Base UI (`src/components/ui/`) — 58 files
| Type | Examples |
|------|---------|
| shadcn/ui | Button, Card, Dialog, DropdownMenu, Input, Badge, Checkbox, Collapsible, AlertDialog |
| Custom | AudioPlayer, AnimatedNumber, ExpandableMetric, LazyChart, ChartSkeleton, LiveDataPulse, glass-panel, BottomSheet, MobileFilterSheet |

### Specialised Components
| Directory | Purpose |
|-----------|---------|
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

No formal type scale — uses inline Tailwind classes:
| Role | Classes |
|------|---------|
| Page title | `text-2xl sm:text-3xl font-bold` |
| Section header | `text-lg font-semibold` |
| Card title | `text-base font-semibold` |
| Body text | `text-sm text-gray-600` |
| Caption | `text-xs text-gray-500` |
| Sidebar labels | `text-sm font-medium text-white/80` |

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

Use the enhanced `DataTable` (`@/components/ui/enhanced/DataTable`) for all data tables:

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

**Features:** Virtual scrolling, sortable columns, row actions dropdown, tooltips for truncated text, sticky header, striped/hoverable rows.

## Known Fragmentation Areas

| Area | Score | Issue |
|------|-------|-------|
| Layout consistency | 7/10 | PageShell component created, adopting incrementally |
| Component system | 6/10 | shadcn foundation solid, custom components vary |
| Typography | 6/10 | Design tokens in CSS @theme + design-tokens.ts |
| Form patterns | 4/10 | Multiple implementations, no unified form library |
| Data tables | 5/10 | Enhanced DataTable exists, convention documented, migrating incrementally |
| Modal/Dialog | 7/10 | Convention documented (Dialog/Sheet/AlertDialog/BottomSheet) |
| Loading states | 4/10 | Suspense, skeletons, spinners — no single pattern |
| Brand consistency | 8/10 | Design tokens centralised in CSS @theme and design-tokens.ts |
| Mobile UX | 8/10 | Responsive well-implemented |
| Navigation | 8/10 | Well-structured sidebar |

## Recommendations

1. ~~Create `src/lib/design-tokens.ts`~~ — **DONE** (822 lines, centralised tokens + CSS @theme)
2. ~~Build `<PageShell>` component~~ — **DONE** (`src/components/layout/PageShell.tsx`)
3. ~~Unify data tables~~ — **DONE** (Enhanced DataTable + convention documented above)
4. ~~Standardise modals~~ — **DONE** (Convention documented above: Dialog/Sheet/AlertDialog/BottomSheet)
5. Create form wrapper — `<FormField label hint error children />`
6. ~~Hide internal pages (`/test-*`, `/chasen-icons`) from production~~ — **DONE** (notFound() guard)
