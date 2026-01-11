# Bug Report: Plan Owner Dropdown Showing All Users

**Date:** 2026-01-11
**Severity:** Medium
**Component:** Strategic Planning / New Plan Page
**Status:** RESOLVED

## Summary

The Plan Owner dropdown in the New Strategic Plan page was showing all users from the `cse_profiles` table instead of only CSE/CAM roles. This included VP Solutions, Sr HR Business Partner, Business Unit Chief Medical Officer, Field Marketing Specialist, and other non-client-facing roles.

## Root Cause

The `loadProfiles()` function in `/src/app/(dashboard)/planning/strategic/new/page.tsx` was querying `cse_profiles` with only an `active = true` filter, returning all active profiles regardless of role.

```javascript
// Before (buggy)
const { data, error } = await supabase
  .from('cse_profiles')
  .select('id, full_name, name_aliases, region, role, active')
  .eq('active', true)
  .order('full_name')

setCseProfiles(data || [])
```

## Evidence

Screenshot showed the Plan Owner dropdown containing:
- Anu Pradhan (CAM) - Correct
- Ben Stevenson (VP Solutions) - Should NOT appear
- Cara Cortese (Sr HR Business Partner) - Should NOT appear
- Carol-Lynne Lloyd (Business Unit Chief Medical Officer) - Should NOT appear
- Christina Tan (Sr Field Marketing Specialist) - Should NOT appear
- Corey Popelier (AVP Program Delivery) - Should NOT appear
- John Salisbury (Client Success Executive) - Correct
- Laura Messing (Client Success Executive) - Correct
- Nikki Wei (CAM) - Correct

## Fix Applied

Added client-side filtering to only include profiles with CSE/CAM related roles:

```javascript
// After (fixed)
const { data, error } = await supabase
  .from('cse_profiles')
  .select('id, full_name, name_aliases, region, role, active')
  .eq('active', true)
  .order('full_name')

if (error) throw error

// Filter to only CSE/CAM related roles
const cseCAMRoles = (data || []).filter(profile => {
  const role = (profile.role || '').toLowerCase()
  return (
    role.includes('cse') ||
    role.includes('cam') ||
    role.includes('client success executive') ||
    role.includes('client account manager') ||
    role.includes('customer success')
  )
})

setCseProfiles(cseCAMRoles)
```

## Affected Components

Both dropdowns on the New Strategic Plan page now correctly filter:
1. **Plan Owner** dropdown (CSE / CAM field)
2. **Collaborators** dropdown (uses same `cseProfiles` array)

## Files Changed

1. `src/app/(dashboard)/planning/strategic/new/page.tsx` - Added role filtering

## Verification

After fix:
- Build passes with zero TypeScript errors
- Plan Owner dropdown only shows CSE/CAM roles
- Collaborators dropdown only shows CSE/CAM roles

## Prevention

Consider:
1. Adding a `role_category` column to `cse_profiles` table (e.g., 'cse', 'cam', 'leadership', 'support')
2. Creating a database view `cse_cam_profiles` that pre-filters to only relevant roles
3. Adding role-based access control to ensure only appropriate roles can create plans
