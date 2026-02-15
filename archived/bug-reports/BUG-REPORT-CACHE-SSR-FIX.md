# Bug Report: Cache Module Server-Side Rendering Issue

## Issue Summary

Pages were failing to load with error: "The default export is not a React Component" due to the cache module attempting to run client-side code (setInterval) during server-side rendering.

## Date Reported

November 25, 2025

## Severity

**Critical** - All pages were broken and returning 404/500 errors

## Affected Components

- `/clients` page
- `/nps` page
- `/meetings` page
- `/actions` page
- `/ai` page

## Root Cause

The `cache.ts` module was creating a singleton instance and setting up a setInterval for cleanup during module initialization. This code was being executed during server-side rendering, which caused Next.js to fail when trying to render the pages.

### Problematic Code (src/lib/cache.ts)

```typescript
// Create singleton instance
export const cache = new Cache()

// Run cleanup every minute
if (typeof window !== 'undefined') {
  setInterval(() => {
    cache.cleanup()
  }, 60 * 1000)
}
```

Even with the `typeof window` check, the singleton was being created on the server side which could cause issues with the interval timer and SSR.

## Error Messages

```
⨯ Error: The default export is not a React Component in "/clients/page"
GET /clients 404
GET /clients 500
```

## Fix Applied

Modified `cache.ts` to properly handle server-side rendering by:

1. Creating a new Cache instance on each server-side render
2. Using a singleton pattern only on the client side
3. Setting up the cleanup interval only on the client side

### Fixed Code

```typescript
// Create singleton instance
let cacheInstance: Cache | null = null

export const cache = (() => {
  if (typeof window === 'undefined') {
    // Server-side: return a new instance each time
    return new Cache()
  }

  // Client-side: use singleton
  if (!cacheInstance) {
    cacheInstance = new Cache()
    // Run cleanup every minute on client-side only
    setInterval(() => {
      cacheInstance!.cleanup()
    }, 60 * 1000)
  }

  return cacheInstance
})()
```

## Impact

### Before Fix

- All pages returning 404 or 500 errors
- Error: "The default export is not a React Component"
- Application completely unusable

### After Fix

- All pages loading successfully (200 status)
- Proper server-side rendering
- Client-side caching working as expected

## Testing Verification

```bash
Testing /clients...
Status: 200
Testing /nps...
Status: 200
Testing /meetings...
Status: 200
Testing /actions...
Status: 200
Testing /ai...
Status: 200
```

## Lessons Learned

1. Always ensure modules are SSR-safe when using Next.js App Router
2. Client-side only code (like setInterval) must be properly isolated
3. Singleton patterns need special handling for SSR environments
4. Cache instances on the server should be isolated per request

## Related Enhancements

This issue occurred while implementing the following enhancements:

- Added pagination support for meetings (20 items per page)
- Implemented client-side caching with 5-minute TTL
- Added real-time subscriptions for live updates
- Calculated actual previous period NPS scores
- Calculated actual response rates from survey data

## Prevention

To prevent similar issues in the future:

1. Always test new modules with SSR in mind
2. Use the IIFE pattern with proper window checks for client-only code
3. Consider using Next.js dynamic imports with `ssr: false` for client-only components
4. Add SSR testing to the development workflow
