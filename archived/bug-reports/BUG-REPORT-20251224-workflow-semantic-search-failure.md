# Bug Report: AI Workflows Failing - Missing Semantic Search Functions

**Date:** 2024-12-24
**Status:** ✅ RESOLVED
**Severity:** Critical (Workflows non-functional)
**Resolution Date:** 2024-12-24

## Problem

AI Workflows (Portfolio Analysis, Risk Assessment) were failing with cryptic errors. Initial error appeared as JSON parse error receiving HTML instead of JSON.

## Root Cause Analysis

### Diagnostic Steps

1. Created diagnostic script `scripts/debug-workflow-failures.mjs`
2. Tested each component of the workflow pipeline:
   - MatchaAI API: ✓ Working
   - Supabase connectivity: ✓ Working
   - Environment variables: ✓ All set
   - **RPC Functions: ✗ MISSING**

### Actual Root Cause

The `match_documents` and `match_conversation_embeddings` PostgreSQL functions don't exist in Supabase. These functions are required for:

- `semanticSearch()` in `src/lib/semantic-search.ts`
- `searchSimilarDocuments()` in `src/lib/embeddings.ts`
- `findSimilarConversations()` in `src/lib/embeddings.ts`

When workflows call these functions, the RPC calls fail with a 404, which causes the workflow to error out.

## Workflow Flow

```
User triggers workflow
  → runPortfolioAnalysis()
    → gatherContext()
      → executeTool('search_meetings')
        → semanticSearch()
          → searchSimilarDocuments()
            → supabase.rpc('match_documents') ← FAILS HERE (function doesn't exist)
```

## Solution

### 1. Migration File Created

Created `docs/migrations/20251224_add_semantic_search_functions.sql` which:

- Enables pgvector extension
- Creates `match_documents` function for document similarity search
- Creates `match_conversation_embeddings` function for conversation search
- Creates `conversation_embeddings` table if not exists
- Sets up proper indexes for vector search
- Grants necessary permissions

### 2. Workflow Resilience Improved

Updated `src/lib/agent-workflows.ts` to use `Promise.allSettled` instead of `Promise.all` in `gatherContext()`. This allows the workflow to continue even if some searches fail, providing degraded but functional output.

### 3. Diagnostic Tools Added

- `scripts/debug-workflow-failures.mjs` - Tests all workflow components
- `scripts/apply-semantic-search-migration.mjs` - Checks migration status

## Action Required

**Run the migration in Supabase SQL Editor:**

1. Open Supabase Dashboard → SQL Editor
2. Copy contents of `docs/migrations/20251224_add_semantic_search_functions.sql`
3. Execute the migration

Or run:

```bash
node scripts/apply-semantic-search-migration.mjs
```

This will open the migration file and provide instructions.

## Files Modified

| File                                                         | Changes                                                  |
| ------------------------------------------------------------ | -------------------------------------------------------- |
| `src/lib/agent-workflows.ts`                                 | Changed Promise.all to Promise.allSettled for resilience |
| `docs/migrations/20251224_add_semantic_search_functions.sql` | New migration                                            |
| `scripts/debug-workflow-failures.mjs`                        | New diagnostic script                                    |
| `scripts/apply-semantic-search-migration.mjs`                | New migration helper                                     |

## Verification

After running the migration, verify with:

```bash
node scripts/debug-workflow-failures.mjs
```

Should show:

```
  ✓ match_documents: exists
  ✓ match_conversation_embeddings: exists
```

Then test workflows in the ChaSen AI interface.

## Resolution

The migration was successfully applied on 2024-12-24 using the Supabase Management API:

```bash
# Via Supabase Management API
curl -X POST "https://api.supabase.com/v1/projects/usoyxsunetvxdjdglkmn/database/query" \
  -H "Authorization: Bearer $SUPABASE_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query": "<migration SQL>"}'
```

### Verification

Functions confirmed to exist in database:

| Function                        | Status    |
| ------------------------------- | --------- |
| `match_documents`               | ✅ EXISTS |
| `match_conversation_embeddings` | ✅ EXISTS |

AI Workflows (Portfolio Analysis, Risk Assessment) should now function correctly with full semantic search capabilities.

### Additional Fix (24 Dec 2024)

Fixed type mismatch in `match_conversation_embeddings` function:

- **Issue**: Function declared `conversation_id` as `text` but table uses `uuid`
- **Error**: `structure of query does not match function result type`
- **Fix**: Updated function to return `conversation_id uuid` instead of `text`

Also added content-type validation in frontend to prevent JSON parse errors when server returns HTML error pages.

## Prevention

- Always run `npm run introspect-schema` after migrations
- Add RPC function existence checks to integration tests
- Consider adding health check endpoint for workflow dependencies
- Store Supabase access tokens securely for automated migrations
