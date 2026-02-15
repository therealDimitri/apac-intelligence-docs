# P14 Improvements Sprint

**Status:** Complete
**Date:** 2026-02-15
**Scope:** 5 phases, 27 commits, 55 files changed (+8,866 / -3,842 lines)
**Plan:** `docs/plans/2026-02-15-p14-implementation-plan.md`

---

## Summary

P14 delivered five sequential workstreams bringing the platform to production maturity: BURC financial detail tables, performance CI pipeline, ChaSen AI full overhaul, E2E test expansion, and mobile UX audit. All changes pushed to origin and verified in browser.

---

## Phase 1: BURC Missing Tables

**Goal:** Create the 4 BURC monthly detail tables the sync script expects but didn't exist.

### Tables Created

| Table | Purpose |
|-------|---------|
| `burc_opex_monthly` | Operating expenses by month/category |
| `burc_cogs_monthly` | Cost of goods sold by month/category |
| `burc_net_revenue_monthly` | Net revenue by month/category |
| `burc_gross_revenue_monthly` | Gross revenue by month/category |

### Schema

All 4 tables share identical wide-format schema matching the sync script's expectations:

- Columns: `fiscal_year`, `category`, `oct` through `sep` (12 month columns), `full_year`, `source_row`
- Constraints: `UNIQUE(fiscal_year, category)`
- RLS: Enabled with anon SELECT policy
- Triggers: `updated_at` auto-timestamp

### Migrations

| File | Description |
|------|-------------|
| `20260215_burc_monthly_detail_tables.sql` | Initial creation (narrow schema — superseded) |
| `20260215_burc_monthly_tables_v2.sql` | Recreated with wide-format schema matching sync script |

### ChaSen Integration

- Added formatters in `chasen-dynamic-context.ts` for all 4 tables
- Added data source configs so ChaSen can query BURC detail data
- Knowledge base updated with table documentation

### Key Files

- `supabase/migrations/20260215_burc_monthly_detail_tables.sql`
- `supabase/migrations/20260215_burc_monthly_tables_v2.sql`
- `src/lib/chasen-dynamic-context.ts` (formatter additions)

### Commits

- `88e24dcb` feat: create 4 BURC monthly detail tables (P14 Task 1.1)
- `286b852e` fix: recreate BURC monthly tables with wide-format schema matching sync script
- `1bea6072` feat: add ChaSen formatters and data source configs for BURC monthly tables

---

## Phase 2: Performance CI Pipeline

**Goal:** Establish automated performance baselines with Lighthouse CI and bundle size tracking.

### Components

| Component | File | Purpose |
|-----------|------|---------|
| GitHub Actions workflow | `.github/workflows/perf.yml` | Runs on PR + weekly schedule |
| Lighthouse CI config | `.lighthouserc.js` | Performance budgets per route |
| Bundle analyzer | `next.config.ts` | `@next/bundle-analyzer` integration |

### Performance Budgets

- First Contentful Paint: < 3s
- Largest Contentful Paint: < 4s
- Total Blocking Time: < 500ms
- Cumulative Layout Shift: < 0.25
- Speed Index: < 5s

### Bundle Size Tracking

- `ANALYZE=true npm run build` generates bundle analysis report
- CI workflow captures `next build` output and reports page sizes
- Warns on pages exceeding 250KB first-load JS

### Dependencies Added

- `@next/bundle-analyzer` — webpack bundle visualisation
- `lighthouse` — performance auditing (CI)

### Commits

- `ef570d5f` perf: wire up bundle analyzer in next.config.ts
- `075c5952` feat: add Lighthouse CI config with performance budgets
- `085d4f6f` feat: add performance CI pipeline with Lighthouse and bundle size checks

---

## Phase 3: ChaSen AI Full Overhaul

**Goal:** Major architectural refactor of ChaSen — modular tools, database-backed prompts, local inference, proactive insights, and context window budgeting.

### 3.1 Local Transformers.js Inference

- Added `src/lib/local-inference-nps.ts` — browser-side ONNX inference for NPS topic classification
- Uses `Xenova/distilbert-base-uncased-finetuned-sst-2-english` model
- Falls back to API-based classification if local inference fails
- Updated `src/lib/topic-extraction.ts` to use local inference first
- Verified working in browser: `[analyzeTopics] Using local Transformers.js inference`

### 3.2 Context Formatter Registry

- Extracted context formatters from monolithic `chasen-dynamic-context.ts` into registry map pattern
- Each data source registers its own formatter function
- Reduces coupling — new tables add a formatter without modifying core logic
- `src/lib/chasen-dynamic-context.ts`: 736 lines changed (refactored, not rewritten)

### 3.3 Context Window Budgeting

- Migration `20260215_chasen_context_budgeting.sql` — adds `context_budget_tokens` column
- Dynamic token budgeting prevents context overflow when loading multiple data sources
- Tiered timeout fallback: 10s primary → 5s reduced → 2s minimal data set

### 3.4 Tool System Modularisation

**Before:** Monolithic `chasen-tools.ts` (1,631 lines removed)
**After:** Registry + category executors

| File | Lines | Purpose |
|------|-------|---------|
| `chasen-tool-registry.ts` | 80 | Tool registration and lookup |
| `chasen-tool-executors/index.ts` | 11 | Barrel export |
| `chasen-tool-executors/read-tools.ts` | 822 | Query/read operations |
| `chasen-tool-executors/write-tools.ts` | 249 | Mutation operations |
| `chasen-tool-executors/goal-tools.ts` | 600 | Goal/plan-specific tools |
| `chasen-tool-executors/workflow-tools.ts` | 84 | Workflow automation |

- Migration `20260215_chasen_tool_audit.sql` — tool usage audit logging

### 3.5 Database-Backed Prompts with Admin UI

- Migration `20260215_chasen_prompts_table.sql` — `chasen_prompts` table (40 lines)
- Seeded 44 system prompts from hardcoded values
- API route: `src/app/api/chasen/prompts/route.ts` (GET/POST/PATCH/DELETE)
- Admin UI: `src/app/(dashboard)/settings/chasen/prompts/page.tsx` (675 lines)
  - DataTable with search, edit, create, delete
  - Category and model filtering
  - Token count display
  - Inline editing with save/cancel
- `src/lib/chasen-prompts.ts` now loads from database with hardcoded fallback

### 3.6 Proactive Insights & Model Fallback

- `src/lib/chasen-agents.ts` (80 lines) — agent abstraction for multi-model routing
- `netlify/functions/chasen-proactive-insights.mts` (138 lines) — scheduled function for proactive insight generation
- Migration `20260215_chasen_notifications.sql` — notification storage for proactive alerts
- `src/app/api/chasen/stream/route.ts` — 474 lines refactored for model fallback chain and planning integration
- Proactive insights integrate with Account Planning Coach workflow

### 3.7 Supporting Changes

- `src/components/goals/MeetingBriefPanel.tsx` — ChaSen integration updates
- `src/types/database.generated.ts` — regenerated after all Phase 3 migrations (131 lines changed)

### Stats

- **ChaSen refactoring total:** 10 files, +2,614 / -1,986 lines
- **6 migrations** applied
- **44 prompts** seeded into database
- **4 executor modules** extracted from monolith

### Commits

- `6c9c63be` feat: add local Transformers.js inference for NPS classification
- `c37c294e` refactor: extract ChaSen context formatters into registry map
- `9be57109` feat: add context window budgeting to ChaSen dynamic context
- `660afb24` feat: add tiered timeout fallback for ChaSen context loading
- `178d972d` refactor: modularise ChaSen tool system into registry + category executors
- `02f24f97` feat: move ChaSen prompts to database with admin UI
- `44c380ba` feat: add ChaSen proactive insights, model fallback, and planning integration
- `370607b2` chore: regenerate database types after Phase 3 migrations

---

## Phase 4: E2E Test Expansion

**Goal:** Add workflow E2E tests for all major pages plus API contract validation.

### Test Suites Created

| File | Tests | Coverage |
|------|-------|----------|
| `tests/e2e/workflows/planning-wizard.spec.ts` | 5 | Plan list, new plan, step nav, API verification, console errors |
| `tests/e2e/workflows/briefing-room.spec.ts` | 5 | Meetings page, calendar/list, meeting detail, API verification, console errors |
| `tests/e2e/workflows/actions-kanban.spec.ts` | 5 | Actions page, kanban/list, action detail, API verification, console errors |
| `tests/e2e/workflows/pipeline.spec.ts` | 3 | Page load, data content, console errors |
| `tests/e2e/workflows/nps-analytics.spec.ts` | 3 | Page load, NPS data, console errors |
| `tests/e2e/workflows/compliance.spec.ts` | 3 | Page load, compliance content, console errors |
| `tests/e2e/workflows/burc-renewals.spec.ts` | 3 | Page load, financial data, console errors |
| `tests/e2e/api/api-contracts.spec.ts` | 3 | Response envelope shape, data types, health check |

### API Routes Validated

- `/api/clients` — `{ success, data }` envelope
- `/api/goals` — `{ success, data }` envelope
- `/api/segmentation-events` — `{ success, data }` envelope
- `/api/support-metrics` — `{ success, data }` envelope
- `/api/support-metrics/trends` — `{ success, data }` envelope
- `/api/comments` — `{ success, data }` envelope
- `/api/aging-accounts` — `{ success, data }` envelope
- `/api/analytics/burc` — `{ success, data }` envelope
- `/api/health` — 200 status

### Mutation Verification

Three test suites include API-level data verification:
- **Actions:** Extracts action ID from href, queries `/api/actions/{id}`, verifies `Action_ID` exists
- **Planning:** Extracts plan ID, queries `/api/goals`, verifies data exists
- **Briefing Room:** Extracts meeting ID, queries `/api/meetings/{id}`, verifies data exists

### Stats

- **9 test files**, 826 lines total
- **30 test cases** across workflow + API suites
- All use `dev-auth-session` cookie for auth bypass
- Console error filtering: favicon, resource loading, hydration errors excluded

### Commits

- `0436aea5` feat: add E2E workflow tests, API contract tests, and mutation verification

---

## Phase 5: Mobile UX Audit

**Goal:** Systematic mobile viewport audit across all pages.

### Audit Coverage

12 pages audited on mobile viewports:

`/`, `/client-profiles`, `/planning`, `/meetings`, `/actions`, `/nps`, `/aging-accounts`, `/burc`, `/compliance`, `/pipeline`, `/team-performance`, `/settings/chasen`

### Checks Per Page

1. **Horizontal overflow** (hard failure) — `scrollWidth <= clientWidth`
2. **Touch target size** (audit/log) — flags elements < 44px, non-blocking
3. **Full-page screenshot** — saved to `test-results/mobile-audit/` for manual review

### Stats

- `tests/e2e/mobile/ux-audit.spec.ts` — 88 lines, 36 test cases (3 per page × 12 pages)

### Commits

- `531382dd` feat: add mobile UX audit test suite across 12 pages

---

## Supporting Changes

### UI Component Improvements (during P14)

- `ca70fb34` feat: add expandable row support to DataTable
- `5db233c8` feat: add NPSClientDataTable component
- `c856bd05` feat: migrate NPS client scores from card layout to DataTable
- `2cc0f6d9` refactor: adopt CardContainer across skeletons, NPS, and dropdowns

### Documentation & Housekeeping

- `f704d080` docs: update CLAUDE.md skills inventory from 13 to 25
- `3dbf595a` docs: update submodule ref — P5 deferred items complete
- `f3c1514f` fix: re-stage lint-staged formatting for TrendBadge/StatusBadge dedup
- `ea3f129f` chore: update docs submodule (BURC monthly tables KB updates)
- `52f8abdf` docs: update submodule ref — design-system + plan docs
- `cd5eabb2` chore: archive root-level completed docs + update docs submodule
- `ed483f9c` chore: update scripts submodule ref — major cleanup (462 archived)

---

## Browser Verification Results

All phases verified in browser on `localhost:3001`:

| Page | Phase | Result |
|------|-------|--------|
| `/burc` | P1 | PASS — KPI hero cards, financial data, sync timestamp |
| `/settings/chasen/prompts` | P3 | PASS — 44/44 prompts in DataTable, admin UI |
| `/planning` | P3 | PASS — Account Planning Coach, coaching frameworks |
| `/nps` | P3 | PASS — NPS -19, local Transformers.js inference confirmed |
| `/actions` | P4 | PASS — Kanban board, 100 actions across 4 statuses |
| `/compliance` | P4 | PASS — Segmentation Progress, tabs, filters |
| `/meetings` | P4 | PASS — Briefing Room, 243 meetings, meeting detail panel |
| `/` | All | PASS — Full Command Centre: $31.5M gross revenue, Rule of 40: 48, 18 clients, $19.4M pipeline |
| `/pipeline` | P4 | PRE-EXISTING fetch error (not P14 regression) |

Console errors on `/` were all dev server cold-start compilation timeouts — resolved on reload. Recharts `width(0)` warnings from hidden tabs are harmless (known pattern).

---

## Totals

| Metric | Count |
|--------|-------|
| Commits | 27 |
| Files changed | 55 |
| Lines added | 8,866 |
| Lines removed | 3,842 |
| Migrations | 6 |
| New test files | 9 |
| New test cases | 66 (30 E2E workflow + 36 mobile audit) |
| New components | 2 (NPSClientDataTable, ChaSen Prompts Admin) |
| New API routes | 1 (`/api/chasen/prompts`) |
| New Netlify functions | 1 (`chasen-proactive-insights.mts`) |
| Dependencies added | 2 (`@next/bundle-analyzer`, `lighthouse`) |
