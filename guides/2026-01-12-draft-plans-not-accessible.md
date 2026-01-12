# Bug Fix: Draft Plans Not Accessible via My Plans

**Date:** 12 January 2026
**Status:** Resolved
**Type:** Bug Fix
**Severity:** High

## Summary

Draft strategic plans created via the new Strategic Planning wizard were not accessible when clicking "Continue" from the My Plans tab. Users received a "Strategy not found" error.

## Root Cause

The bug was caused by a routing mismatch between where plans were stored and where the "Continue" link directed users:

1. **Storage**: New strategic plans are saved to the `strategic_plans` table
2. **Routing**: The "Continue" link was routing to `/planning/territory/{id}`
3. **View Page**: The territory view page queries the `territory_strategies` table (a different table)

This meant plans stored in `strategic_plans` could never be found by the view page that queries `territory_strategies`.

## Technical Details

### The Problem Flow
```
User creates plan → Saved to strategic_plans table
User clicks Continue → Routes to /planning/territory/{id}
Territory view page → Queries territory_strategies table
Result → "Strategy not found" (plan is in wrong table)
```

### Files Involved
- `src/app/(dashboard)/planning/page.tsx` - Planning Hub with My Plans tab
- `src/app/(dashboard)/planning/strategic/new/page.tsx` - Strategic planning wizard
- `src/app/(dashboard)/planning/territory/[id]/page.tsx` - Territory strategy view page

## Solution

### 1. Added Plan Loading Support to Strategic Wizard

Updated `/planning/strategic/new/page.tsx` to support loading existing plans via URL parameter:

```typescript
// Added useSearchParams to read plan ID from URL
import { useRouter, useSearchParams } from 'next/navigation'

// In component:
const searchParams = useSearchParams()
const editPlanId = searchParams.get('id')

// Added useEffect to load existing plan
useEffect(() => {
  if (!editPlanId) return

  async function loadExistingPlan() {
    const { data } = await supabase
      .from('strategic_plans')
      .select('*')
      .eq('id', editPlanId)
      .single()

    // Populate formData with loaded plan data
    setFormData({
      plan_type: data.plan_type,
      owner_name: data.primary_owner,
      // ... other fields
    })

    // Auto-navigate to where user left off
    setPlanId(data.id)
  }

  loadExistingPlan()
}, [editPlanId])
```

### 2. Updated Planning Hub to Use Correct Type

Updated `/planning/page.tsx` to assign `'strategic'` type to strategic plans:

```typescript
// Before: Mapped to territory/account
type: (p.plan_type === 'territory' ? 'territory' : 'account')

// After: Uses 'strategic' type
type: 'strategic' as const
```

### 3. Updated PlanCard Link Logic

Updated the PlanCard component to handle the new `'strategic'` type:

```typescript
// Strategic plans route to wizard with edit mode
const planHref =
  type === 'strategic'
    ? `/planning/strategic/new?id=${plan.id}`
    : `/planning/${type}/${plan.id}`
```

### 4. Updated Delete Handler

Updated delete modal state and handlers to accept `'strategic'` type:

```typescript
const [deleteModal, setDeleteModal] = useState<{
  planType: 'territory' | 'account' | 'strategic' | null
}>()

const handleDeleteConfirm = async () => {
  if (deleteModal.planType === 'strategic') {
    await supabase.from('strategic_plans').delete().eq('id', planId)
  } else {
    // Delete from legacy tables
  }
}
```

## The Fixed Flow
```
User creates plan → Saved to strategic_plans table
User clicks Continue → Routes to /planning/strategic/new?id={uuid}
Strategic wizard → Loads plan from strategic_plans table
Result → Plan loads successfully, user continues editing
```

## Files Modified

1. **src/app/(dashboard)/planning/strategic/new/page.tsx**
   - Added `useSearchParams` import
   - Added `editPlanId` from URL parameter
   - Added `loadExistingPlan` effect to load plan data
   - Auto-navigates to step where user left off

2. **src/app/(dashboard)/planning/page.tsx**
   - Changed strategic plans type from `'territory'|'account'` to `'strategic'`
   - Updated `PlanCard` to handle `'strategic'` type with wizard route
   - Updated `deleteModal` state type to include `'strategic'`
   - Updated `handleDeleteRequest` and `handleDeleteConfirm` for `'strategic'` type

## Testing Performed

- [x] Build passes with zero TypeScript errors
- [x] My Plans shows all 13 draft plans
- [x] Continue button links to `/planning/strategic/new?id={uuid}`
- [x] Clicking Continue loads the plan successfully
- [x] Plan data (owner, territory, progress) is restored
- [x] Auto-navigates to step where user left off
- [x] Delete functionality works for strategic plans

## Commits

1. `fix: Draft plans now accessible via My Plans - routes to strategic wizard with edit mode`
