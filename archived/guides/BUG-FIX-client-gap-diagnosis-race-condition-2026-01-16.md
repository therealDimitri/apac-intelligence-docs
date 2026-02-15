# Bug Fix: Client Gap Diagnosis Shows "No clients found in portfolio"

**Date:** 2026-01-16
**Type:** Bug Fix
**Severity:** High
**Status:** Fixed

## Symptom

In the Strategic Planning wizard, the "Client Gap Diagnosis" panel displays:
> "No clients found in portfolio. Please select an owner with assigned clients."

This occurred even when the selected CSE has clients assigned to them in the database.

## Root Cause Analysis

**Race condition between parallel useEffects**

The Strategic Planning page (`/planning/strategic/new/page.tsx`) had two `useEffect` hooks that ran on component mount:

1. **useEffect #1** (lines 1100-1200): Loads all clients into `availableClients` state
2. **useEffect #2** (lines 1203-1297): Loads existing plan and calls `loadPortfolioForOwner`

When editing an existing plan:
- Both useEffects start simultaneously
- `loadExistingPlan` might complete and call `loadPortfolioForOwner` BEFORE `loadClients` finishes
- `loadPortfolioForOwner` filtered `availableClients` which was still `[]`
- Result: Empty portfolio even though clients exist

**Code path:**
```typescript
// loadPortfolioForOwner (BEFORE fix)
const portfolioClients = availableClients  // <-- Empty at this point!
  .filter(c => ownerClientIds.has(c.id))
  .map(c => { ... })
```

## Solution

Refactored `loadPortfolioForOwner` to be **self-contained** and not depend on `availableClients` state:

```typescript
// loadPortfolioForOwner (AFTER fix)
// 1. Query clients directly from database
const { data: ownerClients } = await supabase
  .from('clients')
  .select('id, canonical_name, display_name, parent_id, tier')
  .eq('cse_name', ownerName)
  .eq('is_active', true)

// 2. Query health data for these clients
const { data: healthData } = await supabase
  .from('client_health_summary')
  .select('client_name, health_score, nps_score, segment, support_health_score')
  .in('client_name', clientNames)

// 3. Query ARR data
const arrResponse = await fetch('/api/planning/client-arr')

// 4. Build portfolio from query results (no race condition)
const portfolioClients = (ownerClients || []).map(c => ({
  id: c.id,
  name: c.display_name || c.canonical_name,
  arr: arrMap.get(...) || 0,
  healthScore: healthMap.get(...)?.health_score ?? null,
  // ...
}))
```

## Files Changed

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/strategic/new/page.tsx` | Refactored `loadPortfolioForOwner` to query database directly |

## Additional Finding

During investigation, discovered that **most CSE profiles have no clients assigned**:

| CSE Name | Client Count |
|----------|--------------|
| Tracey Bland | 5 |
| John Salisbury | 5 |
| Laura Messing | 4 |
| Open Role | 13 |
| *All others* | 0 |

18 out of 22 active CSE profiles have zero clients. Selecting one of these profiles will legitimately show "No clients found in portfolio".

## Testing Verification

1. ✅ Build passes with no TypeScript errors
2. ✅ ESLint passes
3. ✅ Pre-commit hooks pass

## Prevention

The refactored code:
- Eliminates race condition by not depending on state that may not be initialized
- Queries database directly for the data it needs
- Is more predictable and easier to debug

## Commit

```
633e2f85 Fix Client Gap Diagnosis showing no clients (race condition)
```
