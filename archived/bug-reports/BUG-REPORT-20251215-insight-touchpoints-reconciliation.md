# Bug Report: Insight Touch Points Not Reconciling with XLS Parse Data

**Date:** 2025-12-15
**Status:** RESOLVED
**Commit:** 65c5cd3

## Issue

The Priority Matrix displayed "42 incomplete Insight Touch Points" which did not reconcile with the source XLS data. Investigation revealed the compliance table was showing incorrect data for several clients.

## Root Cause

**Client name mismatch between database tables:**

The `segmentation_event_compliance` table and `segmentation_events` table used different client name formats:

| Compliance Table                    | Events Table                    | Actual Events |
| ----------------------------------- | ------------------------------- | ------------- |
| Dept of Health, Victoria            | Department of Health - Victoria | 12            |
| Albury Wodonga                      | Albury Wodonga Health           | 12            |
| Barwon Health                       | Barwon Health Australia         | 6             |
| Singapore Health (SingHealth)       | SingHealth                      | 6             |
| Waikato                             | Te Whatu Ora Waikato            | 12            |
| Royal Victorian Eye and Ear (RVEEH) | Royal Victorian Eye and Ear     | 10            |

The compliance sync script couldn't match events to compliance records because the names didn't match exactly, and the fuzzy matching ("dept" vs "department") failed.

**Example:** Department of Health - Victoria had 12 completed events in `segmentation_events`, but compliance showed 0/12 because "Dept of Health, Victoria" ≠ "Department of Health - Victoria".

## Solution

### 1. Added Missing Aliases to `client_name_aliases` Table

The existing alias table was missing mappings for compliance table name variations:

```sql
-- Added 11 new aliases
INSERT INTO client_name_aliases (display_name, canonical_name) VALUES
  ('Dept of Health, Victoria', 'Department of Health - Victoria'),
  ('Albury Wodonga', 'Albury Wodonga Health'),
  ('Singapore Health (SingHealth)', 'Singapore Health Services Pte Ltd'),
  ('Royal Victorian Eye and Ear Hospital (RVEEH)', 'The Royal Victorian Eye and Ear Hospital'),
  -- ... etc
```

### 2. Updated Sync Script to Use Alias Table

Modified `sync-compliance-with-events.mjs` to:

- Load all aliases from `client_name_aliases` table on startup
- Normalise both compliance and events client names to canonical form
- Match events to compliance records using canonical names
- Fall back to fuzzy matching only when alias lookup fails

### 3. Executed Sync to Fix Data

Ran the updated sync script to correct the compliance records.

## Results

| Metric             | Before | After |
| ------------------ | ------ | ----- |
| Incomplete Clients | 10     | 9     |
| Missing Events     | 42     | 30    |
| DoH Victoria       | 0/12   | 12/12 |

## Scripts Added

| Script                            | Purpose                                        |
| --------------------------------- | ---------------------------------------------- |
| `sync-compliance-with-events.mjs` | Syncs compliance with events using alias table |
| `add-missing-aliases.mjs`         | Adds missing aliases to the database           |
| `debug-insight-xls-vs-db.mjs`     | Compares XLS source data with database         |
| `check-alias-tables.mjs`          | Lists existing client name aliases             |

## Prevention

To prevent this issue recurring:

1. **Use alias table for all client name lookups** - Any code that joins on client names should use the `client_name_aliases` table to normalise names first
2. **Add aliases when new data is imported** - When importing new client data, check if the client name exists in aliases; if not, add it
3. **Run sync script after data imports** - Execute `node scripts/sync-compliance-with-events.mjs` after importing segmentation events

## Related Issues

- Previous bug: SA Health iQemo showing inflated event counts due to name variations
- See: `docs/BUG-REPORT-CLIENT-NAME-INCONSISTENCIES.md`
