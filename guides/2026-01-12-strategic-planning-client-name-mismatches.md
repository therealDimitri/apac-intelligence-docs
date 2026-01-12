# Bug Report: Strategic Planning - Client Name Mismatches

**Date:** 12 January 2026
**Status:** Resolved
**Type:** Bug Fix
**Severity:** Medium

## Summary

Fixed multiple client name mismatch issues affecting the Strategic Planning Portfolio view:
1. RVEEH logo not displaying (showing fallback initials "RV")
2. WA Health missing from John Salisbury's portfolio
3. RVEEH health data, NPS, and segment not loading
4. WA Health pipeline data (Weighted ACV, Total ACV) not loading
5. TCV column showing "-" for all clients (not being aggregated from pipeline)

## Issues Addressed

### 1. RVEEH Logo Not Displaying

**Reported Behaviour:**
- RVEEH client row showed fallback initials "RV" instead of the hospital logo
- ARR data was displaying correctly after previous database fix

**Root Cause:**
Name mismatch in logo resolution chain:
- `clients` table `canonical_name`: "The Royal Victorian Eye and Ear Hospital" (with "The")
- `client_name_aliases` returns: "The Royal Victorian Eye and Ear Hospital"
- `CLIENT_LOGO_MAP` key: "Royal Victorian Eye and Ear Hospital" (without "The")

The logo lookup failed because the canonical name from Supabase didn't match the key in CLIENT_LOGO_MAP.

**Resolution:**
Added both name variants to `CLIENT_LOGO_MAP` in `src/lib/client-logos-local.ts`:
```typescript
'Royal Victorian Eye and Ear Hospital': '/logos/rveeh.webp',
'The Royal Victorian Eye and Ear Hospital': '/logos/rveeh.webp',
```

### 2. WA Health Missing from Portfolio

**Reported Behaviour:**
- John Salisbury's territory shows "VIC, WA"
- Portfolio Clients table only showed 4 clients (Barwon Health, Epworth Healthcare, RVEEH, Western Health)
- WA Health was missing despite being assigned to John

**Root Cause:**
Name mismatch between tables:
- `cse_client_assignments.client_name`: "Western Australia Department Of Health"
- `clients.canonical_name`: "WA Health"

The portfolio loading logic in `strategic/new/page.tsx` queries `cse_client_assignments` to get client names for a CSE, then matches against `clients` table by canonical_name. The substring matching failed because:
- "wa health".includes("western australia department of health") = false
- "western australia department of health".includes("wa health") = false

**Resolution:**
Updated database record in `cse_client_assignments`:
```sql
UPDATE cse_client_assignments
SET client_name = 'WA Health', client_name_normalized = 'WA Health'
WHERE id = 19;
```

## Files Modified

### src/lib/client-logos-local.ts
- Added `'The Royal Victorian Eye and Ear Hospital': '/logos/rveeh.webp'` to CLIENT_LOGO_MAP

### src/app/(dashboard)/planning/strategic/new/page.tsx
- Added `tcv: number` to `PipelineOpportunity` interface
- Added `tcv: row.tcv || 0` in pipeline row mapping
- Extended `pipelineByClient` Map type to include TCV: `{ weighted: number; total: number; tcv: number }`
- Added TCV aggregation in pipeline grouping loop
- Set `tcv: clientPipelineData.tcv` in portfolio client mapping
- Added `tcv: 0` to custom opportunity creation

### Database Updates (via Supabase service role)
- `cse_client_assignments`: Updated record id=19
  - `client_name`: "Western Australia Department Of Health" → "WA Health"
  - `client_name_normalized`: "Western Australia Department Of Health" → "WA Health"

## Testing Performed

- [x] Build passes with zero TypeScript errors
- [x] RVEEH logo displays correctly in Portfolio Clients table
- [x] WA Health now appears in John Salisbury's portfolio
- [x] All 5 clients display for John: Barwon Health, Epworth Healthcare, RVEEH, Western Health, WA Health
- [x] TCV column displays correct values from sales_pipeline_opportunities
- [x] TCV aggregation verified against source Excel (APAC 2026 Sales Budget 6Jan2026.xlsx)

## Prevention

1. **Client Name Consistency**: Ensure `cse_client_assignments.client_name` matches `clients.canonical_name`
2. **Logo Map Coverage**: Add both common variants when canonical names have variations (with/without "The", abbreviations, etc.)
3. **Validation Script**: Consider adding a validation check that compares names across related tables

### 3. RVEEH Health Data Not Loading

**Reported Behaviour:**
- RVEEH showed "-" for Client Health, NPS, and Segment columns
- Data existed in client_health_summary but wasn't being matched

**Root Cause:**
- `client_health_summary.client_name`: "Royal Victorian Eye and Ear Hospital" (without "The")
- `clients.canonical_name`: "The Royal Victorian Eye and Ear Hospital" (with "The")
- Exact string matching failed due to "The " prefix

**Resolution:**
Added name normalization function in `strategic/new/page.tsx`:
```typescript
const normalizeNameForArr = (name: string): string => {
  return (name || '')
    .toLowerCase()
    .replace(/^the\s+/i, '') // Remove leading "The "
    .trim()
}
```
Updated health data matching to use flexible matching:
- Normalizes both canonical name and health summary name
- Uses includes() for partial matching fallback

### 4. WA Health Pipeline Data Not Loading

**Reported Behaviour:**
- WA Health showed "-" for Weighted ACV Target and Total ACV
- Other clients (Western Health, Barwon Health, Epworth) showed correct pipeline data

**Root Cause:**
- `sales_pipeline_opportunities.account_name`: "Western Australia Department Of Health"
- `clients.canonical_name`: "WA Health"
- These are not substrings of each other, so partial matching failed

**Resolution:**
Added pipeline alias mapping:
```typescript
const pipelineAliases: Record<string, string> = {
  'western australia department of health': 'wa health',
  'western australia department of health,': 'wa health',
  // ... other aliases
}
```

### 5. TCV Column Not Displaying

**Reported Behaviour:**
- TCV column showed "-" for all clients in Portfolio Clients table
- TCV data existed in `sales_pipeline_opportunities.tcv` but wasn't being aggregated

**Root Cause:**
- `PipelineOpportunity` interface didn't include `tcv` field
- Pipeline row mapping didn't extract TCV from database rows
- `pipelineByClient` aggregation only tracked `weighted` and `total` ACV, not TCV
- Portfolio client mapping didn't set TCV from aggregated data

**Resolution:**
1. Added `tcv: number` to `PipelineOpportunity` interface
2. Included `tcv: row.tcv || 0` in pipeline row mapping
3. Extended `pipelineByClient` to track `{ weighted, total, tcv }`
4. Set `tcv: clientPipelineData.tcv` in portfolio client mapping

**Result:**
TCV now displays correctly for John Salisbury's portfolio:
- WA Health: $7,083,321
- Western Health: $1,087,343
- Barwon Health: $275,962
- Epworth Healthcare: $229,297
- RVEEH: "-" (opportunities excluded due to Out/Omitted status)

## Related Issues

- Previous fix: RVEEH ARR showing $0 (resolved 2026-01-12)
- Previous fix: clients.canonical_name alignment for RVEEH (resolved 2026-01-12)

## Data Flow Reference

Portfolio loading in `strategic/new/page.tsx`:
```
1. Query cse_client_assignments WHERE cse_name = owner
2. Get client_name list from assignments
3. Filter availableClients (from clients table) by name matching
4. Display portfolio with logos from getClientLogo()
```

For names to match correctly:
- `cse_client_assignments.client_name` must align with `clients.canonical_name`
- `CLIENT_LOGO_MAP` keys must cover all `canonical_name` variants
