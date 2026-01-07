# Bug Report: CSE/CAM Filter Not Working Correctly on Risk Heat Map

**Date:** 2026-01-07
**Status:** Resolved
**Priority:** High
**Component:** Compliance Dashboard - CS Leaderboard Tab

---

## Issue Summary

When clicking CSE/CAM names in the Leaderboard, the Risk Heat Map was not filtering correctly:
1. Clicking "Anupama Pradhan (CAM)" in the leaderboard would show no filter results
2. Even when filtered, the Heat Map would still display all CAMs/CSEs instead of just the selected person

---

## Root Causes

### 1. Name Suffix Mismatch
- Leaderboard displays names with role suffixes: `"Anupama Pradhan (CAM)"`
- Client data stores base names without suffixes: `c.cse = "Anupama Pradhan"`
- Filter comparison failed due to string mismatch

### 2. CAM Field Not Checked
- Filter only checked `c.cse === filters.cseName`
- CAMs are stored in `c.cam` field, not `c.cse`
- Clicking any CAM in leaderboard returned no results

### 3. Heat Map Not Filtered
- `heatMapData` useMemo built list from all CAMs/CSEs
- No logic to filter to just the selected person
- Showed everyone even when a specific filter was active

---

## Solutions Implemented

### Fix 1: Strip Role Suffixes in handleCSEClick

**File:** `src/app/(dashboard)/compliance/page.tsx`

```typescript
// Before
const handleCSEClick = (cseName: string) => {
  setFilters({ cseName })
  setViewMode('cse')
}

// After
const handleCSEClick = (cseName: string) => {
  // Strip role suffixes like "(CAM)", "(CSE)", "(CAM/CSE)" for filtering
  const baseName = cseName.replace(/\s*\((CAM|CSE|CAM\/CSE)\)\s*$/i, '').trim()
  setFilters({ cseName: baseName })
  setViewMode('cse')
}
```

### Fix 2: Check Both CSE and CAM Fields

**File:** `src/hooks/useComplianceDashboard.ts`

```typescript
// Before
if (filters.cseName) {
  result = result.filter(c => c.cse === filters.cseName)
}

// After
// Filter by CSE or CAM (check both fields)
if (filters.cseName) {
  result = result.filter(c => c.cse === filters.cseName || c.cam === filters.cseName)
}
```

### Fix 3: Filter Heat Map to Selected Person

**File:** `src/app/(dashboard)/compliance/page.tsx`

```typescript
// Added activeFilter check in heatMapData useMemo
const activeFilter = filters.cseName

// In CAM loop:
for (const camName of camNames) {
  // Skip if filter is active and this isn't the selected person
  if (activeFilter && camName !== activeFilter) continue
  // ...
}

// In CSE loop:
for (const cse of cseSummaries) {
  // Skip if filter is active and this isn't the selected person
  if (activeFilter && cse.cseName !== activeFilter) continue
  // ...
}

// Added filters.cseName to dependency array
}, [cseSummaries, filteredClients, filters.cseName, getPhotoURL])
```

---

## Files Modified

| File | Changes |
|------|---------|
| `src/app/(dashboard)/compliance/page.tsx` | Strip suffixes in handleCSEClick, filter heatMapData by active filter |
| `src/hooks/useComplianceDashboard.ts` | Check both CSE and CAM fields in filter logic |

---

## Testing Verification

- [x] TypeScript compilation passes (`npx tsc --noEmit`)
- [x] Clicking CSE in leaderboard filters correctly
- [x] Clicking CAM in leaderboard filters correctly
- [x] Heat Map shows only the selected person when filter active
- [x] Heat Map shows all people when no filter active
- [x] Client compliance data filters correctly for both CSE and CAM

---

## Regex Pattern Used

```javascript
/\s*\((CAM|CSE|CAM\/CSE)\)\s*$/i
```

Matches:
- ` (CAM)` -> strips to base name
- ` (CSE)` -> strips to base name
- ` (CAM/CSE)` -> strips to base name
- Case insensitive

---

## Related Files

- `src/components/compliance/EnhancedManagerDashboard.tsx` - CSELeaderboard and RiskHeatMap components
- `src/hooks/useEventCompliance.ts` - Client compliance data with cse/cam fields
