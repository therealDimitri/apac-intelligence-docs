# Bug Fix: OneDrive Path Suffix Error

## Date
10 January 2026

## Issue
BURC sync and Excel parser failing with `ENOENT: no such file or directory` errors due to incorrect OneDrive path containing `(2)` suffix.

## Symptoms
- BURC monthly sync script failing
- Client segmentation activity data not loading
- Console errors showing file not found at paths like:
  ```
  OneDrive-AlteraDigitalHealth(2)/APAC Clients - Client Success/...
  ```

## Root Cause
OneDrive paths in multiple files contained an outdated `(2)` suffix that no longer matched the current filesystem structure:
- `OneDrive-AlteraDigitalHealth(2)` should be `OneDrive-AlteraDigitalHealth`

This likely occurred when OneDrive was reinstalled or reconfigured, changing the sync folder name.

## Files Affected
**Production files (4):**
1. `src/lib/burc-config.ts` - BURC master file path
2. `scripts/sync-burc-monthly.mjs` - Monthly sync script paths
3. `scripts/burc-sync-orchestrator.mjs` - Orchestrator script paths
4. `src/lib/excel-parser.ts` - Client segmentation Excel path

**Utility/debug scripts (51 total):**
- BURC sync and analysis scripts (30+)
- Segmentation import scripts
- NPS import scripts
- Various debug/utility scripts

## Fix Applied
Removed the `(2)` suffix from all OneDrive paths:

```diff
- '/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth(2)/APAC Clients...'
+ '/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Clients...'
```

## Secondary Issue Fixed
During the fix, a variable shadowing bug was also discovered in `scripts/burc-sync-orchestrator.mjs`:

```javascript
// Variable was shadowing the function of the same name
let runValidation = true;  // This shadowed the function runValidation()

// Fixed by renaming:
let shouldRunValidation = true;
```

## Verification
1. Build passes successfully
2. BURC sync script executes without ENOENT errors
3. Excel parser can read client segmentation data

## Prevention
- When OneDrive sync folder changes, search codebase for old paths:
  ```bash
  grep -r "OneDrive-AlteraDigitalHealth" --include="*.ts" --include="*.mjs"
  ```
- Consider using environment variables for OneDrive base path

## Commits
- `62adc3e9` - fix: correct OneDrive path in excel-parser.ts
- `9065eb4` - fix: correct OneDrive paths in all scripts (51 files)
- Previous commits fixed burc-config.ts and sync scripts
