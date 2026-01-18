# Bug Report: NPS Client Logo Distinction

**Date:** 2026-01-18
**Status:** Fixed
**Severity:** Low (UX improvement)
**Component:** NPS Analytics - Top Topics by Client Segment

## Summary

In the "Top Topics by Client Segment" section on the NPS Analytics page, clients with the same parent organisation (e.g., SA Health, SA Health (iPro), SA Health (Sunrise), SA Health (iQemo)) all displayed identical logos, making it impossible to distinguish which specific client was being referenced.

## Symptoms

- SA Health and all its children showed identical logos in the Clients row
- Users couldn't identify which SA Health variant belonged to which segment
- No way to distinguish between clients from the same organisation

## Root Cause

The `ClientLogoDisplay` component correctly uses the parent organisation's logo for all children (e.g., SA Health logo for SA Health (iPro)), but no additional visual indicator was provided to distinguish between variants.

## Fix Applied

**File:** `src/components/TopTopicsBySegment.tsx`

### 1. Product Suffix Badge
For child clients with parentheses in their name (e.g., "SA Health (iPro)"), the product suffix is now extracted and displayed as a small badge:

```typescript
const suffixMatch = client.client_name.match(/\(([^)]+)\)$/)
const productSuffix = suffixMatch ? suffixMatch[1] : null
```

Display:
```
[SA Health Logo] (iPro)
```

### 2. Tooltip on Hover
All client logos now show the full client name in a tooltip on hover, providing additional context without cluttering the UI.

## Visual Result

Before:
```
Clients: [Logo] [Logo] [Logo] [Logo]
         (all identical, no way to tell them apart)
```

After:
```
Clients: [Logo] [Logo] (iPro) [Logo] (Sunrise) [Logo] (iQemo)
         (hover shows full name: "SA Health (iPro)")
```

## Verification

1. Visit NPS Analytics page
2. Scroll to "Top Topics by Client Segment" section
3. SA Health variants now show product suffix badges
4. Hover over any logo to see full client name

## Files Modified

- `src/components/TopTopicsBySegment.tsx` - Added suffix badges and tooltips

## Related Commit

```
Add product suffix badges and tooltips to NPS client logos
```
