# Bug Report: SA Health Meetings Not Matching Correct Client Variant

**Date**: 7 January 2026
**Status**: Fixed
**Severity**: Medium
**Component**: Outlook Import - Client Matching

## Issue

When importing meetings from Outlook, meetings with "SA Health iPro" or other SA Health variants in the subject were being matched to the generic "SA Health" client instead of the specific variant (e.g., "SA Health (iPro)").

This caused meetings to appear with the wrong client assignment in the Briefing Room.

## Root Cause

The `KNOWN_CLIENTS` array in `src/lib/microsoft-graph.ts` only contained the generic `'SA Health'` entry. The `extractClientName()` function checks clients in order and returns the first match, so any SA Health variant would match the generic entry first.

## Solution

1. **Added specific SA Health variants to KNOWN_CLIENTS** (in priority order):
   - `SA Health iPro`
   - `SA Health (iPro)`
   - `SA Health iQemo`
   - `SA Health (iQemo)`
   - `SA Health Sunrise`
   - `SA Health (Sunrise)`
   - `SA Health` (generic fallback - checked last)

2. **Created normalisation function** `normaliseSAHealthClientName()`:
   - Maps variations to database format
   - e.g., "SA Health iPro" → "SA Health (iPro)"

## Database Context

The `clients` table contains 4 SA Health entries:
| canonical_name | display_name |
|----------------|--------------|
| SA Health | SA Health |
| SA Health iPro | SA Health (iPro) |
| SA Health iQemo | SA Health (iQemo) |
| SA Health Sunrise | SA Health (Sunrise) |

## Files Modified

- `src/lib/microsoft-graph.ts`
  - Updated `KNOWN_CLIENTS` array with specific variants before generic
  - Added `normaliseSAHealthClientName()` function
  - Updated `extractClientName()` to use normalisation

## Testing

1. Create an Outlook meeting with subject containing "SA Health iPro"
2. Open Outlook import modal in Briefing Room
3. Verify the meeting shows client as "SA Health (iPro)"
4. Repeat for iQemo and Sunrise variants

## Prevention

Added a comment in the code explaining that **order matters** in the KNOWN_CLIENTS array:
```typescript
/**
 * IMPORTANT: Order matters! More specific names must come BEFORE generic ones.
 * e.g., "SA Health iPro" must be listed before "SA Health" to avoid incorrect matching.
 */
```
