# Bug Report: Actions Page Invalid Date Error

**Date:** 22 December 2025
**Severity:** High
**Status:** Fixed
**Component:** Actions Page (`/actions`)

## Problem

The Actions page was crashing with a runtime error:

```
RangeError: Invalid time value
at Date.toISOString (<anonymous>:null:null)
at eval (...actions/page.tsx):161:69)
at groupSimilarActions (...)
```

## Root Cause

The `groupSimilarActions` function in `src/app/(dashboard)/actions/page.tsx` was calling `new Date(a.dueDate).toISOString()` without validating that `dueDate` was a valid date value.

When `dueDate` is `null`, `undefined`, or an invalid string:

1. `new Date(a.dueDate).getTime()` returns `NaN`
2. `Math.min(...dueDates)` with any `NaN` values returns `NaN`
3. `new Date(NaN).toISOString()` throws `RangeError: Invalid time value`

## Solution

Added proper date validation in three locations:

### 1. `groupSimilarActions` - Date Calculation (lines 145-150)

**Before:**

```typescript
const dueDates = groupActions.map(a => new Date(a.dueDate).getTime())
const earliestDueDate = new Date(Math.min(...dueDates)).toISOString()
```

**After:**

```typescript
const dueDates = groupActions
  .map(a => (a.dueDate ? new Date(a.dueDate).getTime() : NaN))
  .filter(t => !isNaN(t))
const earliestDueDate =
  dueDates.length > 0 ? new Date(Math.min(...dueDates)).toISOString() : new Date().toISOString() // Fallback to now if no valid dates
```

### 2. `groupSimilarActions` - Overdue Check (lines 152-158)

**Before:**

```typescript
const hasOverdue = groupActions.some(a => {
  const dueDate = new Date(a.dueDate)
  dueDate.setHours(0, 0, 0, 0)
  return dueDate < today && a.status !== 'completed' && a.status !== 'cancelled'
})
```

**After:**

```typescript
const hasOverdue = groupActions.some(a => {
  if (!a.dueDate) return false
  const dueDate = new Date(a.dueDate)
  if (isNaN(dueDate.getTime())) return false
  dueDate.setHours(0, 0, 0, 0)
  return dueDate < today && a.status !== 'completed' && a.status !== 'cancelled'
})
```

### 3. Sort Functions (lines 174-181, 205-213)

**Before:**

```typescript
groups.sort((a, b) => {
  const aTime = new Date(a.earliestDueDate).getTime()
  const bTime = new Date(b.earliestDueDate).getTime()
  return sortDirection === 'desc' ? bTime - aTime : aTime - bTime
})
```

**After:**

```typescript
groups.sort((a, b) => {
  const aTime = a.earliestDueDate ? new Date(a.earliestDueDate).getTime() : 0
  const bTime = b.earliestDueDate ? new Date(b.earliestDueDate).getTime() : 0
  if (isNaN(aTime) && isNaN(bTime)) return 0
  if (isNaN(aTime)) return 1
  if (isNaN(bTime)) return -1
  return sortDirection === 'desc' ? bTime - aTime : aTime - bTime
})
```

## Files Changed

- `src/app/(dashboard)/actions/page.tsx` - Added null/invalid date handling

## Verification

- Build passes: `npm run build` completes successfully
- Actions page no longer crashes when actions have missing or invalid due dates

## Prevention

When working with dates from database fields that may be nullable:

1. Always check for null/undefined before creating Date objects
2. Validate Date objects with `isNaN(date.getTime())` before calling methods like `toISOString()`
3. Provide sensible fallbacks for sorting and display purposes
