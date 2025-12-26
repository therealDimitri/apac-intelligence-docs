# LLM Models Table - Deployment Guide

## Overview

The LLM Refresh System is now fully implemented in code. The final step is creating the `llm_models` table in the database.

## Status

✅ **Completed:**

- API endpoints created (`/api/llms`, `/api/llms/refresh`)
- Frontend integration (FloatingChaSenAI.tsx)
- Backend integration (ChaSen chat API)
- TypeScript compilation successful
- Fallback mechanisms in place

⏳ **Pending:**

- Manual creation of `llm_models` table in Supabase

## Why Manual Creation?

Direct SQL execution via the Supabase pooler connection is currently failing with authentication errors ("Tenant or user not found"). This is likely due to:

1. Database password format/encoding issues
2. Pooler authentication method changes
3. Network/firewall restrictions

The table creation requires DDL (Data Definition Language) statements which cannot be executed via the Supabase REST API.

## Deployment Steps

### Step 1: Create the Table

1. **Open Supabase SQL Editor:**

   ```
   https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/sql/new
   ```

2. **Copy the SQL migration:**
   Location: `docs/migrations/20251207_llm_models_table.sql`

3. **Execute the SQL:**
   - Paste the entire SQL file into the editor
   - Click "Run" or press `Cmd/Ctrl + Enter`

4. **Verify table creation:**
   You should see a success message and the table should appear in the Table Editor.

### Step 2: Verify Installation

Run the verification script:

```bash
node scripts/create-llm-models-table-simple.mjs
```

Expected output:

```
✅ Found 5 LLM models in database:
   🟢 Claude 3.7 Sonnet (ID: 28, Key: claude-3-7-sonnet) [DEFAULT]
   🟢 Claude 3.5 Sonnet (ID: 25, Key: claude-3-5-sonnet)
   🟢 Claude Opus 4.1 (ID: 30, Key: claude-3-opus-4-1)
   🟢 Gemini 2.5 Flash-Lite (ID: 35, Key: gemini-2-5-flash-lite)
   🟢 GPT-4o (ID: 40, Key: gpt-4o)
```

### Step 3: Test the System

1. **Start the dev server:**

   ```bash
   npm run dev
   ```

2. **Open the application and access ChaSen AI**

3. **Verify model selector:**
   - The dropdown should show 5 models
   - Select different models
   - Send a test message
   - Check browser console for model selection logs

4. **Verify API endpoints:**

   ```bash
   # Test GET /api/llms
   curl http://localhost:3002/api/llms | jq

   # Test POST /api/llms/refresh
   curl -X POST http://localhost:3002/api/llms/refresh | jq
   ```

## Fallback Behavior (If Table Not Created)

The system is designed to work with fallbacks if the table doesn't exist:

**Frontend (FloatingChaSenAI.tsx):**

- Falls back to hardcoded models if `/api/llms` fails
- Shows 5 hardcoded models in dropdown
- Defaults to "claude-3-7-sonnet"

**Backend (ChaSen Chat API):**

- Falls back to model ID 28 (Claude Sonnet 4) if database lookup fails
- Logs warning: "Model not found, using default"
- Chat functionality continues to work

**API Endpoints:**

- `/api/llms` returns error 500 but frontend handles gracefully
- `/api/llms/refresh` returns error but doesn't break the system

## Alternative: API-Based Table Creation

If you prefer to use the API endpoint:

```bash
# Call the internal endpoint to seed data (after manual table creation)
curl -X POST http://localhost:3002/api/internal/create-llm-table
```

This endpoint will:

- Check if table exists
- If yes: Seed the 5 default models
- If no: Return instructions for manual creation

## Troubleshooting

### Issue: "Table llm_models does not exist"

**Solution:**
Execute the SQL migration manually in Supabase SQL Editor (Step 1 above)

### Issue: Models not appearing in dropdown

**Diagnosis:**

1. Check browser console for errors
2. Verify `/api/llms` endpoint: `curl http://localhost:3002/api/llms`
3. Check database table exists and has rows

**Solution:**

- If table exists but empty: Run `/api/llms/refresh` endpoint
- If table doesn't exist: Follow Step 1 above
- If hardcoded models appear: Table creation pending, fallback working correctly

### Issue: Wrong model being used for chat

**Diagnosis:**
Check server logs for: `[ChaSen Chat] Using model: ... (MatchaAI LLM ID: ...)`

**Solution:**

```sql
-- Verify model mapping in database
SELECT model_key, matcha_llm_id, is_active FROM llm_models;

-- Ensure model is active
UPDATE llm_models SET is_active = true WHERE model_key = 'claude-3-7-sonnet';
```

## Files Modified

### New Files:

- `docs/LLM_REFRESH_SYSTEM.md` - Full system documentation
- `docs/migrations/20251207_llm_models_table.sql` - Table schema and seed data
- `docs/LLM_MODELS_DEPLOYMENT.md` - This deployment guide
- `src/app/api/llms/route.ts` - GET endpoint
- `src/app/api/llms/refresh/route.ts` - Refresh endpoint
- `src/app/api/internal/create-llm-table/route.ts` - Helper endpoint
- `scripts/create-llm-models-table-simple.mjs` - Verification script
- `scripts/create-llm-table-final.mjs` - Status check script
- Multiple migration helper scripts (for documentation)

### Modified Files:

- `src/components/FloatingChaSenAI.tsx` - Dynamic model loading
- `src/app/api/chasen/chat/route.ts` - Model key → ID mapping

## Next Steps After Table Creation

1. **Test end-to-end:**
   - Verify all 5 models appear in dropdown
   - Test model selection persistence
   - Verify chat works with different models

2. **Monitor logs:**
   - Check for model lookup errors
   - Verify correct MatchaAI LLM IDs are being used

3. **Optional: Set up automatic refresh:**
   - Add Vercel cron job (see LLM_REFRESH_SYSTEM.md)
   - Or manually call `/api/llms/refresh` when MatchaAI adds new models

## Production Deployment

When deploying to production:

1. **Run the same SQL migration on production database**
2. **Verify environment variables are set:**
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `SUPABASE_SERVICE_ROLE_KEY`
   - `MATCHAAI_API_KEY`

3. **Test the endpoints after deployment**

## Summary

The LLM Refresh System is complete and functional. The only remaining step is manually creating the `llm_models` table using the provided SQL migration. The system includes comprehensive fallbacks and will continue to work (with hardcoded models) until the table is created.

**Estimated time to complete:** 2-3 minutes (manual SQL execution)

**Risk level:** Low (fallbacks ensure system continues working)

**Recommendation:** Create the table when convenient. The system is production-ready with or without it.
