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

## Known Fragmentation Areas

| Area | Score | Issue |
|------|-------|-------|
| Layout consistency | 5/10 | 5+ layout patterns across pages, no page shell component |
| Component system | 6/10 | shadcn foundation solid, custom components vary |
| Typography | 4/10 | No scale system, inline Tailwind only |
| Form patterns | 4/10 | Multiple implementations, no unified form library |
| Data tables | 3/10 | Multiple libraries (TanStack, manual), no abstraction |
| Modal/Dialog | 5/10 | Mix of shadcn and custom, inconsistent APIs |
| Loading states | 4/10 | Suspense, skeletons, spinners — no single pattern |
| Brand consistency | 7/10 | Purple sidebar consistent, colour varies by page |
| Mobile UX | 8/10 | Responsive well-implemented |
| Navigation | 8/10 | Well-structured sidebar |

## Recommendations

1. Create `src/lib/design-tokens.ts` — centralised colour, spacing, typography tokens
2. Build `<PageShell>` component — consistent page header/layout
3. Unify data tables — `<DataTable columns data sortable filterable />`
4. Standardise modals — `<AppDialog title onClose children />`
5. Create form wrapper — `<FormField label hint error children />`
6. Hide internal pages (`/test-*`, `/chasen-icons`) from production
