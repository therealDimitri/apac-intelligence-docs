# Bug Report: ChaSen Stream Endpoint Role Mapping

**Date:** 27 December 2025
**Severity:** Medium
**Status:** Fixed
**Affected Component:** `/api/chasen/stream/route.ts`

## Summary

The ChaSen AI streaming endpoint was displaying "Team Member" for users with VP-level and other specialised roles, preventing org-aware responses from working correctly in the floating ChaSen component.

## Symptoms

When a user with a VP role (e.g., Dimitri Leimonitis - AVP Client Success) asked ChaSen "Who reports to me?", the response was:

> "I can see your role is listed as a Team Member..."

Instead of recognising the VP role and listing direct reports.

## Root Cause

The `/api/chasen/stream/route.ts` file had an incomplete role mapping at line 1311. It only handled 3 roles in a ternary expression:

```typescript
- Role: ${userContext.role === 'cse' ? 'Client Success Executive' : userContext.role === 'manager' ? 'Manager' : userContext.role === 'executive' ? 'Executive' : 'Team Member'}
```

This meant all other roles (vp, svp, evp, cam, solutions, marketing, program, clinical, hr, support, operations, admin) fell through to "Team Member".

Meanwhile, the `/api/chasen/chat/route.ts` had the correct implementation with all 15 roles in the `ROLE_PRIORITIES` map.

## Fix Applied

Added a comprehensive `getRoleDisplayTitle()` function to the stream route that matches the chat route's role mapping:

```typescript
function getRoleDisplayTitle(role: string): string {
  const roleMap: Record<string, string> = {
    cse: 'Client Success Executive',
    cam: 'Client Account Manager',
    manager: 'CS Manager',
    evp: 'EVP APAC',
    svp: 'SVP Client Success & Operations',
    vp: 'Vice President',
    solutions: 'Solutions Management',
    marketing: 'Field Marketing Specialist',
    program: 'Program Manager',
    clinical: 'Chief Medical Officer',
    hr: 'HR Business Partner',
    support: 'Client Support',
    operations: 'Operations Manager',
    executive: 'Executive',
    admin: 'Administrator',
  }
  return roleMap[role] || 'Team Member'
}
```

Updated the system prompt to use this function:

```typescript
- Role: ${getRoleDisplayTitle(userContext.role)}
```

Also updated the `StreamRequest` interface to include all 15 role types in the union.

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/chasen/stream/route.ts` | Added `getRoleDisplayTitle()` function, updated role type union, fixed system prompt |

## Verification

After the fix, asking "Who reports to me?" now correctly returns:

> "Good morning, Dimitri!"
>
> "Based on the current client assignments, here are the Client Success Executives who form your team:"
> - Gilbert So (Health Check Opal, Auckland DHB, MidCentral)
> - John Salisbury (Grampians Health, WACHS, Epworth, SA Health)
> - Laura Messing (Queensland Health, Mercy Health)
> - Nikki Wei (Insight+, HKHA)
> - Tracey Bland (MINDEF)

## Prevention

When adding new role types to the system:
1. Update `useUserProfile.ts` role mapping
2. Update `/api/chasen/chat/route.ts` ROLE_PRIORITIES
3. Update `/api/chasen/stream/route.ts` getRoleDisplayTitle()
4. Update TypeScript interfaces in both API routes

Consider consolidating role mappings into a shared utility file to prevent future divergence.

## Related

- Feature: [Org-Aware ChaSen AI](./FEATURE-20251227-org-aware-chasen.md)
