# PROCESS: Combined Command Centre Dashboard (P11)

**Status:** Complete
**Date:** 11 February 2026
**Scope:** Merge BU Performance (`/`) and BURC Performance (`/financials`) into a single bento-grid dashboard

## Problem

The executive overview was split across two pages:
- **BU Performance** (`/`) — AI briefing, portfolio health, 4-tab Command Centre (Executive Dashboard, Priority Matrix, Predictive Alerts, Historical Revenue)
- **BURC Performance** (`/financials`) — 6-tab financial deep dive (CSI Ratios, Revenue Performance, BURC Tracking, Pipeline, Renewals, CSI Ratio Actions)

Users context-switched between two URLs. Revenue metrics, pipeline, renewals, CSI ratios, and historical charts were duplicated across both pages.

## Solution

Single 5-tab bento-grid dashboard at `/` with lazy-loaded financial data. `/financials` 301 redirects to `/`.

### Tab Consolidation (10 views -> 5 tabs)

| New Tab | Merges From |
|---------|-------------|
| **Overview** | Root "Executive Dashboard" + BURC Tracking summary |
| **Actions & Priorities** | Root "Priority Actions Matrix" |
| **Financial Performance** | Financials "CSI Ratios" + "BURC Tracking" (EBITA/Pipeline/Revenue) |
| **Pipeline & Renewals** | Financials "Pipeline" + "Renewals" |
| **Analytics** | Root "Historical Revenue" + "Predictive Alerts" + Financials "Revenue Performance" + "CSI Ratio Actions" |

### Duplications Eliminated

| Feature | Kept Version | Dropped |
|---------|-------------|---------|
| Revenue metrics (Gross/Net) | BURCExecutiveDashboard + KPIHeroRow | Financials MetricCard row |
| Pipeline summary | PipelineSectionView (full CRUD) | Financials BURC Tracking pipeline metric |
| Renewals | RenewalsTable + BURCExecutiveDashboard calendar | Financials BURC Tracking renewals metric |
| CSI Ratios | CSITabsContainer (with scenario planning) | Inline CSIRatiosPanel (775 lines deleted) |
| Historical charts | Single Analytics tab | Was duplicated across both pages |
| Net Revenue Impact | Single instance in Financial Performance | Was shown in BURC Tracking + Renewals |

## Implementation Phases

### Phase 1: Extract Components from Monolithic Financials Page
- Decomposed `financials/page.tsx` from 4,178 lines into 16 standalone components in `src/components/financials/`
- Dropped superseded components (CSIRatiosPanel, PipelineKanban)

### Phase 2: Create `useBurcFinancials` Hook
- `src/hooks/useBurcFinancials.ts` — encapsulates 3 parallel API fetches:
  - `GET /api/analytics/financial-actions?limit=100`
  - `GET /api/analytics/burc?section=all`
  - `GET /api/analytics/burc/csi-ratios`
- `autoFetch` option enables lazy loading (only fetches when tab is opened)

### Phase 3: Build the Bento Grid Dashboard
- New components in `src/components/dashboard/`:
  - `DashboardHeader.tsx` — greeting, collapsible AI briefing (indigo->navy gradient), audio
  - `KPIHeroRow.tsx` — 6 metric cards self-fetching from `burc_executive_summary` view
  - `tabs/OverviewTab.tsx` — PortfolioHealthStats + LeadingIndicatorsCard + BURCExecutiveDashboard
  - `tabs/ActionsTab.tsx` — ActionableIntelligenceDashboard with `singleTab="matrix"`
  - `tabs/FinancialPerformanceTab.tsx` — CSITabsContainer + BURC Tracking sub-tabs
  - `tabs/PipelineRenewalsTab.tsx` — PipelineSectionView + RenewalsTable
  - `tabs/AnalyticsTab.tsx` — Historical Revenue + PredictiveAlertsSection + TeamActionCards
- Rewrote `src/app/(dashboard)/page.tsx` (182 lines)

### Phase 4: Redirect and Deep-Link Updates
- `next.config.ts` — `{ source: '/financials', destination: '/', permanent: true }`
- Updated all deep-link references (`/financials` -> `/?tab=financial`)
- Moved `FloatingPageComments` with same `entityId: "financials-dashboard"`

### Phase 5: Cleanup
- Deleted `src/app/(dashboard)/financials/page.tsx` and `loading.tsx`
- Extracted `handleExportReport` to `src/lib/burc-export.ts` (standalone PDF utility)
- Updated `navigation-map.md` and `priorities.md`
- 19 test suites, 471 tests passing
- Visual regression check of all 5 tabs via Playwright

## Key Architecture Decisions

1. **`singleTab` prop** on ActionableIntelligenceDashboard — locks to Priority Matrix tab, avoids duplicating 1,600 lines of assignment logic

2. **Lazy-load pattern** — `useBurcFinancials({ autoFetch: false })` means Financial/Pipeline/Analytics tabs only trigger API calls when opened. Overview tab uses ClientPortfolioContext and BURCExecutiveDashboard's own lighter fetches

3. **KPIHeroRow self-fetch** — queries `burc_executive_summary` Supabase view directly (lightweight), separate from the heavier `/api/analytics/burc` route used by financial tabs

4. **No data connection changes** — BURC hourly sync, all API routes, cron jobs, ClientPortfolioContext, and BURCExecutiveDashboard self-fetch are completely untouched. Pure UI consolidation

## File Changes Summary

### Created
- `src/components/financials/` — 16 files (extracted from monolith)
- `src/components/dashboard/DashboardHeader.tsx`
- `src/components/dashboard/KPIHeroRow.tsx`
- `src/components/dashboard/tabs/` — 5 tab components
- `src/hooks/useBurcFinancials.ts`
- `src/lib/burc-export.ts`

### Modified
- `src/app/(dashboard)/page.tsx` — rewritten (182 lines)
- `src/components/dashboard/index.ts` — added barrel exports
- `src/components/ActionableIntelligenceDashboard.tsx` — added `singleTab` prop
- `next.config.ts` — added `/financials` redirect
- 8 files with `/financials` deep-link references updated

### Deleted
- `src/app/(dashboard)/financials/page.tsx`
- `src/app/(dashboard)/financials/loading.tsx`

## Verification

- `npm run build` — passed
- `npm test` — 19 suites, 471 tests passing
- Playwright visual check — all 5 tabs rendering correctly
- `/financials` 301 redirect confirmed
- 0 console errors throughout
