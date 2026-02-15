# Bug Fix: Seg% Real Data Resolution and Color Coding

**Date:** 2026-01-10
**Severity:** Medium
**Status:** Resolved

## Summary

Two issues were identified with the Seg% (Segmentation Compliance Percentage) column in Client Portfolios:
1. All values were showing 50% (placeholder data) instead of real compliance data
2. Values had no color coding to indicate compliance status

## Root Cause Analysis

### Issue 1: Placeholder Data (All 50%)

**Problem:** The `client_health_summary` materialized view was unable to join compliance data from `segmentation_event_compliance` because of client name mismatches. For example:
- View used: `Albury Wodonga Health` (canonical name)
- Compliance table used: `Albury Wodonga` (display name/alias)

**Solution:** Updated `/api/clients/route.ts` to:
1. Fetch compliance data from `segmentation_event_compliance`
2. Fetch client name aliases from `client_name_aliases`
3. Build a reverse lookup map (canonical_name → display_names)
4. Resolve compliance values using alias matching
5. Use most recent year's data (handles fiscal year transitions)

**Key Code Changes:**

```typescript
// Fetch real compliance data from segmentation_event_compliance
const currentYear = new Date().getFullYear()
const { data: complianceData } = await supabaseAdmin
  .from('segmentation_event_compliance')
  .select('client_name, compliance_percentage, year')
  .gte('year', currentYear - 1) // Get current or previous year
  .order('year', { ascending: false })

// Create canonical -> aliases map for compliance lookup
const canonicalToAliases = new Map<string, string[]>()
if (aliasData) {
  for (const alias of aliasData) {
    const existing = canonicalToAliases.get(alias.canonical_name) || []
    existing.push(alias.display_name)
    canonicalToAliases.set(alias.canonical_name, existing)
  }
}

// Helper to resolve compliance using aliases
const resolveCompliance = (clientName: string): number | null => {
  if (complianceByClient.has(clientName)) {
    return complianceByClient.get(clientName) || null
  }
  const aliases = canonicalToAliases.get(clientName) || []
  for (const alias of aliases) {
    if (complianceByClient.has(alias)) {
      return complianceByClient.get(alias) || null
    }
  }
  return null
}
```

### Issue 2: Missing Color Coding

**Problem:** The Seg% column in list view had no color coding, making it difficult to quickly identify compliance status.

**Location:** `src/app/(dashboard)/client-profiles/page.tsx:1093-1110`

**Solution:** Applied the same color logic used in card view:
- **Green (>=80%)**: Compliant
- **Yellow (50-79%)**: Warning
- **Red (<50%)**: Non-compliant

**Before:**
```typescript
<span className="text-sm font-medium text-gray-700">
  {client.compliance_percentage !== null
    ? `${client.compliance_percentage}%`
    : '-'}
</span>
```

**After:**
```typescript
<span
  className={`text-sm font-medium ${
    client.compliance_percentage !== null &&
    client.compliance_percentage !== undefined
      ? client.compliance_percentage >= 80
        ? 'text-green-600'
        : client.compliance_percentage >= 50
          ? 'text-yellow-600'
          : 'text-red-600'
      : 'text-gray-400'
  }`}
>
  {client.compliance_percentage !== null
    ? `${client.compliance_percentage}%`
    : '-'}
</span>
```

## Files Changed

### 1. `src/app/api/clients/route.ts`
- Added compliance data fetch from `segmentation_event_compliance`
- Added client alias lookup for name resolution
- Built reverse alias map (canonical → display names)
- Created `resolveCompliance()` helper function
- Enriched response with real compliance data

### 2. `src/app/(dashboard)/client-profiles/page.tsx`
- Added color coding logic to Seg% column in list view

### 3. `docs/migrations/20260110_fix_compliance_join_with_aliases.sql`
- Created SQL migration for future materialized view fix (not yet applied)

## Testing

### Verified Compliance Values
| Client | Expected | Actual | Status |
|--------|----------|--------|--------|
| GRMC | 60% | 60% | ✅ Yellow |
| NCS/MinDef | 80% | 80% | ✅ Green |
| RVEEH | 86% | 86% | ✅ Green |
| Te Whatu Ora | 68% | 68% | ✅ Yellow |
| SingHealth | 95% | 95% | ✅ Green |
| Western Health | 69% | 69% | ✅ Yellow |
| WA Health | 40% | 40% | ✅ Red |

## Technical Notes

### Year Logic
The compliance data uses `gte('year', currentYear - 1)` to handle cases where:
- Current year data doesn't exist yet (fiscal year hasn't started)
- Some clients use calendar year (Jan-Dec)
- Some clients use fiscal year (Jul-Jun or Sep-Jun)

### Future Enhancement
A `docs/migrations/20260110_fix_compliance_join_with_aliases.sql` migration was created to fix the materialized view directly. This would improve performance by doing the alias resolution in PostgreSQL rather than the API layer.

## Impact

- **Data Accuracy:** Real compliance percentages now displayed instead of 50% placeholder
- **Visual Clarity:** Color coding provides instant compliance status recognition
- **Consistency:** List view now matches card view styling

## Related

- BUG-FIX-team-tab-and-portfolio-filter.md (same session - CAM fixes)
- client_name_aliases table documentation
