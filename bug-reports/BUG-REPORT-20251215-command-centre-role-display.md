# Bug Report: Command Centre Showing "Team Member" Instead of Actual Role

**Date:** 2025-12-15
**Status:** RESOLVED
**Commit:** `72ff260`

## Issue Description

The Command Centre page was displaying "Team Member" for all users instead of their actual job titles from the database.

**Example:**

- User: Dimitri Leimonitis
- Expected role: "AVP Client Success, APAC"
- Displayed role: "Team Member"

## Root Cause

The code had two mismatched systems for handling user roles:

1. **Database (`cse_profiles.role`)**: Stores actual job titles like:
   - "AVP Client Success, APAC"
   - "Client Success Executive"
   - "VP Solutions"
   - etc.

2. **Application code**: Expected simplified role codes:
   - `cse`
   - `manager`
   - `executive`
   - `admin`

The `useUserProfile` hook was casting the database role to the TypeScript union type, which resulted in invalid values. The `getRoleDisplay()` function then returned "Team Member" as the default fallback.

## Solution

### 1. Updated `UserProfile` Interface

Added a new `roleTitle` field to store the actual job title for display:

```typescript
export interface UserProfile {
  // ... existing fields
  role: 'cse' | 'manager' | 'executive' | 'admin' // Internal role type for permissions
  roleTitle: string // Actual job title from database for display
  // ...
}
```

### 2. Updated `useUserProfile` Hook

Modified the role assignment logic to:

- Store the actual role title from the database for display
- Map role titles to internal role types for permission logic

```typescript
// Store actual role title for display
roleTitle = cseProfile.role || 'Team Member'

// Map role title to internal role type for permissions
const roleLower = (cseProfile.role || '').toLowerCase()
if (roleLower.includes('client success executive') || roleLower === 'cse') {
  role = 'cse'
} else if (
  roleLower.includes('vp') ||
  roleLower.includes('avp') ||
  roleLower.includes('manager') ||
  roleLower.includes('director')
) {
  role = 'manager'
} else if (roleLower.includes('svp') || roleLower.includes('executive')) {
  role = 'executive'
} else if (roleLower.includes('admin')) {
  role = 'admin'
} else {
  role = 'manager' // Default for non-CSE roles
}
```

### 3. Updated Command Centre Page

Removed the `getRoleDisplay()` function and directly display `profile.roleTitle`:

```tsx
<span className="flex items-center gap-1">
  <Building2 className="h-4 w-4" />
  {profile.roleTitle}
</span>
```

## Files Modified

- `src/hooks/useUserProfile.ts` - Added roleTitle field and mapping logic
- `src/app/(dashboard)/page.tsx` - Display roleTitle instead of mapped role
- `src/hooks/__tests__/useSavedViews.test.ts` - Updated test mocks

## Role Mapping Reference

| Job Title Contains                 | Internal Role | Permissions                       |
| ---------------------------------- | ------------- | --------------------------------- |
| "Client Success Executive", "CSE"  | `cse`         | View own clients only             |
| "VP", "AVP", "Manager", "Director" | `manager`     | View all clients                  |
| "SVP", "Executive"                 | `executive`   | View all clients + admin features |
| "Admin"                            | `admin`       | Full access                       |

## Testing

1. Log in as different users
2. Verify Command Centre displays their actual job title from `cse_profiles.role`
3. Verify permission-based filtering still works correctly (CSEs see only their clients)

## Related

- Database table: `cse_profiles`
- Previous bug: Client logos not displaying (fixed in same session)
