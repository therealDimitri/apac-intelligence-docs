# Bug Report: Next.js Dev Server Port 3000 Conflict

**Date:** 2026-01-09
**Severity:** Low
**Status:** Resolved
**Component:** Development Environment

## Summary

The Next.js development server was unable to start on the default port 3000, automatically falling back to alternative ports (3001, 3002). This investigation identified the root cause and documented the resolution.

## Symptoms

- Running `npm run dev` consistently triggered warning: "Port 3000 is in use by an unknown process"
- Next.js auto-selected alternate ports (3001, 3002)
- Standard `lsof -i :3000` returned no results
- `netstat -an | grep 3000` showed: `tcp46 0 0 *.3000 *.* LISTEN`

## Investigation Process

### 1. Process Analysis
- Checked all running node/next processes - none related to this project
- Verified ports 3000-3002 with `lsof` - initially showed no processes
- Found ghost listener via `netstat -an | grep 3000`

### 2. Root Cause Identification
Detailed netstat output revealed:
```
tcp46 0 0 *.3000 *.* LISTEN ... java:528
```

Process identification:
```
root 528 0.1 1.6 ... /opt/homebrew/opt/openjdk/libexec/openjdk.jdk/.../java -jar /opt/homebrew/Cellar/metabase/0.57.7/libexec/metabase.jar
```

**Root Cause:** Homebrew Metabase service (analytics platform) was running as a system service, listening on port 3000.

### 3. Configuration Checks Performed

#### Next.js Configuration (`next.config.ts`)
- Turbopack enabled (correct)
- Standalone output configured
- Image optimisation configured
- Server external packages listed
- No misconfigurations found

#### Package.json
- Dev script: `next dev` (correct)
- Next.js version: 16.0.7 (latest)
- All dependencies properly listed

#### Service Worker (`public/sw.js`)
- Correctly configured to skip caching `/_next/` assets
- Properly excludes API routes and HMR endpoints
- No development caching issues

#### File System
- .next directory existed from previous build (cleaned)
- No lock files present
- node_modules installed correctly

## Resolution

1. Cleared the `.next` directory to remove stale build artifacts
2. Started dev server - automatically used port 3001
3. Server runs correctly on http://localhost:3001

### To Use Port 3000

If port 3000 is required, either:

**Option A:** Stop Metabase temporarily
```bash
brew services stop metabase
```

**Option B:** Configure Metabase to use different port
Edit Metabase config to use a different port (e.g., 3030)

**Option C:** Use the auto-assigned port (recommended)
Continue using port 3001 - no functional difference for development

## Verification

After cleanup, the dev server:
- Started successfully in 592ms
- Turbopack enabled and working
- Authentication redirects functioning (307 to `/auth/dev-signin`)
- Full page renders correctly with all assets loading
- HMR (Hot Module Replacement) operational

## Technical Details

| Component | Status |
|-----------|--------|
| Next.js Version | 16.0.7 |
| Turbopack | Enabled |
| Dev Server Port | 3001 (auto-assigned) |
| Startup Time | ~600ms |
| Authentication | Working |
| HMR | Working |

## Lessons Learned

1. `lsof -i :PORT` may not show all processes, especially root-owned Java services
2. `netstat -vanp tcp | grep PORT` provides more detailed information including process names
3. Homebrew services can use common development ports
4. Next.js gracefully handles port conflicts by auto-selecting alternatives

## Prevention

Consider documenting commonly used ports in the team development setup guide:
- Port 3000: Often used by Metabase (if installed)
- Port 3001-3002: Next.js fallback ports
- Port 5432: PostgreSQL
- Port 54321: Supabase local development

---

**Investigated by:** Claude Opus 4.5
**Environment:** macOS Darwin 25.2.0
