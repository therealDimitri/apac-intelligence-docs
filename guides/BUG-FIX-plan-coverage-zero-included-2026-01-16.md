# Bug Fix: Plan Coverage Showing 0/21 Included

**Date:** 2026-01-16
**Severity:** High (Data Display)
**Status:** ✅ Fixed

## Problem Description

When loading an existing strategic plan, the Plan Coverage and AI Insights section showed "0/21 Included" with "$0.00M Total ACV" and "$0.00M Weighted ACV", even though 21 opportunities were present and targets were displaying correctly.

### Symptoms
| Metric | Expected | Actual (Before Fix) |
|--------|----------|---------------------|
| Included | 21/21 | 0/21 |
| Total ACV | $7.92M | $0.00M |
| Weighted ACV | $2.48M | $0.00M |
| Total ACV Target | $7.92M | $7.92M ✓ |
| Wtd ACV Target | $2.48M | $2.48M ✓ |

## Root Cause

Two issues were identified:

### Issue 1: Saved opportunities missing `selected: true`
When loading an existing plan, the saved `opportunities_data` from the database had `selected: false` or `undefined` for opportunities. This was caused by a previous bug where only focus deals were marked as selected.

**Buggy Code (Line 1233):**
```typescript
opportunities: data.opportunities_data || [],
```

The filter in `OpportunityStrategyStep` excluded all opportunities where `selected === false`:
```typescript
const includedOpportunities = opportunities.filter(o => o.selected !== false)
```

### Issue 2: Fresh pipeline data overwriting saved opportunities
When `loadPortfolioForOwner` was called after loading an existing plan, it would overwrite all saved opportunities with fresh pipeline data, losing user-entered MEDDPICC scores and other user data.

**Buggy Code (Line 1815):**
```typescript
setFormData(prev => ({
  ...prev,
  opportunities: preSelectedOpps, // Always replaces with fresh data
}))
```

## Solution

### Fix 1: Ensure all loaded opportunities are selected by default
Changed line 1233 to map all loaded opportunities with `selected: true`:

```typescript
// Before
opportunities: data.opportunities_data || [],

// After
opportunities: (data.opportunities_data || []).map(
  (o: PipelineOpportunity) => ({ ...o, selected: true })
),
```

### Fix 2: Preserve existing opportunities when loading existing plan
Modified `loadPortfolioForOwner` to check if opportunities already exist before replacing:

```typescript
// Before
setFormData(prev => ({
  ...prev,
  opportunities: preSelectedOpps,
}))

// After
setFormData(prev => {
  // If we already have opportunities saved (loading existing plan), keep them
  // to preserve user data like MEDDPICC scores. Only replace with fresh pipeline
  // data if we're selecting a new owner (prev.opportunities is empty).
  const shouldKeepExistingOpportunities = prev.opportunities.length > 0

  return {
    ...prev,
    opportunities: shouldKeepExistingOpportunities ? prev.opportunities : preSelectedOpps,
  }
})
```

## Files Modified

1. **`src/app/(dashboard)/planning/strategic/new/page.tsx`**
   - Line 1233: Added `.map()` to ensure all loaded opportunities have `selected: true`
   - Lines 1803-1826: Modified `loadPortfolioForOwner` to preserve existing opportunities

## Verification

```bash
# Build passes
npm run build

# Test steps:
# 1. Navigate to /planning
# 2. Edit an existing strategic plan
# 3. Go to Step 4 (Opportunity Strategy)
# 4. Verify Plan Coverage shows all opportunities as Included
# 5. Verify Total ACV and Weighted ACV values are correct
```

## Results

| Metric | Before Fix | After Fix |
|--------|------------|-----------|
| Included | 0/21 | 21/21 |
| Total ACV | $0.00M | $7.92M |
| Weighted ACV | $0.00M | $2.48M |
| MEDDPICC Scores | Lost on reload | Preserved |

## Related

- `OpportunityStrategyStep.tsx` - Component calculating included opportunities
- `PipelineOpportunity` interface - `selected` property
- Previous fix: `BUG-FIX-trend-calculation-relative-dates-2026-01-16.md`
