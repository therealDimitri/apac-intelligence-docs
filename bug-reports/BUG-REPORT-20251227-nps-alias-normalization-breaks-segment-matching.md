# Bug Report: NPS Alias Normalisation Breaks Segment Matching

**Date**: 2025-12-27
**Status**: Fixed
**Severity**: High
**Commit**: `3962e41`

## Issue

NPS Topic Analysis was showing "No topics identified" for the Sleeping Giant segment despite having 20 NPS responses from SingHealth in the database. The root cause was incorrect use of client alias normalisation when matching feedbacks to segments.

### Symptoms

**Expected:**
- Sleeping Giant segment: 20 feedbacks from SingHealth
- Topics: Configuration & Customisation (3), Product & Features (2), User Experience (1), etc.

**Actual:**
- Sleeping Giant segment: 0 feedbacks
- Topics: "No topics identified"

## Root Cause

The `analyzeTopicsBySegment()` function in `src/lib/topic-extraction.ts` was normalising feedback client names using the `client_name_aliases` table, but then comparing against un-normalised `nps_clients` entries.

### The Problem

Both `nps_responses.client_name` and `nps_clients.client_name` use the **display name** format (e.g., "SingHealth"). The alias table maps display names to canonical names:

```
display_name: "SingHealth" → canonical_name: "Singapore Health Services Pte Ltd"
```

The broken code was doing:
1. Take feedback from `nps_responses` with `client_name = "SingHealth"`
2. Normalise to canonical name: `"Singapore Health Services Pte Ltd"`
3. Compare to `nps_clients.client_name` which is `"SingHealth"`
4. `"Singapore Health Services Pte Ltd" !== "SingHealth"` → **NO MATCH**

### Broken Code

```typescript
// Created alias map for normalisation
const aliasMap = new Map<string, string>()
for (const alias of clientAliases) {
  aliasMap.set(alias.display_name, alias.canonical_name)
}

const normalizeClientName = (name: string): string => {
  return aliasMap.get(name) || name
}

// PROBLEM: Normalised feedback name but compared to un-normalised nps_clients
for (const feedback of feedbacks) {
  const normalizedName = normalizeClientName(feedback.client_name)  // "SingHealth" → "Singapore Health Services Pte Ltd"
  const client = clients.find(c => c.client_name === normalizedName) // Comparing to "SingHealth" - NO MATCH!
  // ...
}
```

## Fix Applied

Removed alias normalisation entirely since both tables use the same naming convention. The alias table is for UI display purposes, not for matching between `nps_responses` and `nps_clients`.

### Changes

**1. Removed alias map and normalisation helper:**

```typescript
// BEFORE
const aliasMap = new Map<string, string>()
for (const alias of clientAliases) {
  aliasMap.set(alias.display_name, alias.canonical_name)
}
const normalizeClientName = (name: string): string => {
  return aliasMap.get(name) || name
}

// AFTER
// NOTE: clientAliases parameter is kept for backwards compatibility but not used here.
// Both nps_responses and nps_clients use the same naming convention (display names),
// so no normalization is needed for matching. Aliases are for UI display purposes.
```

**2. Direct comparison instead of normalisation:**

```typescript
// BEFORE
const normalizedName = normalizeClientName(feedback.client_name)
const client = clients.find(c => c.client_name === normalizedName)

// AFTER
const client = clients.find(c => c.client_name === feedback.client_name)
```

**3. Fixed parent-child aggregation to also use direct comparison:**

```typescript
// BEFORE
const hasFeedbacks = segmentFeedbacks.some(f => {
  const normalizedName = normalizeClientName(f.client_name)
  return normalizedName === clientName
})

// AFTER
const hasFeedbacks = segmentFeedbacks.some(f => f.client_name === clientName)
```

**4. Incremented cache version:**

```typescript
const CACHE_VERSION = 'v4' // Fix alias normalization breaking segment matching
```

## Files Changed

- `src/lib/topic-extraction.ts` - Removed alias normalisation logic
- `src/app/(dashboard)/nps/page.tsx` - Incremented cache version to v4

## Verification

After the fix (verified locally):
```
[LOG] [Topic Analysis] Sleeping Giant segment: 20 feedbacks BEFORE aggregation
[LOG] [Topic Analysis] FINAL Sleeping Giant results:
[LOG] [Topic Analysis]   - Client count: 2
[LOG] [Topic Analysis]   - Latest cycle feedbacks: 5
[LOG] [Topic Analysis]   - Latest cycle topics: 5
[LOG] [Topic Analysis]   - All time feedbacks: 20
[LOG] [Topic Analysis]   - All time topics: 6
```

Sleeping Giant now correctly shows:
- #1 Configuration & Customisation (3 mentions, positive)
- #2 Product & Features (2 mentions, positive)
- #3 User Experience (1 mention, positive)
- #4 Account Management (1 mention, positive)
- #5 Collaboration & Partnership (1 mention, positive)

## Impact

This bug affected any segment where client names in `nps_responses` matched entries in the `client_name_aliases` table. The normalisation converted display names to canonical names, but `nps_clients` uses display names, causing zero matches.

Affected segments:
- **Sleeping Giant** - SingHealth and WA Health (both have alias entries)

## Related Bugs

- `BUG-REPORT-20251227-nps-topics-multi-topic-overwrite.md` - Fixed in same session (v3)

## Prevention

- Added clear documentation comments explaining that aliases are for UI display, not for matching between NPS tables
- The `clientAliases` parameter is kept for backwards compatibility but explicitly documented as unused for segment matching
