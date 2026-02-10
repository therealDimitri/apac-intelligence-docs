# Quick Wins

> Last updated: 10 February 2026

Tasks that deliver visible improvement with minimal effort. Each should take < 1 day. **Batch 1: 12/12 complete. Batch 2: 7/8 complete (1 deferred).**

## Batch 2: Polish & Performance — COMPLETE

### 1. Add `loading.tsx` to major route groups — DONE
Created 5 initial loading.tsx files (dashboard, goals, clients, actions, goal detail) + 18 more covering all user-facing routes (24 total). Uses `PageShellSkeleton` wrapper with domain-specific skeleton composition.

### 2. Remove stale `console.log` statements — DONE
Removed 1,149 console.log calls across ~260 files. Added ESLint `no-console` rule (warn level, allows warn/error/info/debug) to prevent regression.

### 3. Lazy-load Three.js (PipelineLandscape) — DONE (already)
Was already using `dynamic(() => import(...), { ssr: false })` with loading skeleton. No change needed.

### 4. Lazy-load D3 (NetworkGraph) — DONE
Converted from static import to `next/dynamic` with `ssr: false` and `NetworkGraphSkeleton` fallback. D3 force layout (~50KB) now code-split.

### 5. Add `loading.tsx` skeleton for Goal Detail — DONE
3-tier skeleton: breadcrumb + title + badges → sticky tab bar (5 tabs) → metadata bar → 2/3 + 1/3 column layout.

### 6. Migrate client-profiles table to DataTable — DONE
Replaced TanStack Table grid with enhanced DataTable. 8 columns with custom cell renderers, sort state, segment ordering, virtual scrolling.

### 7. Migrate NPS table to DataTable — DEFERRED
NPS page uses rich card layout (sparklines, AI insight panels, context menus), not a simple table. Converting to DataTable would require UX redesign. Deferred to a dedicated sprint.

### 8. Standardise loading state for chart components — DONE
Wrapped 4 GoalsDashboard charts with `LazyChart` (IntersectionObserver deferred rendering). Made `ChartCardSkeleton.type` optional (defaults to `'bar'`). Three-tier loading convention documented in design-system.md.

### Bonus: Gotcha checker fix
Fixed false positives in `.husky/check-commit-gotchas.sh` — checks #3/#4 now scan added diff lines only (not entire file content), preventing false flags on `action_id` FK references in related tables.
