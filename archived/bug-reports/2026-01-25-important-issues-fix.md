# Bug Report: Important Architecture Issues Fix

**Date:** 2026-01-25
**Severity:** Important (Non-Critical)
**Status:** Resolved
**Commits:** 4cdc48cc, eea1075f

## Summary

Following a comprehensive code review, four important architectural issues were identified and resolved. These issues did not pose immediate security risks but affected code maintainability, performance, and consistency.

## Issues Fixed

### 1. Module-Level Service Client Instantiation

**Problem:** Multiple modules were creating Supabase clients at module level:
```typescript
// BAD: Creates client when module is imported
const supabase = createClient(url, serviceKey)
```

This pattern caused:
- Build-time failures when environment variables weren't available
- Cold start performance issues in serverless deployments
- Potential memory leaks from multiple client instances

**Solution:** Implemented lazy-initialized singleton pattern in `src/lib/supabase.ts`:
```typescript
let serviceClient: SupabaseClient | null = null

export function getServiceSupabase(): SupabaseClient {
  if (!serviceClient) {
    serviceClient = createClient(url, serviceKey)
  }
  return serviceClient
}
```

**Files Refactored:**
- chasen-agents.ts, chasen-charts.ts, chasen-graph-rag.ts
- chasen-mcp.ts, chasen-memory.ts, chasen-predictions.ts
- chasen-workflows.ts, client-display-names.ts
- next-best-action.ts, performance-monitor.ts

### 2. Rate Limiting Storage

**Problem:** Rate limiting used in-memory storage only, which didn't persist across serverless function instances.

**Solution:** Hybrid rate limiting with:
- Local cache for fast path (0ms lookup)
- Supabase persistence for cross-instance coordination
- Automatic fallback to local-only if DB unavailable

**Migration Applied:** Created `rate_limits` table in Supabase with TTL-based cleanup.

### 3. Error Handling Standardisation

**Problem:** 135+ API routes used inconsistent error handling patterns:
```typescript
// Inconsistent patterns found:
return NextResponse.json({ error: message }, { status: 500 })
return NextResponse.json({ success: false, error: message })
return new Response(JSON.stringify({ error }), { status: 500 })
```

**Solution:** Added centralised error handling in `src/lib/api-utils.ts`:

```typescript
// New helper functions
handleApiError(error, context)     // Maps errors to appropriate HTTP status codes
withErrorHandling(handler, ctx)    // HOF wrapper for automatic try-catch
createErrorResponse(code, msg)     // Standardised error format
createSuccessResponse(data)        // Standardised success format
```

**Error Code Mapping:**
- PGRST301, 401 → 401 Unauthorized
- 403, PGRST302 → 403 Forbidden
- PGRST116 → 404 Not Found
- 23505, 23503, 23502 → 400 Validation Error
- All others → 500 Internal Error

**Routes Refactored (Examples):**
- /api/clients - Full refactor with lazy Supabase client
- /api/admin/data-sync - Standardised error responses

### 4. Debug Mode Always On

**Problem:** NextAuth was configured with `debug: true` in production, exposing sensitive authentication details in logs.

**Solution:** Changed to environment-conditional:
```typescript
debug: process.env.NODE_ENV === 'development'
```

## Testing

- All 56 unit tests pass
- Build succeeds with zero TypeScript errors
- Netlify deployment verified

## Migration Path

The 133 remaining API routes can be migrated gradually using the new helpers. Priority order:
1. Admin routes (sensitive operations)
2. Auth routes (security-critical)
3. High-traffic routes (clients, actions, meetings)
4. Remaining routes

## Related

- Previous fix: 0efdcd20 (Security: Fix 3 critical vulnerabilities)
- See also: docs/QUALITY_STANDARDS.md for error handling guidelines
