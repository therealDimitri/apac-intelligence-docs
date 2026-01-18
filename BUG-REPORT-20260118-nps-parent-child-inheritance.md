# Bug Report: NPS Parent-to-Child Inheritance

**Date:** 2026-01-18
**Status:** Fixed
**Severity:** Medium
**Component:** Strategic Plan Wizard - Plan Coverage Table

## Summary

NPS data was not being inherited correctly for SA Health child clients (iPro, iQemo, Sunrise). The inheritance logic was sibling-based instead of parent-to-child.

## Symptoms

- SA Health (iPro), SA Health (iQemo), and SA Health (Sunrise) were showing different or missing NPS scores
- The parent client "SA Health" NPS score (-55) should have propagated to all children
- Support Health data had the same inheritance issue

## Root Cause

### Database Issue
NPS data was stored under "SA Health (iPro)" instead of the parent "SA Health".

### Code Issue
The inheritance logic used `getBaseName()` which treated all SA Health variants as equals, allowing any sibling to provide data. It should have prioritised the parent client.

```typescript
// BEFORE (incorrect - sibling inheritance)
if (!npsDataByBaseName.has(baseName)) {
  npsDataByBaseName.set(baseName, npsScore)
}

// AFTER (correct - parent prioritised)
const isParent = !clientName.includes('(')
if (isParent || !npsDataByParent.has(parentName)) {
  npsDataByParent.set(parentName, npsScore)
}
```

## Fix Applied

### 1. Database Update
Updated 46 NPS records from `client_name = "SA Health (iPro)"` to `client_name = "SA Health"`.

### 2. Code Changes
**File:** `src/app/(dashboard)/planning/strategic/new/page.tsx`

- Renamed `getBaseName()` to `getParentName()` for clarity
- Added `isParent` check: clients without parentheses are parents
- Parent data takes priority over child/sibling data
- Applied same fix to Support Health inheritance

## Verification

1. Queried NPS database - confirmed 46 records now under "SA Health"
2. Build passed successfully
3. Child clients (iPro, iQemo, Sunrise) now inherit parent NPS score

## Prevention

- When implementing data inheritance, always clarify the hierarchy direction
- Parent clients (no parentheses) should always be the source of truth
- Child clients (with parentheses like "Client (Product)") inherit from parent

## Files Modified

- `src/app/(dashboard)/planning/strategic/new/page.tsx` - Inheritance logic fix

## Related Commit

```
Fix NPS/Support Health inheritance: parent-to-child direction
```
