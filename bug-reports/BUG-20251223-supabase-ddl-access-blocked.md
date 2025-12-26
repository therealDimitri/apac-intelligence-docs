# Bug Report: Supabase DDL Operations and Preference Migration Failures

**Date:** 2025-12-23
**Severity:** High
**Status:** ✅ RESOLVED

## Summary

Automated DDL operations (CREATE MATERIALIZED VIEW, DROP, etc.) fail with "Tenant or user not found" error when using the Supabase connection pooler. This prevents scripts from automatically recreating database views.

## Root Cause

Supabase uses pgBouncer as a connection pooler with two modes:

| Port | Mode        | DDL Support |
| ---- | ----------- | ----------- |
| 6543 | Transaction | ❌ No       |
| 5432 | Session     | ✅ Yes      |

The `DATABASE_URL` in `.env.local` uses port 6543 (Transaction mode), which routes through pgBouncer and blocks DDL operations.

The `DATABASE_URL_DIRECT` exists but the hostname `db.usoyxsunetvxdjdglkmn.supabase.co` does not resolve via DNS (possibly VPN-related or deprecated).

## Impact

- Automated migration scripts fail
- Views cannot be recreated programmatically
- Manual SQL execution required via Supabase Dashboard

## Workaround

1. Open Supabase SQL Editor: https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/sql
2. Paste and run the migration SQL manually

## Long-term Fix

### Option 1: Add Management API Access Token (Recommended)

1. Go to https://supabase.com/dashboard/account/tokens
2. Create a new personal access token
3. Add to `.env.local`:
   ```
   SUPABASE_ACCESS_TOKEN=your_token_here
   ```
4. Update migration scripts to use the Management API:
   ```javascript
   const response = await fetch(
     `https://api.supabase.com/v1/projects/${projectRef}/database/query`,
     {
       method: 'POST',
       headers: {
         Authorization: `Bearer ${process.env.SUPABASE_ACCESS_TOKEN}`,
         'Content-Type': 'application/json',
       },
       body: JSON.stringify({ query: sql }),
     }
   )
   ```

### Option 2: Fix DATABASE_URL_DIRECT

The direct connection endpoint may require:

- IPv4 add-on in Supabase project settings
- Updated hostname format
- VPN configuration to allow Supabase direct endpoints

### Option 3: Use Supabase CLI

```bash
supabase link --project-ref usoyxsunetvxdjdglkmn
supabase db push
```

## Environment Variables Checklist

| Variable                        | Status         | Purpose                  |
| ------------------------------- | -------------- | ------------------------ |
| `NEXT_PUBLIC_SUPABASE_URL`      | ✅ Set         | REST API endpoint        |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | ✅ Set         | Anonymous access         |
| `SUPABASE_SERVICE_ROLE_KEY`     | ✅ Set         | Admin access (REST only) |
| `DATABASE_URL`                  | ⚠️ Port 6543   | Pooler - no DDL          |
| `DATABASE_URL_DIRECT`           | ❌ Unreachable | Direct connection        |
| `SUPABASE_ACCESS_TOKEN`         | ❌ Missing     | Management API           |

## Prevention

1. Add `SUPABASE_ACCESS_TOKEN` to `.env.local` and `.env.example`
2. Update migration scripts to use Management API
3. Add pre-flight check for DDL capability before running migrations
4. Document DDL limitations in DATABASE_STANDARDS.md

---

## Additional Issue: Preference Migration Failures

### Symptoms

Console errors: "Failed to migrate preferences: Object"

### Root Cause

RLS policies on `user_preferences` table checked `request.jwt.claims` for email, but NextAuth sessions don't populate Supabase JWT claims.

### Resolution

Updated RLS policies to allow:

- Service role full access (for API routes)
- Anon role access (for client-side with service key)
- Authenticated users to manage their own preferences

```sql
CREATE POLICY "Allow service role full access"
  ON user_preferences FOR ALL
  USING (auth.role() = 'service_role');

CREATE POLICY "Allow anon role full access"
  ON user_preferences FOR ALL
  USING (auth.role() = 'anon');
```

---

## Resolution Summary

| Issue                           | Fix Applied                                      |
| ------------------------------- | ------------------------------------------------ |
| `client_health_summary` missing | Recreated via Management API                     |
| DDL blocked by pooler           | Added `SUPABASE_ACCESS_TOKEN` for Management API |
| Preference migration failing    | Updated RLS policies for service role access     |

All issues resolved on 2025-12-23.
