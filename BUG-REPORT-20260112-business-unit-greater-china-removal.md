# Bug Report: Remove Greater China from Business Unit Planning

**Date:** 2026-01-12
**Severity:** Low (Data configuration)
**Status:** Resolved

## Summary
The Business Unit Planning page included "Greater China" as a region option, but APAC does not have clients in this region. The geographic hierarchy should be:
- **Business Unit:** APAC
- **Region 1:** ANZ (Australia & New Zealand)
- **Region 2:** SEA & Guam (South East Asia)

## Changes Made

### Business Unit Type
```typescript
// Before
type BusinessUnit = 'ANZ' | 'SEA' | 'Greater China'

// After
type BusinessUnit = 'ANZ' | 'SEA'
```

### Region Options
```typescript
// Before
const BUSINESS_UNITS = [
  { value: 'ANZ', label: 'Australia & New Zealand', flag: '🇦🇺' },
  { value: 'SEA', label: 'South East Asia', flag: '🇸🇬' },
  { value: 'Greater China', label: 'Greater China', flag: '🇨🇳' },
]

// After
const BUSINESS_UNITS = [
  { value: 'ANZ', label: 'Australia & New Zealand', flag: '🇦🇺' },
  { value: 'SEA', label: 'South East Asia', flag: '🇸🇬' },
]
```

### Client Patterns
- Removed all Greater China client patterns (Hong Kong, Taiwan, etc.)
- Added 'guam' and 'grmc' to SEA client patterns

### AI Summary Content
- Removed Greater China fallback text
- Updated SEA summary to mention Guam
- Changed "BU" terminology to "region" in outlook text

## Geographic Hierarchy (Post-Fix)

```
APAC (Business Unit)
├── ANZ (Region 1: Australia & New Zealand)
│   ├── SA Territory (CSE: Laura Messing, CAM: Anu)
│   ├── VIC + NZ Territory (CSE: Tracey Bland, CAM: Anu)
│   └── VIC + WA Territory (CSE: John, CAM: Anu)
│
└── SEA & Guam (Region 2: South East Asia)
    ├── Singapore + Philippines (CSE: Open Role, CAM: Nikki Wei)
    └── Guam (CSE: Open Role, CAM: Nikki Wei)
```

## Files Modified
- `src/app/(dashboard)/planning/business-unit/page.tsx`

## Testing Performed
- [x] Build passes without TypeScript errors
- [x] Region dropdown shows only ANZ and SEA
- [x] SEA client patterns include Guam
- [x] AI summary content updated
