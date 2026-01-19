# Bug Report: Safari Client-Side Exception After Deployment

**Date:** 2026-01-20
**Severity:** High
**Status:** Fixed
**Component:** Service Worker / Browser Caching

## Summary

Safari users experienced "Application error: a client-side exception has occurred" after deployments because the service worker was caching the root HTML page, which referenced old JavaScript bundle URLs that no longer existed.

## Symptoms

- Safari shows "Application error: a client-side exception has occurred while loading apac-cs-dashboards.com"
- Error occurs after deployments
- Other browsers (Chrome, Firefox) may work fine
- Hard refresh doesn't fix the issue
- Issue recurs after each deployment

## Root Cause

**Service Worker HTML Caching**

The service worker (`public/sw.js`) was caching the root HTML page `/` in `STATIC_ASSETS`:

```javascript
// BEFORE (broken)
const STATIC_ASSETS = ['/', '/altera-icon.png', '/favicon.png']
```

**Why This Caused the Issue:**

1. Service worker caches the HTML page on first visit
2. HTML page contains `<script>` tags referencing specific JavaScript bundle URLs (e.g., `/_next/static/chunks/app-layout-abc123.js`)
3. After deployment, Next.js generates new bundle URLs with different hashes
4. Service worker serves cached HTML referencing old bundle URLs
5. Browser tries to load non-existent bundle URLs → 404
6. JavaScript fails to initialize → "Application error: a client-side exception"

**Why Safari Was Affected More:**

- Safari has aggressive service worker caching
- Safari doesn't always check for service worker updates on navigation
- Safari's "Develop > Empty Caches" doesn't clear service worker caches

## Fix Applied

### 1. Removed HTML from Cached Assets

```javascript
// AFTER (fixed)
const STATIC_ASSETS = ['/altera-icon.png', '/favicon.png']
// Note: '/' removed - never cache HTML pages
```

### 2. Added Navigation Request Check

```javascript
// Skip caching for navigation requests (HTML pages)
if (
  url.pathname.startsWith('/api/') ||
  url.pathname.startsWith('/_next/') ||
  url.hostname.includes('supabase') ||
  url.hostname !== self.location.hostname ||
  event.request.mode === 'navigate'  // ← Added this check
) {
  return  // Don't intercept
}
```

### 3. Incremented Cache Version

```javascript
const CACHE_VERSION = 3
const CACHE_NAME = `apac-intelligence-v${CACHE_VERSION}`
```

This forces all clients to update their service worker and clear old caches.

## Files Changed

| File | Change |
|------|--------|
| `public/sw.js` | Removed HTML caching, added navigate check, incremented version |

## Immediate User Fix (While Deployment Propagates)

If users still see the error, they need to clear Safari's service worker:

### Option 1: Safari Develop Menu
1. Enable Develop menu: Safari → Preferences → Advanced → "Show Develop menu"
2. Develop → Empty Caches
3. Develop → Service Workers → Delete All
4. Close Safari completely (Cmd+Q)
5. Reopen and navigate to the site

### Option 2: Clear Website Data
1. Safari → Preferences → Privacy → Manage Website Data
2. Search for "apac-cs-dashboards"
3. Select and click "Remove"
4. Close Safari completely and reopen

### Option 3: Private Window
1. File → New Private Window
2. Navigate to the site (no cached service worker)

## Prevention

1. **Never cache HTML pages** in service workers - they contain bundle references that change on deployment
2. **Only cache truly static assets** like icons, images, fonts
3. **Use cache versioning** to force updates when needed
4. **Test in Safari** after deployments (it has the most aggressive SW caching)

## Technical Notes

### What Can Be Safely Cached
- Icons (`.png`, `.ico`, `.svg`)
- Images (`.jpg`, `.webp`)
- Fonts (`.woff2`)
- Static JSON/data files that never change

### What Should NEVER Be Cached
- HTML pages (contain bundle references)
- JavaScript bundles (hashes change on deployment)
- API responses (dynamic data)
- CSS (may reference assets with changing hashes)

## Related Documentation

- `docs/guides/BUG-FIX-turbopack-service-worker-caching.md` - Related dev environment issue
- Next.js Service Worker best practices

## Commit

```
fix: Service worker caching HTML causing Safari client-side errors

Root cause: Service worker was caching the root HTML page '/'. After
deployment, cached HTML referenced old JavaScript bundle URLs that no
longer existed, causing "Application error: a client-side exception"
in Safari.

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```
