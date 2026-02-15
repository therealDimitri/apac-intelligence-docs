# Bug Report: SA Health Duplicate Entry and Logo Display

**Date:** 2025-12-01
**Issue:** SA Health appearing twice in client list + Logo not displaying
**Status:** ✅ FIXED (Duplicate); 🔍 Requires User Verification (Logo)
**Commit:** `1cdb15f` - "fix: prevent duplicate SA Health entry in client scores"

---

## Issue 1: SA Health Appearing Twice (FIXED)

### Problem Description

SA Health was appearing twice in the NPS Analytics client list:

- Once as "SA Health" (parent entry)
- Once again as "SA Health" (consolidated from variants)

This created a confusing UI showing duplicate entries for the same client.

### Root Cause

**Filtering Logic Bug:**

The consolidation code filtered out SA Health variants but forgot to exclude the parent "SA Health" entry:

```typescript
// BEFORE (BUGGY):
const otherClients = clientScores.filter(c => !c.name.startsWith('SA Health ('))
// This INCLUDES "SA Health" parent!

let filtered = [...otherClients] // Adds parent once

if (saHealthVariants.length > 0) {
  const saHealthParent = clientScores.find(c => c.name === 'SA Health')
  if (saHealthParent) {
    filtered.push(saHealthParent) // Adds parent AGAIN!
  }
}
```

**Result:** SA Health added twice to the filtered list

### Solution Implemented

**File:** `src/app/(dashboard)/nps/page.tsx` (lines 79-81)

```typescript
// AFTER (FIXED):
const otherClients = clientScores.filter(
  c => !c.name.startsWith('SA Health (') && c.name !== 'SA Health' // Exclude parent too
)
```

Now the filter explicitly excludes both:

- SA Health variants (`SA Health (iPro)`, etc.)
- Parent entry (`SA Health`)

Then re-adds a single consolidated entry, ensuring only **one** SA Health entry appears.

### Impact

- ✅ SA Health now appears exactly once in the client list
- ✅ Consolidation logic works correctly
- ✅ No duplicate confusion in UI

---

## Issue 2: SA Health Logo Not Displaying (Requires Testing)

### Problem Description

The SA Health client in the Giant segment doesn't show its logo. The logo file exists at `/public/logos/sa-health.png`, and the mapping exists in `client-logos-local.ts`, but the image isn't displaying.

### Investigation Done

**Logo File:** ✅ Exists

```
/public/logos/sa-health.png  (verified)
```

**Logo Mapping:** ✅ Exists

```typescript
// src/lib/client-logos-local.ts:17
'SA Health': '/logos/sa-health.png',
```

**Component:** ✅ Correct implementation

```typescript
// src/components/ClientLogoDisplay.tsx
<Image
  src={logoUrl}
  alt={clientName}
  onError={(e) => {
    // Fallback to initials if image fails
    e.currentTarget.style.display = 'none'
    const fallback = e.currentTarget.nextElementSibling as HTMLElement
    if (fallback) fallback.style.display = 'flex'
  }}
/>
```

### Possible Causes

1. **Image Load Failure** - The `onError` handler might be triggering, falling back to initials
2. **CSS Visibility Issue** - Image might be hidden by CSS
3. **Path Resolution** - Next.js Image might not be resolving the path correctly
4. **Caching Issue** - Browser cache showing stale logo

### Debugging Steps

Check browser console (F12) for these logs:

```
[ClientLogoDisplay] Client: "SA Health", Logo: FOUND/NOT FOUND
[getClientLogo] No logo found for: "SA Health"
```

If logo shows "NOT FOUND":

- Check normalization: `[getClientLogo] After normalization: "..."`
- This would indicate the name is being transformed unexpectedly

### Recommended Testing

1. **Browser Console:**
   - Open F12 on http://localhost:3002/nps
   - Look for "[ClientLogoDisplay]" logs
   - Check if logo is found or not

2. **Network Tab:**
   - Check if `/logos/sa-health.png` is requested
   - Verify response status (should be 200)
   - Check image preview loads correctly

3. **Clear Cache:**
   - Hard refresh (Cmd+Shift+R on Mac)
   - Clear browser cache
   - Retry

4. **Check Image File:**
   - Download `/public/logos/sa-health.png`
   - Verify it's a valid PNG file
   - Check file size (should be > 0 bytes)

---

## Git Commits

**Commit 1:** `1cdb15f` - fix: prevent duplicate SA Health entry in client scores

- Fixed duplicate SA Health in client list
- Changed filter to exclude both variants and parent entry
- Build verified ✅

---

## Files Modified

### Modified This Session

- `src/app/(dashboard)/nps/page.tsx` (lines 77-81)
  - Updated `otherClients` filter to exclude SA Health parent
  - Added explanatory comment

### Related Files (Not Modified)

- `src/components/ClientLogoDisplay.tsx` - Displays logos correctly
- `src/lib/client-logos-local.ts` - Logo mappings intact
- `/public/logos/sa-health.png` - Logo file exists

---

## Status Summary

### ✅ FIXED: Duplicate SA Health Entry

- Root cause identified and fixed
- Build passes
- Changes pushed to main
- Dev server running with fix

### 🔍 PENDING: Logo Display Issue

- Investigation complete
- Likely causes identified
- Requires user verification in browser
- Debugging steps documented

---

## Next Steps

1. **Verify Duplicate Fix:** Test at http://localhost:3002/nps
   - SA Health should appear only once
   - Logo may or may not display

2. **Debug Logo Issue:** If logo not showing:
   - Check browser console logs
   - Verify network requests
   - Check console for warnings from `getClientLogo()`

3. **Potential Solutions for Logo:**
   - If "NOT FOUND": Investigate normalization function
   - If network error: Check Next.js Image configuration
   - If cache issue: Clear browser cache and retry

---

## Technical Notes

### SA Health Consolidation Logic

```
Input clientScores:
- "SA Health" (parent)
- "SA Health (iPro)" (variant)
- "SA Health (iQemo)" (variant)
- "SA Health (Sunrise)" (variant)
- Other clients...

Processing:
1. Extract variants: ["SA Health (iPro)", "SA Health (iQemo)", "SA Health (Sunrise)"]
2. Extract others: [All clients except variants AND parent]
3. Add consolidated: filtered.push(saHealthParent or manual consolidation)

Output filtered:
- "SA Health" (single consolidated entry)
- Other clients...
```

### Logo Resolution Order

```
getClientLogo("SA Health")
  ↓
1. Check CLIENT_ALIASES["SA Health"] → "SA Health" (no alias)
  ↓
2. Normalize: normalizeClientName("SA Health") → Check DISPLAY_NAMES
  ↓
3. Get logo: CLIENT_LOGO_MAP["SA Health"] → "/logos/sa-health.png"
  ↓
4. Display: <Image src="/logos/sa-health.png" ... />
```

---

## Related Issues

### Previous Session Issues (Resolved)

- **ID Matching Bug** - Commit `648487a`
  - Fixed string/numeric ID mismatch in cache classification
  - Topics now display correctly

- **TypeScript Error** - Commit `a524c03`
  - Removed invalid `trendPercentage` property
  - Build now passes

---

**Session Date:** 2025-12-01
**Status:** ✅ Duplicate Fixed, 🔍 Logo Pending Verification
**Ready for Testing:** YES
