# Goals & Projects Page — 5 Bug Fixes

**Date:** 2026-02-13
**Status:** Fixed
**Scope:** Goals & Projects page UI/UX and data bugs

## Bugs Fixed

### Bug 1: Minimap overlaps zoom icons
- **File:** `src/components/goals/StrategyMap.tsx`
- **Root cause:** ReactFlow `<MiniMap>` defaults to `position="bottom-right"` — same corner as `<Controls position="bottom-right">`, causing overlap
- **Fix:** Added `position="bottom-left"` to `<MiniMap>`, changed margin from `!mb-16` to `!mb-4 !ml-4`

### Bug 2: FloatingChaSenAI overlaps zoom icons
- **File:** `src/components/goals/StrategyMap.tsx`
- **Root cause:** FloatingChaSenAI bubble is `fixed bottom-4 right-4 z-[9999]` (56x56px), sits directly on top of ReactFlow Controls
- **Fix:** Added `!mb-20` to Controls className (80px = 56px icon + 16px gap + 8px breathing room)

### Bug 3: Tab order incorrect
- **File:** `src/app/(dashboard)/goals-initiatives/page.tsx`
- **Root cause:** Dashboard tab was at position 2, should be near the end
- **Fix:** Moved Dashboard from position 2 to position 8 (after Timeline, before Workload)
- **New order:** Overview → Strategy Map → Strategic Pillars → BU Goals → Team Goals → Projects → Timeline → Dashboard → Workload

### Bug 4: Goals by Owner drill-down shows no data for "Unassigned"
- **File:** `src/app/api/goals/route.ts`
- **Root cause:** Dashboard API maps `null` owners to `"Unassigned"` for display. Drill-down passes `owner_id=Unassigned` to the goals API, which does `.eq('owner_id', 'Unassigned')`. But the actual DB value is `NULL`, and Supabase `.eq()` never matches NULL (SQL: `NULL != anything`).
- **Fix:** Special-case `ownerId === 'Unassigned'` to use `.is(ownerCol, null)` instead of `.eq()`

### Bug 5: Linked actions missing deep link UX
- **Files:** `src/components/goals/types.ts`, `src/app/(dashboard)/goals-initiatives/[type]/[id]/page.tsx`, `src/components/goals/sections/ChildItemsSection.tsx`
- **Root cause:** Action rows lacked visual link affordance — no Action_ID displayed, no navigation cue
- **Fix:**
  - Added `Action_ID` to `LinkedAction` type and Supabase select
  - Display Action_ID in purple (`text-purple-600 font-medium`) before description
  - Added `ChevronRight` icon as navigation affordance

## Files Changed

| File | Lines Changed | Purpose |
|------|--------------|---------|
| `src/components/goals/StrategyMap.tsx` | +3/-2 | Minimap → bottom-left, Controls margin for ChaSen clearance |
| `src/app/(dashboard)/goals-initiatives/page.tsx` | +4/-4 | Tab order resequence |
| `src/app/api/goals/route.ts` | +5/-1 | NULL-aware owner filter |
| `src/components/goals/types.ts` | +1 | Add Action_ID to LinkedAction |
| `src/app/(dashboard)/goals-initiatives/[type]/[id]/page.tsx` | +1/-1 | Include Action_ID in select |
| `src/components/goals/sections/ChildItemsSection.tsx` | +4/-2 | Action_ID display + ChevronRight |

## Testing

- `npx tsc --noEmit` — clean
- `npm test` — 19 suites, 471 tests passing
- Browser verified all 5 fixes on localhost:3001
