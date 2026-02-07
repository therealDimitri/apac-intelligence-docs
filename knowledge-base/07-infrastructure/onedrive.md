# OneDrive & SharePoint Integration

## Architecture

OneDrive for Business syncs SharePoint document libraries to the local filesystem at:
```
~/Library/CloudStorage/OneDrive-AlteraDigitalHealth/
```

The folder name can vary after OS re-images (e.g. `OneDrive-Altera Digital Health`). The central resolver handles this automatically.

## Central Path Resolver

**Scripts**: `scripts/lib/onedrive-paths.mjs`
**TypeScript**: `src/lib/onedrive-paths.ts`

Both auto-detect the OneDrive base by scanning `~/Library/CloudStorage/` for any folder matching `OneDrive-Altera*`.

### Exports

| Export | Type | Value |
|--------|------|-------|
| `ONEDRIVE_BASE` | `string \| null` | Detected OneDrive root |
| `BURC_BASE` | `string \| null` | `.../APAC Leadership Team - General/Performance/Financials/BURC` |
| `CLIENT_SUCCESS` | `string \| null` | `.../APAC Clients - Client Success` |
| `DOCUMENTS` | `string \| null` | `.../Documents` |
| `MARKETING` | `string \| null` | `.../Marketing - Marketing Collateral` |
| `BRAND_TEMPLATES` | `string \| null` | `.../Marketing - Altera Templates & Tools` |
| `BURC_MASTER_FILE` | `string \| null` | `.../BURC/2026/2026 APAC Performance.xlsx` |
| `ACTIVITY_REGISTER_2025` | `string \| null` | Client segmentation 2025 |
| `ACTIVITY_REGISTER_2026` | `string \| null` | Client segmentation 2026 |

### Helpers

- `burcFile(year, filename)` — Build year-specific BURC path
- `requireOneDrive()` — Fail-fast guard (call at script start)
- `assertFileExists(path, context)` — Validate before processing

### Backward Compatibility

`src/lib/burc-config.ts` re-exports with `?? ''` fallback so `fs.existsSync()` calls don't need null checks.

## SharePoint Libraries

| Library | Local Path Suffix | Primary Content |
|---------|-------------------|-----------------|
| APAC Leadership Team - General | `/APAC Leadership Team - General/` | BURC financials, performance data |
| APAC Clients - Client Success | `/APAC Clients - Client Success/` | Segmentation register, NPS data |
| Documents | `/Documents/` | Sales budgets, team docs |
| Marketing - Marketing Collateral | `/Marketing - Marketing Collateral/` | Sales hub content, logos |
| Marketing - Altera Templates & Tools | `/Marketing - Altera Templates & Tools/` | Brand templates, PPTX |

## Key Rules

1. **Never hardcode OneDrive paths** — always import from the resolver
2. **Always call `requireOneDrive()`** at script start — fail fast with clear error
3. **The resolver returns null on CI** — Netlify has no OneDrive; code must handle null gracefully
4. **After OS re-image**: Just sign into OneDrive — the resolver auto-detects the new folder name

## Troubleshooting

- **ETIMEDOUT on readFile**: File is cloud-only, not cached locally. Open in Finder to trigger download.
- **OneDrive sign-in errors (48bhe, 8004dec5)**: Device registration stale after re-image. Clear keychain credentials, re-register device via Company Portal.
- **Folder not found**: Run `ls ~/Library/CloudStorage/` to check what OneDrive folders exist.
