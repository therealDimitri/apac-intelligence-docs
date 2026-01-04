# Bug Report: Activity Stream Alias Resolution and Action Refetch Issues

**Date:** 2026-01-04
**Status:** FIXED
**Severity:** Medium (UI/UX + Data Consistency)

## Problem Description

### Issue 1: Activity Stream Not Using Alias Resolution for Actions

The CenterColumn activity stream was only showing actions that exactly matched the client name, ignoring client aliases.

**Example:** SingHealth showed only 9 actions in the activity stream, but the health score breakdown correctly showed 20 actions (because it uses alias resolution in the materialized view).

**Affected Clients:**
| Client | Exact Match Actions | With Alias Resolution |
|--------|---------------------|----------------------|
| SingHealth | 9 | 20 |
| GRMC | 3 | 5 |
| RVEEH | 2 | 6 |
| GHA | 2 | 5 |
| SA Health (Sunrise) | 3 | 8 |

### Issue 2: Deleted Actions Not Disappearing from Timeline

When deleting an action from the activity timeline, the action remained visible until the page was manually refreshed.

## Root Cause

### Issue 1: Missing Alias Resolution
In `CenterColumn.tsx`, the action filter used exact name matching:

```typescript
// BEFORE (wrong)
const clientActions = actions.filter(
  action => action.client.toLowerCase() === client.name.toLowerCase()
)
```

This didn't use the `client_name_aliases` table to match actions stored under different alias names (e.g., "SGH iPro", "CGH iPro", "KKH iPro" → all map to "SingHealth").

### Issue 2: Stale Cache on Refetch
In `useUnifiedActions.ts`, the `fetchActions` function didn't clear the `UnifiedActionService` cache before fetching:

```typescript
// BEFORE (wrong) - silentRefetch cleared cache but regular refetch didn't
const fetchActions = useCallback(async () => {
  try {
    setLoading(true)
    // ... fetch data without clearing cache
  }
})
```

This caused stale data to be returned after deletion operations.

## Solution

### Fix 1: Added Alias Resolution to CenterColumn.tsx

```typescript
// 1. Import the hook
import { useClientAliases } from '@/hooks/useClientAliases'

// 2. Use the hook in component
const { resolveClientName } = useClientAliases()

// 3. Filter actions using alias resolution
const canonicalClientName = resolveClientName(client.name).toLowerCase()
const clientActions = actions.filter(action => {
  const resolvedActionClient = resolveClientName(action.client).toLowerCase()
  return resolvedActionClient === canonicalClientName
})
```

### Fix 2: Added Cache Clear to fetchActions

```typescript
const fetchActions = useCallback(async () => {
  try {
    setLoading(true)
    setError(null)

    // Clear service cache to ensure fresh data on explicit refetch
    UnifiedActionService.clearCache()

    // ... rest of fetch logic
  }
})
```

## Files Modified

1. `src/app/(dashboard)/clients/[clientId]/components/v2/CenterColumn.tsx`
   - Imported `useClientAliases` hook
   - Added `resolveClientName` usage for action filtering
   - Added `resolveClientName` to useMemo dependencies

2. `src/hooks/useUnifiedActions.ts`
   - Added `UnifiedActionService.clearCache()` call at start of `fetchActions`

## Verification

### Activity Stream Action Counts
After fix, all clients now show correct action counts matching the health score breakdown:

| Client | Before (Exact) | After (With Aliases) | Health Summary |
|--------|----------------|---------------------|----------------|
| SingHealth | 9 | 20 | 20 ✓ |
| GRMC | 3 | 5 | 5 ✓ |
| RVEEH | 2 | 6 | 6 ✓ |
| GHA | 2 | 5 | 5 ✓ |

### Delete Action Flow
1. Navigate to client profile
2. Delete an action from activity stream
3. Action immediately disappears ✓

## Related Issues

- BUG-REPORT-20260104-health-trend-card-colour-and-cron.md
- BUG-REPORT-20260104-card-order-and-revenue-styling.md

## Recommendations

1. **Audit other components** that filter by client name to ensure they also use alias resolution
2. **Add integration tests** that verify action counts match between activity stream and health summary
3. **Consider centralising** client matching logic into a shared utility
