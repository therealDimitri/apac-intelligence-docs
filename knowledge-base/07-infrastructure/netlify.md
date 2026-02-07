# Netlify Deployment

## Setup

- **Deploy trigger**: `git push` to `main` branch
- **Build command**: `npm run build` (Next.js)
- **No Vercel** — Netlify only

## Key Constraints

### Submodules Not Available
Netlify does NOT clone git submodules. The `scripts/` directory won't exist during build.
- `src/lib/onedrive-paths.ts` returns `null` (no OneDrive on CI) — this is expected
- `burc-config.ts` falls back to `''` via `?? ''`
- `next.config.ts` has `ignoreBuildErrors: true` as safety net

### TypeScript Checking
- `tsc --noEmit` removed from build script
- Pre-commit hook catches TS errors locally instead
- This avoids build failures from scripts/ submodule type issues

### Environment Variables
Required in Netlify dashboard:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `NEXTAUTH_SECRET`
- `AZURE_AD_CLIENT_ID` / `AZURE_AD_CLIENT_SECRET` / `AZURE_AD_TENANT_ID`
- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY` (for TTS audio briefings)

### Function Timeout
Netlify Functions have a 25-second timeout for streaming responses. ChaSen AI uses `maxSteps: 5` to cap tool-call depth within this window.

## Build Safety

If the build fails:
1. Check `next.config.ts` — `ignoreBuildErrors: true` should prevent TS errors from blocking
2. Check for import paths referencing `scripts/` submodule from `src/`
3. Server-only modules that read the filesystem must handle missing OneDrive gracefully
