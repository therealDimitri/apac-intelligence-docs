# Bug Report: Add to Plan API Not Saving Client Field

**Date**: 17 January 2026
**Severity**: Medium
**Status**: Fixed
**Affected Areas**: Add to Plan workflow, Strategic Plan Actions API

---

## Summary

When adding an action from Planning Insights via the "Add to Plan" modal, the client name was not being saved to the database. Actions would display without the client context, showing only the owner name.

---

## Root Causes

### 1. API Interface Missing Client Field
**File**: `src/app/api/planning/strategic/[id]/actions/route.ts`
**Lines**: 17-31

The `ActionInput` interface was missing the `client` field entirely:

```typescript
// Before (missing client)
interface ActionInput {
  id: string
  description: string  // Also wrong - expected 'action'
  owner?: string
  // ... no client field
}
```

### 2. Wrong Field Name Expected
**File**: `src/app/api/planning/strategic/[id]/actions/route.ts`

The API expected `description` but `AddToPlanModal` was sending `action`:

```typescript
// AddToPlanModal sends:
{ action: insight.recommendation, client: insight.clientName, ... }

// API expected:
{ description: '...' }  // Wrong field name!
```

### 3. Client Field Not Saved
When building `newAction`, the API only copied specific fields and `client` was omitted.

---

## Solution

### Updated ActionInput Interface
```typescript
interface ActionInput {
  id: string
  action?: string // Primary field name
  description?: string // Legacy field name (fallback)
  client?: string // Client context for the action
  owner?: string
  dueDate?: string | null
  priority?: 'high' | 'medium' | 'low' | 'critical'
  status?: 'pending' | 'in_progress' | 'completed' | 'not_started'
  notes?: string
  createdAt?: string
  updatedAt?: string
  ai_suggested?: boolean
  category?: string
}
```

### Updated Validation
```typescript
// Accept either 'action' or 'description' field
const actionText = body.action?.action || body.action?.description
if (!body.action || !actionText) {
  return NextResponse.json(
    { success: false, error: 'Action with action text or description is required' },
    { status: 400 }
  )
}
```

### Updated Action Creation
```typescript
const newAction: ActionInput = {
  id: body.action.id || `action-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
  action: actionText, // Use the resolved action text
  client: body.action.client || '', // Include client context
  owner: body.action.owner || '',
  // ... rest of fields
}
```

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/api/planning/strategic/[id]/actions/route.ts` | Added `client` field, accept both `action` and `description`, normalise status |

---

## Verification Steps

1. Navigate to Planning Hub → Planning Coach tab
2. Expand a client with insights (e.g., Epworth Healthcare)
3. Expand an insight and click "Add to Plan"
4. Confirm adding to an existing plan
5. Navigate to the plan's Actions step
6. Verify the new action shows the client name in indigo text

---

## Before/After Comparison

**Before fix:**
```
Schedule NPS follow-up call...
John Salisbury • No due date
```

**After fix:**
```
Schedule NPS follow-up call...
Epworth Healthcare • John Salisbury • 30/01/2026
```

---

## Related Commits

- `[pending]` - Fix Add to Plan API to save client field

---

## Prevention

To prevent similar issues:
1. Ensure API interfaces match the data being sent from frontend components
2. Use TypeScript strict mode to catch missing fields
3. Add integration tests for AddToPlanModal → API → ActionNarrativeStep data flow
4. Log incoming request body during development to verify field names match
