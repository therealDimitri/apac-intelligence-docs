# Bug Report: Activity Type Dropdown Not Showing Selected Value in Edit Modal

**Date:** 2026-01-02
**Severity:** Medium
**Status:** Fixed
**Commit:** a526d22

## Summary

The Activity Type dropdown in the EditActionModal showed "Select activity type..." (empty) even when the action had an activity type set. The slideover correctly displayed the activity type (e.g., "SUPPORT" or "HEALTH_CHECK"), but clicking Edit opened a modal where the dropdown appeared unselected.

## Symptoms

- Slideover shows Activity Type: "SUPPORT" or "HEALTH_CHECK"
- Click Edit → Modal opens with Activity Type dropdown showing "Select activity type..."
- User had to manually re-select the activity type to save without losing the value

## Root Cause

**React state initialisation race condition**

The console logs revealed the issue:
```
[ActivityTypeSelector] Debug: {receivedValue: 'HEALTH_CHECK', loading: true, optionCount: 0}
[ActivityTypeSelector] Debug: {receivedValue: 'HEALTH_CHECK', loading: false, optionCount: 14}
[ActivityTypeSelector] Debug: {receivedValue: '', effectiveValue: 'all', loading: false}  // <-- Value reset!
[ActivityTypeSelector] Debug: {receivedValue: 'HEALTH_CHECK', loading: false, optionCount: 14}
```

The sequence shows:
1. Initial render with correct value but options still loading
2. Options finish loading, triggers re-render
3. **Value mysteriously becomes empty string**
4. Then value returns to correct value

The issue was in how `useState` was initialised:
```typescript
// Before - closure captures stale action value
const [formData, setFormData] = useState({
  ...
  activityTypeCode: action.activityTypeCode || '',
  ...
})
```

When React Strict Mode double-renders or when the `useActivityTypes` hook completes loading and triggers a re-render, the `useState` initialiser could capture a stale closure value, briefly resetting `activityTypeCode` to empty.

## Fix Applied

Extracted the form data initialisation into a function and used lazy initialisation:

```typescript
// After - function ensures fresh values on every call
const getInitialFormData = () => ({
  title: action.title,
  ...
  activityTypeCode: action.activityTypeCode || '',
  ...
})

// Pass function reference for lazy initialisation
const [formData, setFormData] = useState(getInitialFormData)

// Reuse in useEffect
useEffect(() => {
  setFormData(getInitialFormData())
  ...
}, [action])
```

This ensures:
1. `useState` uses lazy initialisation (function is called once on mount)
2. `useEffect` uses the same function for consistency
3. No stale closures affecting initialisation

## Files Modified

| File | Changes |
|------|---------|
| `src/components/EditActionModal.tsx` | Extracted `getInitialFormData()` function, used lazy useState initialisation |
| `src/components/internal-ops/ActivityTypeSelector.tsx` | Removed debug logging |

## Verification

After the fix, the Activity Type dropdown correctly displays the selected value when opening the Edit modal.

## Prevention

- When initialising React state from props, prefer lazy initialisation (`useState(() => ...)`) over direct values
- Be cautious of closure captures in `useState` initialisers when the component may re-render during prop changes
- Consider using `key` prop on modals to force remounting when the primary data changes

## Related

- Department dropdown in the same modal uses identical pattern and was also affected
- Similar pattern should be reviewed in other edit modals (EditMeetingModal, etc.)
