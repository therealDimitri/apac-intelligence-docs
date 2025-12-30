# Bug Report: Priority Matrix Using Initials Instead of Owner Profile Photos

**Date:** 2025-12-30
**Severity:** Low
**Status:** Resolved

## Summary

The Priority Matrix action cards were displaying purple avatars with owner initials instead of actual CSE profile photos. The `EnhancedAvatar` component supports a `src` prop for photos but it wasn't being provided.

## Symptoms

- Owner badges in Priority Matrix showed purple circles with initials (e.g., "JL", "MS")
- Profile photos stored in Supabase `cse-photos` bucket were not displayed
- Both `MatrixItem` (comfortable view) and `MatrixItemCompact` (compact view) had this issue

## Root Cause

The `EnhancedAvatar` component was being used correctly but without the `src` prop:

```typescript
// Before - only name was passed, so initials were shown
<EnhancedAvatar
  name={item.metadata.owner}
  size="xs"
  className="ring-1 ring-green-200"
/>
```

The CSE profile photos were available via the `useCSEProfiles` hook's `getPhotoURL()` function, but this was not integrated into the Priority Matrix components.

## Resolution

1. Added `useCSEProfiles` hook to `PriorityMatrix.tsx` to access `getPhotoURL`
2. Passed `getPhotoURL` as a prop through the component chain:
   - `PriorityMatrix` → `MatrixQuadrant` → `MatrixItem`/`MatrixItemCompact`
3. Updated `EnhancedAvatar` usage to include the `src` prop:

```typescript
// After - photo URL is now provided
<EnhancedAvatar
  name={item.metadata.owner}
  src={getPhotoURL?.(item.metadata.owner)}
  size="xs"
  className="ring-1 ring-green-200"
/>
```

## Files Modified

| File | Changes |
|------|---------|
| `src/components/priority-matrix/PriorityMatrix.tsx` | Import `useCSEProfiles`, call hook, pass `getPhotoURL` to quadrants |
| `src/components/priority-matrix/MatrixQuadrant.tsx` | Accept and pass `getPhotoURL` prop |
| `src/components/priority-matrix/MatrixItem.tsx` | Accept `getPhotoURL` prop, use in `EnhancedAvatar` |
| `src/components/priority-matrix/MatrixItemCompact.tsx` | Accept `getPhotoURL` prop, use in `EnhancedAvatar` |

## Verification

After applying the fix:
- Owner badges display profile photos from `cse-photos` bucket
- If no photo exists for a CSE, the `EnhancedAvatar` falls back to initials (expected behaviour)
- Both compact and comfortable density modes show photos correctly

## Photo URL Resolution

The `getPhotoURL` function from `useCSEProfiles` hook:
1. Looks up CSE by name (including aliases)
2. Retrieves `photo_url` from `cse_profiles` table
3. Constructs full Supabase storage URL: `{SUPABASE_URL}/storage/v1/object/public/cse-photos/{photo_path}`

## Related Files

- `src/hooks/useCSEProfiles.ts` - Hook that provides `getPhotoURL` function
- `src/components/ui/enhanced/EnhancedAvatar.tsx` - Avatar component with `src` prop support
