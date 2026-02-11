# Priorities

> Last updated: 12 February 2026

## Guiding Principles

1. **Data accuracy over features** — A wrong number erodes trust faster than a missing feature
2. **Automate everything** — CSEs shouldn't manually enter data that exists elsewhere
3. **Intelligent defaults** — Show the right information without requiring configuration
4. **Simple workflows** — Every click should feel purposeful, not navigational
5. **Graceful degradation** — AI features enhance but never block core workflows

## Completed Priorities (Phases 1-4)

All original priorities shipped. See git history for details.

- **P1: Data Integrity** — Client UUID migration, name aliases, BURC validation, dedup, fiscal year params
- **P2: UI/UX Unification** — PageShell (25+ pages), design tokens, DataTable, modals, FormRenderer + ARIA
- **P3: Automation & Intelligence** — Activity sync, 44 features LIVE, staleness alerting, goal hierarchy, compliance cron
- **P4: Production Hardening** — Sync logging (34/34 routes), webhook alerting, disaster recovery, health checks

## Priority 5: Design System Polish — COMPLETE (Medium)

Raised UX coherence from 7.5/10 to ~8.5/10. Top 3 items shipped; remaining 2 deferred as low-impact.

| Task | Impact | Complexity | Score | Status |
|------|--------|------------|-------|--------|
| Unify loading states (24 route-level loading.tsx + three-tier convention) | Medium | Medium | 8/10 | Done |
| Migrate hand-rolled tables to enhanced DataTable (7 pages total) | Medium | Medium | 7/10 | Done |
| Migrate simple forms to ModalFormDialog (AddContactModal, MilestoneFormModal) | Medium | Medium | 7/10 | Done |
| Adopt `LayoutTokens.card` for consistent card patterns | Low | Low | 6/10 | Deferred |
| Consolidate duplicate component patterns (badges, status indicators) | Low | Medium | 6/10 | Deferred |

## Priority 6: Goal Detail Phase 2 — Accordion Layout — COMPLETE (Medium)

Research from P3 sprint: Baymard Institute found horizontal tabs have 27% content miss rate vs 8% for vertical sections. Linear, Notion, and Asana use collapsible accordion sections for detail views.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Replace horizontal tabs with vertically stacked collapsible sections | High | Medium | Done |
| Sticky metadata sidebar on wide viewports | Medium | Medium | Done |
| Single-open accordion mode (each section collapses when another opens) | Medium | Low | Done |

## Priority 7: Performance & Bundle Size — COMPLETE

All items shipped. `'use client'` audit removed 17 unnecessary directives (pure presentational components, wrapper pages, utility files). Remaining 902 directives are legitimately needed (hooks, event handlers, client libraries).

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Audit and remove stale `console.log` statements from production code | Low | Low | Done |
| Identify and lazy-load heavy client components (Three.js, D3, Recharts) | Medium | Medium | Done |
| Implement route-level code splitting for AI Lab / Visualisations | Medium | Medium | Done |
| Add Next.js `loading.tsx` files for major route groups | Medium | Low | Done |
| Audit `'use client'` directives — remove from server-renderable files | Low | High | Done |

## Priority 8: Testing & Quality — COMPLETE (Medium)

19 test suites, 471 tests (all passing). CI pipeline enabled. Per-path coverage thresholds on critical API routes. E2E smoke test covering auth → dashboard → clients → goals → actions.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Set up Jest + React Testing Library infrastructure | Medium | Low | Done |
| Set up Playwright E2E infrastructure (config + npm scripts) | Medium | Low | Done |
| Fix 50 failing tests across 3 suites (network graph, digital twin, deal sandbox) | Medium | Low | Done |
| Enable CI pipeline (lint + tsc + tests + build) | Medium | Low | Done |
| Add tests for critical API routes (goals, actions, comments, BURC sync) | High | Medium | Done |
| Add tests for shared hooks (useGanttData, useLeadingIndicators, useAnomalyDetection) | Medium | Medium | Done |
| Add Playwright E2E smoke test for core user workflows | High | High | Done |

## Priority 9: Accessibility Audit — COMPLETE (Low)

Skip-to-content, jsx-a11y enforcement, aria-live regions, DataTable keyboard navigation (arrow keys + Enter), colour contrast audit (axe-core), and column sort a11y all shipped. Slide-out panels use Radix Dialog which handles focus trapping natively.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Audit keyboard navigation across all major pages | Medium | Medium | Done |
| Add skip-to-content links and focus management | Medium | Low | Done |
| Enable ESLint jsx-a11y at warn level | Medium | Low | Done |
| Verify colour contrast ratios meet WCAG 2.1 AA | Medium | Low | Done |
| Add `aria-live` regions for dynamic content (alerts, toasts, data updates) | Medium | Medium | Done |

## Priority 10: Account Planning Coach UX Overhaul — COMPLETE (High)

Redesigned strategic planning wizard with step/sub-step navigation, ChaSen AI coaching specialisation, plan grouping, and approval workflow. 19 files changed across 4 phases.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Fix status value mismatch (draft/in_progress/pending_review/approved/archived) | Medium | Low | Done |
| Plan rename with auto-generated default names | Medium | Low | Done |
| Plan grouping by owner/status/territory/client with collapsible sections | Medium | Medium | Done |
| Wire ApprovalPanel into plan detail + status badges on cards | Medium | Medium | Done |
| Remove Quick Jump and WizardMinimap (redundant navigation) | Low | Low | Done |
| Fix Discovery scroll-to-top on step change | Low | Low | Done |
| Sub-step navigation sidebar with parent/child tree + breadcrumbs | High | High | Done |
| Step components render only active sub-section | High | Medium | Done |
| 6 new AI action types + specialised prompt builders (Gap Selling, Voss, MEDDPICC, Wortmann) | High | High | Done |
| Auto-generate suggestions on sub-step entry with cache | Medium | Medium | Done |
| AISuggestionCard component with loading shimmer and feedback | Medium | Low | Done |
| Dynamic quick tips referencing specific client names and data | Medium | Medium | Done |
| **UX Polish Sprint** | | | |
| Fix bottom cutoff (desktop footer obscuring content) | Low | Low | Done |
| Target vs Quota summary bar inside Plan Coverage (visible on sub-step nav) | High | Medium | Done |
| Remove Forecast Simulation min-height white space | Low | Low | Done |
| Voss methodology context headings on Stakeholder sub-steps | Medium | Low | Done |
| Sticky Discovery Summary on non-overview sub-steps | Medium | Low | Done |
| Sticky Stakeholder Intelligence Summary + role counts | Medium | Low | Done |
| Sticky Opportunities Summary (pipeline metrics) | Medium | Low | Done |
| Sticky Risk Overview on per-risk sub-steps | Medium | Low | Done |

## P10 Round 2: Planning Coach Fixes — COMPLETE

Follow-up fixes after re-testing the P10 UX overhaul. 15 files changed.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Fix sticky summary bar overlap on all step components (`-mt-6` removal) | Low | Low | Done |
| Add `methodology_guide` AI action type with dedicated prompt builder | Medium | Medium | Done |
| Persist previous insights to localStorage + re-display on click | Medium | Medium | Done |
| Expandable ChaSen slide-over panel (portal + z-index fix) | Medium | Medium | Done |
| Add stakeholder overview cards to Stakeholder Intelligence step | Medium | Low | Done |
| Fix "Improve Score" navigation to correct sub-step target | Low | Low | Done |
| Simplify ClientConfidenceTabs (remove unused grouping code) | Low | Low | Done |

## Priority 11: Combined Command Centre Dashboard — COMPLETE (High)

Merged BU Performance (`/`) and BURC Performance (`/financials`) into a single bento-grid dashboard at `/`. Consolidated 10 views into 5 lazy-loaded tabs, eliminated data duplication, and added a KPI hero row. `/financials` now 301 redirects to `/`.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Extract 16 components from monolithic financials page (4,178 → 640 lines) | Medium | High | Done |
| Create `useBurcFinancials` hook for reusable data fetching (3 parallel APIs) | Medium | Medium | Done |
| Build 5-tab consolidated dashboard (Overview, Financial, Pipeline, Leading Indicators, Analytics) | High | High | Done |
| KPI Hero Row — 6 expandable bento cards with drill-downs (3 data sources, YoY trends, client breakdown) | High | Medium | Done |
| Collapsible AI briefing in DashboardHeader | Medium | Low | Done |
| `singleTab` prop on ActionableIntelligenceDashboard (reuse 1,600 lines of matrix logic) | High | Low | Done |
| 301 redirect `/financials` → `/` + update 8 files with deep links | Medium | Low | Done |
| Delete financials page + extract `handleExportReport` to `src/lib/burc-export.ts` | Low | Low | Done |

**Key architecture decisions:**
- Lazy-load: `useBurcFinancials({ autoFetch: false })` — Financial/Pipeline/Analytics tabs only trigger API calls when opened
- `singleTab` prop: Added 3 lines to ActionableIntelligenceDashboard to lock it to Priority Matrix tab, avoiding duplication of complex assignment logic
- All data connections (BURC sync, API routes, cron jobs) untouched — pure UI consolidation

## P11 Follow-up: KPI Hero + Compliance Fixes — COMPLETE

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| KPI Hero Row: bento card redesign with 6 expandable drill-downs, 3 data sources, YoY trends, client ARR breakdown | High | Medium | Done |
| Compliance view: auto-refresh materialized view after event mutations (RPC + API integration) | Medium | Low | Done |
| Compliance dashboard: default to current year (newly logged events immediately visible) | Low | Low | Done |
| Scheduled events: pass `completed: false` for future events (vs `true` for logged events) | Low | Low | Done |

## P12: Command Centre Dashboard Overhaul — COMPLETE

Comprehensive restructure of the Command Centre dashboard: moved tabs above bento boxes, replaced Actions tab with Leading Indicators, extracted FY/sync controls to page level, removed 3 legacy widgets (CSI Ratios, Pipeline Reconciliation, Requires Attention), consolidated to a 2×2 widget grid with expandable panels, added NPS Themes card, wired Support Health score, renamed widgets to match current terminology.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Move tabs above KPI bento boxes, add Leading Indicators tab, remove Actions tab | Medium | Low | Done |
| Extract FY26 vs FY25 toggle + sync timestamps + refresh to page-level header | Medium | Medium | Done |
| Remove CSI Ratios, Pipeline Reconciliation, Requires Attention widgets | Low | Low | Done |
| Rename "Accounts Receivable" → "Working Capital", "QBRs" → "Plans Complete", "Support Tickets" → "Support Health" | Medium | Low | Done |
| Wire Support Health score from `/api/support-metrics/trends` (portfolio average) | Medium | Medium | Done |
| Wire Plans Complete from `strategic_plans` table | Low | Low | Done |
| New NPSSummaryCard — top 6 themes with sentiment grouping from `/api/planning/nps-themes` | Medium | Medium | Done |
| Expandable Client Health panel — clients grouped by Critical/At Risk/Healthy with scores | High | Medium | Done |
| Expandable Working Capital panel — clients by aging bucket (90+, 60-90, 30-60, Current) | High | Medium | Done |
| Keep tabs mounted with CSS display to prevent re-fetch on tab switch | Medium | Low | Done |

**Key files:** `page.tsx`, `BURCExecutiveDashboard.tsx` (-500/+550 lines), `ExecutiveQuickGlanceWidgets.tsx` (+250 lines), new `NPSSummaryCard.tsx`, new `LeadingIndicatorsTab.tsx`

## Post-P12: Dashboard Data Integrity & Sync Fixes

Data reconciliation pass across all dashboard components. Fixed fabricated EBITA targets, broken Supabase views, stale data logging, and KPI card ordering.

| Task | Impact | Complexity | Status |
|------|--------|------------|--------|
| Swap KPI cards: Total ARR → primary row, Rule of 40 → secondary row | Low | Low | Done |
| Remove duplicate PortfolioHealthStats from OverviewTab | Low | Low | Done |
| Fix `burc_executive_summary` view — live contract subqueries instead of hardcoded zeros | High | Low | Done |
| Fix `burc_waterfall` fiscal_year NULL → 2026 for all 13 rows | Medium | Low | Done |
| EBITA API: use `burc_ebita_monthly` (real BURC plan targets) instead of fabricated 95% targets | High | Medium | Done |
| NPS themes best-period: select most recent period with ≥3 feedback responses | Low | Low | Done |
| sync-logger.mjs: fix `'completed'` → `'success'` status (constraint violation) | High | Low | Done |
| Activity sync: add logger.complete() on 0-activity path, fix triggered_by | Medium | Low | Done |
| BURC sync: handle "Could not find the table" error for missing tables | Low | Low | Done |
| Staleness bar: raise outlook_actions threshold from 25h to 72h (user-generated data) | Medium | Low | Done |
| Clean up 85 orphaned sync_history "running" entries | Medium | Low | Done |

**Key files:** `KPIHeroRow.tsx`, `burc/route.ts` (EBITA rewrite), `sync-logger.mjs`, `StalenessBar.tsx`

## What "Done" Looks Like

The platform succeeds when:
- A CSE never needs to open the BURC Excel file directly
- Leadership can answer "how are we tracking?" without asking anyone
- Meeting follow-ups happen automatically, not through memory
- At-risk clients are flagged before they escalate
- The data on screen matches the source spreadsheets exactly
- Every page loads fast, looks consistent, and works with keyboard alone
