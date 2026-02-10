# Quick Wins

> Last updated: 10 February 2026

Tasks that deliver visible improvement with minimal effort. Each should take < 1 day. **Previous batch: 12/12 complete.** New batch below.

## Batch 2: Polish & Performance

### 1. Add `loading.tsx` to major route groups
Create `loading.tsx` files for `(dashboard)/`, `goals-initiatives/`, `clients/`, `actions/` with skeleton layouts. Eliminates blank white flash on navigation.

### 2. Remove stale `console.log` statements
~1,149 `console.log` calls across `src/`. Strip all except intentional error logging. Use ESLint `no-console` rule with `warn` level after cleanup.

### 3. Lazy-load Three.js (PipelineLandscape)
`/visualisation/pipeline` imports Three.js + React Three Fiber (~500KB). Wrap in `dynamic(() => import(...), { ssr: false })` — it's already client-only but not code-split.

### 4. Lazy-load D3 (NetworkGraph)
Same pattern as #3. `/visualisation/network` imports D3 force layout. Dynamic import reduces main bundle.

### 5. Add `loading.tsx` skeleton for Goal Detail
`/goals-initiatives/[type]/[id]/page.tsx` is 900+ lines. A skeleton with compact metadata bar placeholder + tab bar prevents layout shift.

### 6. Migrate client-profiles table to DataTable
`/client-profiles` uses a hand-rolled `<table>`. Good candidate for enhanced DataTable — already has sortable columns and row click.

### 7. Migrate NPS table to DataTable
`/nps` response table is hand-rolled. Enhanced DataTable gives virtual scrolling (useful for large response sets) and consistent styling.

### 8. Standardise loading state for chart components
Create a `<ChartSkeleton>` variant per chart size (small/medium/large) and adopt across Recharts wrappers. `LazyChart` already exists but isn't used everywhere.

## Priority Order

Start with visible UX improvements:
1. `loading.tsx` route skeletons (#1)
2. Goal detail skeleton (#5)
3. Chart loading states (#8)
4. Lazy-load Three.js (#3)
5. Lazy-load D3 (#4)
6. Client-profiles DataTable (#6)
7. NPS DataTable (#7)
8. Console.log cleanup (#2)
