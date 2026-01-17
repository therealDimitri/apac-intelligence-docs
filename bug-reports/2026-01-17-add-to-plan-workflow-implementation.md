# Add to Plan Workflow Implementation

**Date:** 2026-01-17
**Type:** Feature Enhancement
**Status:** Completed
**Priority:** Medium

## Summary

Redesigned the "Create Plan" button in the Strategic Planning Insights panel to "Add to Plan" with a modal workflow that allows users to add Planning Insights as actions to existing Account Plan Actions sections.

## Problem

Previously, clicking "Create Plan" on a planning insight navigated users away from the planning page to create a new plan. This was disruptive and didn't allow users to easily add insights as actions to existing plans.

## Solution

Implemented a new workflow:

1. **Button Change**: Changed "Create Plan" to "Add to Plan" with a Plus icon (instead of ArrowRight)
2. **Modal Component**: Created `AddToPlanModal` component that:
   - Stays on the same page (modal overlay)
   - Fetches existing plans for the client
   - Shows plan selection with radio buttons
   - Displays plan status badges (draft, approved, archived)
   - Handles edge cases (no plans, disabled plans, loading/error states)
3. **API Endpoint**: Created `/api/planning/strategic/[id]/actions` to atomically append actions to plans

## Files Changed

### Created
- `/src/components/planning/AddToPlanModal.tsx` - Modal component for plan selection
- `/src/app/api/planning/strategic/[id]/actions/route.ts` - API to add actions to plans

### Modified
- `/src/app/(dashboard)/planning/page.tsx` - Updated StrategicInsightsPanel with new button and modal integration
- `/src/components/planning/index.ts` - Added export for AddToPlanModal

## Technical Details

### AddToPlanModal Component
- Fetches plans matching the insight's client name
- Shows territory/account plans that might include the client
- Transforms insight to action format:
  - `id`: Generated UUID
  - `description`: Insight recommendation
  - `owner`: CSE or CAM from insight
  - `priority`: Mapped from insight priority
  - `status`: 'pending' (default)
  - `notes`: Source info including title, category, and supporting data
  - `ai_suggested`: true (marked as AI-generated)

### API Endpoint (POST)
- Validates plan exists and is not archived/approved
- Atomically appends action to `actions_data` JSONB array
- Updates activity log with action details
- Returns updated plan with action count

### Edge Cases Handled
- **Multiple plans**: Radio button selection list
- **No plans for client**: Clear message with "Create New Plan" link
- **Archived/approved plans**: Disabled in selection with status indicator
- **Duplicate actions**: Allowed (user may want to emphasise)

## User Flow

```
1. User expands insight card in Strategic Planning Insights panel
2. Clicks "Add to Plan" button
3. Modal opens with:
   - Preview of action to be added
   - List of available plans (filtered by client)
   - Radio button selection
4. User selects plan → Clicks "Add to Plan"
5. Action appended to plan → Toast confirmation
6. Modal closes → User stays on planning page
```

## Verification

- [x] TypeScript build passes with zero errors
- [x] Existing tests pass (pre-existing failures in useUserProfile unrelated)
- [x] Button text changed from "Create Plan" to "Add to Plan"
- [x] Icon changed from ArrowRight to Plus
- [x] Modal displays correctly with plan selection
- [x] API endpoint handles action addition atomically
- [x] Toast notification shows success message
- [x] Component exported from planning index

## Screenshots

**Button Change:**
```
Before: [Create Plan →]
After:  [+ Add to Plan]
```

## Related Issues

N/A - This was a planned feature enhancement.
