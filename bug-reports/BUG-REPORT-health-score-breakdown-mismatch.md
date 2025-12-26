# Bug Report: Health Score Breakdown Component Mismatch

**Date:** 2025-12-15
**Severity:** Medium
**Status:** Fixed
**Component:** `HealthBreakdown.tsx`

## Issue Description

The Health Score Breakdown modal was displaying sub-component values that did not match the actual database calculation formula. Users would see an Overall Health Score of 100 but sub-components summing to a different total (e.g., 42.5).

## Root Cause

Two separate, incompatible formulas were being used:

### Database Formula (`client_health_summary` view)

| Component  | Max Points | Weight |
| ---------- | ---------- | ------ |
| NPS Score  | 20 pts     | 20%    |
| Engagement | 15 pts     | 15%    |
| Recency    | 15 pts     | 15%    |
| Compliance | 30 pts     | 30%    |
| Actions    | 20 pts     | 20%    |
| **Total**  | **100**    |        |

### Old UI Component Formula

| Component      | Max Points | Weight |
| -------------- | ---------- | ------ |
| NPS Score      | 25 pts     | 25%    |
| Engagement     | 25 pts     | 25%    |
| Segmentation   | 15 pts     | 15%    |
| Aging Accounts | 15 pts     | 15%    |
| Actions        | 10 pts     | 10%    |
| Recency        | 10 pts     | 10%    |
| **Total**      | **100**    |        |

The UI was calculating its own values using different hooks and a completely different weighting system, then displaying the database's `health_score` as the "Total".

## Files Changed

### 1. `src/hooks/useClients.ts`

Extended the `Client` interface to include all health score component fields from the materialized view:

```typescript
export interface Client {
  // ... existing fields ...
  // NEW: Health score component fields (from client_health_summary view)
  meeting_count_30d: number
  meeting_count_90d: number
  days_since_last_meeting: number
  completion_rate: number
  compliance_percentage: number | null
  total_actions_count: number
  completed_actions_count: number
}
```

### 2. `src/app/(dashboard)/clients/[clientId]/components/HealthBreakdown.tsx`

Completely rewrote the health component calculations to use the **exact same formula** as the database view:

- Removed dependencies on `useActions`, `useMeetings`, `useEventCompliance`, `useAgingAccounts`
- Now uses pre-calculated values from `client_health_summary` materialized view
- Formula matches `docs/migrations/20251203_update_health_score_formula.sql` exactly

## Health Score Formula (Reference)

### NPS Score (20 points max)

```
((nps_score + 100) / 200) × 20
```

### Engagement (15 points max)

- 30-day meetings: ≥3 = 8pts, ≥2 = 6pts, ≥1 = 4pts, 0 = 1pt
- 90-day meetings: ≥6 = 7pts, ≥4 = 5pts, ≥2 = 3pts, ≥1 = 1pt, 0 = 0pts

### Recency (15 points max)

- ≤7 days: 15pts
- ≤14 days: 12pts
- ≤30 days: 10pts
- ≤60 days: 5pts
- ≤90 days: 2pts
- > 90 days: 0pts

### Compliance (30 points max)

```
(compliance_percentage / 100) × 30
```

### Actions Management (20 points max)

**Part A - Completion Rate (15 pts max):**

- ≥80%: 15pts
- ≥60%: 12pts
- ≥40%: 8pts
- ≥20%: 4pts
- No actions: 10pts (neutral)
- <20%: 2pts

**Part B - Open Actions Penalty (5 pts max):**

- 0 open: 5pts
- ≤2 open: 4pts
- ≤5 open: 2pts
- > 5 open: 0pts

## Verification

After the fix:

- Component sum now matches the database health score
- UI displays: "Sum of components: X/100" under the total
- Build passes with no TypeScript errors

## Prevention

Added documentation comment to `HealthBreakdown.tsx`:

```typescript
/**
 * IMPORTANT: This component uses the SAME formula as the database materialized view
 * (client_health_summary). Any changes to scoring logic must be reflected in both:
 * - This component
 * - docs/migrations/20251203_update_health_score_formula.sql
 */
```

## Additional Fix: LeftColumn.tsx Modal

The Health Score modal in `LeftColumn.tsx` (the purple-header modal) was also showing incorrect values. This was a separate component from `HealthBreakdown.tsx`.

### Changes to `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`:

1. **Added `healthComponents` useMemo** (lines 395-438):
   - Calculates all 5 components using exact database formula
   - Uses client fields from `client_health_summary` view

2. **Replaced modal component breakdown** (lines 669-780):
   - Now shows actual point values (e.g., "10/20" instead of "70")
   - Added progress bars for each component
   - Added "Component Total: X/100" verification at bottom
   - Each component shows max points label

### New Modal Display Format:

```
NPS Score (20 pts max)         10/20
NPS: +0
[========----] progress bar

Engagement (15 pts max)         1/15
0 meetings (30d), 0 meetings (90d)
[=------------] progress bar

...etc for all 5 components

Component Total: 46/100
```

## Related Files

- `docs/migrations/20251203_update_health_score_formula.sql` - Database formula definition
- `docs/migrations/20251202_create_client_health_materialized_view.sql` - Original view creation
- `src/hooks/useClients.ts` - Extended Client interface with health component fields
- `src/app/(dashboard)/clients/[clientId]/components/HealthBreakdown.tsx` - Expandable breakdown panel
- `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` - Modal breakdown display
