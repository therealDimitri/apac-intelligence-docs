# Bug Report: Stale Client Assignments in Priority Matrix

**Date:** 2025-12-31
**Severity:** Medium
**Status:** Fixed

## Issue Description

CSE assignments in the Priority Matrix would persist even after the underlying compliance event changed to have different clients. For example, when an event originally had "WA Health" and "Department of Health - Victoria" as clients, the CSE assignments for these clients would remain in the database even after the event was updated to have "SingHealth" and "WA Health" instead. This caused incorrect CSE names (like "Tracey Bland") to display on items they were no longer assigned to.

## Root Cause

The `priority_matrix_assignments` table stores client-to-CSE mappings in a JSONB column called `client_assignments`. When compliance events were updated with different clients, the old client assignments were never cleaned up. The system would continue displaying owners based on stale data.

## Solution

Implemented automatic cleanup of stale client assignments in `MatrixContext.tsx`:

1. **Added `cleanupStaleClientAssignments` function** that:
   - Compares currently assigned clients against actual clients in the item
   - Identifies clients that no longer exist in the item
   - Removes stale assignments from both localStorage and database
   - Updates the owner display text accordingly

2. **Scheduled cleanup in `applyPersistedData`**:
   - Runs asynchronously after data loads via `setTimeout`
   - Processes all items in the matrix
   - Case-insensitive client name comparison

## Files Modified

- `src/components/priority-matrix/MatrixContext.tsx`

## Testing

1. View Priority Matrix with items having client assignments
2. Update the underlying compliance event to have different clients
3. Refresh the page
4. Verify old client assignments are automatically removed
5. Verify correct CSEs are now displayed

## Prevention

This fix ensures data consistency by automatically cleaning up orphaned assignments when the source data changes. Future consideration: add a database trigger to handle this cleanup at the database level for even more robustness.
