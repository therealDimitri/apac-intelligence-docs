# Bug Report: Unknown Client in Priority Matrix Assignments

## Date

15 December 2025

## Issue Summary

When assigning items from the Priority Matrix, the created action would display "Unknown Client" instead of the actual client name, even though the Priority Matrix item contained valid client data.

## Root Cause

Priority Matrix items store client data in two different formats depending on the item type:

- **Single-client items**: Use `item.client` (string)
- **Multi-client items** (e.g., compliance events): Use `item.clients` (string array)

The `handleAssign` function in `ActionableIntelligenceDashboard.tsx` was only checking `item.client`, which returned `undefined` for multi-client items, causing the API to receive `null` as the client value.

## Files Affected

- `src/components/ActionableIntelligenceDashboard.tsx` (line 932)

## Fix Applied

Updated the `handleAssign` callback to check both client data formats:

```typescript
// Before (broken)
const clientName = item.client

// After (fixed)
const clientName = item.client || (item.clients && item.clients.length > 0 ? item.clients[0] : null)
```

This ensures:

1. Single-client items use `item.client`
2. Multi-client items use the first client from `item.clients` array
3. Falls back to `null` only if neither is available

## Related Changes

During this fix, the following related improvements were also made:

### API Route Updates (`/api/assignment/route.ts`)

- Added `generateActionId()` function for creating new actions
- Extended Zod schema to accept nullable client, dueDate, and priority fields
- Added `createIfNotFound` parameter to create actions when Priority Matrix ID doesn't exist in database
- Fixed `assignedByEmail` validation to allow empty strings

### Bulk Assignment Updates (`/api/assignment/bulk/route.ts`)

- Added action record creation in the `actions` table
- Added notification status tracking in API response
- Assignment metadata stored in Notes field for tracking

### New Components

- `AssignmentToast.tsx` - Provides visual feedback on assignment success/failure and notification status

## Testing

1. TypeScript compilation: Passed with no errors
2. Verification: `handleAssign` now correctly extracts client name from both `client` and `clients` fields

## Prevention

The Priority Matrix item types should document the dual client data structure clearly. Consider standardising to always use `clients` array for consistency.

## Related Documentation

- `docs/database-schema.md` - Actions table schema
- `src/components/priority-matrix/types.ts` - MatrixItem type definition
