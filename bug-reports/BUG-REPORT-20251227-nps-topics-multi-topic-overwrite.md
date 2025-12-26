# Bug Report: NPS Topics Multi-Topic Overwrite

**Date**: 2025-12-27
**Status**: Fixed
**Severity**: High

## Issue

NPS Topic Analysis was missing topics for responses that had multiple topic classifications. The "Account Management" topic (with 3 mentions) was completely missing from the Leverage segment display, even though it existed in the database.

### Symptoms

**Expected (Database Reality) - Leverage Q4 25:**
- #1 Account Management (positive): 3 mentions
- #2 Support & Service (positive): 2 mentions
- #3 Product & Features (neutral/negative): 2 mentions

**Actual (UI Display):**
- #1 Support & Service (positive): 2 mentions
- #2 Product & Features (negative): 1 mention

Account Management was completely missing despite being the most mentioned topic.

## Root Cause

The `getCachedClassifications()` function in `src/lib/topic-extraction.ts` was using a **Map** that stored only **one** classification per response_id. However, 68 out of 80 NPS responses have **multiple topics** assigned to them.

### Broken Code

```typescript
// OLD: Map only stores ONE value per key - overwrites previous entries!
const cacheMap = new Map<string | number, { topic_name: string; ... }>()

for (const classification of cached) {
  // This OVERWRITES previous classifications for the same response_id
  cacheMap.set(classification.response_id, { ... })
}
```

For example, response ID 920 had both "Account Management" and "Support & Service" topics. Only the last one (Support & Service) was kept, causing Account Management to be lost.

## Fix Applied

Changed `getCachedClassifications()` to return an **array** of classifications per response_id, and updated `analyzeTopics()` to flatten these arrays when processing:

### 1. Updated Return Type

```typescript
// NEW: Map stores ARRAY of classifications per response_id
async function getCachedClassifications(responseIds: Array<string | number>): Promise<
  Map<
    string | number,
    Array<{ topic_name: string; sentiment: ...; insight: string; confidence_score: number }>
  >
>
```

### 2. Fixed Map Building

```typescript
for (const classification of cached) {
  if (!cacheMap.has(classification.response_id)) {
    cacheMap.set(classification.response_id, [])
  }
  cacheMap.get(classification.response_id)!.push({ ... })
}
```

### 3. Updated analyzeTopics() to Flatten Arrays

```typescript
classifications = Array.from(cachedClassifications.entries()).flatMap(
  ([id, classificationArray]) =>
    classificationArray.map(classification => ({ ... }))
)
```

### 4. Incremented Cache Version

```typescript
const CACHE_VERSION = 'v3' // Force cache refresh to apply fix
```

## Files Changed

- `src/lib/topic-extraction.ts` - Fixed multi-topic handling
- `src/app/(dashboard)/nps/page.tsx` - Incremented cache version to v3

## Verification

After the fix:
- Console shows: `Found 14 cached classifications` for 6 Leverage responses (vs. 6 before)
- Leverage Q4 25 now correctly shows:
  - #1 Account Management (3 mentions, positive) ✅
  - #2 Support & Service (2 mentions, positive)
  - #3 Product & Features (2 mentions, negative)

## Impact

This bug affected all segments and all time periods. Any response with multiple topic classifications was only showing the last topic instead of all topics. This significantly understated topic mention counts and could hide important feedback themes.

## Prevention

- Added clear documentation comment about multi-topic support
- The fix uses standard JavaScript patterns (array per key, flatMap) that are more intuitive than single-value overwriting
