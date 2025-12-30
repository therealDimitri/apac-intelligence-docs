# Bug Report: Owners Dropdown Not Using MS Graph API

**Date:** 30 December 2025
**Type:** Bug Fix
**Status:** Resolved

## Summary

The Owners field in the CreateActionModal was not using MS Graph API to search for people in the organisation. Instead, it was fetching owner names from the database (existing actions table), which meant users could only select from previously-entered owners.

## Problem

- The `useOwnersDropdown` hook was fetching distinct owner names from the `actions` table
- This limited selections to people who had already been assigned to actions
- No integration with Microsoft Graph API for real-time people search
- Users could not search for new team members not already in the system

## Root Cause

The original implementation used a custom dropdown with `useOwnersDropdown` hook that queried the database:

```typescript
const { owners } = useOwnersDropdown()
// This returned: SELECT DISTINCT Owners FROM actions
```

## Solution

Replaced the custom dropdown implementation with the existing `PeopleSearchInput` component which:

1. Uses MS Graph API via `/api/organization/people`
2. Provides real-time search across the organisation
3. Shows user details (name, job title, email)
4. Supports multi-select with tags
5. Allows manual entry via Enter key if needed

## Files Modified

| File | Changes |
|------|---------|
| `src/components/CreateActionModal.tsx` | Replaced owner dropdown with PeopleSearchInput |

## Code Changes

### Before
```typescript
import { useOwnersDropdown } from '@/hooks/useOwnersDropdown'

// ... manual dropdown with filteredOwners, handleOwnerSelect, etc.
const { owners } = useOwnersDropdown()
const filteredOwners = owners.filter(...)
```

### After
```typescript
import PeopleSearchInput from '@/components/PeopleSearchInput'

// Simple integration
<PeopleSearchInput
  value={formData.owners}
  onChange={owners => setFormData(prev => ({ ...prev, owners }))}
  placeholder="Search for people in your organisation..."
/>
```

## Removed Code

- `useOwnersDropdown` hook import
- Owner dropdown state variables (`showOwnerDropdown`, `ownerSearchTerm`, `ownerInputRef`, `ownerDropdownRef`)
- Owner click-outside effect handler
- Owner handler functions (`handleOwnerSelect`, `removeOwner`, `handleOwnerInputChange`, `handleOwnerKeyDown`)
- `filteredOwners` filter logic
- Manual owner dropdown UI (pills, input, dropdown list)
- Unused `User` icon import

## Testing

1. Open Create Action modal from any location
2. Click on the Owners field
3. Type a name to search
4. Verify:
   - Search results appear from MS Graph (showing real organisation users)
   - User details shown (name, job title, email)
   - Can select multiple owners
   - Selected owners appear as tags
   - Can remove selected owners
   - Can manually type a name and press Enter if needed

## Impact

- Users can now search for any person in the organisation
- Better user experience with rich user details in search results
- Consistent with other people search components in the application
