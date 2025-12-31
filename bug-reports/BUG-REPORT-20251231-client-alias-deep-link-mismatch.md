# Bug Report: Client Alias Deep Link Mismatch

**Date**: 31 December 2025
**Severity**: Medium
**Status**: Resolved
**Affected Component**: Priority Matrix → Context Menu → "Open Client Profile"

## Summary

Right-clicking on Priority Matrix items and selecting "Open Client Profile" was navigating to a fallback search URL (`/client-profiles?search=...`) instead of the correct client deep link (`/clients/{id}/v2`).

## Root Cause

35 client name aliases in the `client_name_aliases` table were pointing to canonical names that did not match any client in the `client_health_summary` materialised view. This caused the `getClientIdByName` function to fail to find a matching client, triggering the fallback URL pattern.

### Examples of Mismatches

| Display Name | Incorrect Canonical | Correct Canonical |
|-------------|---------------------|-------------------|
| RVEEH | The Royal Victorian Eye and Ear Hospital | Royal Victorian Eye and Ear Hospital |
| GHA | Gippsland Health Alliance | Gippsland Health Alliance (GHA) |
| GRMC | Guam Regional Medical City | Guam Regional Medical City (GRMC) |
| NCS/MinDef | Ministry of Defence, Singapore | NCS/MinDef Singapore |
| SingHealth | Singapore Health Services Pte Ltd | SingHealth |
| St Luke's | St Luke's Medical Center Global City Inc | Saint Luke's Medical Centre (SLMC) |
| WA Health | Western Australia Department of Health | WA Health |
| SA Health | SA Health | SA Health (Sunrise) |

## Files Modified

### Code Changes

1. **`src/components/priority-matrix/PriorityMatrix.tsx`**
   - Added `useClientAliases` hook import
   - Updated `getClientIdByName` to resolve aliases before client lookup
   - Enables deep linking for action items with aliased client names

2. **`src/components/priority-matrix/PriorityMatrixMultiView.tsx`**
   - Same alias resolution fix applied for consistency

### Database Changes

All 35 mismatched aliases updated in `client_name_aliases` table to point to correct canonical names.

## Fix Details

### Code Fix (alias resolution)

```tsx
// Before: Direct client lookup (failed for aliased names)
const getClientIdByName = (clientName: string): string | undefined => {
  const client = clients.find(c => c.name.toLowerCase() === clientName.toLowerCase())
  return client?.id
}

// After: Resolve alias first, then lookup
const getClientIdByName = useCallback(
  (clientName: string): string | undefined => {
    // First try to resolve alias to canonical name
    const canonicalName = resolveClientName(clientName)

    // Try exact match first with canonical name
    let client = clients.find(c => c.name.toLowerCase() === canonicalName.toLowerCase())

    // If not found, try with original name (in case alias resolution wasn't needed)
    if (!client && canonicalName !== clientName) {
      client = clients.find(c => c.name.toLowerCase() === clientName.toLowerCase())
    }

    return client?.id
  },
  [clients, resolveClientName]
)
```

### Database Fix (canonical name corrections)

Executed script `scripts/fix-all-alias-mismatches-v2.mjs` to update all 35 mismatched aliases:

```javascript
const CANONICAL_FIXES = {
  'Gippsland Health Alliance': 'Gippsland Health Alliance (GHA)',
  'Grampians Health Alliance': 'Grampians Health',
  'Guam Regional Medical City': 'Guam Regional Medical City (GRMC)',
  'The Royal Victorian Eye and Ear Hospital': 'Royal Victorian Eye and Ear Hospital',
  'Ministry of Defence, Singapore': 'NCS/MinDef Singapore',
  'Singapore Health Services Pte Ltd': 'SingHealth',
  'Western Australia Department of Health': 'WA Health',
  "St Luke's Medical Center Global City Inc": "Saint Luke's Medical Centre (SLMC)",
  // ... and more
}
```

## Verification

After applying fixes:
1. Console logs confirmed: `[getClientIdByName] Found client: Royal Victorian Eye and Ear Hospital (ID: 13)`
2. Page navigated to: `http://localhost:3002/clients/13/v2` ✅
3. All 53 aliases now point to valid clients in the system

## Prevention

1. **Validation Script**: Created `scripts/check-all-alias-mismatches.mjs` for ongoing alias health monitoring
2. **Recommendation**: Run alias validation after any client name changes or new client additions
3. **Consider**: Adding a database constraint or trigger to validate canonical names exist in client list

## Testing

To verify the fix works correctly:

1. Navigate to Command Centre (`/`)
2. Right-click on any Priority Matrix item (e.g., "Prepare RVEEH renewal")
3. Select "Open Client Profile" from context menu
4. Verify navigation goes to `/clients/{id}/v2` (not `/client-profiles?search=...`)

## Follow-up Fix: Logo Display Broken

After the initial alias fix, client logos stopped displaying because `CLIENT_LOGO_MAP` in `client-logos-local.ts` was using the OLD canonical names as keys.

### Additional Changes Required

**`src/lib/client-logos-local.ts`**:
- Updated `CLIENT_LOGO_MAP` keys to match `client_health_summary.client_name` exactly
- Updated `FALLBACK_ALIASES` values to resolve to the correct canonical names

| Old Key | New Key |
|---------|---------|
| "Gippsland Health Alliance" | "Gippsland Health Alliance (GHA)" |
| "Grampians Health Alliance" | "Grampians Health" |
| "Singapore Health Services Pte Ltd" | "SingHealth" |
| "Ministry of Defence, Singapore" | "NCS/MinDef Singapore" |
| "The Royal Victorian Eye and Ear Hospital" | "Royal Victorian Eye and Ear Hospital" |
| "Western Australia Department of Health" | "WA Health" |
| "St Luke's Medical Center Global City Inc" | "Saint Luke's Medical Centre (SLMC)" |
| "SA Health iPro" | "SA Health (iPro)" |

## Follow-up Fix #2: Compliance Modal Instead of Profile

After fixing aliases and logos, "Open Client Profile" was still opening the Segmentation Compliance modal instead of the main client profile.

### Root Cause

The `QuickActionsMenu.tsx` was detecting "segmentation events" and automatically adding `?section=compliance` to the URL:

```javascript
// Line 121-124 - incorrectly classified items as segmentation events
const isSegmentationEvent =
  item.subtitle?.toLowerCase().includes('segmentation') ||
  item.subtitle?.toLowerCase().includes('compliance') ||
  item.type === 'critical'

// Lines 258-262 - added section=compliance for these items
onClick: () => {
  const section = isSegmentationEvent ? 'compliance' : undefined  // PROBLEM
  router.push(buildClientDeepLink(mostUrgentClient, section))
```

### Fix Applied

Removed the `section` parameter from both:
1. "Open Client Profile" / "Open Most Urgent Client" action (line 260)
2. "Choose Client to Open" submenu items (line 453)

Now all "Open Client Profile" actions navigate directly to `/clients/{id}/v2` without any section parameter.

### Key Learning

**Single Source of Truth**: The `client_health_summary` materialised view is the source of truth for canonical client names. All other systems (aliases, logos, deep links) must reference these exact names.

## Related Files

- `src/hooks/useClientAliases.ts` - Client alias resolution hook
- `src/lib/client-logos-local.ts` - Logo lookup with fallback aliases
- `src/components/priority-matrix/QuickActionsMenu.tsx` - Context menu with deep link navigation
- `scripts/check-all-alias-mismatches.mjs` - Validation script
- `scripts/fix-all-alias-mismatches-v2.mjs` - Fix script
