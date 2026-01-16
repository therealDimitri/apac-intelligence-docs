# Bug Fix: Export Node.js Module Build Error

**Date:** 2026-01-16
**Severity:** Critical (Build Blocking)
**Status:** ✅ Fixed

## Problem Description

After adding plan export functionality (PowerPoint, Excel, PDF), the Next.js build failed with the following error:

```
Module build failed: UnhandledSchemeError: Reading from "node:fs" is not handled by plugins (Unhandled scheme).

Import trace for requested module:
node:fs
./node_modules/pptxgenjs/dist/pptxgen.es.js
./src/lib/planning/export-plan.ts
./src/app/(dashboard)/planning/page.tsx
```

The `pptxgenjs` library uses Node.js `fs` module which is not available in client-side code. Next.js/Webpack cannot bundle server-side modules for client-side execution.

## Root Cause

The `export-plan.ts` file was importing server-side libraries (`pptxgenjs`, `xlsx`, `jspdf`) directly in a client component (`page.tsx`). These libraries contain Node.js-specific code that cannot run in the browser.

```typescript
// ❌ PROBLEMATIC - Client-side file importing server libraries
import pptxgen from 'pptxgenjs'  // Uses node:fs
import * as XLSX from 'xlsx'
import { jsPDF } from 'jspdf'
```

## Solution

Converted the client-side export utility to call the existing server-side API endpoint instead of importing the libraries directly.

### Before (Broken)
```typescript
// src/lib/planning/export-plan.ts
import pptxgen from 'pptxgenjs'  // ❌ Server-only library
import * as XLSX from 'xlsx'
import { jsPDF } from 'jspdf'

export async function exportPlan(plan, format) {
  // Direct library usage - fails in browser
  const pptx = new pptxgen()
  // ...
}
```

### After (Fixed)
```typescript
// src/lib/planning/export-plan.ts
export async function exportPlan(plan, format) {
  // ✅ Call server API instead
  const response = await fetch('/api/planning/export', {
    method: 'POST',
    body: JSON.stringify({ planId: plan.id, format }),
  })

  const blob = await response.blob()
  // Trigger browser download
  const url = window.URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  a.click()
}
```

The server-side API at `/api/planning/export/route.ts` already existed and handles the actual document generation using `pptxgenjs`, `xlsx`, and `jspdf`.

## Files Modified

1. **`src/lib/planning/export-plan.ts`** - Removed server library imports, now calls API
2. **`src/app/(dashboard)/planning/page.tsx`** - Export dropdown UI (unchanged)

## Architecture Pattern

```
┌─────────────────────────┐     ┌────────────────────────────┐
│   Client (Browser)       │     │   Server (Node.js)          │
├─────────────────────────┤     ├────────────────────────────┤
│ export-plan.ts          │────▶│ /api/planning/export       │
│ - Calls API             │     │ - pptxgenjs (PPTX)         │
│ - Triggers download     │◀────│ - xlsx (Excel)             │
│                         │     │ - jspdf (PDF)              │
└─────────────────────────┘     └────────────────────────────┘
```

## Key Learnings

1. **Server-only modules in client code**: Libraries that use Node.js APIs (`fs`, `path`, etc.) cannot be imported in client components
2. **node: protocol**: The `node:fs` import syntax is a clear indicator of Node.js-only code
3. **API routes as bridges**: Use Next.js API routes to bridge client-side UI with server-side functionality
4. **Dynamic imports won't help here**: Even with `dynamic(() => import(...), { ssr: false })`, the module bundling still fails

## Prevention

When adding libraries that generate files:
1. Check if library uses Node.js modules (look for `node:` imports or `fs`, `path`, etc.)
2. If server-only, create an API route
3. Client code should only handle fetch/download logic

## Verification

```bash
# Build passes
npm run build

# Manual test
1. Navigate to /planning
2. Find a plan card
3. Click export dropdown
4. Select PowerPoint/Excel/PDF
5. File downloads successfully
```

## Related

- `/api/planning/export/route.ts` - Server-side export handler
- `pptxgenjs` - Node.js PowerPoint generation library
- `xlsx` - Node.js Excel generation library
- `jspdf` - PDF generation (works in browser, but used server-side for consistency)
