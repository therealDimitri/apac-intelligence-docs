# Bug Report: Client Logos Not Displaying

**Date:** 26 December 2025
**Status:** RESOLVED
**Severity:** Medium
**Affected Pages:** NPS Analytics, Priority Matrix, Client Profiles, all pages using ClientLogoDisplay

## Summary

Client logos were not displaying across the application. Instead of showing the actual logo images, the UI was falling back to coloured initials (e.g., "EH" for Epworth Healthcare instead of the logo).

## Root Causes

Two separate issues contributed to this bug:

### Issue 1: Next.js Image Optimisation Failure

The Next.js `<Image>` component was failing to optimise images located in OneDrive-synced folders. The error in the console was:

```
⨯ The requested resource isn't a valid image for /logos/epworth-healthcare.webp received null
```

**Cause:** The project path contains special characters (`OneDrive-AlteraDigitalHealth(2)`), which caused Next.js's sharp-based image optimisation to fail when reading the WebP files.

**The WebP files were valid:** File inspection confirmed proper RIFF/WEBP headers and VP8 encoding.

### Issue 2: Middleware Blocking Static Files

The authentication middleware (`src/proxy.ts`) was blocking access to static files in the `/public/logos/` directory. All routes not explicitly listed in `publicPaths` required authentication, including static asset requests.

## Solution

### Fix 1: Replace Next.js Image with Native img Tags

Updated the following components to use native `<img>` tags instead of Next.js `<Image>`:

| File | Component(s) Modified |
|------|----------------------|
| `src/components/ClientLogoDisplay.tsx` | Main display component |
| `src/components/priority-matrix/ClientLogoStack.tsx` | MiniClientLogo |
| `src/components/priority-matrix/MultiClientLogoDisplay.tsx` | SingleLogoDisplay, StackedGridItem, HorizontalOverlapItem, PrimaryCounterDisplay |

**Code Pattern:**
```tsx
// Before (broken)
<Image
  src={logoUrl}
  alt={clientName}
  width={size}
  height={size}
  className="object-contain"
/>

// After (fixed)
{/* eslint-disable-next-line @next/next/no-img-element */}
<img
  src={logoUrl}
  alt={clientName}
  className="object-contain w-full h-full"
  onError={() => setImageError(true)}
/>
```

Each component now also includes `useState` for `imageError` to handle graceful fallback to initials if the image fails to load.

### Fix 2: Add Static Paths to Middleware

Added logo paths to the `publicPaths` array in `src/proxy.ts`:

```typescript
const publicPaths = [
  // ... existing paths ...
  '/logos', // Static client logo files
  '/altera-icon.png', // Altera icon
]
```

## Verification

After applying fixes:

```bash
# Static file access now returns HTTP 200
$ curl -sI "http://localhost:3002/logos/epworth-healthcare.webp"
HTTP/1.1 200 OK
Content-Type: image/webp
Content-Length: 4718
```

Server logs confirm 41 client aliases loaded from Supabase and no image optimisation errors.

## Files Modified

1. `src/components/ClientLogoDisplay.tsx` - Replaced Image with native img
2. `src/components/priority-matrix/ClientLogoStack.tsx` - Replaced Image with native img
3. `src/components/priority-matrix/MultiClientLogoDisplay.tsx` - Replaced Image with native img (4 sub-components)
4. `src/proxy.ts` - Added `/logos` and `/altera-icon.png` to public paths

## Lessons Learned

1. **Next.js Image in OneDrive paths:** The Next.js Image component's optimisation layer (using sharp) can fail with paths containing special characters like parentheses. Using native `<img>` tags bypasses this issue.

2. **Middleware and static assets:** Always ensure static asset directories are excluded from authentication middleware to prevent unnecessary redirects.

3. **Supabase aliases working correctly:** The client name aliasing via Supabase `client_name_aliases` table was working as designed - 41 aliases were loaded successfully.

## Related Documentation

- `docs/architecture/DATABASE_STANDARDS.md` - Client name alias patterns
- `src/lib/client-logos-local.ts` - Logo resolution logic
- `src/hooks/useClientAliases.ts` - Supabase alias loading
