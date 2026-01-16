# Bug Fix: Planning Wizard Parent-Child Account Grouping

**Date:** 2026-01-16
**Severity:** Medium (Data Display)
**Status:** ✅ Fixed

## Problem Description

The Planning Wizard was showing 6 clients for Open Role CSE instead of the expected 5. The Client Portfolios page correctly showed 5 parent-level accounts with children rolled up into SingHealth, but the wizard was displaying an extra client.

### Expected (5 clients):
1. Mount Alvernia Hospital
2. Saint Luke's Medical Centre (SLMC)
3. NCS/MinDef Singapore
4. Guam Regional Medical City (GRMC)
5. SingHealth (with 6 children rolled up)

### Actual (6 clients):
Same as above plus "Strategic Asia Pacific Partners" as a separate entry.

## Root Cause

Two issues were identified:

### 1. Code Issue
The `loadPortfolioForOwner` function was querying `cse_client_assignments` table and using fuzzy name matching, which didn't respect the parent-child hierarchy defined in the `clients` table.

### 2. Database Issue
"Strategic Asia Pacific Partners" (SAPP) was set as a standalone client (`parent_id = NULL`) when it should have been a child of GRMC. The `cse_client_assignments` table had entries showing SAPP's `client_name_normalized` as "Guam Regional Medical Centre", indicating they're related.

## Solution

### Code Fix
Updated `loadPortfolioForOwner` to query the `clients` table directly with `parent_id IS NULL` filter:

```typescript
// Before (Broken) - queried assignments table
const { data: assignedClients } = await supabase
  .from('cse_client_assignments')
  .select('client_name, client_name_normalized, client_uuid')
  .eq('cse_name', ownerName)
  .eq('is_active', true)

// After (Fixed) - query clients table with parent filter
const { data: parentClients } = await supabase
  .from('clients')
  .select('id, canonical_name, display_name, parent_id')
  .eq('cse_name', ownerName)
  .is('parent_id', null)
  .eq('is_active', true)
```

### Database Fix
Updated "Strategic Asia Pacific Partners" to be a child of GRMC:

```sql
UPDATE clients
SET parent_id = 'ccd202f8-aecb-477e-ab52-a8f7953c4b6c'  -- GRMC's UUID
WHERE id = '1abb79eb-e3a6-465c-a49c-8653e79834bb';      -- SAPP's UUID
```

## Files Modified

1. **`src/app/(dashboard)/planning/strategic/new/page.tsx`**
   - Updated `loadPortfolioForOwner` function to query `clients` table directly
   - Filter by `parent_id IS NULL` to only show parent-level accounts
   - Children are automatically rolled up into their parent accounts

2. **Database: `clients` table**
   - Set `parent_id` for "Strategic Asia Pacific Partners" to GRMC's UUID

## Architecture Pattern

```
┌─────────────────────────────────────────────────────────────┐
│                     clients table                            │
├─────────────────────────────────────────────────────────────┤
│ Parent Account (parent_id = NULL)                            │
│   └── Child Account (parent_id = parent.id)                  │
│   └── Child Account (parent_id = parent.id)                  │
├─────────────────────────────────────────────────────────────┤
│ Example: SingHealth                                          │
│   ├── Singapore General Hospital                             │
│   ├── Changi General Hospital                                │
│   ├── KK Women's and Children's Hospital                     │
│   ├── National Cancer Centre                                 │
│   ├── National Heart Centre                                  │
│   └── Sengkang General Hospital                              │
├─────────────────────────────────────────────────────────────┤
│ Example: GRMC                                                │
│   └── Strategic Asia Pacific Partners (SAPP)                 │
└─────────────────────────────────────────────────────────────┘
```

## Key Learnings

1. **Use `clients` table as source of truth**: The `clients` table has proper parent-child relationships via `parent_id`. Always query it directly for hierarchical data.

2. **`cse_client_assignments` for legacy mapping**: This table was used for name aliasing but doesn't understand hierarchy. Use it only for name resolution.

3. **Consistent filtering**: When loading portfolios, always filter by `parent_id IS NULL` to show only top-level accounts with children rolled up.

## Verification

```bash
# Build passes
npm run build

# Manual test
1. Navigate to /planning/strategic/new
2. Select "Open Role" from CSE dropdown
3. Verify "5 clients loaded" message
4. Proceed to Step 4 (Opportunities)
5. Verify Plan Coverage shows 5 parent-level accounts
```

## Related

- `/client-profiles` - Client Portfolios page (reference implementation)
- `clients` table schema - `parent_id` column for hierarchy
- `cse_client_assignments` table - Legacy name mapping (not used for hierarchy)
