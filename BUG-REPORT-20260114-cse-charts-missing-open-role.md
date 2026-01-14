# Bug Report: Open Role Missing from CSE Performance Charts

## Date
14 January 2026

## Severity
Medium - Data visibility issue

## Summary
The "Open Role" CSE was not appearing in the CSE Performance bar charts on the aging-accounts compliance page, causing incomplete data representation.

## Root Cause
In `ExecutiveView.tsx` at line 455, "Open Role" was explicitly excluded from the CSE Performance charts by the `excludedCSENames` filter array:

```typescript
const excludedCSENames = ['Unassigned', 'Open Role']
```

This filter was applied to both `complianceByCSE` and `complianceUnder90ByCSE` data arrays that feed the bar charts.

## Impact
- The "% Under 60 Days" and "% Under 90 Days" CSE Performance bar charts were missing "Open Role" data
- Users could not see compliance metrics for clients assigned to Open Role positions
- This created an incomplete picture of overall compliance status

## Fix Applied
Removed 'Open Role' from the exclusion list while keeping 'Unassigned' filtered:

**Before:**
```typescript
const excludedCSENames = ['Unassigned', 'Open Role']
```

**After:**
```typescript
const excludedCSENames = ['Unassigned']
```

## Files Modified
- `src/app/(dashboard)/aging-accounts/compliance/components/ExecutiveView.tsx` (line 455)

## Verification
- Build passes successfully
- Open Role now appears in CSE Performance charts

## Commit
`d0215c92` - fix: include Open Role in CSE Performance charts

## Lessons Learned
- When filtering data from visualisations, consider whether placeholder names like "Open Role" may actually contain meaningful data
- "Unassigned" typically represents unprocessed or orphaned data, while "Open Role" represents actual workload that needs visibility
