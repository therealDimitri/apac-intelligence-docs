# Security Incident Report: Scripts Repository Secret Leak

**Date**: 9 January 2026
**Severity**: High
**Status**: Resolved
**Repository**: `therealDimitri/apac-intelligence-scripts`

## Incident Summary

GitGuardian detected exposed secrets in the `apac-intelligence-scripts` repository following a commit on 8 January 2026 at 12:32:08 UTC.

## Exposed Secrets

| Secret Type | File | Status |
|-------------|------|--------|
| PostgreSQL URI (with password) | `apply-support-phase3-migration.mjs` | Removed |
| Supabase Service Role JWT | `apply-planning-hub-migration.mjs` | Removed |
| Supabase Service Role JWT (older) | `add-ar-knowledge.mjs`, `import-segmentation-events-2025.mjs` | Removed |

## Root Cause

Migration scripts were committed with hardcoded database credentials as fallback values:

```javascript
// BAD - hardcoded secret as fallback
const DATABASE_URL = process.env.DATABASE_URL ||
  'postgresql://postgres:PASSWORD@db.xxx.supabase.co:5432/postgres'

// BAD - hardcoded JWT as fallback
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'eyJ...'
```

## Remediation Steps Taken

### 1. Fixed Source Files
Updated scripts to require environment variables without fallbacks:

```javascript
// GOOD - require env var, fail if missing
const DATABASE_URL = process.env.DATABASE_URL
if (!DATABASE_URL) {
  console.error('DATABASE_URL environment variable is required')
  process.exit(1)
}
```

### 2. Cleaned Git History
Used BFG Repo-Cleaner to remove secrets from entire git history:

```bash
# Created secrets file
cat > /tmp/all-secrets.txt << 'EOF'
[PASSWORD]
[JWT_TOKEN_1]
[JWT_TOKEN_2]
EOF

# Ran BFG
bfg --replace-text /tmp/all-secrets.txt --no-blob-protection .

# Cleaned and force pushed
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force origin main
```

### 3. Updated Submodule Reference
Main repository updated to reference the cleaned scripts commit.

## Required Actions (Manual)

**CRITICAL**: The exposed credentials must be rotated in Supabase:

1. **Database Password**:
   - Go to Supabase Dashboard → Project Settings → Database
   - Click "Reset database password"
   - Update `DATABASE_URL` in all deployment environments

2. **Service Role Key**:
   - Go to Supabase Dashboard → Project Settings → API
   - Regenerate API Keys (this regenerates JWT secret)
   - Update `SUPABASE_SERVICE_ROLE_KEY` in all deployment environments

## Prevention Measures

### Existing Controls
- `.gitignore` excludes `.env*` files
- Pre-commit hooks with secretlint (main repo)

### Recommended Improvements

1. **Add secretlint to scripts repo**:
   ```bash
   npm install --save-dev secretlint @secretlint/secretlint-rule-preset-recommend
   ```

2. **Add pre-commit hook**:
   ```json
   // package.json
   {
     "scripts": {
       "lint:secrets": "secretlint '**/*'"
     }
   }
   ```

3. **Code review checklist**: Always check for hardcoded credentials before merging

4. **Use environment variable validation**:
   ```javascript
   // Create a standard pattern for all scripts
   import { requireEnv } from './utils/env.mjs'

   const DATABASE_URL = requireEnv('DATABASE_URL')
   const SUPABASE_KEY = requireEnv('SUPABASE_SERVICE_ROLE_KEY')
   ```

## Timeline

| Time (AEDT) | Event |
|-------------|-------|
| 08 Jan 23:32 | Scripts committed with hardcoded secrets |
| 09 Jan ~11:28 | GitGuardian alerts received |
| 09 Jan ~11:35 | Investigation started |
| 09 Jan ~11:55 | Source files fixed |
| 09 Jan ~12:00 | Git history cleaned with BFG |
| 09 Jan ~12:01 | Force push completed |
| 09 Jan ~12:02 | Submodule reference updated |

## Lessons Learned

1. **Never use hardcoded secrets as fallbacks** - even for "convenience" during development
2. **Scripts repositories need the same security controls** as main repositories
3. **GitGuardian provides valuable last-line-of-defence** detection
4. **BFG Repo-Cleaner** is effective for cleaning git history but credentials should still be rotated

## Related Documents

- [SECURITY-INCIDENT-20251227-exposed-credentials.md](./SECURITY-INCIDENT-20251227-exposed-credentials.md) - Previous similar incident
