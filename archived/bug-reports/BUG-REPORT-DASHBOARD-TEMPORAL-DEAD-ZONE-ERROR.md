# Bug Report: Dashboard Temporal Dead Zone Error

**Date**: 2025-11-27
**Severity**: CRITICAL
**Status**: RESOLVED
**Commits**: 6946746 (incomplete fix), 772fe1b (complete fix)

---

## Summary

The dashboard page completely broke with a runtime error: `Uncaught ReferenceError: Cannot access 'k' before initialization`. This was caused by a temporal dead zone error where helper functions were declared inside the component AFTER the hooks that referenced them.

---

## Error Details

### Console Error

```
Uncaught ReferenceError: Cannot access 'k' before initialization
    at 0f56eef714ce85d7.js:1:17163
```

### Impact

- **User Impact**: Dashboard page completely broken, unable to load
- **Scope**: All users attempting to access the dashboard (home page)
- **Business Impact**: CRITICAL - Dashboard is the landing page after login

---

## Root Cause

### Technical Explanation

In commit `c560d4a`, when implementing dynamic data for the dashboard, I added two helper functions (`formatTimeAgo` and `formatDueDate`) inside the `Home` component. However, these functions were declared AFTER the `useMemo` hooks that called them.

**Problematic Code Structure** (from broken version):

```typescript
export default function Home() {
  // ... other hooks ...

  // useMemo hooks calling formatTimeAgo and formatDueDate
  const recentActivity = useMemo(() => {
    // ... code that calls formatTimeAgo()
  }, [meetings, actions])

  const upcomingActions = useMemo(() => {
    // ... code that calls formatDueDate()
  }, [actions])

  // Helper functions declared AFTER being used above
  const formatTimeAgo = (date: Date) => {
    // ...
  }

  const formatDueDate = (dateString: string) => {
    // ...
  }

  // ... rest of component
}
```

### Why This Failed

JavaScript hoists function declarations and variable declarations, but in this case:

1. **Function expressions** (using `const formatTimeAgo = ...`) are hoisted as `undefined`
2. When `useMemo` executes during component render, it tries to call `formatTimeAgo()`
3. At that point, `formatTimeAgo` exists in memory but is still `undefined` (temporal dead zone)
4. This throws: `Cannot access 'k' before initialization` (where 'k' is the minified variable name)

### Why It Wasn't Caught Earlier

- **TypeScript compilation**: Passes because the functions are declared in the same scope
- **Development mode**: May work differently due to React's dev optimisations
- **Production build**: Minification and optimisation exposed the temporal dead zone issue

---

## Solution

### Fix Applied

Moved both helper functions OUTSIDE the component definition, before the component is exported. This ensures they are fully initialized before any hooks execute.

**Fixed Code Structure** (src/app/(dashboard)/page.tsx:21-39):

```typescript
// Helper functions defined outside component to avoid temporal dead zone
const formatTimeAgo = (date: Date) => {
  const now = new Date()
  const diffMs = now.getTime() - date.getTime()
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMs / 3600000)
  const diffDays = Math.floor(diffMs / 86400000)

  if (diffMins < 60) return `${diffMins} ${diffMins === 1 ? 'minute' : 'minutes'} ago`
  if (diffHours < 24) return `${diffHours} ${diffHours === 1 ? 'hour' : 'hours'} ago`
  return `${diffDays} ${diffDays === 1 ? 'day' : 'days'} ago`
}

const formatDueDate = (dateString: string) => {
  const date = new Date(dateString)
  const month = date.toLocaleString('default', { month: 'short' })
  const day = date.getDate()
  return `${month} ${day}`
}

export default function Home() {
  // Now useMemo hooks can safely call these functions
  // ...
}
```

### Additional Changes

- **IMPORTANT**: Initial fix (commit 6946746) moved functions outside but forgot to DELETE the duplicates inside the component
- **Second fix (commit 772fe1b)**: Removed duplicate function declarations that were inside the component (original lines 141-160)
- Functions are now module-level constants available throughout the file
- No duplicate declarations remain

---

## Files Modified

- `src/app/(dashboard)/page.tsx` - Moved helper functions outside component

---

## Testing

### Verification Steps

1. ✅ TypeScript compilation: `npx tsc --noEmit` - Clean (no errors)
2. ✅ Production build: `npm run build` - Successful
3. ✅ Dashboard loads without runtime errors

### Test Results

```bash
$ npx tsc --noEmit
# No output (success)

$ npm run build
 ✓ Compiled successfully in 1400.8ms
 ✓ Generating static pages using 13 workers (20/20) in 294.0ms
```

---

## Prevention

### Best Practices

1. **Function Declaration Order**: Always declare helper functions BEFORE using them in hooks
2. **Module-Level Utilities**: For pure utility functions, declare them outside the component
3. **Early Testing**: Test production builds during development to catch minification issues
4. **Static Analysis**: Consider ESLint rules to catch temporal dead zone issues

### Code Review Checklist

- [ ] Helper functions used in hooks are declared before the hooks
- [ ] Pure utility functions are declared outside components when possible
- [ ] Production build tested before committing significant changes
- [ ] No temporal dead zone errors in production bundle

---

## Related Issues

- Previous commit `c560d4a`: "fix: resolve 9 critical bugs across dashboard, actions, NPS, and meetings"
- This hotfix resolves regression introduced in that commit

---

## Timeline

- **2025-11-27 (commit c560d4a)**: Bug introduced during dashboard dynamic data implementation
- **2025-11-27 (user report #1)**: Critical bug reported - dashboard completely broken
- **2025-11-27 (commit 6946746)**: First hotfix attempt - moved functions outside component but forgot to remove duplicates
- **2025-11-27 (user report #2)**: Dashboard still broken - same error persisting
- **2025-11-27 (commit 772fe1b)**: Complete fix - removed duplicate function declarations from inside component

---

## Lessons Learned

1. **Component Structure Matters**: The order of declarations inside React components affects runtime behavior
2. **Production Testing**: Always test production builds, not just development mode
3. **Temporal Dead Zone**: Be aware of JavaScript's temporal dead zone with `const`/`let` declarations
4. **Helper Functions**: Consider moving pure utility functions outside components as a best practice
5. **Complete Fixes**: When refactoring, ensure you REMOVE old code, not just ADD new code - leaving duplicates can cause the same issues to persist
6. **Verification**: After a fix, verify in production environment, not just build success

---

## References

- [MDN: Temporal Dead Zone](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Statements/let#temporal_dead_zone_tdz)
- [React Hooks Best Practices](https://react.dev/reference/react)
- Commit: `c560d4a` (regression introduced)
- Commit: `6946746` (incomplete hotfix - moved functions but left duplicates)
- Commit: `772fe1b` (complete fix - removed duplicates)
