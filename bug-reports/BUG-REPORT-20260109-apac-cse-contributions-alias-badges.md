# APAC CSE Contributions - Alias Resolution and Role Badges

**Date:** 2026-01-09
**Type:** Bug Fix / Enhancement
**Status:** Resolved
**Priority:** High

---

## Issue Description

The APAC Planning Command Centre (`/planning/apac`) had two issues:

1. **CSE name matching not using aliases**: CSE names from `client_segmentation` weren't being matched to `cse_profiles` using the `name_aliases` field, resulting in $0 revenue figures
2. **Role displayed as text instead of badge**: Role labels like "(CSE)" and "(CAM)" were appended as plain text instead of visual badges
3. **Kenny Gan incorrectly included**: Country Manager role was incorrectly included in the CSE/CAM filter

## Root Cause

### Issue 1: No Alias Resolution
The code was doing direct name matching:
```typescript
const cseData = cseArrMap.get(profile.full_name)
```

But `client_segmentation.cse_name` might contain variants like "Johnathan Salisbury" while `cse_profiles.full_name` has "John Salisbury".

### Issue 2: Text-based Role Labels
Role was concatenated into the name string:
```typescript
name: `${profile.full_name} (${roleLabel})`,
```

### Issue 3: Incorrect Role Filter
The query included "Country Manager":
```typescript
.or('role.ilike.%CSE%,role.ilike.%CAM%,role.eq.Client Success Executive,role.eq.Country Manager')
```

## Solution

### 1. Added CSE Name Alias Lookup
```typescript
// Build CSE name alias lookup: maps any name variant to canonical full_name
const cseNameToCanonical = new Map<string, string>()
cseProfiles.data?.forEach((profile: CSEProfileData) => {
  // Map canonical name to itself
  cseNameToCanonical.set(profile.full_name.toLowerCase(), profile.full_name)
  // Map each alias to the canonical name
  if (profile.name_aliases && Array.isArray(profile.name_aliases)) {
    profile.name_aliases.forEach((alias: string) => {
      cseNameToCanonical.set(alias.toLowerCase(), profile.full_name)
    })
  }
})

// When processing client_segmentation, resolve to canonical name
const canonicalCseName = cseNameToCanonical.get(seg.cse_name.toLowerCase()) || seg.cse_name
```

### 2. Added Role Badge Component
```typescript
function RoleBadge({ role }: { role?: 'CSE' | 'CAM' | 'CSM' }) {
  const config = {
    CSE: { label: 'CSE', colour: 'bg-blue-50 text-blue-700 border-blue-200' },
    CAM: { label: 'CAM', colour: 'bg-purple-50 text-purple-700 border-purple-200' },
    CSM: { label: 'CSM', colour: 'bg-teal-50 text-teal-700 border-teal-200' },
  }
  // ... badge rendering
}
```

### 3. Updated BUContribution Interface
Added `role` field to pass role separately from name:
```typescript
export interface BUContribution {
  id: string
  name: string
  role?: 'CSE' | 'CAM' | 'CSM'  // Added
  // ... other fields
}
```

### 4. Fixed Role Filter
Removed "Country Manager" from the query:
```typescript
.or('role.ilike.%CSE%,role.ilike.%CAM%,role.eq.Client Success Executive')
```

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/apac/page.tsx` | Added alias lookup, removed Country Manager filter, pass role separately |
| `src/components/planning/BUContributionsTable.tsx` | Added `role` field to interface, added `RoleBadge` component, updated table cell |

## Database Tables Used

- `cse_profiles` - CSE/CAM profiles with `name_aliases` array for name variants
- `client_segmentation` - Client-to-CSE assignments (may contain alias names)
- `burc_client_arr` - Client ARR data

## How Alias Resolution Works

1. **Build lookup map**: Create a Map from all name variants (full_name + aliases) to canonical full_name
2. **Resolve on match**: When processing client_segmentation, resolve cse_name to canonical name
3. **Aggregate by canonical**: All client ARR is aggregated under the canonical CSE name

## Testing Checklist

- [x] Build passes without TypeScript errors
- [x] Kenny Gan (Country Manager) no longer appears in table
- [x] CSE names show as badges instead of text
- [x] Role badges display with correct colours (blue for CSE, purple for CAM)
- [x] Profile photos display from `cse_profiles.photo_url`
- [x] Initials avatar fallback for missing photos
- [x] "Open Role" displays as "Open Role - Asia + Guam"
- [ ] CSE revenue figures populate correctly (pending refresh test)

## Badge Colour Scheme

| Role | Background | Text | Border |
|------|------------|------|--------|
| CSE | `bg-blue-50` | `text-blue-700` | `border-blue-200` |
| CAM | `bg-purple-50` | `text-purple-700` | `border-purple-200` |
| CSM | `bg-teal-50` | `text-teal-700` | `border-teal-200` |

---

## Related Bug Reports

- `BUG-REPORT-20260109-territory-strategy-cse-alias-resolution.md` - Similar alias resolution fix for Territory Strategy page
