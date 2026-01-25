# Bug Report: User Management Page - Photos, Client Counts, and CAM Assignments

**Date**: 2026-01-25
**Status**: Fixed
**Commit**: 777928ac

## Issues Reported

1. **Profile photos not displaying** - User avatar icons shown instead of actual photos
2. **Clients assigned showing 0** - All CSE/CAM users showed 0 assigned clients
3. **CSE Assignments tab blank** - "No assignments found" message displayed
4. **CAM Assignments missing** - Only CSE assignments were being queried, CAMs excluded

## Root Cause Analysis

### 1. Photo URL Construction Issue

**Location**: `/src/app/api/admin/users/route.ts`

**Problem**: The `photo_url` column in `cse_profiles` table stores only the filename (e.g., `Tracey-Bland.jpeg`), not the full URL. The API was returning this raw filename, which isn't a valid image URL.

**Evidence**:
```javascript
// Database stores: "Tracey-Bland.jpeg"
// UI expected: "https://[supabase-url]/storage/v1/object/public/cse-photos/Tracey-Bland.jpeg"
```

### 2. Wrong Column Name for Assignments

**Location**: `/src/app/api/admin/users/route.ts` and `/src/app/api/admin/cse-assignments/route.ts`

**Problem**: The APIs were querying `nps_clients.cse_name` column, but the actual column is named `cse`. Similarly, the `cam` column wasn't being queried at all.

**Database Schema** (actual):
```sql
-- nps_clients table columns:
-- cse (text) - CSE assignment
-- cam (text) - CAM assignment
-- NOT cse_name or cam_name
```

**Incorrect Query**:
```javascript
// WRONG - column doesn't exist
const { data } = await supabase.from('nps_clients').select('cse_name')
```

**Correct Query**:
```javascript
// CORRECT - matches actual column names
const { data } = await supabase.from('nps_clients').select('cse, cam')
```

## Fixes Applied

### Fix 1: Photo URL Construction (users/route.ts)

Added helper function to construct full Supabase storage URL:

```typescript
const buildPhotoUrl = (photoUrl: string | null): string | null => {
  if (!photoUrl) return null
  if (photoUrl.startsWith('http://') || photoUrl.startsWith('https://')) return photoUrl
  const filename = photoUrl.startsWith('/') ? photoUrl.substring(1) : photoUrl
  return `${process.env.NEXT_PUBLIC_SUPABASE_URL}/storage/v1/object/public/cse-photos/${filename}`
}
```

### Fix 2: Correct Column Names (users/route.ts)

Changed assignment count query to use correct column names:

```typescript
// Before
const { data: assignments } = await supabase.from('nps_clients').select('cse_name')

// After
const { data: assignments } = await supabase.from('nps_clients').select('cse, cam')
```

### Fix 3: CSE Assignments API (cse-assignments/route.ts)

Updated all references from `cse_name` to `cse`:

```typescript
// Select correct columns
.select('cse, cam, client_name, client_uuid, created_at')

// Group by CSE
if (assignment.cse) { ... }

// Group by CAM (new)
if (assignment.cam) { ... }
```

### Fix 4: UI - CAM Assignments Section (users/page.tsx)

Added CAM assignments display section alongside CSE assignments:

- New `camAssignmentGroups` state
- Separate Card component for CAM-Client Assignments
- Visual distinction with blue icon for CAM vs purple for CSE

## Verification

Tested with direct database queries:

```
=== Sample User Response ===
{
  "name": "Tracey Bland",
  "role": "Client Success Executive",
  "photo_url": "https://[supabase]/storage/v1/object/public/cse-photos/Tracey-Bland.jpeg",
  "assigned_clients_count": 5  // Was 0 before fix
}

=== CSE Assignments ===
Tracey Bland: 5 clients
Laura Messing: 4 clients
Open Role: 5 clients
John Salisbury: 5 clients

=== CAM Assignments (NEW) ===
Anu Pradhan: 13 clients
Nikki Wei: 5 clients
```

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/admin/users/route.ts` | Added photo URL builder, fixed column names |
| `src/app/api/admin/cse-assignments/route.ts` | Fixed column names, added CAM grouping |
| `src/app/(dashboard)/admin/users/page.tsx` | Added CAM assignments UI section |

## Prevention

Added comments in code to prevent future confusion:

```typescript
// Note: nps_clients uses 'cse' and 'cam' columns (not 'cse_name' or 'cam_name')
```

## Related

- Similar pattern used in: `useUserProfile.ts`, `useCSEProfiles.ts`, `MentionSuggestion.tsx`
- All construct photo URLs using the same Supabase storage pattern
