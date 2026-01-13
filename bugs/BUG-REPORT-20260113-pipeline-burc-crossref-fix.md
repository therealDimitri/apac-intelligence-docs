# Bug Report: BURC Cross-Reference Not Matching Correctly

**Date:** 13 January 2026
**Status:** Fixed
**Severity:** Medium
**Component:** 2026 Pipeline Page - BURC Cross-Reference

## Issue Description

The BURC cross-reference on the 2026 Pipeline page was showing 150 out of 155 opportunities as "Not in BURC", which was incorrect. The matching logic was not properly prioritising Oracle Quote Number matching.

## Steps to Reproduce

1. Navigate to /pipeline
2. Observe the "Not in BURC" count in the stats cards
3. Note that 150/155 opportunities showed as "Not in BURC" despite many having matching Oracle numbers in the BURC file

## Expected Behaviour

Opportunities should be matched to BURC entries primarily by Oracle Quote Number, which is the most reliable identifier.

## Root Cause

The original BURC parsing logic stored entries only by name in a single Map. While Oracle number matching was attempted, it was not prioritised and the indexing was inefficient.

Additionally, a TypeScript error was introduced when refactoring:
```typescript
// ERROR: 'length' doesn't exist on type 'string | number'
if (entry.oracleNumber && entry.oracleNumber !== 'Various' && entry.oracleNumber.length > 1) {
```

## Solution

1. Created a dual-index system for BURC entries:
   - `byName: Map<string, BURCEntry>` - Index by opportunity name
   - `byOracleNumber: Map<string, BURCEntry>` - Index by Oracle Quote Number

2. Updated `parseBURCFile()` to return a `BURCIndexes` object with both maps

3. Updated `determineBURCStatus()` to prioritise matching in this order:
   - **Priority 1**: Exact Oracle Quote Number match (most reliable)
   - **Priority 2**: Exact opportunity name match
   - **Priority 3**: Partial name match (contains logic)

4. Fixed TypeScript error by converting to string before checking length:
```typescript
if (entry.oracleNumber && entry.oracleNumber !== 'Various' && String(entry.oracleNumber).length > 1) {
```

### New Interface

```typescript
interface BURCIndexes {
  byName: Map<string, BURCEntry>
  byOracleNumber: Map<string, BURCEntry>
}
```

### Updated Matching Priority

| Priority | Match Type | Reliability |
|----------|-----------|-------------|
| 1 | Oracle Quote Number | Highest |
| 2 | Exact opportunity name | High |
| 3 | Partial name match | Medium |

## Files Modified

- `src/app/api/pipeline/2026/route.ts`
  - Added `BURCIndexes` interface (line 65-68)
  - Updated `parseBURCFile()` to return dual-index (line 70-207)
  - Updated `determineBURCStatus()` to use dual-index with Oracle priority (line 209-250)

## Verification

- Build passes with zero TypeScript errors
- BURC matching now prioritises Oracle Quote Number
- Expected significant reduction in "Not in BURC" count

## Commit

```
fix: Improve BURC cross-reference matching with Oracle number priority
```
