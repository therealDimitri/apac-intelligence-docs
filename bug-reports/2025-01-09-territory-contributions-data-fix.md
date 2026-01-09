# Bug Report: Territory Contributions Data Display Fix

**Date:** 2025-01-09
**Severity:** Medium
**Status:** Resolved
**Commit:** e42dd6b4

## Summary

Two issues were identified and fixed:
1. Territory Contributions table showing $0 for all Current and Target values
2. React duplicate key warning in territory/new page

## Issue 1: Territory Contributions Data Not Displaying

### Problem

The Territory Contributions table on the APAC Planning Command Centre page (`/planning/apac`) displayed $0 for all Current, Target, and Gap columns despite data existing in the database.

### Root Cause

The `buData` array was being built using stale React state values (`financials.currentRevenue`, `financials.targetRevenue`, `financials.totalGap`) instead of the freshly fetched data.

**The problematic code:**
```typescript
// Line 283-341 (BEFORE fix)
// This was OUTSIDE the if block, using stale state
const buData: BUContribution[] = [
  {
    id: 'au-vic',
    name: 'Australia - Victoria',
    currentRevenue: (financials.currentRevenue || 0) * 0.35, // Still zeros!
    // ...
  }
]
```

React state updates (`setFinancials`) are asynchronous. When `setBuContributions(buData)` was called, `financials` still contained the initial state (all zeros) because the state update hadn't been processed yet.

### Solution

Moved the territory data construction inside the `if (executiveSummary.data)` block and used local variables instead of state:

```typescript
// NOW inside the if block, using local variables
const currentRevenue = exec.total_arr || 0
const buData: BUContribution[] = [
  {
    id: 'au-vic',
    name: 'Australia - Victoria',
    currentRevenue: currentRevenue * 0.35,  // Uses fresh data
    targetRevenue: growthTarget * 0.35,     // Uses fresh data
    gap: gap * 0.35,                        // Uses fresh data
    // ...
  }
]
```

### Files Modified

- `src/app/(dashboard)/planning/apac/page.tsx`

## Issue 2: React Duplicate Key Warning

### Problem

Console warning: "Encountered two children with the same key `a3000000-0000-0000-0000-000000000001`" in the territory planning wizard.

### Root Cause

Multiple clients were resolving to the same `clientRecord` during lookups (aliased clients mapping to the same canonical entry), resulting in duplicate IDs in the portfolio list.

### Solution

Changed the React key from `client.id` to a composite key `${client.id}-${idx}`:

```typescript
// BEFORE
<tr key={client.id} className="hover:bg-gray-50">

// AFTER
<tr key={`${client.id}-${idx}`} className="hover:bg-gray-50">
```

### Files Modified

- `src/app/(dashboard)/planning/territory/new/page.tsx`

## Additional Change: Rename

- Renamed "Business Unit Contributions" to "Territory Contributions"
- Updated header, subtitle, and column header in `BUContributionsTable.tsx`

### Files Modified

- `src/components/planning/BUContributionsTable.tsx`

## Testing Verification

- [x] Build passes without TypeScript errors
- [x] Pre-commit hooks pass (ESLint, Prettier, TypeScript)
- [x] Territory Contributions should now display actual revenue data
- [x] No duplicate key warnings in console

## Lessons Learned

1. **Never rely on React state immediately after setting it** - state updates are asynchronous
2. **Use local variables for calculations** when building data structures that depend on freshly fetched values
3. **Always use unique keys in React lists** - when IDs may be duplicated, combine with index
