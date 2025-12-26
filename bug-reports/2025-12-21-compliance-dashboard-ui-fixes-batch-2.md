# Bug Report: Compliance Dashboard UI Fixes - Batch 2

**Date:** 2025-12-21
**Status:** Resolved
**Priority:** Medium
**Affected Areas:** Compliance Dashboard, Historical Trend Chart, CSE Profile Photos, Audit Trail, Navigation

## Summary

Multiple UI issues were identified and fixed across the Compliance Dashboard, including historical period filtering, CSE profile alias lookups, URL-based navigation, and audit trail data display.

## Issues Identified and Fixed

### 1. Historical Period Buttons Not Functional

**Location:** `src/app/(dashboard)/aging-accounts/compliance/components/ExecutiveView.tsx`

**Problem:** The Historical Trend chart had period buttons (1M, 3M, 6M, 12M) that did nothing when clicked.

**Root Cause:** The buttons had no click handlers or state management.

**Fix:**

```typescript
// Added useState import and period state
import { useMemo, useState } from 'react'

const [selectedPeriod, setSelectedPeriod] = useState<'1M' | '3M' | '6M' | '12M'>('3M')

// Added filtered historical trend data
const filteredHistoricalTrend = useMemo(() => {
  const periodMonths = { '1M': 1, '3M': 3, '6M': 6, '12M': 12 }
  const monthsToShow = periodMonths[selectedPeriod]
  return historicalData.trend.slice(-monthsToShow)
}, [historicalData?.trend, selectedPeriod])

// Updated button rendering with click handlers and active styling
<button
  onClick={() => setSelectedPeriod(period)}
  className={`... ${selectedPeriod === period ? 'bg-purple-600 text-white' : '...'}`}
>
  {period}
</button>
```

### 2. Unassigned Clients View Button Not Working

**Location:** `src/app/(dashboard)/aging-accounts/page.tsx`

**Problem:** Clicking "View" on unassigned clients from the Compliance Dashboard did not show the filtered results in the Detailed View.

**Root Cause:** The page defaulted to the Compliance Dashboard tab and only handled the `client` URL parameter, not the `cse` parameter. When navigating with URL parameters, the tab wasn't switching.

**Fix:**

```typescript
// Updated useEffect to handle both client and cse parameters
useEffect(() => {
  const clientParam = searchParams.get('client')
  const cseParam = searchParams.get('cse')

  // If client or CSE parameter is provided, switch to Detailed View and apply filters
  if (clientParam) {
    setSearchTerm(clientParam)
    setActiveTab('detailed')
  }

  if (cseParam) {
    setSelectedCSE(cseParam)
    setActiveTab('detailed')
  }
}, [searchParams])
```

### 3. Jonathan Salisbury Photo Not Displaying

**Location:** `src/hooks/useCSEProfiles.ts`

**Problem:** CSE named "Jonathan Salisbury" in the aging data was not matching the profile photo stored under "John Salisbury" or similar.

**Root Cause:** The `getPhotoURL` function only looked up by exact `full_name` match and didn't utilise the `name_aliases` field in the CSE profiles table.

**Fix:**

```typescript
// Updated name map creation to include aliases
data?.forEach(profile => {
  nameMap.set(profile.full_name, profile)

  // Also add entries for each alias for easier lookup
  if (profile.name_aliases && Array.isArray(profile.name_aliases)) {
    profile.name_aliases.forEach((alias: string) => {
      if (alias) {
        nameMap.set(alias, profile)
      }
    })
  }
})

// Added findProfile function with fallback matching
const findProfile = (cseName: string): CSEProfile | null => {
  // First try exact match (includes aliases)
  let profile = profilesByName.get(cseName)
  if (profile) return profile

  // Try case-insensitive match
  const lowerName = cseName.toLowerCase()
  for (const [key, p] of profilesByName) {
    if (key.toLowerCase() === lowerName) return p
  }

  // Try matching by last name (e.g., "Jonathan Salisbury" → "John Salisbury")
  const nameParts = cseName.split(' ')
  if (nameParts.length >= 2) {
    const lastName = nameParts[nameParts.length - 1]
    for (const p of profiles) {
      if (p.full_name.endsWith(lastName)) return p
    }
  }

  return null
}
```

### 4. Audit Trail Displaying Mock Data

**Location:**

- `src/app/(dashboard)/aging-accounts/compliance/components/ComplianceView.tsx`
- `src/app/(dashboard)/aging-accounts/compliance/components/AuditTrailTable.tsx`

**Problem:** The Audit Trail table was showing mock/fake data instead of real database entries.

**Root Cause:**

1. ComplianceView was passing `undefined` to AuditTrailTable when `auditEntries` was empty
2. AuditTrailTable generated mock data when `providedEntries` was undefined/falsy

**Fix:**

```typescript
// ComplianceView - always pass the array, even if empty
<AuditTrailTable
  entries={auditEntries}  // Removed the conditional that passed undefined
  onExport={handleExportAudit}
  onViewEntry={(entry) => console.log('View audit entry:', entry)}
/>

// AuditTrailTable - removed mock data generation
// Before: Complex mock data generator
// After: Simple assignment
const entries = providedEntries || []

// Updated empty state message
{!hasActiveFilters && (
  <p className="text-xs text-gray-400 mt-2">
    Audit entries will appear here when compliance alerts are triggered
  </p>
)}
```

## Files Modified

- `src/app/(dashboard)/aging-accounts/compliance/components/ExecutiveView.tsx`
  - Added useState import
  - Added selectedPeriod state and filteredHistoricalTrend memo
  - Updated period buttons with click handlers and active styling
  - Used filtered data in LineChart

- `src/app/(dashboard)/aging-accounts/page.tsx`
  - Updated URL parameter handling to include `cse` parameter
  - Auto-switch to Detailed View when URL parameters are present

- `src/hooks/useCSEProfiles.ts`
  - Added alias mapping to profilesByName map
  - Added findProfile function with fallback matching strategies
  - Updated getPhotoURL and getProfile to use findProfile

- `src/app/(dashboard)/aging-accounts/compliance/components/ComplianceView.tsx`
  - Simplified entries prop to always pass the array

- `src/app/(dashboard)/aging-accounts/compliance/components/AuditTrailTable.tsx`
  - Removed mock data generation
  - Updated empty state message to explain when entries will appear

## Testing

All changes verified with `npm run build` passing successfully.

## Notes

- The Historical period filter defaults to 3M (3 months) which is the most commonly used view
- CSE profile matching now uses a three-tier approach: exact match → case-insensitive → last name match
- Audit Trail will show "No audit entries available" until compliance alerts are configured and triggered
- For complete audit trail functionality, consider integrating additional data sources (e.g., ar_notes table, payment history)
