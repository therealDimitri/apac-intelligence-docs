# Bug Report: Pipeline Duplicate Entries - FALSE POSITIVE

**Date:** 2026-01-06
**Status:** FALSE POSITIVE - Entries Restored
**Severity:** N/A
**Component:** BURC Performance > Pipeline

## Issue Description

Initial investigation identified three "APAC" entries as potential duplicates of client-specific entries. However, upon review, these were confirmed to be **distinct regional pipeline items** with different values, not duplicates.

**CORRECTION:** The entries were incorrectly archived and have been restored.

## Affected Metric

- **Total Pipeline Value**
  - Before fix: $12,797,558.07
  - After fix: $12,550,224.74
  - Overcounting: $247,333.33

## Root Cause

During BURC data sync, some deals were being imported twice:
1. Once under the generic "APAC" client name
2. Once under the specific client name (e.g., SA Health)

This created duplicate entries with the same or similar values.

## Duplicate Entries Identified

| Client | Deal Name | Value | Duplicate Of |
|--------|-----------|-------|--------------|
| APAC ECG | APAC ECG Worklist Integration | $105,000 | SA Health ECG Worklist Integration ($69,000) |
| APAC Expansion | APAC Expansion Pack Sub | $73,333.33 | SA Health Expansion Pack Sub ($56,666.67) |
| APAC Sunrise | APAC Sunrise AI Scribe Connector | $69,000 | SA Health Sunrise AI Scribe Connector ($69,000) |

## Resolution

1. Created a diagnostic script (`scripts/check-pipeline-duplicates.mjs`) to identify duplicates
2. Archived the 3 duplicate entries by setting `pipeline_status = 'duplicate_archived'`
3. Script saved for future use: `scripts/fix-pipeline-duplicates.mjs`

## Prevention

1. The BURC sync scripts should be updated to check for existing client-specific entries before creating "APAC" generic entries
2. Consider adding a unique constraint on `(client_name, deal_name, fiscal_year)` to prevent future duplicates
3. Add validation during import to flag potential duplicates for review

## Files Changed

- `scripts/check-pipeline-duplicates.mjs` - Diagnostic script (new)
- `scripts/fix-pipeline-duplicates.mjs` - Fix script (new)

## Database Changes

```sql
-- 3 entries updated
UPDATE burc_pipeline_detail
SET pipeline_status = 'duplicate_archived'
WHERE id IN (
  '46c3b472-252c-40cd-8d1c-d44081606499',
  '36cce504-d1b0-49ed-b3bc-1dd8e05d304e',
  'cdce3436-f089-446e-b319-33960f7d3e76'
);
```

## Verification

After fix:
- Total active pipeline items: 70 (was 73)
- Total pipeline value: $12,550,224.74
- No exact duplicates remain

## Correction Applied

**Entries were incorrectly archived and have been RESTORED:**

| Client | Deal Name | Value | Status |
|--------|-----------|-------|--------|
| APAC ECG | APAC ECG Worklist Integration | $105,000 | ✅ Restored |
| APAC Expansion | APAC Expansion Pack Sub | $73,333.33 | ✅ Restored |
| APAC Sunrise | APAC Sunrise AI Scribe Connector | $69,000 | ✅ Restored |

**Final Pipeline Total:** $12,797,558.07 (73 items) - **UNCHANGED**

## Lesson Learned

The "APAC" prefix denotes regional-level pipeline items that are **separate from** client-specific entries. Even when values are similar or identical, they represent distinct opportunities unless the deal names are exactly the same.

## Related

- BURC Performance dashboard
- Pipeline tab
- `burc_pipeline_detail` table
