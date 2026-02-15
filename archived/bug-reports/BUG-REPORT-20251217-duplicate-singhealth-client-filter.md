# Bug Report: Duplicate SingHealth Client in Priority Matrix Filter

**Date:** 2025-12-17
**Status:** Fixed
**Severity:** Low (UI/Display issue)
**Component:** Priority Matrix Client Filter

## Issue Description

The client dropdown filter in the Priority Matrix was displaying duplicate entries for SingHealth:

- "SingHealth"
- "Singapore Health Services Pte..."

These should be merged and displayed as a single "SingHealth" entry.

## Root Cause

The `CONFIRMED_ATTRITION` constant in `ActionableIntelligenceDashboard.tsx` was using legacy client names that didn't match the canonical database names:

```typescript
// BEFORE (incorrect)
const CONFIRMED_ATTRITION = [
  { client: 'Singapore Health Services Pte Ltd', year: 2029, reason: 'Contract expiration' },
  { client: 'Ministry of Defence, Singapore', year: 2029, reason: 'Contract expiration' },
]
```

This caused items with these legacy names to appear alongside items using canonical names from the database, resulting in duplicate client entries in the filter dropdown.

## Investigation

1. Checked all database tables (actions, unified_meetings, segmentation_events, nps_responses, clients, client_health_materialized) - all consistently use "SingHealth"
2. Grep search found the legacy name hardcoded in `CONFIRMED_ATTRITION`
3. The client name mapper (`client-name-mapper.ts`) has `SingHealth` as a canonical name, but the legacy `Singapore Health Services Pte Ltd` was used directly without mapping

## Solution

Updated `CONFIRMED_ATTRITION` to use canonical client names:

```typescript
// AFTER (correct)
const CONFIRMED_ATTRITION = [
  { client: 'SingHealth', year: 2029, reason: 'Contract expiration' },
  { client: 'NCS/MinDef Singapore', year: 2029, reason: 'Contract expiration' },
]
```

## Files Modified

- `src/components/ActionableIntelligenceDashboard.tsx` - Updated client names in CONFIRMED_ATTRITION

## Prevention

When adding client names to any constant or configuration:

1. Always use canonical names from `docs/database-schema.md` or `client-name-mapper.ts`
2. Never hardcode legacy client names like "Singapore Health Services Pte Ltd"
3. Reference `DISPLAY_NAMES` in `client-name-mapper.ts` for the authoritative list

## Related Files

- `src/lib/client-name-mapper.ts` - Canonical name definitions
- `src/lib/client-logos-local.ts` - Client logo mappings with aliases
- `src/components/priority-matrix/MatrixFilterBar.tsx` - Client filter implementation

## Commit

`0bafc31` - fix(dashboard): use canonical client names in CONFIRMED_ATTRITION
