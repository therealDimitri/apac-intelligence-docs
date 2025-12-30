# Feature: Client Multi-Select with Checkboxes

**Date:** 30 December 2025
**Type:** Enhancement
**Status:** Implemented

## Summary

Created a reusable `ClientMultiSelect` component with checkbox-based multi-selection and applied it to both `CreateActionModal` and `EditActionModal`. Also updated the Owners field in `EditActionModal` to use MS Graph People Search.

## Features

### ClientMultiSelect Component

A new reusable component (`src/components/ClientMultiSelect.tsx`) with:

- **Checkbox-based selection** - Each client shows a checkbox, staying selected when clicked
- **Dropdown stays open** - Enables selecting multiple items without reopening
- **Selected items as pills** - Visual tags above the input showing selected clients
- **Search filtering** - Type to filter the client list
- **"Internal" option** - Special option at top for non-client work
- **Segment badges** - Shows client segment (Maintain, Leverage, etc.) next to each name
- **Custom entry** - Press Enter to add custom client names not in the list

### Component Props

```typescript
interface ClientMultiSelectProps {
  value: string[]               // Selected client names
  onChange: (clients: string[]) => void
  placeholder?: string
  disabled?: boolean
  includeInternal?: boolean     // Show "Internal" option (default: true)
}
```

## Files Modified

| File | Changes |
|------|---------|
| `src/components/ClientMultiSelect.tsx` | **NEW** - Reusable multi-select component |
| `src/components/CreateActionModal.tsx` | Replaced client dropdown with ClientMultiSelect |
| `src/components/EditActionModal.tsx` | Replaced client dropdown with ClientMultiSelect, owners with PeopleSearchInput |

## Code Removed

From both modals:
- Client dropdown state (`showClientDropdown`, `clientSearchTerm`, refs)
- Client click-outside effect handlers
- Client filter and handler functions (`filteredClients`, `handleClientSelect`, `removeClient`, etc.)
- Manual client dropdown UI (input, dropdown list)

From EditActionModal:
- Owner dropdown state and handlers (now uses `PeopleSearchInput`)
- `useOwnersDropdown` hook import
- `useClients` hook import (now encapsulated in ClientMultiSelect)

## User Experience

### Before
- Clicking a client in dropdown added it and closed the dropdown
- Had to reopen dropdown to select additional clients
- No visual indication of selection state in dropdown

### After
- Clicking a client toggles its checkbox
- Dropdown stays open for multiple selections
- Clear visual feedback with checkmarks and highlighted rows
- Selected items clearly visible as pills above input
- "Internal" option prominently displayed at top

## Usage Example

```tsx
<ClientMultiSelect
  value={formData.clients}
  onChange={clients => setFormData(prev => ({ ...prev, clients }))}
  placeholder="Search or select clients..."
  includeInternal={true}
/>
```

## Testing

1. Open Create Action modal
2. Click on the Clients field
3. Verify:
   - "Internal" option appears at top with checkbox
   - Client list shows with checkboxes
   - Clicking a client toggles the checkbox (doesn't close dropdown)
   - Selected clients appear as blue pills above input
   - Search filters the list
   - Segment badges appear next to client names
   - Can remove selected clients by clicking X on pills
   - Typing and pressing Enter adds custom client names
