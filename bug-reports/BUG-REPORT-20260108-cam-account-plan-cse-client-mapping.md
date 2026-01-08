# CAM Account Plan - Incorrect CSE-Client Mapping

**Date:** 2026-01-08
**Type:** Bug Fix
**Status:** Resolved
**Priority:** High

---

## Issue Description

The CAM Account Plan page was showing incorrect client assignments for CSEs. Specifically, Epworth Healthcare was appearing under Tracey Bland's territory when:
- The database (`clients` table) shows Epworth Healthcare is assigned to **John Salisbury**
- Tracey Bland only has 4-5 clients assigned in the database

## Root Cause

The page was using **hardcoded CSE-client mappings** (`CSE_CLIENTS` constant) instead of querying the database. This static data had drifted significantly from the actual assignments in:
- `client_segmentation` table
- `clients` table

The hardcoded list had ~20 clients for Tracey Bland when the database only showed 4.

## Solution

Refactored the CAM Account Plan page to use database-driven CSE-client mappings with proper alias resolution:

### Changes Made

1. **Added state for database-driven mapping**
   ```typescript
   const [cseClientMap, setCseClientMap] = useState<Record<string, string[]>>({})
   ```

2. **Updated `loadData` to fetch CSE assignments**
   - Fetches from `client_segmentation` (primary source)
   - Falls back to `clients` table `cse_name` field
   - Cross-references via `client_name_aliases` for name resolution

3. **Updated client filter logic**
   - Changed from `CSE_CLIENTS[formData.cse_partner]` to `cseClientMap[formData.cse_partner]`
   - Now shows accurate client count: "Showing X clients assigned to {CSE}"

4. **Updated CSE dropdown**
   - Shows client count per CSE: "{CSE} - {Territory} (X clients)"

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/account/new/page.tsx` | Database-driven CSE-client mapping |

## Database Tables Used

- `client_segmentation` - Primary source for CSE assignments
- `clients` - Fallback CSE assignments and client data
- `client_name_aliases` - Name resolution/matching
- `client_health_scores_materialized` - Health data for snapshots

## Alias Resolution Logic

```typescript
// Build alias lookup map (any name -> canonical name)
const aliasMap = new Map<string, string>()
aliases.forEach(a => {
  if (a.display_name) aliasMap.set(a.display_name.toLowerCase(), a.canonical_name)
  if (a.canonical_name) aliasMap.set(a.canonical_name.toLowerCase(), a.canonical_name)
})

// Helper to get canonical name for any client name
const getCanonical = (name: string | null): string | null => {
  if (!name) return null
  return aliasMap.get(name.toLowerCase()) || name
}
```

## Testing Checklist

- [x] Type check passes
- [x] CSE dropdown shows correct client counts
- [x] Selecting CSE filters to correct clients
- [x] Epworth Healthcare no longer appears under Tracey Bland
- [x] Tracey Bland shows only her assigned clients (Albury Wodonga, Grampians, GHA, DoH Victoria)

## Prevention

The hardcoded `CSE_CLIENTS` constant is now effectively dead code for client filtering. It remains in the file for reference but should be removed in a future cleanup.

**Recommendation:** Always use database queries with alias resolution for any CSE/client relationship lookups rather than hardcoded mappings.

---

## Commits

1. `072625ce` - fix: correct Epworth Healthcare CSE assignment (temporary fix)
2. `c5a2e2b1` - refactor: use database-driven CSE-client mapping with alias resolution (proper fix)
