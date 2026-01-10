# Bug Fix: Client Portfolios CAM Names and Open Role Placeholder Photo

**Date:** 2026-01-10
**Severity:** Medium
**Status:** Resolved

## Summary

Two issues were identified in the Client Portfolios page:
1. CAM (Client Account Manager) names were showing "-" for most clients
2. "Open Role" profile placeholder photo was displaying as a broken image

## Root Cause Analysis

### Issue 1: CAM Names Not Displaying

**Problem:** The `/api/clients` endpoint was looking up CAM names by matching `client_name` from the `client_health_summary` view against `canonical_name` from the `clients` table. However, the names didn't match exactly:

| View client_name | clients.canonical_name |
|-----------------|------------------------|
| Gippsland Health Alliance (GHA) | Gippsland Health Alliance |
| Guam Regional Medical City (GRMC) | Guam Regional Medical City |
| Royal Victorian Eye and Ear Hospital | The Royal Victorian Eye and Ear Hospital |
| SA Health (iPro) | SA Health iPro |
| SA Health (iQemo) | SA Health iQemo |
| SA Health (Sunrise) | SA Health Sunrise |
| WA Health | Western Australia Department of Health |
| SingHealth | Singapore Health Services Pte Ltd |
| Saint Luke's Medical Centre (SLMC) | St Luke's Medical Center Global City Inc |
| NCS/MinDef Singapore | Ministry of Defence, Singapore |

**Solution:**
1. Modified `/api/clients` route to use the `client_name_aliases` table for resolving view client names to canonical names
2. Updated 10 `canonical_name` values in the `clients` table to match view names

### Issue 2: Open Role Placeholder Photo Broken

**Problem:** The "Open Role" profile in `cse_profiles` table had a base64 data URL stored in `photo_url`, but the `getPhotoURL` function in `useCSEProfiles.ts` was prepending the Supabase storage URL to all photo URLs, resulting in an invalid URL.

**Solution:** Updated `getPhotoURL` to check for and handle:
- Base64 data URLs (return as-is)
- Placeholder paths starting with `/placeholder` (return as-is for Next.js handling)

## Files Changed

### 1. `src/app/api/clients/route.ts`
Added alias table lookup for CAM resolution:
```typescript
// Fetch client name aliases for resolving view names to canonical names
const { data: aliasData, error: aliasError } = await supabaseAdmin
  .from('client_name_aliases')
  .select('display_name, canonical_name')
  .eq('is_active', true)

// Create a reverse alias map: display_name -> canonical_name
const aliasToCanonical = new Map<string, string>()
if (aliasData) {
  for (const alias of aliasData) {
    if (alias.display_name && alias.canonical_name) {
      aliasToCanonical.set(alias.display_name, alias.canonical_name)
    }
  }
}

// Helper function to resolve client_name to CAM
const resolveCAM = (clientName: string): string | null => {
  // First try direct match with canonical_name
  if (camByCanonical.has(clientName)) {
    return camByCanonical.get(clientName) || null
  }
  // Try to resolve via alias (view name -> canonical_name)
  const canonicalName = aliasToCanonical.get(clientName)
  if (canonicalName && camByCanonical.has(canonicalName)) {
    return camByCanonical.get(canonicalName) || null
  }
  return null
}
```

### 2. `src/hooks/useCSEProfiles.ts`
Added handling for data URLs and placeholder paths:
```typescript
const getPhotoURL = (cseName: string): string | null => {
  const profile = findProfile(cseName)
  if (!profile || !profile.photo_url) return null

  // If it's a data URL (base64), return as-is
  if (profile.photo_url.startsWith('data:')) {
    return profile.photo_url
  }

  // If it's a placeholder path, return as-is (handled by Next.js)
  if (profile.photo_url.startsWith('/placeholder')) {
    return profile.photo_url
  }

  // Convert storage path to full Supabase URL
  const photoPath = profile.photo_url.startsWith('/')
    ? profile.photo_url.substring(1)
    : profile.photo_url

  return `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/cse-photos/${photoPath}`
}
```

### 3. Database Update
Updated 10 records in `clients` table to match `canonical_name` with view names.

## Testing

1. Loaded Client Portfolios page
2. Verified CAM names display correctly for all clients
3. Verified "Open Role" placeholder photo displays correctly
4. Verified existing CSE photos still load correctly

## Prevention

- When adding new clients, ensure `canonical_name` in `clients` table matches the name used in the `client_health_summary` view, or add appropriate entries to `client_name_aliases` table
- When storing profile photos, be explicit about URL type (storage path vs data URL vs placeholder)

## Related Tables

- `client_health_summary` (materialized view)
- `clients` (canonical_name, cam_name columns)
- `client_name_aliases` (display_name, canonical_name mapping)
- `cse_profiles` (photo_url column)
