# Bug Report: Compliance Dashboard UI Fixes

**Date:** 2025-12-21
**Status:** Resolved
**Priority:** Medium
**Affected Areas:** Compliance Dashboard, Chart Components, Alert Configuration, CSE Performance

## Summary

Multiple UI issues were identified and fixed across the Compliance Dashboard, including chart styling, profile photos, and data display improvements.

## Issues Identified

### 1. MS Graph API User Search Not Finding Users

**Location:** `src/components/aged-accounts/AlertConfigModal.tsx:111`

**Problem:** The Alert Configuration modal's user search functionality was not displaying search results even when users existed.

**Root Cause:** The API response was being read incorrectly. The code was accessing `data.users` but the API returns `result.data`.

**Fix:**

```typescript
// Before
setSearchResults(data.users || [])

// After
const result = await response.json()
setSearchResults(result.data || [])
```

### 2. Chart Colours Rendering as Black

**Location:** `src/app/globals.css`

**Problem:** Tremor charts in the Compliance Dashboard were rendering with black colours instead of the expected purple, emerald, and other themed colours.

**Root Cause:** Tailwind CSS v4 uses a different colour system architecture than Tailwind v3, and Tremor v3 expects the older colour class structure. The new `@theme inline` block in Tailwind v4 requires explicit colour definitions.

**Fix:** Added full colour palette definitions to the `@theme inline` block:

```css
@theme inline {
  --color-purple-50: #faf5ff;
  --color-purple-100: #f3e8ff;
  /* ... full palette for purple, emerald, red, amber, blue, gray */
}
```

### 3. Y-Axis Text Cut Off on Charts

**Location:** `src/app/(dashboard)/aging-accounts/compliance/components/ExecutiveView.tsx`

**Problem:** Y-axis percentage labels were being cut off on the BarChart and LineChart components.

**Root Cause:** The `yAxisWidth` prop was set to 48 pixels, which was insufficient for percentage labels.

**Fix:**

```typescript
// Before
yAxisWidth={48}

// After
yAxisWidth={56}
```

### 4. Transparent Tooltip/Hover Card Background

**Location:** `src/app/globals.css`

**Problem:** Chart tooltip backgrounds were transparent, making the text difficult to read when overlapping data.

**Root Cause:** Tremor/Recharts tooltip components lacked proper background styling.

**Fix:** Added CSS rules for solid backgrounds:

```css
.tremor-Tooltip-root {
  background-color: white !important;
  border: 1px solid #e5e7eb !important;
  box-shadow:
    0 4px 6px -1px rgb(0 0 0 / 0.1),
    0 2px 4px -2px rgb(0 0 0 / 0.1) !important;
}

.recharts-default-tooltip {
  background-color: white !important;
  border: 1px solid #e5e7eb !important;
  border-radius: 0.5rem !important;
  box-shadow:
    0 4px 6px -1px rgb(0 0 0 / 0.1),
    0 2px 4px -2px rgb(0 0 0 / 0.1) !important;
}
```

### 5. CSE Profile Photos Not Displaying

**Location:** `src/app/(dashboard)/aging-accounts/compliance/components/OperationsView.tsx`

**Problem:** CSE Performance cards displayed initials instead of profile photos from Supabase.

**Root Cause:** The component was not using the existing `useCSEProfiles` hook that provides photo URLs.

**Fix:**

1. Added imports for `Image` from `next/image` and `useCSEProfiles` hook
2. Added hook call: `const { getPhotoURL } = useCSEProfiles()`
3. Updated avatar rendering to check for photo URL and display image if available:

```typescript
{(() => {
  const photoURL = getPhotoURL(cse.cseName)
  return photoURL ? (
    <Image src={photoURL} alt={`${cse.cseName} profile photo`} width={40} height={40} />
  ) : (
    <div className="...">
      {/* Initials fallback */}
    </div>
  )
})()}
```

### 6. Audit Trail Using Mock Data

**Location:** `src/app/(dashboard)/aging-accounts/compliance/components/ComplianceView.tsx`

**Problem:** The Audit Trail table was showing mock/fake data instead of real database entries.

**Root Cause:** No data was being passed to the AuditTrailTable component, causing it to fall back to generating mock entries.

**Fix:**

1. Created new hook `src/hooks/useARAuditTrail.ts` to fetch from `aging_alerts_log` table
2. Updated ComplianceView to use the hook and pass entries to AuditTrailTable:

```typescript
const { entries: auditEntries } = useARAuditTrail()

<AuditTrailTable
  entries={auditEntries.length > 0 ? auditEntries : undefined}
  ...
/>
```

## Files Modified

- `src/app/globals.css` - Added Tailwind v4 colour definitions and tooltip styling
- `src/components/aged-accounts/AlertConfigModal.tsx` - Fixed API response parsing
- `src/app/(dashboard)/aging-accounts/compliance/components/ExecutiveView.tsx` - Increased yAxisWidth
- `src/app/(dashboard)/aging-accounts/compliance/components/OperationsView.tsx` - Added CSE profile photos
- `src/app/(dashboard)/aging-accounts/compliance/components/ComplianceView.tsx` - Connected audit trail to real data

## Files Created

- `src/hooks/useARAuditTrail.ts` - Hook to fetch audit data from database

## Testing

All changes verified with `npm run build` passing successfully.

## Notes

- The audit trail currently pulls from `aging_alerts_log` which only contains threshold breach alerts. For a complete AR activity audit trail, additional data sources would need to be integrated.
- CSE profile photos require the `cse_profiles` table to be populated with `photo_url` values pointing to the `cse-photos` Supabase storage bucket.
