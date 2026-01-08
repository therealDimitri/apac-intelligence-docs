# Azure AD Duplicate Surname Display

**Date:** 2026-01-08
**Type:** Bug Fix
**Status:** Resolved
**Priority:** Medium

---

## Issue Description

The logged-in user profile section in the sidebar was displaying the user's surname twice. For example:
- Line 1: "Dimitri Leimonitis"
- Line 2: "Leimonitis"

## Root Cause

Azure AD was sending the user's `name` field with newline characters and/or duplicate name parts. The exact format appeared to be:
```
"Dimitri Leimonitis\nLeimonitis"
```

This caused the name to render on two lines, with the surname appearing as a separate line.

## Solution

Updated the sidebar's name parsing logic to:

1. **Strip newlines** - Replace all `\r\n` characters with spaces
2. **Collapse whitespace** - Replace multiple consecutive spaces with single spaces
3. **Remove duplicate surname** - If the name follows a "First Last Last" pattern (where the surname appears twice), remove the duplicate

### Code Changes

```typescript
// Before:
const rawUserName = session?.user?.name || 'User'

// After:
const rawUserName = (session?.user?.name || 'User')
  .replace(/[\r\n]+/g, ' ') // Remove newlines
  .replace(/\s+/g, ' ') // Collapse multiple spaces
  .trim()

// Additional duplicate surname detection:
const nameParts = userName.split(' ').filter(p => p.length > 0)
if (nameParts.length > 2) {
  const lastPart = nameParts[nameParts.length - 1]
  const lastPartIndex = nameParts
    .slice(0, -1)
    .findIndex(p => p.toLowerCase() === lastPart.toLowerCase())
  if (lastPartIndex !== -1) {
    nameParts.splice(nameParts.length - 1, 1)
    userName = nameParts.join(' ')
  }
}
```

## Files Modified

| File | Changes |
|------|---------|
| `src/components/layout/sidebar.tsx` | Added newline stripping, whitespace collapsing, and duplicate surname removal |

## Testing Checklist

- [x] Type check passes
- [x] ESLint passes
- [x] User name displays correctly without duplicate surname
- [x] Existing "Last, First" format handling still works
- [x] Normal "First Last" names unaffected

## Prevention

Azure AD profile data should be treated as potentially malformed. Any user display name from Azure AD should be sanitised before display.

**Recommendation:** Consider adding a utility function `sanitizeUserName(name: string)` for consistent name cleaning across the application.

---

## Commits

1. `0c2a00f6` - fix: remove duplicate surname from Azure AD name display
