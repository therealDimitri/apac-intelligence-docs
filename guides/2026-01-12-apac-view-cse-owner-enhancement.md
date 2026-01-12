# Enhancement Report: APAC Combined View & CSE-Only Plan Owner

**Date:** 12 January 2026
**Status:** Resolved
**Type:** Enhancement
**Severity:** Medium

## Summary

Two enhancements were implemented:
1. Added APAC combined view to Business Units page that merges ANZ + SEA + Guam regions
2. Updated Strategic Plan creation to default owner to CSE-only, with CAMs moved to collaborators

## Issue Details

### APAC Combined View
**Reported Behaviour:**
- Business Units page only showed ANZ and SEA as separate options
- No way to view combined APAC metrics across all regions

**Expected Behaviour:**
- APAC option should be available that combines all regional data

### CSE-Only Plan Owner
**Reported Behaviour:**
- Plan Owner dropdown showed both CSE and CAM roles
- Selecting a CAM would auto-default to Account Deep-Dive mode
- Message displayed "CAM - defaulting to Account Deep-Dive"

**Expected Behaviour:**
- Only CSEs should be selectable as plan owners
- CAMs should only appear in the collaborators dropdown
- Both Territory and Account Deep-dive should default to CSE ownership

## Root Cause

### APAC Combined View
The `filterClientsByBU` function and API endpoint did not support an APAC option that combined the ANZ and SEA client patterns.

### CSE-Only Plan Owner
The profile loading filtered for both CSE and CAM roles, and the owner selection logic treated CAMs as valid plan owners with auto-switching behaviour.

## Solution

### Files Modified

1. **`src/app/(dashboard)/planning/business-unit/page.tsx`**
   - Added 'APAC' to BusinessUnit type
   - Added APAC option with globe emoji to BUSINESS_UNITS constant
   - Updated `filterClientsByBU` to combine ANZ + SEA patterns for APAC

2. **`src/app/api/planning/financials/business-unit/route.ts`**
   - Added APAC to BU_TERRITORIES with combined region list
   - Updated `filterClientsByBU` to handle APAC combining ANZ and SEA clients
   - Updated `calculateBUTarget` with APAC growth target (10%)
   - Updated `buildTerritoryBreakdown` to include both ANZ and SEA territories for APAC

3. **`src/app/(dashboard)/planning/strategic/new/page.tsx`**
   - Added separate `allTeamProfiles` state for collaborators (includes CAMs)
   - Updated profile filter to only include CSE roles for owner dropdown
   - Removed CAM detection and auto-switching logic from `handleOwnerSelect`
   - Changed owner label from "CSE / CAM" to "CSE"
   - Updated info message to guide users to add CAMs as collaborators
   - Collaborators dropdown now uses `allTeamProfiles` and shows "(CAM)" suffix

## Code Changes

### APAC Region Filter
```typescript
// APAC combines all regions (ANZ + SEA)
if (bu === 'APAC') {
  const anzPatterns = BU_CLIENT_PATTERNS['ANZ']
  const seaPatterns = BU_CLIENT_PATTERNS['SEA']
  const allPatterns = [...anzPatterns, ...seaPatterns]

  return externalClients.filter(client =>
    allPatterns.some(pattern => client.name.toLowerCase().includes(pattern.toLowerCase()))
  )
}
```

### CSE-Only Profile Filter
```typescript
// Filter to only CSE related roles (CSEs are plan owners, CAMs are collaborators)
const cseRoles = (data || []).filter(profile => {
  const role = (profile.role || '').toLowerCase()
  const isCSE = role.includes('cse') || role.includes('client success executive')
  const isCAM = role.includes('cam') || role.includes('client account manager')
  return isCSE && !isCAM
})
```

## Testing Performed

- [x] Build passes with zero TypeScript errors
- [x] APAC option appears in Business Units dropdown
- [x] APAC view shows combined ANZ + SEA territories
- [x] Plan Owner dropdown only shows CSE roles
- [x] CAMs appear in collaborators dropdown with "(CAM)" suffix
- [x] Plan type selection remains user-controlled (no auto-switching)

## Prevention

- Business rules for role-based access should be clearly documented
- UI/UX decisions about owner vs collaborator roles should be explicit in specs
