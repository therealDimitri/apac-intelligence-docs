# Bug Report: @supabase/ssr Module Not Found

**Date:** 2026-01-09
**Severity:** Critical (Blocks deployment)
**Status:** Resolved

## Summary
Netlify deployment failed due to missing `@supabase/ssr` package import in the quick meeting scheduling API route.

## Error Message
```
Error: Turbopack build failed with 1 errors:
./src/app/api/meetings/schedule-quick/route.ts:11:1
Module not found: Can't resolve '@supabase/ssr'
```

## Root Cause
The file `src/app/api/meetings/schedule-quick/route.ts` was using:
```typescript
import { createServerClient } from '@supabase/ssr'
```

However, the `@supabase/ssr` package was not installed in the project. The project uses `@supabase/supabase-js` with a custom `getServiceSupabase()` helper function instead.

## Resolution
Replaced the `@supabase/ssr` import with the existing project pattern:

**Before:**
```typescript
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

async function getSupabaseClient() {
  const cookieStore = await cookies()
  return createServerClient(...)
}
```

**After:**
```typescript
import { getServiceSupabase } from '@/lib/supabase'

// Usage: const supabase = getServiceSupabase()
```

## Files Modified
- `src/app/api/meetings/schedule-quick/route.ts`

## Verification
- Local build: Successful
- Commit: `8b01513f`
- Deployment: Triggered, awaiting confirmation

## Prevention
When creating new API routes that need Supabase:
1. Always use `getServiceSupabase()` from `@/lib/supabase`
2. Do not install or use `@supabase/ssr` unless specifically added to the project
3. Run `npm run build` locally before pushing to verify no module resolution errors
