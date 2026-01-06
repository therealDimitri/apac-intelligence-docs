# Bug Report: ARR by Client - Incorrect Client Names and Pipeline Data

**Date:** 6 January 2026
**Component:** Executive Dashboard - Total ARR Card
**Files:**
- `src/components/burc/BURCExecutiveDashboard.tsx`
- `scripts/sync-burc-data.mjs`
- `scripts/sync-burc-data-supabase.mjs`
**Severity:** High (Data Quality)

## Issue Description

The ARR by Client expandable list under the Total ARR card had two major issues:

### Issue 1: Incorrect Client Name Mappings
The BURC sync scripts had hardcoded client code → name mappings that were **completely wrong**:

| Code | Incorrect Name | Correct Name |
|------|---------------|--------------|
| AWH | Austin Health | **Albury Wodonga Health** |
| MAH | Mercy Aged Care | **Mount Alvernia Hospital** |
| NCS | Northern Health | **NCS/MinDef** |

### Issue 2: Pipeline Data Mixed with Committed ARR
The query was also including:
1. **"Bus Case"** - Business case placeholder entries (not real clients)
2. **"Best Case"** category - Pipeline/pending renewals (not yet committed revenue)

## Investigation

Cross-referenced database with source BURC file (`2026 APAC Performance.xlsx`):

### BURC Categories Explained:
| Category | Meaning | Should Show in ARR? |
|----------|---------|---------------------|
| **Backlog** | Committed/contracted revenue | ✅ Yes |
| **Best Case** | Pipeline, pending renewals | ❌ No |
| **Business Case** | Placeholder/proposals | ❌ No |
| **Lost** | Churned clients | ❌ No |

### Example Clients Investigated:
- **Mercy Aged Care (MAH)**: Found in BURC with "Backlog" status - $309K committed ✅
- **Austin Health (AWH)**: Mix of "Backlog" ($160K) and "Best Case" ($198K pending renewal) ⚠️

## Root Cause

The original query fetched ALL entries from `burc_client_maintenance` without filtering by category, mixing committed revenue with pipeline.

**Original Query:**
```typescript
const { data: maintenanceData } = await supabase
  .from('burc_client_maintenance')
  .select('client_name, annual_total')
  .neq('client_name', 'Lost')
  .order('annual_total', { ascending: false })
```

## Fix Applied

Filter to only include "Backlog" category (committed/contracted revenue) and exclude placeholder entries:

**Fixed Query:**
```typescript
const { data: maintenanceData } = await supabase
  .from('burc_client_maintenance')
  .select('client_name, annual_total')
  .eq('category', 'Backlog')      // Only committed revenue
  .neq('client_name', 'Lost')     // Exclude churned placeholder
  .neq('client_name', 'Bus Case') // Exclude business case placeholder
  .order('annual_total', { ascending: false })
```

## Database Context

The `burc_client_maintenance` table contains entries from BURC with categories:
- **Backlog** (17 entries, $15.6M) - Committed maintenance contracts
- **Best Case** (7 entries, $4.1M) - Pipeline/pending renewals
- **Business Case** (1 entry, $148K) - Placeholder ("Lost")

## Testing

1. Navigate to Command Centre → Executive Dashboard
2. Click the Total ARR card to expand
3. Verify ARR by Client list shows only committed (Backlog) revenue
4. Confirm pipeline items (Best Case) are excluded

## Fixes Applied

### Fix 1: Corrected Client Name Mappings
Updated mappings in both sync scripts:

**`scripts/sync-burc-data.mjs` (line 356-369):**
```javascript
const clientNames = {
  'AWH': 'Albury Wodonga Health',    // Was: 'Austin Health'
  'MAH': 'Mount Alvernia Hospital',  // Was: 'Mercy Aged Care'
  'NCS': 'NCS/MinDef',               // Was: 'Northern Health'
  // ... other mappings unchanged
};
```

**`scripts/sync-burc-data-supabase.mjs` (line 242-255):** Same fix applied.

### Fix 2: Database Records Updated
Directly updated `burc_client_maintenance` table:
- 2 records: Austin Health → Albury Wodonga Health
- 1 record: Mercy Aged Care → Mount Alvernia Hospital
- 1 record: Northern Health → NCS/MinDef

### Fix 3: Query Filter for Committed Revenue Only
Updated query in `BURCExecutiveDashboard.tsx` to only include "Backlog" category.

## Impact

- ARR by Client now shows **correct client names** matching BURC source file
- Only committed/contracted revenue shown (Backlog category)
- Pipeline revenue (Best Case) excluded to prevent confusion
- Total ARR card value remains unchanged (calculated separately)

## Corrected ARR by Client List

| Client | Committed ARR |
|--------|---------------|
| SA Health | $6.43M |
| Sing Health | $4.65M |
| St Luke's Medical Centre | $677K |
| WA Health | $578K |
| GRMC | $533K |
| Grampians Health Alliance | $470K |
| **NCS/MinDef** | $362K |
| Waikato | $320K |
| **Mount Alvernia Hospital** | $309K |
| Barwon Health | $249K |
| Epworth Healthcare | $182K |
| **Albury Wodonga Health** | $134K |
| GHA Regional | $130K |
| Royal Victorian Eye & Ear | $100K |
| Western Health | $89K |

**Total: 15 clients, $15.21M committed ARR**
