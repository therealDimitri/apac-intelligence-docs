# Security Incident Report: Exposed Database Credentials

**Date:** 27 December 2025
**Status:** RESOLVED
**Severity:** Critical
**Detection:** GitGuardian automated scanning

## Summary

GitGuardian detected exposed secrets in the `therealDimitri/apac-intelligence-scripts` repository:
1. PostgreSQL database connection URI with password
2. Supabase Service Role JWT token

These credentials were hardcoded in migration scripts and pushed to the public repository on 26 December 2025.

## Exposed Credentials

| Secret Type | Files Affected |
|-------------|----------------|
| PostgreSQL URI with password | `execute-aged-migration-v2.mjs`, `create-webhook-logs-table.mjs`, `create-cse-assignments-table.mjs` |
| Supabase Service Role JWT | `import-segmentation-events-2025.mjs`, `add-ar-knowledge.mjs` |

## Risk Assessment

- **PostgreSQL Password:** Could allow direct database access, data exfiltration, or modification
- **Service Role JWT:** Bypasses Row Level Security (RLS), grants full admin access to all tables

## Remediation Actions

### 1. Code Fixes (Immediate)

Removed all hardcoded credentials from scripts and replaced with environment variable references:

```javascript
// BEFORE (vulnerable)
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
const connectionString = 'postgresql://postgres:PASSWORD@...';

// AFTER (secure)
dotenv.config({ path: join(__dirname, '../.env.local') });
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;
const connectionString = process.env.DATABASE_URL_DIRECT;

if (!SUPABASE_KEY) {
  console.error('❌ Missing SUPABASE_SERVICE_ROLE_KEY');
  process.exit(1);
}
```

**Commits:**
- `apac-intelligence-scripts`: `ceeabe1` - security: remove hardcoded database credentials and API keys
- `apac-intelligence-v2`: `bf8eede` - chore: update scripts submodule with security fix

### 2. Credential Rotation

All exposed credentials were rotated:

| Credential | Action |
|------------|--------|
| Database Password | Rotated via Supabase Dashboard |
| API Keys | Migrated from legacy JWT to new Publishable/Secret format |
| Legacy JWT Keys | Disabled in Supabase Dashboard |

### 3. Environment Configuration

Updated `.env.local` with new credentials:
- `DATABASE_URL` - Pooler connection with new password
- `DATABASE_URL_DIRECT` - Direct connection with new password
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` - New publishable key (`sb_publishable_...`)
- `SUPABASE_SERVICE_ROLE_KEY` - New secret key (`sb_secret_...`)

### 4. Verification

All connections tested and verified working:
- ✅ Supabase API (Publishable Key)
- ✅ Supabase API (Secret Key)
- ✅ PostgreSQL Direct Connection
- ✅ PostgreSQL Pooler Connection

## Files Modified

### Scripts Repository (`apac-intelligence-scripts`)

1. **execute-aged-migration-v2.mjs**
   - Removed hardcoded DB password fallback
   - Added validation for required env vars

2. **create-webhook-logs-table.mjs**
   - Removed hardcoded DB password fallback
   - Added explicit error message for missing env var

3. **create-cse-assignments-table.mjs**
   - Added dotenv configuration
   - Removed hardcoded DB password
   - Added validation for required env vars

4. **import-segmentation-events-2025.mjs**
   - Added dotenv configuration
   - Replaced hardcoded JWT with env var
   - Added validation for required env vars

5. **add-ar-knowledge.mjs**
   - Added dotenv configuration
   - Replaced hardcoded JWT with env var
   - Added validation for required env vars

## Preventive Measures

### Implemented

1. **Environment Variable Pattern:** All scripts now load credentials from `.env.local`
2. **Explicit Validation:** Scripts fail fast with clear error messages if env vars missing
3. **Security Comments:** Added inline comments warning against hardcoding secrets
4. **Pre-commit Secret Scanning:** Added `secretlint` to scan staged files before every commit
   - Installed `secretlint` with `@secretlint/secretlint-rule-preset-recommend`
   - Created `.secretlintrc.json` configuration
   - Added `secrets:scan` and `secrets:scan:staged` npm scripts
   - Updated `.husky/pre-commit` to block commits containing secrets
   - Commit: `153f089` - feat: add pre-commit secret scanning with secretlint

5. **GitHub Secret Scanning:** Enabled via repository settings (Code security and analysis)

### Recommended (Outstanding)

1. **Git History Cleanup:** Consider using BFG Repo-Cleaner to remove secrets from git history
2. **Repository Visibility:** Review if scripts repository should be private
3. **.gitignore Review:** Ensure all `.env*` files are properly gitignored

## Timeline

| Time | Event |
|------|-------|
| 26 Dec 2025, 07:36 UTC | Secrets pushed to repository |
| 27 Dec 2025 | GitGuardian alerts received |
| 27 Dec 2025 | Code fixes implemented and pushed |
| 27 Dec 2025 | Credentials rotated in Supabase |
| 27 Dec 2025 | Legacy API keys disabled |
| 27 Dec 2025 | Connections verified working |
| 28 Dec 2025 | Pre-commit secret scanning implemented |
| 28 Dec 2025 | GitHub secret scanning enabled |

## Lessons Learned

1. **Never hardcode credentials** - Always use environment variables, even for "quick" scripts
2. **Use fallbacks carefully** - Fallback values for connection strings should never contain real credentials
3. **Review before push** - Check for sensitive data before pushing to remote repositories
4. **Automated scanning** - GitGuardian detection was valuable for catching this quickly

## Related Documentation

- Supabase API Keys: https://supabase.com/docs/guides/api/api-keys
- GitGuardian Remediation: https://docs.gitguardian.com/secrets-detection/remediation

## Contact

For questions about this incident, contact the development team.
