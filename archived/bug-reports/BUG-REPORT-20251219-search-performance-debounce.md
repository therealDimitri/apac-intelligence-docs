# Bug Report: Search Input Performance - Debounce Fix

## Date

19 December 2025

## Issue Summary

The search input in the Briefing Room meetings page was experiencing significant lag. Every keystroke caused noticeable delay and "thinking" behaviour, making the search field unresponsive.

## Symptoms

- Typing in the search field felt sluggish
- Visible delay after each character entry
- UI appeared to "think" or freeze briefly after each keystroke
- Poor user experience when searching for meetings

## Root Cause

The search input in `CondensedStatsBar.tsx` was directly calling the parent's `onSearchChange` handler on every `onChange` event. This triggered:

1. Immediate state update (`setSearchTerm`)
2. `useMemo` recalculation for `meetingsFilters`
3. `useMeetings` hook re-execution with new filters
4. Database query with search term

Each keystroke was triggering a full database query, causing the lag.

```typescript
// Before: Every keystroke triggers database query
<input
  value={searchValue}
  onChange={e => onSearchChange(e.target.value)}
/>
```

## Solution

Implemented debouncing in the search input component:

1. Added local state (`localSearchValue`) for immediate UI feedback
2. Created a debounced handler that waits 300ms after the user stops typing
3. Only triggers the actual search query after the debounce delay
4. Added cleanup for the timer on component unmount
5. Syncs local state when external `searchValue` changes (e.g., from saved views)

```typescript
// After: Local state for responsive UI, debounced callback for queries
const [localSearchValue, setLocalSearchValue] = useState(searchValue)
const debounceTimerRef = useRef<NodeJS.Timeout | null>(null)

const handleSearchInputChange = (value: string) => {
  setLocalSearchValue(value) // Update immediately for responsive UI

  if (debounceTimerRef.current) {
    clearTimeout(debounceTimerRef.current)
  }

  debounceTimerRef.current = setTimeout(() => {
    onSearchChange(value) // Trigger actual search after 300ms
  }, 300)
}
```

## Files Modified

1. `src/components/CondensedStatsBar.tsx`
   - Added React imports: `useState`, `useEffect`, `useRef`
   - Added local state for search input value
   - Added debounce timer ref
   - Added `handleSearchInputChange` function with 300ms debounce
   - Added effect to sync local value with external `searchValue`
   - Added cleanup effect for timer on unmount
   - Updated input to use local state and debounced handler

## Technical Details

### Debounce Timing

- 300ms delay chosen as optimal balance between responsiveness and query reduction
- User typically types 3-5 characters before pausing, so 300ms captures full typing sessions

### State Synchronisation

- External `searchValue` changes (e.g., loading saved views) sync to local state
- Prevents desync between displayed value and parent state

### Memory Management

- Timer is cleaned up on component unmount to prevent memory leaks
- Previous timer is cleared before setting a new one to prevent stale callbacks

## Testing

- Build passes with no TypeScript errors
- Search input now responds immediately to typing
- Database queries only fire after user stops typing for 300ms
- Saved views correctly update the search field
- Clear filters correctly resets the search field

## Prevention

- Consider adding debouncing to any input that triggers expensive operations
- Use local state for immediate UI feedback when parent state updates are costly
- Always clean up timers and subscriptions on component unmount

## Commits

- Pending commit for search debounce fix
