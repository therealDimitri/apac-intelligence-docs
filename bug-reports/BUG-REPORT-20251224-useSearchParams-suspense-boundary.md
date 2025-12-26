# Bug Report: useSearchParams() Suspense Boundary Required

**Date:** 2025-12-24
**Status:** Fixed
**Severity:** Critical (Build Failure)
**Affected Component:** `src/app/(dashboard)/layout.tsx`

---

## Summary

Netlify deploy failed with the error:

```
useSearchParams() should be wrapped in a suspense boundary at page "/aging-accounts/compliance"
```

This prevented all deployments from completing successfully.

---

## Root Cause

Next.js 16 requires `useSearchParams()` to be wrapped in a `<Suspense>` boundary when used in components that may be rendered during static page generation.

**Components using useSearchParams:**

1. `src/contexts/ClientContext.tsx` - The `ClientProvider` uses `useSearchParams` to detect client from URL
2. `src/hooks/useChaSenContext.ts` - Uses `useSearchParams` for page context detection

**Why it failed:**

- `ClientProvider` wraps the entire dashboard layout
- During static generation of `/aging-accounts/compliance`, Next.js encountered `useSearchParams()` without a Suspense boundary
- The build process throws an error because it cannot determine search params at build time

### Technical Details

```tsx
// ClientContext.tsx - Line 31
const searchParams = useSearchParams()

// useChaSenContext.ts - Line 15
const searchParams = useSearchParams()
```

Both hooks are used in the dashboard layout, which wraps all dashboard pages including the compliance page that was being statically generated.

---

## Fix Applied

Wrapped the `ClientProvider` in a `<Suspense>` boundary in `src/app/(dashboard)/layout.tsx`:

```tsx
// Before
export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <SessionProvider>
      <ClientProvider>
        <TooltipProvider delayDuration={200}>
          <DashboardLayoutContent>{children}</DashboardLayoutContent>
          <Toaster />
        </TooltipProvider>
      </ClientProvider>
    </SessionProvider>
  )
}

// After
export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <SessionProvider>
      {/* Suspense boundary required for useSearchParams in ClientProvider and useChaSenContext */}
      <Suspense fallback={null}>
        <ClientProvider>
          <TooltipProvider delayDuration={200}>
            <DashboardLayoutContent>{children}</DashboardLayoutContent>
            <Toaster />
          </TooltipProvider>
        </ClientProvider>
      </Suspense>
    </SessionProvider>
  )
}
```

This allows Next.js to defer the rendering of components that depend on search params until client-side hydration.

---

## Affected Areas

All dashboard pages are now properly wrapped, including:

- `/aging-accounts/compliance`
- `/aging-accounts`
- `/clients`
- `/meetings`
- `/actions`
- `/nps`
- All other dashboard routes

---

## Testing Performed

1. Ran `npm run build` locally
2. Verified all 95 static pages generated successfully
3. Confirmed `/aging-accounts/compliance` page builds without error
4. Verified no TypeScript errors in the build

---

## Prevention

When using `useSearchParams()` in Next.js 16+:

1. **Always wrap in Suspense** - Any component using `useSearchParams()` should be wrapped in `<Suspense>` boundary
2. **Check layout files** - If a context provider uses search params, ensure the layout wraps it in Suspense
3. **Test builds locally** - Run `npm run build` before pushing to catch static generation issues
4. **Consider alternatives** - For build-time data, use `generateStaticParams()` instead of client-side search params

---

## Related Documentation

- [Next.js useSearchParams documentation](https://nextjs.org/docs/app/api-reference/functions/use-search-params)
- [Next.js Suspense boundaries](https://nextjs.org/docs/app/building-your-application/routing/loading-ui-and-streaming)

---

## Commit

```
fix: wrap ClientProvider in Suspense for useSearchParams compatibility
Commit: 47c116a
```
