# Sales Hub Consolidation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Consolidate 4 separate Sales Hub pages into 1 unified tabbed interface with unified search.

**Architecture:** Single page with 3 tabs (Products, Bundles, AI Recommendations), unified search that queries across all content types, and a shared detail panel component. State managed via React hooks with URL hash sync for deep linking.

**Tech Stack:** Next.js 14 App Router, React 18, TypeScript, Tailwind CSS, Lucide icons, existing hooks (useProductCatalog, useSolutionBundles, useToolkits, useClientContext)

---

## Task 1: Create Unified Detail Panel Component

**Files:**
- Create: `src/app/(dashboard)/sales-hub/components/UnifiedDetailPanel.tsx`

**Step 1: Create the component file with full implementation**

**Step 2: Verify file created**

Run: `ls -la src/app/\(dashboard\)/sales-hub/components/`

**Step 3: Commit**

---

## Task 2: Create Products Tab Component

**Files:**
- Create: `src/app/(dashboard)/sales-hub/components/ProductsTab.tsx`

---

## Task 3: Create Bundles Tab Component

**Files:**
- Create: `src/app/(dashboard)/sales-hub/components/BundlesTab.tsx`

---

## Task 4: Create Recommendations Tab Component

**Files:**
- Create: `src/app/(dashboard)/sales-hub/components/RecommendationsTab.tsx`

---

## Task 5: Create Main Consolidated Page

**Files:**
- Modify: `src/app/(dashboard)/sales-hub/page.tsx` (replace entirely)

---

## Task 6: Remove Old Pages

**Files:**
- Delete: `src/app/(dashboard)/sales-hub/bundles/page.tsx`
- Delete: `src/app/(dashboard)/sales-hub/search/page.tsx`
- Delete: `src/app/(dashboard)/sales-hub/recommendations/page.tsx`

---

## Task 7: Update Navigation Links

**Files:**
- Modify: Navigation files if Sales Hub subnav exists

---

## Task 8: Run Tests and Final Verification

- Run test suite
- Run build
- Manual testing checklist

---

## Task 9: Merge and Deploy

- Push feature branch
- Create PR or merge to main
- Verify Netlify deployment

---

**Total Tasks:** 9
**New Files:** 4 components
**Modified Files:** 1 (main page)
**Deleted Files:** 3 (old pages)
