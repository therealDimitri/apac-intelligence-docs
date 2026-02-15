# Bug Report: Add to Plan Database Column Errors

**Date**: 17 January 2026
**Status**: Fixed
**Severity**: High
**Component**: Planning Hub - Add to Plan Modal

## Summary

The "Add to Plan" modal workflow was failing with 500 errors due to references to non-existent database columns in the `strategic_plans` table.

## Symptoms

1. Opening the Add to Plan modal showed error: "column strategic_plans.client_id does not exist"
2. After initial fix, error changed to: "column strategic_plans.steps_completed does not exist"
3. After second fix, error changed to: "column strategic_plans.approved_at does not exist"
4. When attempting to add action, error: "column strategic_plans.activity_log does not exist"

## Root Cause

The API routes for strategic plans were explicitly specifying columns in SELECT statements that don't exist in the actual database schema:

1. `/api/planning/strategic/route.ts` - Listed columns including `client_id`, `steps_completed`, `approved_at`, `submitted_at`, `submitted_by`, `approved_by`
2. `/api/planning/strategic/[id]/actions/route.ts` - Referenced `activity_log` column for reading and writing

The database schema was never properly documented, and the API code assumed columns existed that were never created.

## Files Affected

| File | Issue |
|------|-------|
| `src/app/api/planning/strategic/route.ts` | Explicit column list with non-existent columns |
| `src/app/api/planning/strategic/[id]/actions/route.ts` | References to `activity_log` column |
| `src/components/planning/AddToPlanModal.tsx` | Used client_name filter parameter |

## Resolution

### 1. Strategic Plans API (`route.ts`)

Changed from explicit column selection to `select('*')`:

```typescript
// Before
let query = supabase
  .from('strategic_plans')
  .select(`
    id, plan_type, fiscal_year, primary_owner, ...,
    client_id,        // Does not exist
    steps_completed,  // Does not exist
    approved_at,      // Does not exist
    ...
  `, { count: 'exact' })

// After
let query = supabase
  .from('strategic_plans')
  .select('*', { count: 'exact' })
```

### 2. Actions API (`[id]/actions/route.ts`)

Removed `activity_log` column from select and update:

```typescript
// Before
.select('id, status, actions_data, activity_log, primary_owner')
.update({ actions_data, activity_log, updated_at })

// After
.select('id, status, actions_data, primary_owner')
.update({ actions_data, updated_at })
```

### 3. AddToPlanModal Component

Changed to fetch all plans and filter client-side:

```typescript
// Before
const response = await fetch(
  `/api/planning/strategic?client_name=${encodeURIComponent(insight.clientName)}`
)

// After
const response = await fetch('/api/planning/strategic')
// Then filter client-side
const matchingPlans = result.data.filter(plan => {
  if (plan.status === 'archived') return false
  if (plan.client_name?.toLowerCase() === insight.clientName.toLowerCase()) return true
  if (plan.plan_type === 'territory' || plan.plan_type === 'hybrid') return true
  return false
})
```

## Verification

1. Opened Planning Hub page
2. Expanded Epworth Healthcare in Strategic Planning Insights
3. Clicked "Add to Plan" button on "Detractor requires recovery plan" insight
4. Modal opened correctly showing 3 available plans
5. Selected "VIC, NZ" territory plan
6. Clicked "Add to Plan" button
7. Toast notification confirmed: "Action added to VIC, NZ"

## Lessons Learned

1. **Always verify database schema before writing queries** - The `docs/database-schema.md` file should have been checked first
2. **Use `select('*')` when column availability is uncertain** - The `[id]/route.ts` endpoint used this pattern and worked correctly
3. **The `strategic_plans` table needs to be added to schema documentation** - Currently missing from `docs/database-schema.md`

## Related Commits

- `92a3601f` - Fix database column errors in Add to Plan workflow

## Recommendations

1. Run `npm run introspect-schema` to regenerate `docs/database-schema.md` to include the `strategic_plans` table
2. Add schema validation tests for all API routes
3. Consider adding database schema verification to the CI/CD pipeline
