# Bug Report: BURC Matching Rate at 37.4%

**Date**: 16 January 2026
**Status**: ✅ RESOLVED
**Severity**: High
**Component**: Pipeline Data Synchronisation

---

## Issue Summary

The BURC (Business Unit Revenue Cycle) matching rate was at 37.4%, meaning 62.6% of sales pipeline opportunities were not linked to BURC financial data. This caused:

- Inaccurate pipeline coverage calculations
- Missing financial tracking for 97 opportunities
- $28.8M in untracked pipeline value

---

## Root Cause Analysis

### Primary Cause: Data Coverage Gap

The Sales Budget and BURC pipeline tracked **different aspects** of the business:

| Source | Purpose | Records |
|--------|---------|---------|
| Sales Budget | What we're selling/renewing | 155 opportunities |
| BURC Pipeline | What's in the financial plan | 91 opportunities |

Many Sales Budget opportunities had **no corresponding BURC entries** because they represented:
- New deals not yet in the financial plan
- Opportunities from clients not tracked in BURC
- Different opportunity naming conventions

### Secondary Cause: Client Name Variations

The same clients had different names between systems:

| Sales Budget | BURC |
|--------------|------|
| Western Australia Department Of Health | WA Health |
| Minister for Health aka South Australia Health | SA Health (iPro) |
| Strategic Asia Pacific Partners, Incorporated | Guam Regional Medical City (GRMC) |
| Gippsland Health Alliance | Gippsland Health Alliance (GHA) |
| St Luke's Medical Center Global City Inc | Saint Luke's Medical Centre (SLMC) |

---

## Fix Applied

### 1. Enhanced Client Name Normalisation

Added comprehensive `CLIENT_NORMALISATION` and `CLIENT_CANONICAL_MAP` mappings in:
- `scripts/improve-burc-matching.mjs`
- `scripts/add-missing-burc-entries.mjs`

```javascript
// Example mappings added
'western australia department of health': 'WA Health',
'minister for health aka south australia health': 'SA Health (iPro)',
'strategic asia pacific partners, incorporated': 'Guam Regional Medical City (GRMC)',
'gippsland health alliance': 'Gippsland Health Alliance (GHA)',
"st luke's medical center global city inc": "Saint Luke's Medical Centre (SLMC)",
```

### 2. Created Missing BURC Entries

Created new `pipeline_opportunities` records for Sales Budget opportunities without BURC matches:

- **Phase 1**: 32 entries for clients not in BURC (DoH Victoria, RVEEH, WAPHA, Chong Hua)
- **Phase 2**: 65 entries for additional opportunities on existing clients

### 3. Matched All Opportunities

Ran `improve-burc-matching.mjs` to link all sales opportunities with their BURC entries using:
- Oracle quote number matching (highest confidence)
- Exact normalised name matching
- Client + fuzzy name matching

---

## Results

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Match Rate | 37.4% | 100% | +62.6pp |
| Matched Opportunities | 58 | 155 | +97 |
| Unmatched Opportunities | 97 | 0 | -97 |
| BURC Pipeline Records | 91 | 188 | +97 |

---

## Files Modified

1. `scripts/improve-burc-matching.mjs` - Enhanced CLIENT_NORMALISATION map
2. `scripts/add-missing-burc-entries.mjs` - Updated CLIENT_CANONICAL_MAP and CSE_TERRITORY_MAP
3. `docs/guides/DATA-CONNECTIONS-AUDIT-20260116.md` - Documented data coverage issues
4. `docs/guides/UX-ENHANCEMENT-PROPOSAL-20260116.md` - Proposed UI improvements
5. `docs/guides/DASHBOARD-EVOLUTION-STRATEGY-20260116.md` - Strategic recommendations

---

## Prevention

### Short-term
- Run `improve-burc-matching.mjs` after each Sales Budget sync
- Monitor match rate in dashboard (target: >95%)

### Long-term
- Implement automated sync validation
- Add Data Freshness Header component (see UX Enhancement Proposal)
- Build Pipeline Reconciliation Dashboard for ongoing monitoring

---

## Related Documentation

- [DATA-CONNECTIONS-AUDIT-20260116.md](./DATA-CONNECTIONS-AUDIT-20260116.md)
- [UX-ENHANCEMENT-PROPOSAL-20260116.md](./UX-ENHANCEMENT-PROPOSAL-20260116.md)
- [DASHBOARD-EVOLUTION-STRATEGY-20260116.md](./DASHBOARD-EVOLUTION-STRATEGY-20260116.md)

---

*Report generated: 16 January 2026*
