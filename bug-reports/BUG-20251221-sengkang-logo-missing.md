# Bug Fix: Sengkang General Hospital Logo Not Displaying in Priority Matrix

**Date:** 21 December 2025
**Type:** Bug Fix
**Status:** Fixed

## Summary

Sengkang General Hospital Pte. Ltd. was displaying initials instead of the SingHealth logo in the Priority Matrix aged accounts alerts.

## Root Cause

The `getClientLogo` function applies a cleanup regex `replace(/[,;.]+$/, '')` to remove trailing punctuation. This means:

- Input: `"Sengkang General Hospital Pte. Ltd."`
- After cleanup: `"Sengkang General Hospital Pte. Ltd"` (trailing period removed)

However, the alias was only registered for the version WITH the trailing period:

```typescript
'Sengkang General Hospital Pte. Ltd.': 'Singapore Health Services Pte Ltd'
```

After cleanup, the name no longer matched the registered alias.

## Fix Applied

Added additional alias entries to cover variations after punctuation cleanup:

```typescript
// In src/lib/client-logos-local.ts - CLIENT_ALIASES
'Sengkang General Hospital Pte. Ltd.': 'Singapore Health Services Pte Ltd',
'Sengkang General Hospital Pte. Ltd': 'Singapore Health Services Pte Ltd',  // Without trailing period (after cleanup)
'Sengkang General Hospital Pte Ltd': 'Singapore Health Services Pte Ltd',   // Without any periods
'Sengkang General Hospital': 'Singapore Health Services Pte Ltd',
```

## Files Changed

| File                            | Change                                             |
| ------------------------------- | -------------------------------------------------- |
| `src/lib/client-logos-local.ts` | Added alias variants for Sengkang General Hospital |

## Related Issues

This is similar to the Strategic Asia Pacific Partners issue fixed earlier, where trailing commas in API responses caused logo lookup failures.

## Prevention

When adding new client logo aliases, always consider:

1. The exact API response string
2. The string after cleanup (trailing punctuation removed)
3. Common variations in spelling/formatting
