# Bug Report: Invalid Date in Unified Actions System

**Date:** 30 December 2025
**Status:** Fixed
**Severity:** High (Runtime crash)

---

## Error Details

### Error Type
`RangeError: Invalid time value`

### Error Message
```
at Date.toISOString (<anonymous>:null:null)
at useUnifiedActions.useCallback[toLegacyActions]
```

### Affected Components
- `useUnifiedActions` hook
- `useActions` hook (wrapper)
- `ActionableIntelligenceDashboard` component
- Any component using `useActions`

---

## Root Cause

The `toLegacyActions()` function in `useUnifiedActions.ts` was calling `toISOString()` on Date objects without validating they were valid dates. When the database contained malformed date strings that couldn't be parsed, the `parseDDMMYYYY()` function was returning `Invalid Date` objects, which then caused crashes when `toISOString()` was called.

### Code Path
1. Database record with malformed `Due_Date` value
2. `parseDDMMYYYY()` attempts to parse → returns `Invalid Date`
3. `transformRecord()` stores invalid Date in `dueDate` field
4. `toLegacyActions()` calls `action.dueDate.toISOString()` → **CRASH**

---

## Fix Applied

### 1. `toLegacyActions()` - Safety Check (src/hooks/useUnifiedActions.ts)

```typescript
// Before (vulnerable)
dueDate: action.dueDate.toISOString(),

// After (safe)
let dueDateStr: string
try {
  dueDateStr = action.dueDate instanceof Date && !isNaN(action.dueDate.getTime())
    ? action.dueDate.toISOString()
    : new Date().toISOString() // Fallback to today if invalid
} catch {
  dueDateStr = new Date().toISOString()
}
```

### 2. `parseDDMMYYYY()` - Improved Validation (src/types/unified-actions.ts)

```typescript
// Before (could return Invalid Date)
return new Date(dateStr)

// After (always returns valid date)
result = new Date(dateStr)
if (!isNaN(result.getTime())) return result

// Fallback to today if all parsing fails
console.warn(`[parseDDMMYYYY] Could not parse date: "${dateStr}", using today's date`)
return new Date()
```

---

## Prevention

1. **Always validate Date objects** before calling `toISOString()` or other Date methods
2. **Use `isNaN(date.getTime())`** to check if a Date is valid
3. **Provide fallbacks** for date parsing functions
4. **Log warnings** when fallbacks are used to identify data quality issues

---

## Testing Verification

- TypeScript compilation: Passes
- Runtime: No longer crashes on pages using `useActions`
- Fallback behaviour: Invalid dates default to today's date

---

## Related Commits

- `e7b1291` - fix: Handle invalid dates in unified actions system
