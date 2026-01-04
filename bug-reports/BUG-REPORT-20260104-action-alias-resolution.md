# Bug Report: Health Score Actions Component Using Exact Name Matching

**Date:** 2026-01-04
**Status:** FIXED
**Severity:** Medium
**Related To:** BUG-REPORT-20260104-health-score-reconciliation.md

## Problem Description

Health scores on client detail pages were incorrectly calculating the Actions component because the action filtering used exact client name matching instead of alias resolution.

**Affected Clients:**
- Saint Luke's Medical Centre (SLMC) - Actions used names like "SLMC", "St Luke's Medical Centre"
- SingHealth - Actions used names like "SingHealth Sunrise", "CGH iPro", "KKH iPro"
- SA Health (Sunrise) - Actions used name "SA Health"
- WA Health - Actions used name "Western Australia Department Of Health"
- Gippsland Health Alliance (GHA) - Actions used names like "GHA", "GHA Regional Opal"
- NCS/MinDef Singapore - Actions used name "Ministry of Defence, Singapore"
- Royal Victorian Eye and Ear Hospital - Actions used "The Royal Victorian Eye and Ear Hospital"

## Root Cause

The action filtering code in LeftColumn, RightColumn, and HealthBreakdown components used exact case-insensitive matching:

```typescript
// Old code - exact matching only
const clientActions = actions.filter(action =>
  action.client.toLowerCase() === client.name.toLowerCase()
)
```

This failed to match action records that used alias names for clients (e.g., "SLMC" instead of "Saint Luke's Medical Centre (SLMC)").

## Solution

### 1. Added Missing Client Aliases

Added 12 new aliases to `client_name_aliases` table:

| Display Name | Canonical Name |
|--------------|----------------|
| St Luke's Medical Center Global City Inc | Saint Luke's Medical Centre (SLMC) |
| SingHealth Sunrise | SingHealth |
| Singapore Health Services Pte Ltd | SingHealth |
| National Cancer Centre Of Singapore | SingHealth |
| CGH iPro | SingHealth |
| KKH iPro | SingHealth |
| NHCS iPro | SingHealth |
| SGH iPro | SingHealth |
| SKH iPro | SingHealth |
| GHA Regional Opal | Gippsland Health Alliance (GHA) |
| The Royal Victorian Eye and Ear Hospital | Royal Victorian Eye and Ear Hospital |
| Ministry of Defence, Singapore | NCS/MinDef Singapore |
| Sengkang General Hospital Pte. Ltd | SingHealth |

### 2. Updated Action Filtering to Use Alias Resolution

All components now use the `useClientAliases` hook and `resolveClientName` function:

```typescript
// New code - with alias resolution
import { useClientAliases } from '@/hooks/useClientAliases'

const { resolveClientName, isLoading: aliasesLoading } = useClientAliases()

const clientActions = useMemo(() => {
  return actions.filter(action => {
    const resolvedName = resolveClientName(action.client)
    return resolvedName.toLowerCase() === client.name.toLowerCase()
  })
}, [actions, client.name, resolveClientName])
```

### 3. Updated Loading State to Include Aliases

The FOUC prevention now waits for both actions AND aliases to load:

```typescript
const isLoadingActionData = actionsLoading || aliasesLoading
const completedActions = isLoadingActionData
  ? (client.completed_actions_count ?? 0)  // Use cached
  : clientActions.filter(a => a.status === 'completed').length  // Use live
```

## Files Modified

1. `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`
   - Added `useClientAliases` hook
   - Updated `clientActions` filter to use `resolveClientName`
   - Updated loading state to include `aliasesLoading`

2. `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
   - Added `useClientAliases` hook
   - Updated `clientActions` filter to use `resolveClientName`
   - Updated inline filters to use pre-computed `clientActions`
   - Updated loading state to include `aliasesLoading`

3. `src/app/(dashboard)/clients/[clientId]/components/HealthBreakdown.tsx`
   - Added `useClientAliases` hook
   - Updated `actionsData` calculation to use `resolveClientName`
   - Updated loading state to include `aliasesLoading`

4. `client_name_aliases` table (Supabase)
   - Added 12 new alias mappings for action client names

## Behaviour After Fix

| Phase | List View (client-profiles) | Detail View |
|-------|----------------------------|-------------|
| Initial | Cached counts from materialized view | Cached counts (same as list) |
| After load | Cached counts | Live counts with alias resolution |

Both views now use alias resolution and show consistent action counts.

## Materialized View Refresh (2026-01-04)

The materialized view (`client_health_summary`) already includes alias resolution in its SQL. After adding the new aliases, the view was refreshed via:

```sql
REFRESH MATERIALIZED VIEW client_health_summary;
```

**Verification Results (post-refresh):**
| Client | Actions (Before) | Actions (After) | Match |
|--------|------------------|-----------------|-------|
| Saint Luke's Medical Centre (SLMC) | 11/15 | 11/18 | ✓ |
| SingHealth | 2/10 | 2/20 | ✓ |
| SA Health (Sunrise) | 2/8 | 2/8 | ✓ |
| WA Health | 2/10 | 2/10 | ✓ |
| Gippsland Health Alliance (GHA) | 0/5 | 0/5 | ✓ |

All clients now show consistent action counts between list and detail views.

## Scripts Added

- `scripts/add-missing-action-aliases.mjs` - Adds missing alias mappings
- `scripts/check-action-name-mismatches.mjs` - Diagnoses action name matching issues
- `scripts/verify-alias-resolution.mjs` - Verifies alias resolution is working

## Testing

1. Navigate to client-profiles page
2. Note the health score for St Luke's/SingHealth/SA Health
3. Click into the client detail page
4. Verify the score initially matches the list (cached data)
5. After loading completes, verify the Actions component shows the correct count with alias resolution
