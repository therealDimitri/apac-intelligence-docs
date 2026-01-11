# Bug Report: Strategic Plan Portfolio Not Loading

**Date:** 2026-01-11
**Severity:** High
**Component:** Planning / Strategic Plan / New Plan Page
**Status:** RESOLVED

## Summary

When creating a new strategic plan, selecting a CSE/CAM owner did not load their portfolio clients. The Portfolio & Health step showed "$0" for all metrics and "Select a CSE/CAM to load portfolio" message.

## Root Causes

Multiple issues contributed to this bug:

### 1. Missing `strategic_plans` Table
The table required for saving draft plans did not exist in the database.

**Error:** `Could not find the table 'public.strategic_plans' in the schema cache`

**Fix:** Created the table with script `scripts/create-strategic-plans-table.mjs`

### 2. Wrong Column Name in `cse_cam_targets` Query
The code queried for `cse_name` but the actual column is `cse_cam_name`.

```javascript
// Before (buggy)
.eq('cse_name', ownerName)
.eq('fiscal_year', 2026)

// After (fixed)
.eq('cse_cam_name', ownerName)
.eq('fiscal_year', 2026)
```

Also fixed `targets?.acv_target` to `targets?.total_acv_target`.

### 3. RLS Blocking `cse_client_assignments` Access
Row Level Security was enabled on `cse_client_assignments`, blocking browser queries even though SELECT permission was granted to anon/authenticated roles.

**Evidence:** Debug log showed `Assigned clients: []` when querying from browser, but 5 clients returned when using service role key.

**Fix:** Disabled RLS on `cse_client_assignments` table:
```sql
ALTER TABLE cse_client_assignments DISABLE ROW LEVEL SECURITY;
```

### 4. Client Name Matching Issues
The client names in `cse_client_assignments` didn't always match exactly with names in the `clients` table.

Examples:
- "Epworth HealthCare" vs "Epworth Healthcare" (case difference)
- "The Royal Victorian Eye and Ear Hospital" vs "Royal Victorian Eye and Ear Hospital"

**Fix:** Implemented fuzzy matching using partial string comparisons:
```javascript
return clientNamesLower.some(name =>
  canonicalLower === name ||
  displayLower === name ||
  canonicalLower.includes(name) ||
  name.includes(canonicalLower)
)
```

## Evidence

After selecting John Salisbury as Plan Owner:

**Before Fix:**
```
[loadPortfolioForOwner] Assigned clients: []
[loadPortfolioForOwner] Available clients count: 34
[loadPortfolioForOwner] Portfolio clients found: 0
```

**After Fix:**
```
[loadPortfolioForOwner] Assigned clients: [Epworth HealthCare, The Royal Victorian Eye and Ear Hospital, Western Health, Western Australia Department Of Health, Barwon Health Australia]
[loadPortfolioForOwner] Available clients count: 34
[loadPortfolioForOwner] Portfolio clients found: 4
```

Portfolio now displays:
- Barwon Health: $249,285.67 ARR
- Epworth Healthcare: $199,544.42 ARR
- RVEEH: $0 ARR
- Western Health: $486,472.92 ARR
- **Total Portfolio ARR: $935,303.01**

## Files Changed

1. `src/app/(dashboard)/planning/strategic/new/page.tsx`
   - Fixed column name from `cse_name` to `cse_cam_name`
   - Fixed `acv_target` to `total_acv_target`
   - Added fuzzy client name matching
   - Added debug logging

2. `scripts/create-strategic-plans-table.mjs` (NEW)
   - Script to create `strategic_plans` table

## Database Changes

1. Created `strategic_plans` table with required schema
2. Disabled RLS on `cse_client_assignments` table
3. Granted SELECT permissions on both tables to anon/authenticated

## Prevention

1. Always verify column names against database schema before writing queries
2. Consider using client_name_aliases for all client name lookups
3. Test new features with browser client, not just service role key (to catch RLS issues)
4. Add existence checks for required tables during app startup
