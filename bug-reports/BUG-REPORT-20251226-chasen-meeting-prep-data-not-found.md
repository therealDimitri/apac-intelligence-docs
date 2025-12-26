# Bug Report: ChaSen Crews Not Finding Existing Client Data

**Date**: 26 December 2025
**Severity**: High
**Status**: Fixed
**Commits**: `a2b3e20` (initial fix), `[pending]` (extended fix)

---

## Summary

Multiple ChaSen crews were failing to find client data due to incorrect column names and missing alias resolution. Meeting Prep for Gippsland Health Alliance (GHA) was showing "Health N/A%, 0 actions" despite having health_score: 100 and valid NPS data.

## Affected Crews

| Crew                   | Issues                                       |
| ---------------------- | -------------------------------------------- |
| **Meeting Prep**       | Missing alias resolution, wrong column names |
| **Client Report**      | Missing alias resolution, wrong column names |
| **Portfolio Analysis** | Wrong column names                           |
| **Risk Assessment**    | Wrong column names                           |

## Root Causes

### 1. Missing Client Alias Resolution

The Meeting Prep crew wasn't using the `client_name_aliases` table to resolve different name variations. Client data is stored with varying name formats across tables:

| Table                   | Client Name Format                                                    |
| ----------------------- | --------------------------------------------------------------------- |
| `nps_clients`           | `Gippsland Health Alliance (GHA)`                                     |
| `unified_meetings`      | `GHA`, `Gippsland Health Alliance (GHA)`, `Gippsland Health Alliance` |
| `client_health_summary` | `Gippsland Health Alliance (GHA)`                                     |

Without alias resolution, queries using just one name variation missed data stored under other names.

### 2. Incorrect Column Names in Database Queries

Multiple column name errors prevented data retrieval:

| Table                   | Wrong Column       | Correct Column       |
| ----------------------- | ------------------ | -------------------- |
| `unified_meetings`      | `client`           | `client_name`        |
| `unified_meetings`      | `subject`          | `title`              |
| `unified_meetings`      | `start_time`       | `meeting_date`       |
| `client_health_summary` | `health_status`    | `status`             |
| `client_health_summary` | `latest_nps_score` | `nps_score`          |
| `actions`               | `action`           | `Action_Description` |
| `actions`               | `status`           | `Status`             |
| `actions`               | `priority`         | `Priority`           |
| `actions`               | `due_date`         | `Due_Date`           |
| `nps_responses`         | `sentiment`        | `category`           |

## Fix Applied

### Added Alias Resolution Helper

```typescript
async function getAllClientNames(clientName: string): Promise<string[]> {
  const supabase = getServiceSupabase()
  const names = new Set<string>([clientName])

  // Fetch all aliases that might match this client
  const { data: aliases } = await supabase
    .from('client_name_aliases')
    .select('canonical_name, display_name')
    .eq('is_active', true)
    .or(`canonical_name.ilike.%${clientName}%,display_name.ilike.%${clientName}%`)

  if (aliases && aliases.length > 0) {
    aliases.forEach(a => {
      names.add(a.canonical_name)
      names.add(a.display_name)
    })

    // Also fetch peer aliases with same canonical name
    const canonicalNames = aliases.map(a => a.canonical_name)
    if (canonicalNames.length > 0) {
      const { data: peerAliases } = await supabase
        .from('client_name_aliases')
        .select('display_name')
        .eq('is_active', true)
        .in('canonical_name', canonicalNames)

      peerAliases?.forEach(a => {
        names.add(a.display_name)
      })
    }
  }

  return Array.from(names)
}
```

### Updated Query Logic

- Queries now use `.in()` or `.or()` with all resolved client names
- All column names corrected to match database schema
- Prompt and response building updated to use correct field names

## Testing

1. Open ChaSen AI (Cmd+K or navigate to /ai)
2. Select "Meeting Prep" crew
3. Enter client name "GHA" or "Gippsland Health Alliance"
4. Verify response shows:
   - Health Score (should be 100%)
   - NPS Score (should be 100)
   - Recent meetings (if any)
   - Open actions (if any)

## Files Changed

- `src/app/api/chasen/crew/route.ts` - Added alias resolution, fixed column names

## Related

- `client_name_aliases` table - Contains bidirectional mappings between canonical and display names
- `useNPSAnalysis.ts:getAllClientNames()` - Reference implementation of alias resolution pattern
- `docs/database-schema.md` - Source of truth for column names

## Prevention

This reinforces the importance of:

1. Always consulting `docs/database-schema.md` before writing database queries
2. Using alias resolution for any client-name-based lookups
3. Running `npm run validate-schema` to catch column name errors early
