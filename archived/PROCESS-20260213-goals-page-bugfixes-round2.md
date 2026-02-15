# Goals & Projects Page — 4 Bug Fixes (Round 2)

**Date:** 2026-02-13
**Status:** Fixed
**Scope:** Goals & Projects page UI/UX and data bugs (follow-up to PROCESS-20260213-goals-page-bugfixes.md)

## Bugs Fixed

### Bug 1: Strategic Pillar detail — tabs instead of accordion
- **File:** `src/app/(dashboard)/goals-initiatives/[type]/[id]/page.tsx`
- **Root cause:** All goal types used the same `<Accordion>` layout with 5 collapsible sections. Pillars have many child BU Goals and benefit from a scannable tab layout.
- **Fix:** Added horizontal tab bar for `goalType === 'pillar'` only. Uses `display:none/block` for tab persistence (avoids re-mount/re-fetch). Lazy-fetches data on first tab visit via existing `fetchedRef` + fetch functions. Non-pillar types keep accordion layout unchanged.

### Bug 2: Projects missing from Strategy Map / Overview
- **File:** `src/hooks/useStrategyMap.ts`
- **Root cause:** `initialExpanded` only included pillar + company goal IDs. Line 397: `if (!expandedNodes.has(teamGoal.id)) return` skipped all initiatives because team goals weren't in the expanded set.
- **Fix:** Added team goal IDs from hierarchy data to `initialExpanded`:
  ```typescript
  ...hierarchies.filter(Boolean).flatMap(h => (h!.tree.children || []).map(tg => tg.id)),
  ```

### Bug 3: Inconsistent loading spinners
- **Files:** `src/app/(dashboard)/goals-initiatives/page.tsx`, `src/app/(dashboard)/goals-initiatives/[type]/[id]/page.tsx`
- **Root cause:** 6 dynamic imports used plain gray text (`text-sm text-gray-400`). Detail page used `animate-pulse`. Strategy Map had the canonical spinner: `RefreshCw animate-spin text-purple-600`.
- **Fix:** Replaced all 7 loading states with the standard purple spinning RefreshCw icon. Heights preserved per component.

### Bug 4: Goal type selector text wrapping
- **File:** `src/components/goals/GoalCreateModal.tsx`
- **Root cause:** `grid grid-cols-4 gap-2` with `text-xs font-medium` label. "Strategic Pillar" (16 chars) wrapped to 2 lines at ~80-100px button width.
- **Fix:** Added `whitespace-nowrap` to the label `<span>` className.

## Files Changed

| File | Lines Changed | Purpose |
|------|--------------|---------|
| `src/app/(dashboard)/goals-initiatives/[type]/[id]/page.tsx` | +113/-3 | Pillar tab layout + loading spinner |
| `src/app/(dashboard)/goals-initiatives/page.tsx` | +12/-12 | 6 loading spinners standardised |
| `src/hooks/useStrategyMap.ts` | +2/-1 | Team goals in initial expanded set |
| `src/components/goals/GoalCreateModal.tsx` | +1/-1 | whitespace-nowrap on type label |

## Testing

- `npx tsc --noEmit` — clean
- `npm test` — 19 suites, 471 tests passing
