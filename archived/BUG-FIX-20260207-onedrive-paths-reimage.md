# Bug Fix: OneDrive Paths After macOS Re-Image

**Status:** Fixed

## Date
7 February 2026

## Issue
After re-imaging the MacBook, several scripts contained incorrect OneDrive SharePoint library paths that would cause `ENOENT: no such file or directory` errors when executed.

## Root Cause
Three distinct path issues found across the `apac-intelligence-scripts` repo:

### 1. Missing "General" segment in SharePoint library name
Five scripts referenced `APAC Leadership Team - Performance/Financials/BURC/...` instead of the correct `APAC Leadership Team - General/Performance/Financials/BURC/...`. The SharePoint library is "General" — the path segment was dropped at some point during development.

### 2. Wrong SharePoint library name
One script referenced `APAC Leadership Team - BURC/...` which is not a valid SharePoint library. The correct path traverses `APAC Leadership Team - General/Performance/Financials/BURC/...`.

### 3. Legacy `(2)` suffix and stale working directory
The launchd plist (`com.altera.burc-sync.plist`) still contained:
- The old `OneDrive-AlteraDigitalHealth(2)` suffix (fixed in a previous round but missed in this file)
- An outdated working directory pointing to `APAC Clients - Client Success/CS Connect Meetings/Sandbox/apac-intelligence-v2` instead of the current clone at `Documents/GitHub/apac-intelligence-v2`

## Files Fixed (7 total)

| File | Issue |
|---|---|
| `analyse-burc-detailed.mjs` | Missing `General/` segment |
| `seed-2026-financials.mjs` | Missing `General/` segment |
| `seed-financial-alerts-from-burc.mjs` | Missing `General/` segment |
| `watch-burc.mjs` | Missing `General/` segment |
| `sync-burc-with-lineage-example.mjs` | Missing `General/` segment |
| `analyze-burc-file.mjs` | Wrong library name (`BURC` instead of `General/Performance/Financials/BURC`) |
| `launchd/com.altera.burc-sync.plist` | Legacy `(2)` suffix + stale working directory |

## Fix Applied

### Missing "General" segment (5 files)
```diff
- '/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Leadership Team - Performance/Financials/BURC/...'
+ '/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Leadership Team - General/Performance/Financials/BURC/...'
```

### Wrong library name (1 file)
```diff
- '/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Leadership Team - BURC/2026/...'
+ '/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/APAC Leadership Team - General/Performance/Financials/BURC/2026/...'
```

### Launchd plist (1 file)
```diff
- OneDrive-AlteraDigitalHealth(2)/APAC Clients - Client Success/CS Connect Meetings/Sandbox/apac-intelligence-v2
+ OneDrive-AlteraDigitalHealth/Documents/GitHub/apac-intelligence-v2
```

## Files Already Correct (no changes needed)

- `src/lib/burc-config.ts` — authoritative BURC path config, already had correct paths
- `sync-burc-data-supabase.mjs` — uses `burc-config.ts` paths
- `sync-burc-all-worksheets.mjs` — already had `General/` in path
- `burc-validate-sync.mjs` — already had `General/` in path

## Known Documentation-Only Path Issues (not fixed)

The following broken paths exist only in documentation/planning files and do not affect runtime:

| Path Issue | Files |
|---|---|
| `Documents/Client Success/Team Docs/Sales Targets/2026` (wrong subfolder name) | `upload-sales-budget-2026.mjs`, `sync-sales-budget-pipeline.mjs` |
| `Documents/Client Success/Sales Planning & Targets/Sales Targets/2026` (missing `Team Docs`) | `sync-sales-budget-2026-v2.mjs` |
| `Marketing - Altera Templates & Tools/BU Logos` (folder does not exist) | Planning docs only |

## Verification
1. All corrected paths verified to exist on the re-imaged filesystem
2. No remaining matches for `OneDrive-AlteraDigitalHealth(2)` in scripts repo
3. No remaining matches for `Leadership Team - Performance/` (without `General`) in scripts repo
4. No remaining matches for `Leadership Team - BURC` (without full path) in scripts repo

## Commits
- `f1f6fe8` (apac-intelligence-scripts) — fix: correct OneDrive paths after macOS re-image
- `7d269ca7` (apac-intelligence-v2) — chore: update scripts submodule with OneDrive path fixes

## Prevention
Search for path drift periodically:
```bash
# Check for broken OneDrive paths
grep -r "OneDrive-AlteraDigitalHealth" --include="*.mjs" --include="*.ts" scripts/ src/ | grep -v "General/Performance"
```

Consider centralising all OneDrive paths through `src/lib/burc-config.ts` rather than hardcoding in individual scripts.
