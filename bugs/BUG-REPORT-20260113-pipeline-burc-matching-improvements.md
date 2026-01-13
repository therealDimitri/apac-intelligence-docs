# Bug Report: BURC Cross-Reference Matching Improvements

**Date:** 13 January 2026
**Status:** Improved (Partial Fix)
**Severity:** Medium
**Component:** 2026 Pipeline Page - BURC Cross-Reference

## Issue Description

The BURC cross-reference matching was not finding all expected matches between the Sales Budget pipeline and the BURC Performance file. The user expected the following counts from the BURC file:

- **R&M Sheet:** 27 Pipeline (Green)
- **Dial 2 Sheet:**
  - 15 Best Case (Green)
  - 2 Backlog (Green)
  - 9 Business Case
  - 6 Best Case (Yellow)
  - 1 Best Case (Red)
  - 17 Pipeline (not included in forecast)

**Total Expected:** 77 entries in BURC

However, the matching was only finding approximately 34 matches initially.

## Root Cause Analysis

Multiple factors contributed to the matching issues:

1. **Missing Section Detection:** The "Pipeline (not included in forecast)" section in Dial 2 sheet was not being detected, causing 17 entries to not be categorised correctly.

2. **Oracle Number Format Differences:** Some BURC entries have Oracle numbers with letter suffixes (e.g., "545891a") while Sales Budget has base numbers (e.g., "545891").

3. **Different Opportunity Names:** The opportunity names in Sales Budget often differ significantly from those in BURC, making name-based matching unreliable.

4. **No Account Name in BURC:** The BURC file contains account IDs (e.g., "46023") instead of account names, preventing account-based matching.

5. **Many Sales Budget Entries Not in BURC:** A significant portion of the 155 Sales Budget opportunities simply don't exist in the BURC forecast file.

## Solution Implemented

### 1. Added Pipeline Not Included Section Detection

Updated `parseBURCFile()` to detect "Pipeline (not included in forecast)" section:

```typescript
} else if (
  firstCellLower.includes('pipeline') &&
  firstCellLower.includes('not included')
) {
  currentSection = 'dial2-pipeline-not-included'
  continue
}
```

### 2. Added New BURC Status

Created `pipeline-not-forecast` status for entries that are in BURC but not included in the forecast:

```typescript
burcStatus:
  | 'best-case'
  | 'backlog-green'
  | 'backlog-yellow'
  | 'backlog-red'
  | 'business-case'
  | 'pipeline-not-forecast'  // NEW
  | 'not-in-burc'
```

### 3. Oracle Number Prefix Matching

Added logic to match Oracle numbers by stripping letter suffixes:

```typescript
const baseOracleKey = oracleKey.replace(/[a-zA-Z]+$/, '')
for (const [burcOracle, entry] of byOracleNumber) {
  const baseBurcOracle = burcOracle.replace(/[a-zA-Z]+$/, '')
  if (baseOracleKey === baseBurcOracle || baseOracleKey === burcOracle || oracleKey === baseBurcOracle) {
    return mapBURCEntryToStatus(entry)
  }
}
```

### 4. Composite Key Matching (Attempted)

Added a third index for matching by name + account + ACV combination. However, this has limited effectiveness due to BURC having account IDs instead of names.

### Matching Priority Order

1. **Exact Oracle Quote Number match**
2. **Oracle number prefix match** (strips trailing letters)
3. **Composite key match** (name + account + ACV)
4. **Exact opportunity name match**
5. **Partial name match** (contains logic)

## Results After Fix

| Metric | Before | After | Expected |
|--------|--------|-------|----------|
| Not in BURC | 121 | 106 | ~78* |
| Best Case | 6 | 6 | 22 |
| Total Backlog | 28 | 28 | 29 |

*Note: Expected "Not in BURC" is 155 - 77 = 78, assuming all BURC entries have corresponding Sales Budget entries.

## Known Limitations

1. **Name Mismatch:** Sales Budget opportunity names (e.g., "20250519 Barwon Health Add iPM...") don't match BURC names (e.g., "awh clinical alerts manager")

2. **Missing Oracle Numbers:** Many Sales Budget entries have no Oracle number, making matching impossible for those entries

3. **Account ID vs Name:** BURC uses account IDs while Sales Budget uses account names, preventing account-based correlation

4. **Different Data Sources:** The Sales Budget and BURC files track different subsets of opportunities

## Recommendations for Further Improvement

1. **Manual Mapping Table:** Create a lookup table that maps Sales Budget opportunity IDs to BURC entry names

2. **Fuzzy Name Matching:** Implement Levenshtein distance or similar algorithm for flexible name matching

3. **Add Oracle Numbers to Sales Budget:** Ensure all Sales Budget entries have Oracle Quote Numbers

4. **Standardise Naming Convention:** Use consistent opportunity naming between Sales Budget and BURC

## Files Modified

- `src/app/api/pipeline/2026/route.ts`
  - Added `pipeline-not-forecast` status
  - Added Pipeline Not Included section detection
  - Added Oracle prefix matching
  - Added composite key matching infrastructure
  - Enhanced BURCEntry interface with accountName and acv fields

- `src/app/(dashboard)/pipeline/page.tsx`
  - Added `pipeline-not-forecast` to BURC_STATUS_CONFIG with grey styling

## Verification

- Build passes with zero TypeScript errors
- Pipeline Not Included section now properly detected (15 entries moved from "Not in BURC")
- New status displays correctly in the UI

## Commit

```
a1afdda3 - feat: Improve BURC cross-reference matching with multiple strategies
```
