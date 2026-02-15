# Changelog - 8 January 2026

## Summary

This session focused on bug fixes and UI improvements across the platform, with emphasis on data accuracy and visual consistency.

---

## Bug Fixes

### 1. Azure AD Duplicate Surname Display
**Commit:** `0c2a00f6`

**Issue:** User profile in sidebar displayed surname twice (e.g., "Dimitri Leimonitis" followed by "Leimonitis" on a new line).

**Cause:** Azure AD was sending names with newline characters and/or duplicate name parts.

**Fix:**
- Strip newlines from raw name
- Collapse multiple spaces
- Detect and remove duplicate surname patterns

**Files:** `src/components/layout/sidebar.tsx`

---

### 2. CAM Account Plan - Incorrect CSE-Client Mapping
**Commits:** `072625ce`, `c5a2e2b1`

**Issue:** Epworth Healthcare was incorrectly showing under Tracey Bland's territory when it belongs to John Salisbury.

**Cause:** Hardcoded `CSE_CLIENTS` mapping had drifted from actual database assignments.

**Fix:**
- Replaced hardcoded mapping with database-driven CSE-client lookup
- Added alias resolution via `client_name_aliases` table
- Cross-references `client_segmentation` and `clients` tables

**Files:** `src/app/(dashboard)/planning/account/new/page.tsx`

---

### 3. ChaSen AI / Universal Search Button Border Inconsistency
**Commit:** `2698e666`

**Issue:** Border corners had inconsistent fills due to mixed rem and px units.

**Fix:** Standardised border-radius to pixel values:
- Outer: `rounded-[10px]`
- Inner: `rounded-[8px]`

**Files:** `src/components/layout/sidebar.tsx`

---

### 4. Sidebar Scrollbar White Background
**Commits:** `8e883f00`, `1cf80b54`

**Issue:** Scrollbar appeared with white background, not matching the purple sidebar theme.

**Cause:** Tailwind scrollbar utilities required an uninstalled plugin.

**Fix:**
- Created custom `.scrollbar-sidebar` CSS class
- Applied purple-themed colours matching sidebar gradient
- Increased scrollbar width to 8px for visibility

**Files:**
- `src/app/globals.css`
- `src/components/layout/sidebar.tsx`

---

## Features

### 5. Support Health Dashboard (Phases 1-4)
**Commit:** `9252f9d0`

Implemented comprehensive Support Health Dashboard with:
- Client support metrics table with health scores
- CSE/CAM profile photos displayed alongside metrics
- Column tooltips for Critical and Aging 30D+ columns
- Known Problems Panel for tracking issues

**Files:**
- `src/app/(dashboard)/support/page.tsx`
- `src/app/api/support-metrics/route.ts`
- `src/components/support/SupportOverviewTable.tsx`
- `src/components/support/KnownProblemsPanel.tsx`

---

### 6. CSE and CAM Display on Client Profile Cards
**Commit:** `6dab6e31`

Added display of both CSE and CAM assignments on client profile cards for better visibility of account ownership.

---

## Technical Improvements

### Database-Driven Mappings
Refactored from hardcoded constants to database queries with alias resolution. This pattern should be followed for all CSE/client relationship lookups.

### Alias Resolution Pattern
```typescript
// Build alias lookup map (any name -> canonical name)
const aliasMap = new Map<string, string>()
aliases.forEach(a => {
  if (a.display_name) aliasMap.set(a.display_name.toLowerCase(), a.canonical_name)
  if (a.canonical_name) aliasMap.set(a.canonical_name.toLowerCase(), a.canonical_name)
})

// Helper to get canonical name
const getCanonical = (name: string | null): string | null => {
  if (!name) return null
  return aliasMap.get(name.toLowerCase()) || name
}
```

---

## Bug Reports Created

| Report | Issue |
|--------|-------|
| `BUG-REPORT-20260108-azure-ad-duplicate-surname.md` | Azure AD name display fix |
| `BUG-REPORT-20260108-cam-account-plan-cse-client-mapping.md` | CSE-client mapping fix |

---

## Commits (Chronological)

| Commit | Description |
|--------|-------------|
| `072625ce` | fix: correct Epworth Healthcare CSE assignment in CAM Account Plan |
| `c5a2e2b1` | refactor: use database-driven CSE-client mapping with alias resolution |
| `2698e666` | fix: consistent border-radius for ChaSen AI and Universal Search buttons |
| `6dab6e31` | feat: display both CSE and CAM on client profile cards |
| `9252f9d0` | feat: implement Support Health Dashboard (Phases 1-4) |
| `8e883f00` | fix: sidebar scrollbar styling to match purple theme |
| `1cf80b54` | fix: apply scrollbar styling to entire sidebar container |
| `0c2a00f6` | fix: remove duplicate surname from Azure AD name display |
