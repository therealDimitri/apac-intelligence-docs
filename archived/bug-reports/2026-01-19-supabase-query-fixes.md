# Supabase Query Fixes - Column Names and Error Handling

**Date:** 2026-01-19
**Commit:** TBD
**Type:** Bug Fix
**Status:** Completed

## Summary

Fixed two Supabase query issues causing 400 and 406 errors in the browser console:
1. Wrong column names in `unified_meetings` queries
2. Using `.single()` instead of `.maybeSingle()` for optional client lookups

## Issue 1: Wrong Column Names in unified_meetings Queries

### Symptoms
- 400 Bad Request errors for `unified_meetings` queries
- Error URLs showed queries using `date`, `type`, and `status` columns

### Root Cause
The BURCExecutiveDashboard.tsx was using incorrect column names when querying the `unified_meetings` table:
- `date` should be `meeting_date`
- `type` should be `meeting_type`
- `status` column exists, so this was correct

### File Changed: `src/components/burc/BURCExecutiveDashboard.tsx`

**Before (lines 353-376):**
```typescript
const { count: meetingsLast30d } = await supabase
  .from('unified_meetings')
  .select('*', { count: 'exact', head: true })
  .gte('date', thirtyDaysAgo.toISOString().split('T')[0])  // WRONG
  .eq('status', 'completed')

const { count: meetingsPrior30d } = await supabase
  .from('unified_meetings')
  .select('*', { count: 'exact', head: true })
  .gte('date', sixtyDaysAgo.toISOString().split('T')[0])   // WRONG
  .lt('date', thirtyDaysAgo.toISOString().split('T')[0])   // WRONG
  .eq('status', 'completed')

const { count: qbrsThisQuarter } = await supabase
  .from('unified_meetings')
  .select('*', { count: 'exact', head: true })
  .eq('type', 'QBR')                                        // WRONG
  .eq('status', 'completed')
  .gte('date', ...)                                         // WRONG
```

**After:**
```typescript
const { count: meetingsLast30d } = await supabase
  .from('unified_meetings')
  .select('*', { count: 'exact', head: true })
  .gte('meeting_date', thirtyDaysAgo.toISOString().split('T')[0])
  .eq('status', 'completed')

const { count: meetingsPrior30d } = await supabase
  .from('unified_meetings')
  .select('*', { count: 'exact', head: true })
  .gte('meeting_date', sixtyDaysAgo.toISOString().split('T')[0])
  .lt('meeting_date', thirtyDaysAgo.toISOString().split('T')[0])
  .eq('status', 'completed')

const { count: qbrsThisQuarter } = await supabase
  .from('unified_meetings')
  .select('*', { count: 'exact', head: true })
  .eq('meeting_type', 'QBR')
  .eq('status', 'completed')
  .gte('meeting_date', ...)
```

## Issue 2: 406 Error for nps_clients Lookups

### Symptoms
- 406 Not Acceptable errors for `nps_clients` queries
- Occurred when looking up clients that don't exist in the NPS clients table
- Example: "Royal Victorian Eye and Ear Hospital"

### Root Cause
The `detectSegmentChange()` function in segment-deadline-utils.ts was using `.single()` which throws a 406 error when no row is found. This is the expected behaviour for `.single()`, but it pollutes the console with errors for clients that simply don't have NPS data.

### File Changed: `src/lib/segment-deadline-utils.ts`

**Before (lines 58-64):**
```typescript
// Step 1: Get current segment from nps_clients
const { data: currentClient, error: clientError } = await supabase
  .from('nps_clients')
  .select('segment')
  .eq('client_name', clientName)
  .single()  // Throws 406 when no row exists
```

**After:**
```typescript
// Step 1: Get current segment from nps_clients
// Use .maybeSingle() instead of .single() to avoid 406 error when client doesn't exist
const { data: currentClient, error: clientError } = await supabase
  .from('nps_clients')
  .select('segment')
  .eq('client_name', clientName)
  .maybeSingle()  // Returns null instead of error when no row exists
```

## Database Schema Reference

### unified_meetings table columns
| Column Name | Correct |
|-------------|---------|
| `meeting_date` | Yes |
| `meeting_type` | Yes |
| `status` | Yes |
| `date` | No (doesn't exist) |
| `type` | No (doesn't exist) |

### Supabase Query Methods
| Method | Behaviour |
|--------|-----------|
| `.single()` | Returns error if 0 or 2+ rows found |
| `.maybeSingle()` | Returns null if 0 rows, error if 2+ rows |

## Testing

- Build passes without TypeScript errors
- No 400 or 406 errors in browser console
- Meeting stats display correctly in Executive Dashboard
- Segment deadline detection works for clients with and without NPS data

## Prevention

These issues highlight the importance of:
1. Always verifying column names against `docs/database-schema.md` before writing queries
2. Using `.maybeSingle()` instead of `.single()` when the row might not exist
3. Running `npm run validate-schema` before committing database queries
