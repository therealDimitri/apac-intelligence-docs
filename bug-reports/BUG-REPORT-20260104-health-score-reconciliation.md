# Bug Report: Health Score Mismatch Between Client Profiles and Detail Pages

**Date:** 2026-01-04
**Status:** FIXED (Updated)
**Severity:** High
**Affected Components:** client-profiles/page.tsx, RightColumn.tsx, LeftColumn.tsx, HealthBreakdown.tsx

## Problem Description

Health scores displayed inconsistently across different pages:
- **Client Profiles page** (list view): Showed 75 for GHA
- **Client Detail page** (main display): Showed 60 for GHA
- **Client Detail page** (Client Status Summary): Showed 35 for St Luke's

Additional issues identified:
- **Sorting Issue**: Client profiles were sorted by stale `client.health_score` but displayed calculated scores
- **FOUC (Flash of Unstyled Content)**: Health scores would flash/change when actions data loaded

Users reported confusion when navigating between pages and seeing different health scores for the same client.

## Root Cause Analysis

### Issue 1: Inconsistent Data Sources
Multiple components were calculating health scores using different data sources:

1. **client-profiles/page.tsx**: Used `client.health_score` from materialized view (stale data)
2. **LeftColumn.tsx**: Calculated dynamically using `calculatedNpsScore` from NPS responses + live actions
3. **RightColumn.tsx**: Used `client.health_score` from materialized view (stale data)
4. **HealthBreakdown.tsx**: Used `client.nps_score` from database

### Issue 2: Sorting vs Display Mismatch
The client-profiles page was:
- **Sorting** by `client.health_score` (stale materialized view data)
- **Displaying** `calculatedHealthScore` (dynamically calculated)

This caused cards to appear out of order relative to their displayed scores.

### Issue 3: FOUC from Async Data Loading
When components loaded:
1. Initial render: `actions` = empty array → actions points = 10 (full points)
2. After data loads: `actions` = real data → actions points = calculated value

This caused the health score to visibly change after page load.

## Health Score Formula

The correct formula (from `@/lib/health-score-config.ts`):

| Component | Weight | Calculation |
|-----------|--------|-------------|
| NPS | 20 pts | `((npsScore + 100) / 200) * 20` |
| Compliance | 60 pts | `(compliancePct / 100) * 60` |
| Working Capital | 10 pts | `(workingCapitalPct / 100) * 10` |
| Actions | 10 pts | `(completedActions / totalActions) * 10` |
| **Total** | **100 pts** | Sum of all components |

## Solution

### Fix 1: Pre-calculate Health Scores for Sorting (client-profiles/page.tsx)

Created a `clientHealthScores` Map that pre-calculates scores BEFORE sorting:

```typescript
// Pre-calculate health scores for all clients to use for sorting AND display
const clientHealthScores = useMemo(() => {
  const scores = new Map<string, number>()
  clients.forEach(client => {
    const { total } = calculateHealthScore(
      client.nps_score,
      client.compliance_percentage,
      workingCapitalData,
      actionsData
    )
    scores.set(client.id, total)
  })
  return scores
}, [clients])

// Sort by CALCULATED health score (not stale DB value)
filtered.sort((a, b) => {
  const healthA = clientHealthScores.get(a.id) ?? 0
  const healthB = clientHealthScores.get(b.id) ?? 0
  return healthB - healthA
})
```

### Fix 2: Prevent FOUC with Cached Data (LeftColumn, RightColumn, HealthBreakdown)

While actions are loading, use cached counts from the materialized view:

```typescript
const { actions, loading: actionsLoading } = useActions()

// Use cached data while loading to prevent FOUC
const completedActions = actionsLoading
  ? (client.completed_actions_count ?? 0)
  : clientActions.filter(a => a.status === 'completed').length
const totalActions = actionsLoading
  ? (client.total_actions_count ?? 0)
  : clientActions.length
```

This ensures:
1. Initial render uses cached data (matches materialized view)
2. After load, uses live data (may differ slightly if data changed)
3. No visible flash of changing values

### Fix 3: Dynamic Health Score Calculation (RightColumn.tsx)

Added `calculatedHealthScore` to match LeftColumn:

```typescript
const calculatedHealthScore = useMemo(() => {
  const npsPoints = Math.round(((npsScore + 100) / 200) * 20)
  const compliancePoints = Math.round((compliancePct / 100) * 60)
  const workingCapitalPoints = Math.round((workingCapitalPct / 100) * 10)
  const actionsPoints = Math.round((actionsCompletionPct / 100) * 10)
  return npsPoints + compliancePoints + workingCapitalPoints + actionsPoints
}, [client, calculatedNpsScore, clientActions, actionsLoading])
```

## Files Modified

1. `src/app/(dashboard)/client-profiles/page.tsx`
   - Added `clientHealthScores` Map for pre-calculated scores
   - Updated sorting to use pre-calculated scores
   - Updated rendering to use pre-calculated scores

2. `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
   - Added `actionsLoading` from useActions
   - Use cached data while loading to prevent FOUC

3. `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
   - Added `actionsLoading` from useActions
   - Use cached data while loading to prevent FOUC

4. `src/app/(dashboard)/clients/[clientId]/components/HealthBreakdown.tsx`
   - Added `actionsLoading` from useActions
   - Use cached data while loading to prevent FOUC

## Testing

1. Navigate to `/client-profiles` - verify clients are sorted by displayed health score (descending)
2. Click on a client - verify detail page shows same score as profiles list
3. Refresh detail page - verify no flash/change in health score
4. Check Health Breakdown component - verify scores match main display

## Future Recommendations

1. **Create shared hook**: `useCalculatedHealthScore(client)` to centralise calculation
2. **Update materialized view**: Keep `client_health_summary` in sync with formula
3. **Add automated tests**: Verify health score consistency across pages
4. **Consider SSR**: Pre-calculate scores on server to eliminate any client-side flash

## Commits

```
fix: reconcile health scores across client-profiles and detail pages
Commit: 6a0a8ae

fix: prevent FOUC and fix sorting in health scores
Commit: (pending)
```
