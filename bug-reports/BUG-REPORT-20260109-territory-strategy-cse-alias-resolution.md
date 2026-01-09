# Territory Strategy - CSE Name Alias Resolution

**Date:** 2026-01-09
**Type:** Bug Fix / Refactor
**Status:** Resolved
**Priority:** High

---

## Issue Description

The Territory Strategy page (`/planning/territory/new`) was using hardcoded CSE options (`CSE_OPTIONS` constant) instead of the `cse_profiles` database table. This caused several issues:

1. **"Open Role" mismatch**: The display showed "Open Role Asia" but database queries expected "Open Role"
2. **No alias resolution**: Changes to CSE names required code changes instead of database updates
3. **Data integrity issues**: Hardcoded mappings drifted from actual database values

## Root Cause

The page had a static `CSE_OPTIONS` constant with a manual `dbName` mapping:

```typescript
const CSE_OPTIONS = [
  { name: 'Tracey Bland', dbName: 'Tracey Bland', territory: 'Victoria, NZ' },
  { name: 'Open Role Asia', dbName: 'Open Role', territory: 'Asia + Guam' },
  // ...
]
```

This pattern:
- Duplicated data that already exists in `cse_profiles`
- Ignored the `name_aliases` field designed for this purpose
- Required code changes for any CSE name updates

## Solution

Refactored to use the `cse_profiles` table with proper alias resolution:

### Code Changes

1. **Added CSEProfile interface**
   ```typescript
   interface CSEProfile {
     id: number
     full_name: string      // Canonical name for DB queries
     name_aliases: string[] // Display names (first alias used)
     region: string | null
     role: string | null
     active: boolean
   }
   ```

2. **Added state and useEffect for loading profiles**
   ```typescript
   const [cseProfiles, setCseProfiles] = useState<CSEProfile[]>([])
   const [loadingProfiles, setLoadingProfiles] = useState(true)

   useEffect(() => {
     const { data } = await supabase
       .from('cse_profiles')
       .select('id, full_name, name_aliases, region, role, active')
       .eq('active', true)
       .eq('role', 'CSE')
     setCseProfiles(data || [])
   }, [])
   ```

3. **Added helper functions for alias resolution**
   ```typescript
   // Get display name (first alias or full_name)
   const getCSEDisplayName = (profile: CSEProfile): string => {
     if (profile.name_aliases?.length > 0) {
       return profile.name_aliases[0]
     }
     return profile.full_name
   }

   // Find profile by any name (full_name or alias)
   const findCSEProfile = (name: string): CSEProfile | undefined => {
     return cseProfiles.find(p => {
       if (p.full_name.toLowerCase() === name.toLowerCase()) return true
       if (p.name_aliases?.some(a => a.toLowerCase() === name.toLowerCase())) return true
       return false
     })
   }
   ```

4. **Updated handleCSESelect to use canonical full_name for DB queries**
   ```typescript
   const handleCSESelect = async (cseName: string) => {
     const cse = findCSEProfile(cseName)
     if (!cse) return

     const dbCseName = cse.full_name  // Use canonical name for queries
     const displayName = getCSEDisplayName(cse)
     // ...
   }
   ```

### Database Changes

Updated `cse_profiles` table to add "Open Role Asia" as alias:

```sql
UPDATE cse_profiles
SET name_aliases = ARRAY['Open Role Asia']
WHERE full_name = 'Open Role';
```

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/territory/new/page.tsx` | Removed hardcoded CSE_OPTIONS, added dynamic profile loading with alias resolution |

## Database Tables Used

- `cse_profiles` - CSE/CAM profiles with `name_aliases` array for display name aliases

## How Alias Resolution Works

1. **Display**: Uses first entry from `name_aliases` array, falls back to `full_name`
2. **Database Queries**: Always uses `full_name` (canonical name)
3. **Selection**: Matches against both `full_name` and all `name_aliases`

## Testing Checklist

- [x] Build passes without TypeScript errors
- [x] CSE dropdown loads profiles from database
- [x] "Open Role Asia" displays correctly
- [x] Database queries use canonical "Open Role" name
- [x] Client portfolio loads correctly for all CSEs

## Prevention

The `cse_profiles` table with `name_aliases` is now the single source of truth for CSE name mappings. Future CSE name changes should:

1. Update `cse_profiles.full_name` for canonical name changes
2. Add display variants to `cse_profiles.name_aliases` array
3. Never create hardcoded name mappings in code

---

## Additional Fix: SingHealth Subsidiary Consolidation

### Issue
SingHealth subsidiaries (Changi General Hospital, KK Women's Hospital, Singapore General Hospital, etc.) were appearing as 7 separate entries in the portfolio when they should be consolidated under "SingHealth".

### Root Cause
The deduplication was based on client record ID, but these subsidiaries existed as separate entries in `cse_client_assignments` without corresponding `clients` table records to share IDs.

### Solution
Changed deduplication to use **canonical name** from `client_name_aliases`:

```typescript
// Helper to get canonical name for deduplication
const getCanonicalName = (name: string): string => {
  const lowerName = name.toLowerCase()
  return aliasToCanonical.get(lowerName) || lowerName
}

// Deduplicate by canonical name (e.g., "Changi General Hospital" -> "singhealth")
const canonicalName = getCanonicalName(clientName)
if (processedCanonicalNames.has(canonicalName)) {
  continue
}
processedCanonicalNames.add(canonicalName)
```

Also updated display name logic to show "SingHealth" instead of first-encountered subsidiary name.

---

## Commits

1. `a851eb69` - refactor: use cse_profiles table for CSE name alias resolution
2. `d04b3a89` - fix: consolidate SingHealth subsidiaries using client_name_aliases
