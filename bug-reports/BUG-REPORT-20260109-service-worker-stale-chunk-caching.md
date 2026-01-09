# Bug Report: Service Worker Caching Stale Next.js Chunks

**Date**: 9 January 2026
**Severity**: High
**Status**: Resolved
**Affected Component**: `public/sw.js` (Service Worker)

## Summary

The Next.js 16 development server was returning 404 errors for chunk files like `/_next/static/chunks/node_modules_09a9742d._.js`, causing client-side exceptions and unstyled content. The issue persisted across server restarts and `.next` directory clears.

## Root Cause

The service worker's fetch event handler was caching ALL GET requests, including Next.js development assets at `/_next/static/chunks/`. When Turbopack regenerated these chunks with different hashes (which happens frequently during development), the service worker served stale cached responses for URLs that no longer existed on the server.

### Problematic Code (Before)

```javascript
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') {
    return
  }

  event.respondWith(
    caches.match(event.request).then(response => {
      return response || fetch(event.request)
    })
  )
})
```

This code would:
1. Cache a chunk file like `/_next/static/chunks/abc123.js`
2. When Turbopack regenerated chunks, the old URL would return a stale cached response
3. The browser would try to use the stale response, causing 404-like behaviour and broken JavaScript

## Solution

Modified the service worker to exclude Next.js development assets, API routes, and hot module replacement paths from caching.

### Fixed Code (After)

```javascript
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') {
    return
  }

  const url = new URL(event.request.url)

  // Never cache Next.js development assets - they change frequently with Turbopack
  if (url.pathname.startsWith('/_next/')) {
    return
  }

  // Also skip caching for API routes and hot module replacement
  if (url.pathname.startsWith('/api/') || url.pathname.includes('__webpack') || url.pathname.includes('__turbopack')) {
    return
  }

  event.respondWith(
    caches.match(event.request).then(response => {
      return response || fetch(event.request)
    })
  )
})
```

Additionally, the cache version was incremented from `apac-intelligence-v1` to `apac-intelligence-v2` to ensure existing stale caches are cleared when the new service worker activates.

## Files Modified

| File | Change |
|------|--------|
| `public/sw.js` | Added path exclusions for `/_next/`, `/api/`, `__webpack`, and `__turbopack` in fetch handler; incremented cache version |

## Testing Steps

1. Clear browser cache and unregister existing service workers
2. Start the Next.js development server with `npm run dev`
3. Navigate to the application
4. Make code changes that trigger Turbopack chunk regeneration
5. Verify no 404 errors appear in the console for `/_next/` paths
6. Verify the application loads with correct styles and functionality

## Lessons Learned

- Service workers should never cache bundler-generated assets with hash-based filenames in development environments
- When using Turbopack (or any hot-reloading bundler), chunk URLs are ephemeral and should always be fetched fresh
- Service worker caching strategies should explicitly exclude development tooling paths
- Cache version bumping ensures clean slate when caching logic changes

## Related Issues

- This is a common issue when service workers are introduced without considering the development workflow
- Similar problems can occur in production if cache-busting headers are not properly configured

## Prevention

Consider adding a development mode check to the service worker that disables caching entirely during development:

```javascript
// Optional: Disable all caching in development
const isDev = self.location.hostname === 'localhost'
if (isDev) {
  // Skip all caching logic in development
  return
}
```
