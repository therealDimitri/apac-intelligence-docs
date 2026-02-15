# Bug Report: Application Crash - Select Components with Empty String Values

## Date

2025-12-24

## Severity

**High** - Application crashes completely when rendering Select components with empty string values

## Summary

Multiple components using Radix UI Select had options with empty string (`''`) values, which caused client-side crashes. The error manifested when clicking the settings gear icon but the issue existed in multiple components across the application.

## Error Message

```
Uncaught Error: A <Select.Item /> must have a value prop that is not an empty string.
This is because the Select value can be set to an empty string to clear the selection and show the placeholder.
```

## Root Cause

Radix UI Select reserves the empty string value (`''`) for clearing selections and showing the placeholder. When a `Select.Item` is given an empty string as its value, Radix throws a runtime error that crashes the application.

## Files Fixed

### 1. `src/components/UserPreferencesModal.tsx`

**Issue:** Segment filter option had `value: ''`

```typescript
// Before
{ value: '', label: 'All Segments' }

// After
{ value: 'all', label: 'All Segments' }
```

Also updated value binding and change handler to convert between `'all'` and `null`.

### 2. `src/components/ScheduleEventModal.tsx`

**Issue:** Event type placeholder option had `value: ''`

```typescript
// Before
{ value: '', label: 'Select an event type' }

// After
{ value: '__placeholder__', label: 'Select an event type' }
```

Also updated state initialisation, reset logic, and validation checks.

### 3. `src/components/AIInsightsPanel.tsx`

**Issue:** Three filter options had `value: ''` for "All Types", "All Categories", "All Impact Levels"

```typescript
// Before
{ value: '', label: 'All Types' }
{ value: '', label: 'All Categories' }
{ value: '', label: 'All Impact Levels' }

// After
{ value: 'all', label: 'All Types' }
{ value: 'all', label: 'All Categories' }
{ value: 'all', label: 'All Impact Levels' }
```

Also updated value bindings and change handlers.

### 4. `src/components/EventTypeVisualization.tsx`

**Issue:** Event selector placeholder had `value: ''`

```typescript
// Before
{ value: '', label: 'Choose an event type...' }

// After
{ value: '__placeholder__', label: 'Choose an event type...' }
```

Also updated value binding and change handler.

### 5. `src/components/priority-matrix/ReassignModal.tsx`

**Issue:** Owner selector placeholder had `value: ''`

```typescript
// Before
{ value: '', label: 'Choose an owner...' }

// After
{ value: '__placeholder__', label: 'Choose an owner...' }
```

Also updated state initialisation, reset logic, and submit validation.

## Fix Pattern

For **filter/preference** values where the option means "show all" or "no filter":

- Use `value: 'all'` for the "All X" option
- Value binding: `value={stateValue || 'all'}`
- Change handler: `onValueChange={value => setState(value === 'all' ? null : value)}`

For **placeholder/selection** values where the option means "no selection yet":

- Use `value: '__placeholder__'` for the placeholder option
- State initialisation: `useState('__placeholder__')`
- Reset logic: `setState('__placeholder__')`
- Validation: `if (!value || value === '__placeholder__') { /* invalid */ }`

## Testing

- [x] TypeScript compilation passes
- [ ] Manual testing: Settings modal opens without crash
- [ ] Manual testing: Schedule Event modal works
- [ ] Manual testing: AI Insights filters work
- [ ] Manual testing: Event Type Visualisation selector works
- [ ] Manual testing: Priority Matrix reassign modal works

## Prevention

When using Radix UI Select components:

1. **Never use empty strings** as option values
2. Use meaningful sentinel values like `'all'`, `'none'`, or `'__placeholder__'`
3. Handle conversion to/from `null` or empty state in value binding and change handlers
4. Document this constraint in component documentation
