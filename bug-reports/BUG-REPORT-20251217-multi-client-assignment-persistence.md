# Bug Report: Multi-Client Assignment Modal Not Persisting Assignments

**Date:** 17 December 2025
**Severity:** High
**Status:** RESOLVED

## Problem Summary

The Multi-Client Assignment Modal was not properly persisting assignments when:

1. Different CSEs were assigned to different clients (resulting in "X CSEs" owner label)
2. Users changed assignments from one CSE to another

When reopening the modal, it would show "0 of 9 assigned" instead of the previously saved assignments.

## Root Cause Analysis

The issue had two components:

### Issue 1: "X CSEs" Pattern Not Matching Team Members

When multiple different CSEs were assigned to different clients, the system stored an aggregate label like "2 CSEs" or "3 CSEs" as the owner. When the modal reopened:

1. `existingOwner` would be "2 CSEs"
2. The code tried to find a team member matching "2 CSEs": `allTeamMembers.find(m => m.name.toLowerCase() === "2 cses")`
3. No match was found, so `existingAssignee` was `null`
4. All clients were initialised with `null` assignments
5. Modal displayed "0 of 9 assigned"

### Issue 2: Per-Client Assignments Not Persisted

The system only stored the aggregate "owner" label for the matrix item, not the individual per-client assignments. This meant:

- Individual client-to-CSE mappings were lost between modal sessions
- When reopening the modal, the system couldn't reconstruct which CSE was assigned to which client

## Files Modified

### 1. `src/components/priority-matrix/MatrixContext.tsx`

Added per-client assignment storage functions:

```typescript
// New storage key
const STORAGE_KEY_CLIENT_ASSIGNMENTS = 'priority-matrix-client-assignments'

// New exported functions
export function loadPersistedClientAssignments(): ClientAssignmentsMap
export function saveClientAssignments(itemId: string, assignments: Record<string, string>)
export function getItemClientAssignments(itemId: string): Record<string, string>
```

### 2. `src/components/priority-matrix/index.ts`

Exported the new functions:

```typescript
export {
  MatrixProvider,
  useMatrix,
  saveClientAssignments,
  getItemClientAssignments,
} from './MatrixContext'
```

### 3. `src/components/ActionableIntelligenceDashboard.tsx`

**Import changes:**

```typescript
import {
  PriorityMatrix,
  MatrixProvider,
  useMatrix,
  saveClientAssignments,
  getItemClientAssignments,
} from './priority-matrix'
```

**Save per-client assignments on submit:**

```typescript
// Save per-client assignments to localStorage for persistence
const clientAssignmentsMap: Record<string, string> = {}
results
  .filter(r => r.success)
  .forEach(r => {
    clientAssignmentsMap[r.clientName] = r.assigneeName
  })
saveClientAssignments(multiClientModal.item.id, clientAssignmentsMap)
```

**Pass saved assignments to modal:**

```typescript
<MultiClientAssignmentModal
  // ... other props
  savedClientAssignments={
    multiClientModal.item ? getItemClientAssignments(multiClientModal.item.id) : undefined
  }
/>
```

### 4. `src/components/assignment/MultiClientAssignmentModal.tsx`

**Added new prop:**

```typescript
interface MultiClientAssignmentModalProps {
  // ... existing props
  /** Saved per-client assignments from localStorage (takes priority over existingOwner) */
  savedClientAssignments?: Record<string, string>
}
```

**Updated initialisation logic:**

```typescript
// Priority 1: Use saved per-client assignments if available
if (savedClientAssignments && Object.keys(savedClientAssignments).length > 0) {
  clients.forEach(client => {
    const savedAssigneeName = savedClientAssignments[client]
    if (savedAssigneeName) {
      const assignee =
        allTeamMembers.find(m => m.name.toLowerCase() === savedAssigneeName.toLowerCase()) || null
      initialAssignments.set(client, assignee)
    }
  })
  // If all clients have the same assignee, set bulk assignee
} else {
  // Priority 2: Fall back to existingOwner (only for actual names, not "X CSEs")
  if (existingOwner && !existingOwner.match(/^\d+\s+CSEs?$/i)) {
    // Use existingOwner logic
  }
}
```

## Verification Steps

1. Build passes: `npm run build` ✓
2. Assign multiple clients to the same CSE → Reopen modal → Shows all assigned ✓
3. Assign different clients to different CSEs → Reopen modal → Shows individual assignments ✓
4. Change assignment from one CSE to another → Reopen modal → Shows new assignment ✓

## localStorage Data Structure

New storage key: `priority-matrix-client-assignments`

Format:

```json
{
  "segmentation-event-xyz": {
    "Client A": "John Salisbury",
    "Client B": "BoonTeck Lim",
    "Client C": "John Salisbury"
  },
  "nps-alert-abc": {
    "Client X": "John Salisbury"
  }
}
```

## Related Issues

This fix is part of a series of Priority Matrix persistence improvements:

- `BUG-REPORT-20251217-priority-matrix-badge-persistence.md` - Initial badge persistence fix
- Name inconsistency fix (Jonathan vs John Salisbury)
- "X CSEs" filter exclusion fix

## Lessons Learned

1. When storing aggregate labels (like "X CSEs"), ensure the system can still reconstruct individual data
2. Per-entity storage is more robust than aggregate labels for multi-selection scenarios
3. Always handle edge cases where stored data doesn't match lookup dictionaries
