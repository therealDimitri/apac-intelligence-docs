# Bug Fix: Team Tab Display and Client Portfolio Filter

**Date:** 2026-01-10
**Severity:** Medium
**Status:** Resolved

## Summary

Two issues were identified in the Client Profiles section:
1. CAM members in Team tab were showing "Regional Account Manager" instead of meaningful last contact information
2. Client Portfolio filter was labelled "All CSEs" and only included CSE names, excluding CAMs

## Root Cause Analysis

### Issue 1: Team Tab Display

**Problem:** In `RightColumn.tsx`, the CAM member's `lastContact` field was hardcoded to the string "Regional Account Manager" instead of using the calculated last contact date based on meeting data.

**Location:** `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx:378`

**Before:**
```typescript
if (camName) {
  members.push({
    name: camName,
    role: camProfile?.role || 'CAM',
    roleLabel: 'CAM',
    status: 'online' as const,
    lastContact: 'Regional Account Manager',  // Hardcoded string
  })
}
```

**After:**
```typescript
if (camName) {
  members.push({
    name: camName,
    role: camProfile?.role || 'CAM',
    roleLabel: 'CAM',
    status: 'online' as const,
    lastContact,  // Uses calculated lastContact from meeting data
  })
}
```

### Issue 2: Client Portfolio Filter

**Problem:** The filter dropdown in Client Portfolios was:
- Labelled "All CSEs" instead of "All"
- Only populated with CSE names, excluding CAM names
- Search only searched by client name and CSE name, not CAM name

**Location:** `src/app/(dashboard)/client-profiles/page.tsx`

**Changes:**
1. Changed filter label from "All CSEs" to "All"
2. Renamed `uniqueCSEs` to `uniqueTeamMembers` and included both CSE and CAM names
3. Updated filter logic to match clients by either `cse_name` or `cam_name`
4. Updated search placeholder from "Search clients or CSE..." to "Search clients, CSE or CAM..."
5. Updated search logic to include CAM name in search results

## Files Changed

### 1. `src/app/(dashboard)/clients/[clientId]/components/v2/RightColumn.tsx`
- Fixed CAM member `lastContact` to use calculated value instead of hardcoded string

### 2. `src/app/(dashboard)/client-profiles/page.tsx`
- Changed filter dropdown option from "All CSEs" to "All"
- Renamed `uniqueCSEs` to `uniqueTeamMembers` including both CSE and CAM names
- Updated filter logic: `client.cse_name === selectedCSE || client.cam_name === selectedCSE`
- Updated search placeholder text
- Updated search filter to include `client.cam_name?.toLowerCase().includes(search)`

## Testing

1. Loaded a client profile with both CSE and CAM assigned
2. Verified Team tab shows calculated last contact for both CSE and CAM
3. Verified Client Portfolios filter shows "All" as default option
4. Verified dropdown includes both CSE and CAM names
5. Verified filtering by CAM name shows correct clients
6. Verified search finds clients by CAM name

## Impact

- **Equity:** Dashboard now treats CSEs and CAMs equally as client partners
- **User Experience:** Team tab shows meaningful last contact information for all team members
- **Searchability:** Users can now search and filter by CAM name in Client Portfolios

## Related

- Previous fix: BUG-FIX-client-portfolios-cam-and-placeholder.md (CAM name resolution and placeholder photos)
