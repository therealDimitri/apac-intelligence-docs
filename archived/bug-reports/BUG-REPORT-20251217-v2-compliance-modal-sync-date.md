# Bug Report: V2 Compliance Modal Missing Sync Date

**Date:** 17 December 2025
**Status:** Resolved
**Commit:** 44443b6

## Issue Summary

The "Data last synced" date was not appearing in the V2 client compliance modal, despite being correctly implemented in the RightColumn.tsx component for the non-V2 view.

## Root Cause Analysis

The V2 client profile page (`/clients/[clientId]/v2`) uses `LeftColumn.tsx` for rendering the compliance modal, NOT `RightColumn.tsx` as initially assumed. The sync date display code had been added to `RightColumn.tsx` in a previous fix, but the V2 view was unaffected because it uses a different component.

### Investigation Process

1. Added debug logging to `useEventCompliance.ts` to trace data flow
2. Verified via console logs that `last_updated` data was being fetched correctly from Supabase
3. Observed that `segmentation_events` query returned null (likely RLS policy) but fallback to `viewData.last_updated` worked correctly
4. Identified that V2 page uses `LeftColumn.tsx` for the compliance modal

### Console Log Evidence

```
[useEventCompliance] Sync date query result: {data: null, error: null}
viewDataLastUpdated: 2025-12-16T20:53:31.096039+00:00
Final last_updated value: 2025-12-16T20:53:31.096039+00:00
```

The data was present but not being displayed in the V2 modal.

## Resolution

Added the sync date display paragraph to `LeftColumn.tsx` in the compliance modal header section:

```typescript
{eventCompliance.last_updated && (
  <p className="text-xs text-white/60 mt-1 flex items-center gap-1">
    <Clock className="h-3 w-3" />
    Data last synced:{' '}
    {new Date(eventCompliance.last_updated).toLocaleDateString('en-AU', {
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    })}
  </p>
)}
```

## Files Changed

| File                                                                  | Change                                                           |
| --------------------------------------------------------------------- | ---------------------------------------------------------------- |
| `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx` | Added sync date display to compliance modal header               |
| `src/hooks/useEventCompliance.ts`                                     | Minor refactor to use `finalLastUpdated` variable (code clarity) |

## Verification

After the fix, the page snapshot confirmed the sync date is now displaying:

```
paragraph [ref=e1336]: text: "Data last synced: 17 Dec 2025, 07:53 am"
```

## Lessons Learned

1. **Component Architecture**: The V2 client profile page uses a different component hierarchy than the non-V2 version. Changes to shared functionality need to be applied to both `LeftColumn.tsx` (V2) and `RightColumn.tsx` (non-V2) when they contain similar UI elements.

2. **Debug Logging**: Adding temporary console logs to trace data flow was effective in confirming the data was being fetched correctly, narrowing down the issue to the display layer.

## Related Commits

- `e7d924e` - Fix last sync date to use global segmentation events date
- `9f3d046` - Fix last sync date query to handle client name variants
- `f3563a0` - Add last XLS sync date to compliance details modal

## Testing Checklist

- [x] Sync date appears in V2 compliance modal
- [x] Date format is Australian (en-AU): "17 Dec 2025, 07:53 am"
- [x] Clock icon displays correctly
- [x] Build compiles without errors
