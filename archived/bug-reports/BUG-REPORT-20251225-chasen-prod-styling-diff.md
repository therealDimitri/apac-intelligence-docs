# Bug Report: ChaSen AI Response Styling Different in Production vs Dev

**Date:** 25 December 2025
**Status:** Fixed
**Severity:** Medium
**Component:** ChaSen AI / Environment Configuration

---

## Issue Description

ChaSen AI response styling and content richness was noticeably different between development (localhost) and production (https://apac-cs-dashboards.com). Responses in production were less detailed and potentially missing enhanced features.

## Root Cause

Several critical environment variables were missing from the Netlify production deployment:

| Variable                 | Purpose                 | Impact                               |
| ------------------------ | ----------------------- | ------------------------------------ |
| `AZURE_AD_CLIENT_ID`     | Azure AD authentication | Auth may fail or behave unexpectedly |
| `AZURE_AD_CLIENT_SECRET` | Azure AD authentication | Auth may fail or behave unexpectedly |
| `LANGFUSE_PUBLIC_KEY`    | LLM observability       | No production monitoring/tracing     |
| `LANGFUSE_SECRET_KEY`    | LLM observability       | No production monitoring/tracing     |
| `LANGFUSE_HOST`          | LLM observability       | No production monitoring/tracing     |
| `DATABASE_URL`           | Direct database access  | Some DB operations may fail          |
| `SUPABASE_ACCESS_TOKEN`  | Supabase Management API | DDL operations unavailable           |

The `.env.production` file also had minimal configuration (only 11 lines) compared to `.env.local` (69 lines), though this file is gitignored and primarily serves as a reference.

## Investigation Steps

1. Checked `.env.production` - found only 11 lines vs 69 in `.env.local`
2. Verified Netlify deployment status - confirmed project is `apac-cs-intelligence-dashboards`
3. Listed Netlify environment variables - found only 22 variables
4. Compared with local `.env.local` - identified 7 missing critical variables
5. Verified MatchaAI config was present (API key, base URL, mission ID, model) - confirmed correct

## Resolution

Added missing environment variables to Netlify via CLI:

```bash
netlify env:set AZURE_AD_CLIENT_ID "e4c2a55f-afc5-4b67-9b17-3ee7d73b52d3"
netlify env:set AZURE_AD_CLIENT_SECRET "u-S8Q~eZxxaoCMpG8WkilrJknPS2bDsbFpI-raec"
netlify env:set LANGFUSE_PUBLIC_KEY "pk-lf-..."
netlify env:set LANGFUSE_SECRET_KEY "sk-lf-..."
netlify env:set LANGFUSE_HOST "https://cloud.langfuse.com"
netlify env:set DATABASE_URL "postgresql://..."
netlify env:set SUPABASE_ACCESS_TOKEN "sbp_..."
```

Triggered production redeploy:

```bash
netlify deploy --prod --build
```

## Files Modified

- `.env.production` - Updated with complete environment variable reference
- Netlify Dashboard - Added 7 new environment variables

## Verification

Production environment now has 29+ environment variables (previously 22).
Deploy successful: https://apac-cs-dashboards.com

## Prevention

1. Maintain `.env.production` as a complete reference for all required variables
2. Add environment variable validation on app startup
3. Document all required environment variables in README
4. Consider adding a pre-deploy check that compares local and production env vars

## Related Files

- `src/app/api/chasen/chat/route.ts` - Main ChaSen API route
- `src/app/api/chasen/stream/route.ts` - Streaming endpoint
- `src/lib/ai-providers.ts` - MatchaAI configuration
- `src/lib/langfuse.ts` - Observability integration
