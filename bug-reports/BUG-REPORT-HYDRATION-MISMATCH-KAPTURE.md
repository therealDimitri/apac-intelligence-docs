# Bug Report: Hydration Mismatch Warning - Kapture Browser Extension

## Issue Summary

React hydration warning appears in development due to Kapture browser extension adding classes to the body element after server-side rendering but before React hydration completes.

## Date Reported

November 26, 2025

## Severity

**Low/Informational** - This is a development-only warning that doesn't affect functionality. The application works correctly despite this warning.

## Affected Components

- Root layout (`src/app/layout.tsx`)
- Body element classes

## Root Cause

The Kapture browser extension injects additional CSS classes into the body element after the page loads but before React hydration completes. This causes a mismatch between:

- **Server HTML**: `className="inter_5972bc34-module__OU16Qa__className antialiased h-full bg-gray-50"`
- **Client HTML**: `className="inter_5972bc34-module__OU16Qa__className antialiased h-full bg-gray-50 kapture-..."`

The additional `kapture-...` classes are added by the browser extension, not by our application code.

## Error Message

```
A tree hydrated but some attributes of the server rendered HTML didn't match the client properties.
This won't be patched up. This can happen if a SSR-ed Client Component used:
- External changing data without sending a snapshot of it along with the HTML.
- It can also happen if the client has a browser extension installed which messes with the HTML before React loaded.
```

## Impact

- **Functionality**: None - the application works correctly
- **Performance**: None - hydration completes successfully
- **User Experience**: None - users don't see this warning
- **Development**: Warning appears in console during development

## Why This Happens

1. Next.js server renders the page with specific body classes
2. Browser receives the HTML and starts loading JavaScript
3. Kapture extension injects its tracking classes into the body
4. React attempts to hydrate and notices the mismatch
5. React logs a warning but continues working normally

## Solutions

### Option 1: Ignore the Warning (Recommended)

This is a harmless development warning that doesn't affect production or functionality. Simply ignore it.

### Option 2: Disable Kapture Extension in Development

Temporarily disable the Kapture extension while developing:

1. Open Chrome Extensions (chrome://extensions/)
2. Toggle off Kapture
3. Refresh your development server

### Option 3: Suppress Hydration Warnings (Not Recommended)

You could suppress hydration warnings for the body element, but this might hide real issues:

```tsx
// In src/app/layout.tsx
<body
  className={`${inter.className} antialiased h-full bg-gray-50`}
  suppressHydrationWarning={true}  // Only use if absolutely necessary
>
```

### Option 4: Use a Development-Only Browser Profile

Create a separate browser profile for development without extensions:

1. Create a new Chrome profile for development
2. Don't install browser extensions in this profile
3. Use this profile for development work

## Verification

The application is working correctly despite this warning:

- ✅ All pages load successfully (200 status)
- ✅ Authentication works properly
- ✅ Data fetching and display works
- ✅ Real-time subscriptions work
- ✅ Client-side navigation works

## Related Information

- This is a known issue with browser extensions that modify the DOM
- React's hydration process is strict about HTML matching
- Similar issues occur with password managers, ad blockers, and other extensions
- The warning only appears in development mode with React's strict checks

## Conclusion

This hydration warning is caused by the Kapture browser extension and can be safely ignored. It does not indicate any problem with the application code or functionality. The application continues to work correctly despite the warning.
