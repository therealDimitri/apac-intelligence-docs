# Scripts Submodule

## Structure

```
apac-intelligence-v2/
  scripts/               ← git submodule → apac-intelligence-scripts repo
    lib/
      onedrive-paths.mjs ← Central OneDrive resolver
    *.mjs                ← 400+ utility scripts
    tender-scraper/      ← Playwright-based tender scraper
    launchd/             ← macOS launch agent configs
    CLAUDE.md            ← Scripts-specific instructions
```

## Workflow

### Committing Changes

Scripts is a separate repo. Changes must be committed in both places:

```bash
# 1. Commit inside submodule
cd scripts/
git add -A && git commit -m "feat: description" && git push

# 2. Update submodule pointer in parent
cd ..
git add scripts
git commit -m "chore: update scripts submodule" && git push
```

### After Fresh Clone

```bash
git submodule update --init --recursive
npm install  # postinstall depends on scripts/ being present
```

## Script Patterns

### Environment Loading
Scripts load `.env.local` from the **parent directory**:
```javascript
dotenv.config({ path: path.join(__dirname, '..', '.env.local') })
```

Always run from the v2 directory:
```bash
cd apac-intelligence-v2/
node scripts/sync-burc-data-supabase.mjs
```

### Supabase Client Setup
```javascript
import { createClient } from '@supabase/supabase-js'
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
)
```

### OneDrive Path Import
```javascript
import { BURC_MASTER_FILE, requireOneDrive } from './lib/onedrive-paths.mjs'
requireOneDrive()
```

## Script Categories

| Prefix | Purpose | Destructive? |
|--------|---------|--------------|
| `sync-` | Data synchronisation (Excel → Supabase) | Usually |
| `import-` | Bulk data imports | Yes |
| `analyse-`/`analyze-` | Read-only data analysis | No |
| `fix-` | Data corrections | Yes |
| `seed-` | Seed initial data | Yes |
| `validate-`/`verify-` | Validation checks | No |
| `watch-` | File watchers | No |
| `debug-` | Debugging/investigation | No |
| `enrich-` | Add derived data to existing records | Yes |

## Key Scripts

| Script | Purpose | Frequency |
|--------|---------|-----------|
| `sync-burc-data-supabase.mjs` | Main BURC → Supabase sync | On BURC file change |
| `burc-sync-orchestrator.mjs` | Coordinates multi-sheet BURC sync | On BURC file change |
| `sync-excel-activities.mjs` | Activity register → segmentation_events | Weekly |
| `burc-validate-sync.mjs` | Validates synced data matches Excel | After any sync |
| `sync-burc-monthly.mjs` | Monthly financial data sync | Monthly |
| `import-global-nps.mjs` | NPS survey data import | Quarterly |
