# Bug Fix: CAM Assignments Missing in Top Critical Accounts Table

**Date**: 2026-01-13
**Commit**: `a3f042fa`
**Component**: Invoice Tracker API - Aging By CSE

## Problem

The CAM (Client Account Manager) column in the Top Critical Accounts table on the Working Capital page was showing "-" for all clients, even though CAM assignments existed in the `nps_clients` table.

### Root Cause

Client names from the Invoice Tracker system didn't match the client names stored in the `nps_clients` table. The original implementation only used exact string matching.

**Examples of mismatches**:
- Invoice Tracker: `Singapore Health Services Pte Ltd` → nps_clients: `SingHealth`
- Invoice Tracker: `St Luke's Medical Center Global City Inc` → nps_clients: `Saint Luke's Medical Centre (SLMC)`
- Invoice Tracker: `National Cancer Centre Of Singapore` → nps_clients: `NCC`

## Solution

Implemented a multi-tier fuzzy matching system in `/src/app/api/invoice-tracker/aging-by-cse/route.ts`:

### 1. Normalisation Function

```typescript
function normaliseClientName(name: string): string {
  return name
    .toLowerCase()
    .replace(/\s+(pte|pty|ltd|inc|corp|limited|hospital|health|medical|centre|center|services|of|the)\.?/gi, '')
    .replace(/[^a-z0-9]/g, '')
    .trim()
}
```

Strips common business suffixes and non-alphanumeric characters to create comparable strings.

### 2. Client Alias Mapping

```typescript
const CLIENT_ALIASES: Record<string, string[]> = {
  singapore: ['singhealth'],
  stlukesglobalcity: ['saintlukesslmc', 'saintlukes', 'stlukes'],
  nationalcancersingapore: ['ncc', 'nationalcancer'],
  strategicasiapacificpartners: ['sapp', 'strategicasia'],
  sengkanggeneral: ['sengkang'],
}
```

Maps normalised Invoice Tracker names to known aliases in nps_clients.

### 3. Multi-Tier Matching (`findCAMForClient`)

The function attempts matches in this order:
1. **Exact match** - Case-insensitive direct comparison
2. **Normalised match** - Compare normalised strings
3. **Alias match** - Check if normalised name has known aliases
4. **Partial match** - Check if either name contains the other

## Files Changed

| File | Changes |
|------|---------|
| `src/app/api/invoice-tracker/aging-by-cse/route.ts` | Added fuzzy matching functions and alias mapping |

## Testing

Verified in browser that CAM column now correctly displays:
- **Singapore Health Services Pte Ltd** → **Nikki Wei**
- **St Luke's Medical Center Global City Inc** → **Nikki Wei**

Clients without CAM entries in nps_clients continue to show "-" as expected.

## Related

- Previous commit `72e0348a` added initial CAM lookup with exact matching
- The `nps_clients` table is the source of truth for CAM assignments
