# Bug Report: CSI Ratios Display Issues in Email Templates

**Date:** 2025-01-27
**Severity:** Medium
**Status:** Fixed

## Summary

Two display issues in the CSI Operating Ratios section of email templates:
1. G&A Ratio showing 1622% instead of 16.2%
2. Goals missing comparison operators (>=, <=)

## Root Cause Analysis

### Issue 1: G&A Ratio Multiplied by 100 Twice

**Location:** `/src/lib/emails/ai-email-generator.ts` line 1337

**Problem:** The G&A ratio value was being multiplied by 100 in the email template display, but the value was already stored as a percentage (e.g., 16.2 representing 16.2%) from the data aggregator.

**Code Before:**
```typescript
${teamData.csiRatios.gaRatio !== undefined ? (teamData.csiRatios.gaRatio * 100).toFixed(0) + '%' : 'N/A'}
```

This caused 16.2 to become 1620%, displayed as 1622% after rounding.

**Code After:**
```typescript
${teamData.csiRatios.gaRatio !== undefined ? teamData.csiRatios.gaRatio.toFixed(1) + '%' : 'N/A'}
```

### Issue 2: Goals Missing Comparison Operators

**Location:** `/src/lib/emails/ai-email-generator.ts` lines 1291, 1304, 1317, 1330, 1343

**Problem:** Goals were displayed without the comparison operator, making it unclear whether the target is a minimum (>=) or maximum (<=).

**Before:**
- PS: "Goal: 2"
- Maintenance: "Goal: 4"
- Sales: "Goal: 1"
- R&D: "Goal: 1.0" (or fallback ">=1.0")
- G&A: "Goal: 20%" (or fallback "<=20%")

**After:**
- PS: "Goal: >=2"
- Maintenance: "Goal: >=4"
- Sales: "Goal: >=1"
- R&D: "Goal: >=1"
- G&A: "Goal: <=20%"

## Files Changed

- `/src/lib/emails/ai-email-generator.ts`
  - Line 1291: Added >= prefix to PS goal
  - Line 1304: Added >= prefix to Maintenance goal
  - Line 1317: Added >= prefix to Sales goal
  - Line 1330: Added >= prefix to R&D goal
  - Line 1337: Removed `* 100` from G&A ratio display, added one decimal place
  - Line 1343: Changed to use <= prefix with % suffix for G&A goal

## Testing

1. Build verification: `npm run build` passes with zero errors
2. The CSI ratios section now displays:
   - G&A Ratio: "16.2%" (correct percentage)
   - PS Goal: ">=2"
   - Maintenance Goal: ">=4"
   - Sales Goal: ">=1"
   - R&D Goal: ">=1"
   - G&A Goal: "<=20%"

## Impact

- All team email reports with CSI ratios section
- Affected the visual display only, not underlying calculations
- G&A ratio status calculations were already correct (using 20.0 as threshold)

## Lessons Learned

1. When displaying percentages, verify whether the source value is already a percentage or a decimal
2. Goal displays should always include comparison operators to indicate direction
3. The data aggregator documentation at line 628-631 clearly states G&A is calculated as `G&A OPEX / Total Net Revenue x 100`, meaning it's already a percentage
