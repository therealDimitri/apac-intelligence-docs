# Bug Fix: Turbopack Service Worker Caching Causes 404 Errors

## Issue Summary

**Date:** 9 January 2026
**Severity:** Critical (Dev Environment Broken)
**Status:** Fixed

## Problem Description

The local development server was returning 404 errors for all JavaScript chunks and CSS files, causing the page to render without styling or interactivity.

### Symptoms

- Page loads with unstyled HTML (no CSS)
- Browser console shows dozens of 404 errors for `/_next/static/chunks/` files
- Chunk URLs contain Turbopack-style naming (e.g., `[turbopack]_browser_dev_hmr-client_hmr-client_ts_*.js`)
- Server logs show no errors - server appears healthy
- Issue persists across page refreshes and cache clears

### Console Errors Example

```
Failed to load resource: 404 - /_next/static/chunks/[root-of-the-server]__f6202ce6._.css
Failed to load resource: 404 - /_next/static/chunks/[turbopack]_browser_dev_hmr-client_hmr-client_ts_bae88007._.js
Failed to load resource: 404 - /_next/static/chunks/node_modules_next_dist_compiled_react-dom_*.js
```

## Root Cause

1. **Service Worker Caching**: The application's service worker cached HTML pages that reference Turbopack-generated chunk URLs
2. **Bundler Mismatch**: When switching between Turbopack and webpack, or after clearing `.next`, the old cached HTML still referenced non-existent Turbopack chunks
3. **Browser Cache Persistence**: Standard cache clearing and hard refresh don't clear service worker caches or browser navigation cache

### Technical Details

- Next.js 16+ uses Turbopack by default for dev
- Turbopack generates chunks with different naming conventions than webpack
- Service workers cache the initial HTML response
- Cached HTML references old chunk URLs that no longer exist after server restart

## Solution

### Immediate Fix

1. Kill all Next.js processes:
   ```bash
   pkill -f "next"
   ```

2. Clear all caches:
   ```bash
   rm -rf .next node_modules/.cache
   ```

3. Start dev server with webpack:
   ```bash
   npx next dev --webpack
   ```

4. Clear browser service workers (in browser DevTools > Application > Service Workers > Unregister)

5. Close browser completely and reopen

### Permanent Fix

Updated `package.json` to use webpack by default:

```json
{
  "scripts": {
    "dev": "next dev --webpack"
  }
}
```

## Files Modified

### package.json

```diff
- "dev": "next dev",
+ "dev": "next dev --webpack",
```

## Prevention Measures

### For Developers

1. **Always use webpack for dev** - The `--webpack` flag is now the default in package.json
2. **Clear service workers** when experiencing unexplained 404s:
   - DevTools > Application > Service Workers > Unregister all
3. **Use incognito mode** for testing after cache issues
4. **Kill zombie processes** before restarting dev server

### If Issue Recurs

```bash
# Nuclear option - clear everything
pkill -f "next"
rm -rf .next node_modules/.cache
npm run dev

# In browser - clear service workers
# DevTools > Application > Service Workers > Unregister
# Then hard refresh (Cmd+Shift+R / Ctrl+Shift+R)
```

## Why Webpack Over Turbopack

While Turbopack is faster for large codebases, we're using webpack because:

1. **Stability**: Webpack has proven reliability on OneDrive-synced folders
2. **Service Worker Compatibility**: Better handling of chunk URL consistency
3. **Cache Predictability**: More consistent chunk naming between restarts
4. **Production Parity**: Production builds use webpack, so dev matches prod

## Commands Reference

```bash
# Start dev server (now uses webpack by default)
npm run dev

# If issues persist, full clean
pkill -f "next"
rm -rf .next node_modules/.cache
npm run dev

# Check what bundler is running (look for "webpack" or "Turbopack" in output)
# ▲ Next.js 16.1.1 (webpack)  <- Good
# ▲ Next.js 16.1.1 (Turbopack) <- May cause caching issues
```

## Related Documentation

- `docs/QUALITY_STANDARDS.md` - Quality checklist
- `docs/guides/BUG-FIX-production-404-and-macbook-layout.md` - Related production 404 fix
