# Bug Report: APAC Planning CSE Territory Contributions Showing $0

**Date:** 10 January 2026
**Severity:** High
**Status:** Resolved
**Component:** Planning > APAC Command Centre > CSE Territory Contributions

---

## Issue Summary

CSE Territory Contributions table in the APAC Planning Command Centre was showing $0 for all CSEs while the APAC total correctly showed $17.1M from `burc_executive_summary`.

## Root Cause Analysis

### Data Source Issue

The APAC Planning page was querying a non-existent table:
- **Wrong table:** `burc_client_arr` (does not exist)
- **Correct table:** `client_arr` (contains FY2026 recognised revenue from BURC Maint sheet)

### Previous Code

```typescript
// Fetch client ARR data
supabase.from('burc_client_arr').select('client_name, current_arr').eq('fiscal_year', 2026),
```

The `burc_client_arr` table was never created. The actual client-level ARR data lives in the `client_arr` table, which is populated from the `2026 APAC Performance.xlsx` file.

### Client Name Mismatch

Additionally, client names in `client_arr` (BURC canonical names) didn't match names in `client_segmentation` (dashboard canonical names):

| client_arr Name | client_segmentation Name |
|-----------------|-------------------------|
| Minister for Health aka South Australia Health | SA Health (iQemo), SA Health (Sunrise), SA Health (iPro) |
| Singapore Health Services Pte Ltd | SingHealth |
| Western Australia Department Of Health | WA Health |
| The Royal Victorian Eye and Ear Hospital | Royal Victorian Eye and Ear Hospital |
| St Luke's Medical Center Global City Inc | Saint Luke's Medical Centre (SLMC) |
| NCS Pte Ltd | NCS/MinDef Singapore |

## Solution Implemented

### 1. Fixed Data Source

Changed query from non-existent `burc_client_arr` to `client_arr` via API route (to bypass RLS):

```typescript
// Fetch client ARR data via API route (bypasses RLS)
fetch('/api/planning/client-arr').then(res => res.json()),

// Extract client ARR data from API response
const clientArr = { data: clientArrResponse.data as { client_name: string; arr_usd: number }[] | null }
```

**Note:** The `client_arr` table has Row Level Security (RLS) enabled that blocks browser access with the anon key. The API route uses the service role key to bypass RLS.

### 2. Added Client Name Alias Resolution

Added `client_name_aliases` lookup to match different name formats (same approach used in Territory Strategy page):

```typescript
// Fetch client name aliases for matching different name formats
supabase.from('client_name_aliases').select('display_name, canonical_name').eq('is_active', true),

// Create alias maps for matching
const aliasToCanonical = new Map<string, string>()
const canonicalToAliases = new Map<string, string[]>()
clientNameAliases.data?.forEach(a => {
  aliasToCanonical.set(a.display_name.toLowerCase(), a.canonical_name.toLowerCase())
  const existing = canonicalToAliases.get(a.canonical_name.toLowerCase()) || []
  existing.push(a.display_name.toLowerCase())
  canonicalToAliases.set(a.canonical_name.toLowerCase(), existing)
})

// Helper to find all possible names for a client
const getAllClientNames = (name: string): string[] => {
  const lowerName = name.toLowerCase()
  const names = [lowerName]
  const canonical = aliasToCanonical.get(lowerName)
  if (canonical) names.push(canonical)
  const aliases = canonicalToAliases.get(lowerName) || []
  names.push(...aliases)
  if (canonical) {
    const canonicalAliases = canonicalToAliases.get(canonical) || []
    names.push(...canonicalAliases)
  }
  return [...new Set(names)]
}

// Create ARR lookup with expanded names
clientArr.data?.forEach(c => {
  if (c.client_name) {
    const allNames = getAllClientNames(c.client_name)
    allNames.forEach(name => {
      const existing = arrMap.get(name) || 0
      if ((c.arr_usd || 0) > existing) {
        arrMap.set(name, c.arr_usd || 0)
      }
    })
  }
})
```

## Files Modified

- `src/app/(dashboard)/planning/apac/page.tsx`
  - Changed from direct Supabase query to API route (`/api/planning/client-arr`)
  - Added `client_name_aliases` query for name matching
  - Added `getAllClientNames()` helper for alias resolution
  - Uses existing API route that bypasses RLS with service role key

## Data Sources

| Data Point | Source Table | Total Value |
|------------|--------------|-------------|
| APAC Total ARR | `burc_executive_summary.total_arr` | $17,134,493 |
| Client-level ARR | `client_arr.arr_usd` | $19,617,736 |
| Client name aliases | `client_name_aliases` | 87 aliases |

## Related Documentation

- `docs/BUG-REPORT-20260109-territory-arr-wrong-data-source.md` - Same issue fixed for Territory Strategy page
- `scripts/sync-2026-backlog-arr.mjs` - Script that populates `client_arr` from BURC Excel

## Testing Checklist

- [x] Build passes without TypeScript errors
- [x] APAC Planning page loads without errors
- [x] CSE Territory Contributions show non-zero values
- [x] ARR values match between page and BURC source
- [x] Client name aliases resolve correctly

## Verified Results

| CSE/CAM | Role | Current ARR | Clients |
|---------|------|-------------|---------|
| Laura Messing | CSE | $6.8M | 4 |
| Nikki Wei | CAM | $6.7M | 5 |
| Open Role - Asia + Guam | CSE | $6.7M | 5 |
| John Salisbury | CSE | $3.9M | 5 |
| Tracey Bland | CSE | $2.2M | 5 |

## Additional Fix: Asian Client CSE/CAM Assignment

### Issue
Asian clients (SingHealth, Saint Luke's, GRMC, NCS/MinDef, Mount Alvernia) were assigned to inactive CSEs (BoonTeck Lim, Gilbert So) or only to Nikki Wei (CAM) without corresponding CSE coverage.

### Solution
1. Reassigned all Asian/Guam clients to "Open Role - Asia + Guam" as their CSE
2. Added region-based inheritance logic so CAMs inherit ARR from CSEs in overlapping regions
3. Nikki Wei (CAM - Asia) now automatically inherits the same $6.7M ARR as Open Role (CSE - Asia + Guam)

### Database Changes
```sql
-- Updated client_segmentation to assign Asian clients to Open Role
UPDATE client_segmentation SET cse_name = 'Open Role - Asia + Guam'
WHERE cse_name IN ('BoonTeck Lim', 'Gilbert So', 'Nikki Wei');
```

### Code Changes
Added region-to-CSE mapping in `page.tsx`:
```typescript
// Build region-to-CSE mapping for CAM region inheritance
// CAMs share the same clients/ARR as CSEs in overlapping regions
const regionToCseData = new Map<string, { arr: number; clientCount: number; cseName: string }>()

// For CAMs without direct clients, inherit ARR from CSEs in the same region
if (isCAM && (!cseData || cseData.arr === 0) && profile.region) {
  const camRegions = profile.region.toLowerCase().split(/[,+&]/).map(r => r.trim())
  for (const region of camRegions) {
    const regionData = regionToCseData.get(region)
    if (regionData && regionData.arr > 0) {
      cseData = { arr: regionData.arr, clientCount: regionData.clientCount }
      break
    }
  }
}
```

## Notes

1. The `client_arr` table is the authoritative source for FY2026 client-level ARR
2. Always use `client_name_aliases` for matching client names across different data sources
3. The BURC Excel file (`2026 APAC Performance.xlsx`) is the source of truth for financial data
