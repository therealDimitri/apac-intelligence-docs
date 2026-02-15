# Bug Report: CSE/CAM Partnership Structure

**Date:** 10 January 2026
**Type:** Data Model Fix
**Status:** Resolved
**Commit:** c290acd4

---

## Issue

The CSE Performance Dashboard was showing incorrect team structure. The dashboard displayed:
- "3 CSEs" for Australia+NZ region (incorrect)
- Duplicate target entries for CSEs and CAMs separately

The user clarified that the correct structure is:
- CSE and CAM are **partners** who share the same targets
- Anu Pradhan (CAM) supports ALL ANZ CSEs: Tracey Bland, John Salisbury, Laura Messing
- Nikki Wei (CAM) supports the Asia+Guam CSE: Open Role
- CAM targets = aggregation of their supported CSEs' targets (not separate entries)

---

## Root Cause

1. **Seed Data Issue:** The `cse_cam_targets` table had separate target rows for CAMs, which duplicated the targets instead of aggregating them
2. **Missing CAM Mapping:** The territory mapping (`CSE_TERRITORY_MAP`) didn't include CAM partner information
3. **Display Issue:** The dashboard components didn't show the CSE/CAM partnership relationship

---

## Resolution

### 1. Database Fix
Deleted duplicate CAM target rows from `cse_cam_targets` table. CAM targets should be calculated as the sum of their supported CSEs, not stored separately.

### 2. Context Updates (`PlanningPortfolioContext.tsx`)

Added CAM partner mapping to `CSE_TERRITORY_MAP`:
```typescript
export const CSE_TERRITORY_MAP: Record<
  string,
  { territory: string; region: RegionType; cam: string }
> = {
  'Tracey Bland': { territory: 'VIC + NZ', region: 'Australia+NZ', cam: 'Anu Pradhan' },
  'John Salisbury': { territory: 'WA + VIC', region: 'Australia+NZ', cam: 'Anu Pradhan' },
  'Laura Messing': { territory: 'SA', region: 'Australia+NZ', cam: 'Anu Pradhan' },
  'Open Role': { territory: 'Asia + Guam', region: 'Asia+Guam', cam: 'Nikki Wei' },
}
```

Added new `CAM_CSE_MAP` for reverse lookup:
```typescript
export const CAM_CSE_MAP: Record<string, { cses: string[]; region: RegionType }> = {
  'Anu Pradhan': { cses: ['Tracey Bland', 'John Salisbury', 'Laura Messing'], region: 'Australia+NZ' },
  'Nikki Wei': { cses: ['Open Role'], region: 'Asia+Guam' },
}
```

### 3. Component Updates

**CSEPerformanceDashboard.tsx:**
- Added `cam_name` to `CSEPerformance`, `TerritoryRollup`, and `RegionRollup` interfaces
- CSE cards now display "CAM: Anu Pradhan" or "CAM: Nikki Wei"

**RegionView.tsx:**
- Region cards now show CAM name (e.g., "CAM: Anu Pradhan")
- Fixed singular/plural grammar for territories

---

## Correct Team Structure

| Region | CSEs | CAM | Notes |
|--------|------|-----|-------|
| Australia+NZ | Tracey Bland (VIC + NZ) | Anu Pradhan | CAM supports all 3 CSEs |
| Australia+NZ | John Salisbury (WA + VIC) | Anu Pradhan | Shared targets |
| Australia+NZ | Laura Messing (SA) | Anu Pradhan | Shared targets |
| Asia+Guam | Open Role (Asia + Guam) | Nikki Wei | 1 CSE + 1 CAM |

---

## Files Changed

- `src/contexts/PlanningPortfolioContext.tsx` - Added CAM mapping and type updates
- `src/components/planning/CSEPerformanceDashboard.tsx` - Display CAM on cards
- `src/components/planning/RegionView.tsx` - Display CAM on region cards
- `src/app/(dashboard)/planning/page.tsx` - Pass cam_name in transformation

---

## Testing

1. Build verification: `npm run build` passes
2. Visual verification: CSE cards show CAM partner
3. Region view shows correct counts (3 CSEs for ANZ, 1 for Asia+Guam) with CAM

---

## Screenshots

Screenshots saved to:
- `/Users/jimmy.leimonitis/.playwright-mcp/planning-cse-cam-partnerships.png`
- `/Users/jimmy.leimonitis/.playwright-mcp/planning-region-cam-partnerships.png`
