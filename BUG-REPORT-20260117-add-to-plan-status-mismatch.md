# Bug Report: Add to Plan Action Status Mismatch

**Date:** 17 January 2026
**Status:** Fixed
**Commit:** 1827ec49

## Issue Description

When adding an insight to an existing plan using the "Add to Plan" workflow, navigating to the Actions step in the plan wizard caused a runtime TypeError:

```
TypeError: Cannot read properties of undefined (reading 'icon')
at ActionNarrativeStep.tsx:530
```

The page would crash and display an error overlay instead of the Actions list.

## Root Cause

The `AddToPlanModal.tsx` was setting `status: 'pending'` when transforming an insight to an action:

```typescript
// AddToPlanModal.tsx line 187
status: 'pending' as const,
```

However, the `STATUS_CONFIG` in `ActionNarrativeStep.tsx` only supports three status values:
- `not_started`
- `in_progress`
- `completed`

When the action was loaded with `status: 'pending'`, the lookup `STATUS_CONFIG[action.status]` returned `undefined`, causing the subsequent `.icon` access to throw a TypeError.

## Solution

### 1. Fixed the status value in AddToPlanModal

Changed from `'pending'` to `'not_started'` to match the expected values:

```typescript
// Before
status: 'pending' as const,

// After
status: 'not_started' as const,
```

### 2. Added defensive fallbacks in ActionNarrativeStep

Added fallback values when looking up configs to prevent crashes from invalid data:

```typescript
// Before
const priorityConfig = PRIORITY_CONFIG[action.priority]
const statusConfig = STATUS_CONFIG[action.status]

// After
const priorityConfig = PRIORITY_CONFIG[action.priority] || PRIORITY_CONFIG.medium
const statusConfig = STATUS_CONFIG[action.status] || STATUS_CONFIG.not_started
```

## Files Modified

- `/src/components/planning/AddToPlanModal.tsx` (line 187)
- `/src/app/(dashboard)/planning/strategic/new/steps/ActionNarrativeStep.tsx` (lines 528-529)

## Testing Performed

1. Added an insight to a plan using "Add to Plan" workflow
2. Navigated to the plan's Actions step
3. Verified the action displays correctly without errors
4. Verified the status shows as "Not Started" in the UI
5. Build passes: `npm run build` - Zero TypeScript errors

## Lessons Learned

- Always verify that status/enum values match between components that share data
- Add defensive fallbacks when accessing config objects with dynamic keys
- Test the full user flow after making changes to data transformation logic
