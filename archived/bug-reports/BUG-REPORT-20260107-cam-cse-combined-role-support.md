# Bug Report: CAM/CSE Combined Role Support

**Date:** 2026-01-07
**Status:** Resolved
**Priority:** Medium
**Component:** Dashboard-wide (Compliance, Team Performance)

---

## Issue Summary

Users performing both CAM (Client Account Manager) and CSE (Client Success Executive) roles temporarily were displaying incorrectly across the dashboard:

1. **Nikki Wei** (Asia region): Had "CSE & CAM" role in database but appeared twice in some views (once as CSE, once as CAM) or was missing the CAM/CSE designation
2. **Anupama Pradhan (Anu)**: Was not appearing on the Client Success Leaderboard despite being a CAM

---

## Root Cause

The application only supported binary role types (`'CSE'` or `'CAM'`) and did not handle combined roles:

- `TeamMemberRole` type was `'CSE' | 'CAM'` only
- Team Performance API used simple role detection that didn't detect "CSE & CAM" from database
- Dashboard components duplicated entries for people with both roles

---

## Solution Implemented

### 1. Type System Update
**File:** `src/types/team-performance.ts`

```typescript
// Before
export type TeamMemberRole = 'CSE' | 'CAM'

// After
export type TeamMemberRole = 'CSE' | 'CAM' | 'CAM/CSE'
```

### 2. API Role Detection
**File:** `src/app/api/team-performance/route.ts`

Updated role detection to check for combined roles:

```typescript
// Check for combined role first (e.g., "CSE & CAM" in database)
const isCombinedRole = roleStr.includes('cse') && (roleStr.includes('cam') || roleStr.includes('account manager'))
const isCAMOnly = !isCombinedRole && (roleStr === 'cam' || roleStr.includes('account manager'))

const role: 'CSE' | 'CAM' | 'CAM/CSE' = isCombinedRole
  ? 'CAM/CSE'
  : isCAMOnly
    ? 'CAM'
    : 'CSE'
```

Updated client assignment to combine both sources for CAM/CSE:

```typescript
if (role === 'CAM/CSE') {
  const cseClientList = cseClients.get(profile.full_name) || []
  const camClientList = camClients.get(profile.full_name) || []
  clientNames = [...new Set([...cseClientList, ...camClientList])]
}
```

Updated CSE profile query to include combined roles:

```typescript
.or('role.eq.Client Success Executive,role.eq.Client Account Manager,role.eq.CAM,role.eq.CSE,role.ilike.%CSE%CAM%')
```

### 3. RoleBadge Component
**File:** `src/components/team-performance/CSEPerformanceTable.tsx`

Added gradient styling for CAM/CSE badge:

```typescript
const roleStyles = {
  CSE: 'bg-blue-100 text-blue-700 border border-blue-200',
  CAM: 'bg-purple-100 text-purple-700 border border-purple-200',
  'CAM/CSE': 'bg-gradient-to-r from-purple-100 to-blue-100 text-purple-700 border border-purple-200',
}
```

Added CAM/CSE filter option:

```html
<option value="CAM/CSE">CAM/CSE Only</option>
```

### 4. Compliance Dashboard
**File:** `src/app/(dashboard)/compliance/page.tsx`

Updated leaderboard and heat map data transformations to:
- Show "(CAM/CSE)" suffix for combined role users
- Show "(CAM)" suffix for CAM-only users
- Avoid duplicate entries for people with both roles
- Include profile photos in the Risk Heat Map

### 5. Summary Counts
Updated team summary to count CAM/CSE members in both CSE and CAM totals:

```typescript
const summary: TeamSummary = {
  totalCSEs: pureCSEs + combinedRoles,  // Include CAM/CSE in CSE count
  totalCAMs: pureCAMs + combinedRoles,  // Include CAM/CSE in CAM count
  // ...
}
```

---

## Files Modified

| File | Changes |
|------|---------|
| `src/types/team-performance.ts` | Added 'CAM/CSE' to TeamMemberRole union type |
| `src/app/api/team-performance/route.ts` | Combined role detection, client assignment, query filter, summary counts |
| `src/components/team-performance/CSEPerformanceTable.tsx` | RoleBadge styling, filter dropdown |
| `src/app/(dashboard)/compliance/page.tsx` | Leaderboard data, heat map data with photos |
| `src/components/compliance/EnhancedManagerDashboard.tsx` | Heat map photo support |

---

## Testing Verification

- [x] TypeScript compilation passes (`npx tsc --noEmit`)
- [x] Nikki Wei displays as "Nikki Wei (CAM/CSE)" in leaderboard
- [x] Anu (Anupama Pradhan) appears on leaderboard as "(CAM)"
- [x] Risk Heat Map shows profile photos for CSEs and CAMs
- [x] No duplicate entries for combined role users
- [x] Team Performance table shows CAM/CSE badge with gradient styling
- [x] Role filter includes CAM/CSE option

---

## Database Context

Current role values in `cse_profiles` table:
- `Nikki Wei`: role = "CSE & CAM", region = "Asia"
- `Anupama Pradhan`: role = "CAM", region = "ANZ"

No database changes required - solution handles existing data format.
