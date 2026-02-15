# Bug Report: Stale Coverage Data When Switching CSEs

**Date:** 11 January 2026
**Page:** `/planning/territory/new`
**Commit:** `39cdde57`
**Severity:** Medium

---

## Issue

Coverage ratio displayed the same values for all CSEs in the Territory Strategy planning page. Users reported seeing identical Wgt ACV Target ($477,337) regardless of which CSE was selected.

---

## Root Cause

When `handleCSESelect()` was called to load a new CSE's data, it correctly reset the `portfolio` to an empty array while loading. However, **targets and pipeline opportunities were not reset**.

This caused:
1. Previous CSE's targets to remain visible during async load
2. If new CSE had no targets in database, stale data persisted indefinitely
3. Coverage ratio (pipeline/target) showed incorrect values

**Affected Code (before fix):**
```typescript
// Line 380-387 - Only portfolio was reset
setFormData(prev => ({
  ...prev,
  cse_name: displayName,
  territory: cse.region || '',
  portfolio: [], // Clear portfolio while loading
  portfolioConfirmed: false,
  // targets NOT reset - bug!
}))
```

---

## Database Verification

Confirmed targets ARE correctly stored per CSE in `cse_cam_targets`:

| CSE | Q1 Wgt ACV Target |
|-----|-------------------|
| John Salisbury | $317,406.73 |
| Laura Messing | $670,072.00 |
| Tracey Bland | $477,336.69 |
| Anu Pradhan | $1,464,815.34 |
| Nikki Wei | $621,052.14 |
| Open Role | $621,052.14 |

The $477,337 value seen for all CSEs was Tracey Bland's target persisting from a previous selection.

---

## Fix Applied

Reset all CSE-specific data when switching CSEs:

```typescript
setFormData(prev => ({
  ...prev,
  cse_name: displayName,
  territory: cse.region || '',
  portfolio: [],
  portfolioConfirmed: false,
  targets: {
    quarterly: [
      { quarter: 'Q1', tcv: 0, wgtAcvTarget: 0, wgtAcvPipeline: 0, coverage: 0, confidence: 'medium' },
      { quarter: 'Q2', tcv: 0, wgtAcvTarget: 0, wgtAcvPipeline: 0, coverage: 0, confidence: 'medium' },
      { quarter: 'Q3', tcv: 0, wgtAcvTarget: 0, wgtAcvPipeline: 0, coverage: 0, confidence: 'medium' },
      { quarter: 'Q4', tcv: 0, wgtAcvTarget: 0, wgtAcvPipeline: 0, coverage: 0, confidence: 'medium' },
    ],
    pipeline: { total: 0, tcv: 0, coverage: 0, avgDealSize: 0 },
  },
}))
// Also clear pipeline opportunities
setPipelineOpportunities([])
```

---

## Testing Checklist

- [x] Build passes with zero TypeScript errors
- [ ] Select CSE A - verify unique targets load
- [ ] Switch to CSE B - verify targets reset to 0 during load, then show CSE B's values
- [ ] Switch to CSE with no targets - verify shows 0 (not previous CSE's data)
- [ ] Coverage ratio reflects correct pipeline/target for each CSE

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/planning/territory/new/page.tsx` | Reset targets and pipeline on CSE switch |

---

## Prevention

This bug highlights the importance of resetting all related state when a selection changes in React components. Consider:
1. Creating a `resetCSEData()` helper function for consistent state clearing
2. Adding unit tests for state transitions when CSE selection changes
3. Using React Query or similar for data fetching with built-in cache invalidation
