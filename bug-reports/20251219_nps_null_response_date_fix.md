# Bug Report: NPS Calculation Issues (NULL Dates & Alias Mismatch)

**Date:** 2025-12-19
**Status:** Fixed
**Severity:** High
**Affected Clients:** Grampians Health (NULL dates), RVEEH (alias mismatch), WA Health (alias mismatch), NCS/MinDef Singapore (alias mismatch), SLMC (missing alias), GRMC (missing alias)

## Problem Description

NPS scores in the database did not match the "Most Recent NPS Result" card in the UI for certain clients. Specifically:
- Grampians Health: Database showed NPS 0, should be -50 (NULL response_date issue)
- RVEEH: Database showed NPS 0, should be 100 (alias mismatch issue)
- WA Health: Database showed NPS 0, should be -25 (alias mismatch issue)
- NCS/MinDef Singapore: Database showed NPS 0, should be 0 but UI showed "No NPS responses" (alias mismatch)
- SLMC: Database showed NPS 0, should be -100 (missing alias in database)
- GRMC: Database showed NPS 0, should be 100 (missing alias - "Guam Regional Medical Centre" vs "Guam Regional Medical City")

### Symptoms

1. Health score was using NPS 0 instead of actual NPS value
2. Most Recent NPS Result card showed different value than database
3. Clients with NULL `response_date` but valid `period` field were being ignored

## Root Cause

### Issue 1: NULL response_date Values

156 NPS responses in the database have NULL `response_date` but valid `period` fields (e.g., "Q2 25"). The materialized view was filtering by:

```sql
AND r.response_date >= DATE_TRUNC('quarter', MAX(response_date))
```

This excluded all responses with NULL `response_date`, even if they had valid `period` data.

### Issue 2: Different Period Calculation Methods

- **Database SQL**: Used `response_date` to determine the most recent quarter
- **UI (useNPSTrend)**: Used `response_date` to calculate period, causing `new Date(null)` to return 1970

### Issue 3: NPS Alias Lookup Not Bidirectional (RVEEH, WA Health)

The NPS calculation only looked up aliases where `canonical_name = nps_clients.client_name`. However, for some clients:
- **RVEEH**: `nps_clients.client_name` = "Royal Victorian Eye and Ear Hospital" (a display_name)
- **nps_responses.client_name** = "The Royal Victorian Eye and Ear Hospital" (the canonical_name)
- The alias lookup couldn't match because RVEEH's name is a display_name, not canonical

Similarly for WA Health:
- **nps_clients.client_name** = "WA Health" (a display_name)
- **nps_responses.client_name** = "Western Australia Department Of Health" (the canonical_name)

### Issue 4: UI Hooks Not Using Alias Lookup (NCS/MinDef, SLMC)

The `useNPSAnalysis` and `useNPSTrend` hooks used exact match queries:
```typescript
query = query.eq('client_name', clientName)
```

This caused the UI to show "No NPS responses yet" even when data existed under aliased names.

### Issue 5: Missing Alias Entry (SLMC)

SLMC had NPS responses stored under "St Luke's Medical Centre" but this name wasn't in the `client_name_aliases` table. The alias was added to connect it to the canonical name.

### Grampians Health Example

| response_date | period | score | category |
|---------------|--------|-------|----------|
| NULL | Q2 25 | 7 | Passive |
| NULL | Q2 25 | 4 | Detractor |
| NULL | Q4 24 | 5 | Detractor |

- All 3 responses have NULL `response_date`
- Q2 25 is the most recent period
- Expected NPS for Q2 25: ((0-1)/2)*100 = -50
- Database was calculating: 0 (no responses matched the date filter)

## Fix Applied

### 1. Database Migration (`docs/migrations/20251219_fix_health_score_with_aliases.sql`)

Updated the NPS calculation to use the `period` field instead of `response_date`:

```sql
-- NPS Metrics (MOST RECENT PERIOD ONLY - matches UI calculation)
-- Uses the 'period' field (e.g., "Q2 25") instead of response_date to handle NULL dates
LEFT JOIN LATERAL (
  SELECT
    COALESCE(
      ROUND(
        (COUNT(*) FILTER (WHERE score >= 9)::DECIMAL / NULLIF(COUNT(*), 0) * 100) -
        (COUNT(*) FILTER (WHERE score <= 6)::DECIMAL / NULLIF(COUNT(*), 0) * 100)
      ),
      0
    ) as nps_score,
    -- ... other fields
  FROM nps_responses r
  WHERE (...)
  -- Filter to MOST RECENT PERIOD only (matches UI useNPSTrend calculation)
  -- Uses period field (e.g., "Q2 25") to handle NULL response_dates
  AND r.period = (
    -- Find the most recent period that has data for this client
    -- Period format: "Q# YY" (e.g., "Q2 25", "Q4 24")
    -- Sort by year desc, then quarter desc to get the latest
    SELECT r2.period
    FROM nps_responses r2
    WHERE r2.period IS NOT NULL
      AND r2.period ~ '^Q[1-4]\s+\d{2}$'
      AND (...)
    ORDER BY
      -- Extract year (2-digit) and quarter for sorting
      CAST(SUBSTRING(r2.period FROM '\d{2}$') AS INTEGER) DESC,
      CAST(SUBSTRING(r2.period FROM 'Q(\d)') AS INTEGER) DESC
    LIMIT 1
  )
) nps_metrics ON true
```

### 2. Updated useNPSTrend Hook (`src/hooks/useNPSAnalysis.ts`)

Updated to prioritise `period` field over `response_date`:

```typescript
// Group by quarter - use period field if available, otherwise calculate from response_date
// This handles cases where response_date is NULL but period is set (e.g., "Q2 25")
responses.forEach(response => {
  let period: string

  // Prefer the period field if it's valid (format: "Q# YY")
  if (response.period && /^Q[1-4]\s+\d{2}$/.test(response.period)) {
    // Convert "Q2 25" to "Q2 2025" format for sorting consistency
    const [q, y] = response.period.split(' ')
    const fullYear = parseInt(y) < 50 ? `20${y}` : `19${y}` // Handle 2-digit years
    period = `${q} ${fullYear}`
  } else if (response.response_date) {
    // Fallback to calculating from response_date
    const date = new Date(response.response_date)
    const year = date.getFullYear()
    const quarter = Math.floor(date.getMonth() / 3) + 1
    period = `Q${quarter} ${year}`
  } else {
    // Skip responses with no valid period or date
    return
  }
  // ... rest of processing
})
```

### 3. Added Alias Lookup to UI Hooks (`src/hooks/useNPSAnalysis.ts`)

Added a helper function for bidirectional alias lookup and updated both `useNPSAnalysis` and `useNPSTrend` hooks:

```typescript
/**
 * Helper function to get all possible client names via alias lookup
 * Supports bidirectional alias lookup (canonical → display and display → canonical)
 */
async function getAllClientNames(clientName: string): Promise<string[]> {
  const names = new Set<string>([clientName])

  // Fetch all aliases that might match this client
  const { data: aliases } = await supabase
    .from('client_name_aliases')
    .select('canonical_name, display_name')
    .eq('is_active', true)
    .or(`canonical_name.eq.${clientName},display_name.eq.${clientName}`)

  if (aliases && aliases.length > 0) {
    aliases.forEach(a => {
      names.add(a.canonical_name)
      names.add(a.display_name)
    })
    // ... get peer aliases
  }

  return Array.from(names)
}

// Then in the hooks:
const allNames = await getAllClientNames(clientName)
const { data } = await supabase
  .from('nps_responses')
  .select('*')
  .in('client_name', allNames)
```

### 4. Added Missing Aliases for SLMC and GRMC

- Added "St Luke's Medical Centre" as an alias pointing to "St Luke's Medical Center Global City Inc"
- Added "Guam Regional Medical Centre" as an alias pointing to "GRMC (Guam Regional Medical Centre)"

## Results After Fix

### Verification Output

| Client | DB NPS | Expected | Match | Period | Responses |
|--------|--------|----------|-------|--------|-----------|
| Albury Wodonga Health | 0 | 0 | ✓ | Q4 25 | 1 |
| Barwon Health Australia | -50 | -50 | ✓ | Q4 25 | 2 |
| Department of Health - Victoria | 0 | 0 | ✓ | Q4 25 | 2 |
| Epworth Healthcare | -100 | -100 | ✓ | Q4 25 | 1 |
| Gippsland Health Alliance (GHA) | 100 | 100 | ✓ | Q4 25 | 3 |
| **Grampians Health** | **-50** | **-50** | **✓** | **Q2 25** | **2** |
| **Guam Regional Medical City (GRMC)** | **100** | **100** | **✓** | **Q4 25** | **1** |
| Mount Alvernia Hospital | -40 | -40 | ✓ | Q4 25 | 5 |
| **NCS/MinDef Singapore** | **0** | **0** | **✓** | **Q4 25** | **5** |
| **Royal Victorian Eye and Ear Hospital** | **100** | **100** | **✓** | **Q4 25** | **1** |
| SA Health (iPro) | -55 | -55 | ✓ | Q4 25 | 11 |
| SA Health (iQemo)* | -55 | -55 | ✓ | Q4 25 | 11 |
| SA Health (Sunrise)* | -55 | -55 | ✓ | Q4 25 | 11 |
| **Saint Luke's Medical Centre (SLMC)** | **-100** | **-100** | **✓** | **Q4 25** | **2** |
| SingHealth | 0 | 0 | ✓ | Q4 25 | 5 |
| Te Whatu Ora Waikato | 100 | 100 | ✓ | Q2 25 | 1 |
| **WA Health** | **-25** | **-25** | **✓** | **Q4 25** | **4** |
| Western Health | -100 | -100 | ✓ | Q2 25 | 2 |

*SA Health variants aggregate ALL SA Health responses by design

### Key Fix Results

- **Grampians Health**: Now shows -50 (correct for Q2 25 with 2 responses)
- **RVEEH**: Now shows 100 (correct for Q4 25 with 1 promoter)
- **WA Health**: Now shows -25 (correct for Q4 25 with 4 responses)
- **NCS/MinDef Singapore**: Now shows 0 with 5 responses (1 promoter, 1 detractor, 3 passives)
- **SLMC**: Now shows -100 (correct for Q4 25 with 2 detractors)
- **GRMC**: Now shows 100 (correct for Q4 25 with 1 promoter)

## Files Modified

- `docs/migrations/20251219_fix_health_score_with_aliases.sql` - Updated NPS calculation with bidirectional alias lookup
- `src/hooks/useNPSAnalysis.ts` - Added alias lookup to useNPSAnalysis and useNPSTrend hooks
- `client_name_aliases` table - Added missing aliases:
  - "St Luke's Medical Centre" → "St Luke's Medical Center Global City Inc"
  - "Guam Regional Medical Centre" → "GRMC (Guam Regional Medical Centre)"

## Technical Details

### Period Field Format

The `period` field uses format "Q# YY" (e.g., "Q2 25", "Q4 24"):
- Q = Quarter number (1-4)
- YY = 2-digit year

The SQL regex `'^Q[1-4]\s+\d{2}$'` validates this format.

### Period Sorting Logic

To find the most recent period:
```sql
ORDER BY
  CAST(SUBSTRING(r2.period FROM '\d{2}$') AS INTEGER) DESC,  -- Year desc
  CAST(SUBSTRING(r2.period FROM 'Q(\d)') AS INTEGER) DESC    -- Quarter desc
LIMIT 1
```

This correctly sorts "Q4 25" > "Q2 25" > "Q4 24" > "Q2 24".

### Health Score Formula (v3.2)

```
Health Score = NPS (40 pts) + Compliance (50 pts) + Working Capital (10 pts)

NPS Component:      ((nps_score + 100) / 200) * 40
                    NPS calculated from MOST RECENT PERIOD (using period field)
Compliance:         (min(100, compliance_%) / 100) * 50
Working Capital:    (min(100, wc_%) / 100) * 10

Defaults:
- NPS: 0 (neutral) - when no responses in any period
- Compliance: 50% (if no data)
- Working Capital: 100% (no aging data = no problem)
```

## Testing Checklist

- [x] Grampians Health shows NPS -50 (Q2 25 period)
- [x] RVEEH shows NPS 100 (Q4 25 period) via bidirectional alias lookup
- [x] WA Health shows NPS -25 (Q4 25 period) via bidirectional alias lookup
- [x] NCS/MinDef Singapore shows NPS data in UI (5 responses) via hook alias lookup
- [x] SLMC shows NPS -100 (Q4 25 period) via added alias
- [x] GRMC shows NPS 100 (Q4 25 period) via added alias
- [x] All 18 clients have correct NPS from their latest period
- [x] SA Health variants correctly aggregate all SA Health responses
- [x] Clients with no NPS responses default to 0
- [x] useNPSTrend hook correctly groups by period field
- [x] useNPSAnalysis hook correctly uses alias lookup
- [x] Health scores recalculated with correct NPS values
- [x] User verified all fixes working in production

## Prevention

### NPS Data Import
1. When importing NPS data, ensure either `response_date` OR `period` field is populated
2. The `period` field is now the primary source for determining the survey period
3. If both are populated, `period` field takes precedence in the UI
4. Database now uses `period` field exclusively for period filtering

### Client Name Aliases
5. When adding a new client to `nps_clients`, ensure corresponding entries exist in `client_name_aliases`
6. When NPS responses use a different name variant, add that variant as an alias
7. The bidirectional alias lookup handles most variations automatically, but exact name matching is required
8. Common issues: "Centre" vs "Center", "The" prefix, abbreviated names (GRMC, SLMC, RVEEH)

## Related Issues

- Previous fix: `20251219_health_score_mismatch_fix.md` - Health score mismatch and alias lookup
- Previous fix: `20251219_compliance_mismatch_fix.md` - Compliance data source mismatch
