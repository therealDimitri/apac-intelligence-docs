# Bug Report: Support Health Card Shows "No support data available"

**Date:** 8 January 2026
**Status:** ✅ Fixed
**Commit:** `acb7e6d8`

## Issue Summary

The SupportHealthCard component on client profile pages was displaying "No support data available" even when data existed in the `support_sla_metrics` table.

## Root Cause

Client name mismatch between different database tables:

| Table | Client Name |
|-------|-------------|
| `client_segmentation` | "Barwon Health Australia" |
| `support_sla_metrics` | "Barwon Health" |

The original `/api/support-metrics` endpoint used simple `ilike` matching without consulting the `client_name_aliases` table, which meant "Barwon Health Australia" would not match "Barwon Health" in the database.

## Additional Context

The original design used a dynamic API route at `/api/clients/[clientId]/support-metrics/route.ts` which did have proper alias resolution. However, this route was returning 404 errors due to OneDrive having compatibility issues with bracket characters `[clientId]` in folder names on macOS.

## Solution

### 1. Updated `/api/support-metrics/route.ts`

Added alias resolution to the existing working endpoint:

```typescript
if (clientName) {
  // Get all possible aliases for this client from the alias table
  const { data: aliases } = await supabase
    .from('client_name_aliases')
    .select('display_name, canonical_name')
    .or(`canonical_name.ilike.%${clientName}%,display_name.ilike.%${clientName}%`)
    .eq('is_active', true)

  // Build list of names to search for
  const searchNames = new Set<string>()
  searchNames.add(clientName)
  aliases?.forEach(a => {
    searchNames.add(a.display_name)
    searchNames.add(a.canonical_name)
  })

  // Build OR filter for all name variations
  const nameFilters = Array.from(searchNames)
    .filter(n => n)
    .map(n => `client_name.ilike.%${n}%`)
    .join(',')

  if (nameFilters) {
    query = query.or(nameFilters)
  } else {
    query = query.ilike('client_name', `%${clientName}%`)
  }
}
```

### 2. Updated `SupportHealthCard.tsx`

Changed the component to use the working `/api/support-metrics?client=` endpoint instead of the broken dynamic route:

```typescript
// Before (broken - 404 due to OneDrive bracket issues)
const res = await fetch(`/api/clients/${encodeURIComponent(clientId)}/support-metrics`)

// After (working)
const searchParam = clientName || clientId
const res = await fetch(`/api/support-metrics?client=${encodeURIComponent(searchParam)}`)
```

Also added client-side trend calculation since the response format changed.

## Files Modified

1. `src/app/api/support-metrics/route.ts` - Added alias table lookup
2. `src/components/support/SupportHealthCard.tsx` - Changed API endpoint and response handling

## Verification

After the fix, the Support Health card on client profiles displays correctly:
- Health Score: 90 (Healthy)
- Period: Dec 2025
- Open Cases: 4
- SLA Compliance: N/A%
- Aging >30d: 4
- Satisfaction: 5.0/5.0

## Lessons Learned

1. **Always use client alias resolution** when querying any table that may have different client name formats
2. **OneDrive on macOS has issues with bracket characters** in folder names - consider using query parameters instead of dynamic routes when working in OneDrive-synced directories
3. **Test with real data** - the issue only appeared when client names differed between tables

## Related Issues

- Previous session added "Grampians" → "Grampians Health" alias for similar name mismatch issue
- Same pattern exists for other clients where support system uses shortened names
