# Deploy Optimisation Report - 26 December 2025

## Summary

Performed comprehensive cleanup and optimisation of the APAC Intelligence Hub project to reduce deploy file size and improve build performance.

## Space Savings

| Category           | Before | After  | Saved   |
| ------------------ | ------ | ------ | ------- |
| Total Project      | 1.8 GB | 1.2 GB | ~600 MB |
| .next Build Folder | 489 MB | 202 MB | ~287 MB |
| Scripts Folder     | 2.8 MB | 1.1 MB | ~1.7 MB |
| Public Folder      | 2.6 MB | 1.8 MB | ~800 KB |

## Changes Made

### 1. Files Removed

| File/Folder                                    | Size    | Reason                     |
| ---------------------------------------------- | ------- | -------------------------- |
| `.DS_Store` files (17+)                        | ~100 KB | macOS metadata files       |
| `public/favicon-old.png`                       | 903 KB  | Unused old favicon         |
| `src/app/(dashboard)/meetings/page.backup.tsx` | ~50 KB  | Backup file                |
| `test-results.json`                            | ~5 KB   | Test artifact              |
| `.next/` folder                                | 489 MB  | Build output (regenerated) |
| `.netlify/` folder                             | 44 KB   | Netlify cache              |
| `.swc/` folder                                 | ~5 KB   | SWC cache                  |
| `tsconfig.tsbuildinfo`                         | 477 KB  | TypeScript cache           |
| `deno.lock`                                    | 4 KB    | Unused Deno lock file      |
| `scripts/archive/`                             | 1.6 MB  | 290 archived scripts       |
| `scripts/archived-segmentation/`               | 76 KB   | Old segmentation scripts   |

### 2. Dependencies Updated

**Installed (missing):**

- `zod` - Schema validation
- `@react-email/render` - Email rendering
- `@radix-ui/react-dialog` - Dialog components
- `@radix-ui/react-visually-hidden` - Accessibility
- `@tiptap/core` - Rich text editor core

**Removed (unused):**

- `@supabase/auth-helpers-nextjs` - Not used (using NextAuth)
- `axios` - Not used (using native fetch)

**Installed (dev):**

- `@next/bundle-analyzer` - Bundle analysis tool

### 3. Next.js Configuration Optimised

Updated `next.config.ts` with:

```typescript
// Standalone output for smaller deployments
output: 'standalone',

// Modern image formats
images: {
  formats: ['image/avif', 'image/webp'],
}

// Package import optimisation
experimental: {
  optimizePackageImports: [
    'lucide-react',
    '@radix-ui/react-icons',
    'date-fns',
    '@tremor/react',
    'recharts',
    'framer-motion',
  ],
}

// Server-only packages excluded from client bundles
serverExternalPackages: [
  'tesseract.js',
  'pdf-parse',
  'pdf-to-img',
  'pdfjs-dist',
  'xlsx',
  'jspdf',
  'docx',
  '@langchain/core',
  '@langchain/langgraph',
  '@anthropic-ai/sdk',
  'pg',
  'postgres',
  'resend',
  'langfuse',
]

// Turbopack enabled (Next.js 16 default)
turbopack: {},
```

### 4. .gitignore Enhanced

Added patterns for:

- Test results (`test-results.json`)
- Backup files (`*.backup.*`, `*.bak`, `*.old`)
- Deno files (`deno.lock`)
- IDE folders (`.idea/`, `.vscode/`)
- Log files (`*.log`)
- Mac files (`**/.DS_Store`)
- SWC cache (`.swc/`)

## Heavy Dependencies Analysis

These packages contribute significantly to bundle size:

| Package           | Size   | Used In          | Recommendation                |
| ----------------- | ------ | ---------------- | ----------------------------- |
| `@tremor/react`   | 45 MB  | Dashboard charts | Consider lighter alternatives |
| `pdfjs-dist`      | 37 MB  | PDF parsing      | Keep (server-only)            |
| `jspdf`           | 29 MB  | PDF generation   | Keep (server-only)            |
| `@langchain/core` | 18 MB  | AI workflows     | Keep (server-only)            |
| `xlsx`            | 7.2 MB | Excel parsing    | Keep (server-only)            |
| `recharts`        | 7.5 MB | Charts           | Already optimised imports     |
| `@tiptap/*`       | 7.1 MB | Rich text editor | Required                      |

## Recommended Future Optimisations

### High Priority

1. **Replace @tremor/react** (45 MB saved)
   - Consider using Recharts directly with custom styling
   - Or use shadcn/ui charts which are lighter

2. **Image Optimisation**
   - Compress PNG logos in `/public/logos/` (some are 190KB+)
   - Convert large PNGs to WebP format
   - Use Next.js Image component consistently

3. **Code Splitting**
   - Lazy load heavy components (rich text editor, PDF viewer)
   - Use dynamic imports for admin-only features

### Medium Priority

4. **Bundle Analysis**
   Run bundle analyzer to identify more opportunities:

   ```bash
   ANALYZE=true npm run build
   ```

5. **Tree-shaking Verification**
   - Ensure all icon imports are specific (not `import * from`)
   - Check for unused exports

6. **Documentation Cleanup**
   - Archive old bug reports (58 files, 564 KB)
   - Archive old migrations (66 files, 640 KB)

### Low Priority

7. **Consider monorepo structure** for shared components
8. **Use Bun or pnpm** for faster installs and smaller node_modules

## Build Performance

- Build time improved with Turbopack (Next.js 16 default)
- Standalone output reduces deployment size
- Server external packages prevent unnecessary bundling

## Verification

Build tested successfully after all changes:

```
npm run build
```

All routes compiled correctly with no errors.

---

_Report generated: 26 December 2025_
_Author: Claude Code_
