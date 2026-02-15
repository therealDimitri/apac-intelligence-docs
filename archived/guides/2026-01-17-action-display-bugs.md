# Bug Report: Action Display Issues in Account Plan Actions Step

**Date**: 17 January 2026
**Severity**: High
**Status**: Fixed
**Affected Areas**: Account Plan wizard - Actions step, AddToPlanModal

---

## Summary

Actions added to Account Plans via the "Add to Plan" modal displayed incorrectly, showing:
- Wrong owner (e.g., John Salisbury appearing in Tracey Bland's plan)
- Missing action titles/descriptions
- Unix epoch dates (31/12/1969)
- Missing client context

---

## Root Causes

### 1. Field Name Mismatch in AddToPlanModal
**File**: `src/components/planning/AddToPlanModal.tsx`
**Line**: 178-194 (transformInsightToAction function)

The modal used `description` field but `ActionNarrativeStep` expected `action`:
```typescript
// Before (incorrect)
return {
  description: insight.recommendation,  // Wrong field name
  ...
}

// After (fixed)
return {
  action: insight.recommendation,  // Correct field name
  ...
}
```

### 2. Wrong Owner Assignment
**File**: `src/components/planning/AddToPlanModal.tsx`

The owner was being set from the insight's CSE/CAM instead of the plan owner:
```typescript
// Before (incorrect)
owner: insight.cse || insight.cam || '',

// After (fixed)
owner: planOwner || insight.cse || insight.cam || '',  // Plan owner first
```

### 3. Null Due Date Causing Unix Epoch Display
**File**: `src/components/planning/AddToPlanModal.tsx`

`dueDate: null` caused `new Date(null)` to return epoch date (31/12/1969):
```typescript
// Before (incorrect)
dueDate: null,

// After (fixed)
dueDate: defaultDueDate.toISOString().split('T')[0],  // 2 weeks from now
```

### 4. Missing Client Field
**File**: `src/components/planning/AddToPlanModal.tsx`

Client name was not included when adding actions:
```typescript
// Before (missing)
// No client field

// After (fixed)
client: insight.clientName,
```

### 5. Legacy Data Not Handled
**File**: `src/app/(dashboard)/planning/strategic/new/steps/ActionNarrativeStep.tsx`

The component didn't handle legacy data that used different field names:
```typescript
// Fixed - support both formats
const actionText = action.action || (action as any).description || 'No description'
const rawStatus = action.status as string
const normalizedStatus = rawStatus === 'pending' ? 'not_started' : action.status
```

---

## Database Impact

Existing actions in `strategic_plans.actions_data` may have:
- `description` instead of `action`
- `owner` set to insight CSE/CAM instead of plan owner
- `dueDate: null`
- Missing `client` field

The component now handles these legacy formats gracefully.

---

## Files Modified

| File | Changes |
|------|---------|
| `src/components/planning/AddToPlanModal.tsx` | Fixed field names, added client, default dueDate, plan owner |
| `src/app/(dashboard)/planning/strategic/new/steps/ActionNarrativeStep.tsx` | Handle legacy data, null dates, status normalisation |
| `src/app/(dashboard)/planning/strategic/new/steps/OpportunityStrategyStep.tsx` | Updated Probability dropdown to color-coded badge style |

---

## Verification Steps

1. Navigate to Planning Hub
2. Select a Planning Insight with "Add to Plan" button
3. Select an existing plan and add the action
4. Navigate to the plan's Actions step
5. Verify:
   - Action title displays correctly (not empty)
   - Client name shows with indigo colour
   - Owner shows as plan owner
   - Due date shows 2 weeks from now (not 31/12/1969)
   - Status dropdown works correctly

---

## Related Commits

- `5ec2831e` - Fix action display issues in Account Plan Actions step

---

## Prevention

To prevent similar issues:
1. Use TypeScript strict mode to catch field mismatches
2. Add integration tests for AddToPlanModal → ActionNarrativeStep data flow
3. Validate data structure on save with schema validation
4. Add defensive handling for legacy data formats
