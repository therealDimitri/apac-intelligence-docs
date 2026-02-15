# Finish In-Flight Features — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Commit and verify three in-flight features: GoalTableView edit/delete, News/Tenders refactor, and Compass Survey navigation.

**Architecture:** All three features are already implemented — this plan covers testing, minor gaps, and committing. GoalTableView is a small component enhancement. News/Tenders is a substantial refactor (~13 files). Compass Survey is fully committed but needs a smoke test.

**Tech Stack:** Next.js 16, TypeScript, Supabase, Playwright (browser testing on port 3001)

---

### Task 1: Commit GoalTableView Edit/Delete Enhancement

**Files:**
- Modified: `src/components/goals/GoalTableView.tsx`

**Context:** GoalTableView already has `onEdit` and `onDelete` props wired from the parent page (`goals-initiatives/page.tsx:683-684`). The component change adds an actions column with Edit3 and Trash2 icon buttons that appear on row hover via `group/row` + `group-hover/row:opacity-100`. This is self-contained and ready to commit.

**Step 1: Run type check on GoalTableView**

```bash
cd ~/GitHub/apac-intelligence-v2
npx tsc --noEmit src/components/goals/GoalTableView.tsx 2>&1 | head -20
```

Expected: No errors (or only unrelated errors from other files).

**Step 2: Commit GoalTableView**

```bash
git add src/components/goals/GoalTableView.tsx
git commit -m "feat(goals): add edit/delete action buttons to GoalTableView

Adds optional onEdit and onDelete props with hover-reveal icon buttons
(Edit3 + Trash2) in a new actions column. Uses group/row Tailwind
pattern for row-hover visibility.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 2: Type-Check News/Tenders Changes

**Files:**
- `.github/workflows/tender-scraper.yml`
- `src/app/(dashboard)/sales-hub/components/NewsIntelligenceTab.tsx`
- `src/app/api/sales-hub/news/tenders/route.ts`
- `src/hooks/useNewsIntelligence.ts`
- `src/lib/ai-providers.ts`
- `src/lib/news-intelligence/rss-fetcher.ts`
- `src/lib/news-intelligence/tender-fetcher.ts`
- `src/types/database.generated.ts`
- `package.json` + `package-lock.json`

**Context:** Tender fetcher was refactored into two channels: Channel A (Netlify cron — lightweight RSS) and Channel B (GitHub Actions — Playwright scrapers). RSS fetcher now routes tender sources to the tender fetcher. API returns `source_url` field. Hook types updated. AI provider response parsing improved. Database types refreshed.

**Step 1: Run full type check**

```bash
cd ~/GitHub/apac-intelligence-v2
npx tsc --noEmit 2>&1 | head -40
```

Expected: Clean or only pre-existing errors. If new errors found, fix before proceeding.

**Step 2: Verify tender fetcher compiles**

Check that `fetchAusTenderAtmRss` is exported and used correctly in both `tender-fetcher.ts` and `rss-fetcher.ts`:

```bash
grep -n "fetchAusTenderAtmRss" src/lib/news-intelligence/tender-fetcher.ts src/lib/news-intelligence/rss-fetcher.ts
```

Expected: Export in tender-fetcher.ts, import in rss-fetcher.ts.

---

### Task 3: Browser-Test News Intelligence Tab

**Step 1: Navigate to Sales Hub → News Intelligence**

Open `http://localhost:3001/sales-hub` in Playwright, click the News Intelligence tab.

**Step 2: Verify tenders table**

- Check that tender rows render with columns (title, agency, close date, value, status)
- Verify source URL links appear where available (external link icon)
- Test filtering by region/status if filters exist
- Check row hover shows edit/delete icons (if enabled in this view)

**Step 3: Verify news articles tab**

- Switch to articles sub-tab
- Confirm articles load with relevance scores and category badges

If anything is broken, fix before committing.

---

### Task 4: Commit News/Tenders Changes

**Step 1: Stage all news/tender files**

```bash
git add \
  .github/workflows/tender-scraper.yml \
  src/app/\(dashboard\)/sales-hub/components/NewsIntelligenceTab.tsx \
  src/app/api/sales-hub/news/tenders/route.ts \
  src/hooks/useNewsIntelligence.ts \
  src/lib/ai-providers.ts \
  src/lib/news-intelligence/rss-fetcher.ts \
  src/lib/news-intelligence/tender-fetcher.ts \
  src/types/database.generated.ts \
  package.json package-lock.json
```

**Step 2: Commit**

```bash
git commit -m "feat(news): refactor tender fetcher + RSS integration

- Split tender fetching into Channel A (RSS for Netlify cron) and
  Channel B (Playwright for GitHub Actions)
- Add fetchAusTenderAtmRss() with healthcare keyword filtering
- Route tender RSS sources through rss-fetcher integration
- Add source_url field to tenders API + hook types
- Increase tender limit to 500 (was 100)
- Improve MatchaAI response parsing (prefer output_text blocks)
- Add NZ-GETS option to GitHub Actions workflow
- Refresh database generated types
- Refactor NewsIntelligenceTab UI

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 5: Smoke-Test Compass Survey

**Context:** Compass Survey is fully committed (21 files, 3 DB tables, 8 API routes, 11 components). It's already in the sidebar under Analytics → Compass Survey. This task just verifies it loads.

**Step 1: Navigate to Compass Survey**

Open `http://localhost:3001/compass` in Playwright.

**Step 2: Check page loads**

- Verify KPI cards render (NPS, mean recommend, mid-year interest)
- Verify AI narrative panel loads (may show "Generate" button if no cached narrative)
- Check that session heatmap or outcome bars render (if survey data is imported)
- If page shows empty state (no data), that's expected — data requires running `scripts/import-compass-survey.mjs`

**Step 3: Close browser**

Use `browser_close` to clean up Playwright session.

---

### Task 6: Update Submodule Refs and Push

**Step 1: Check if submodule refs need updating**

```bash
git status docs scripts
```

If modified (showing new commits in submodules), stage them:

```bash
git add docs scripts
git commit -m "chore: update submodule refs

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

**Step 2: Push all commits**

```bash
git push origin main
```

---

## Summary

| Task | Scope | Risk |
|------|-------|------|
| 1. GoalTableView commit | 1 file, 45 lines | Low — parent already wires props |
| 2. Type-check news/tenders | 10 files, ~900 lines | Medium — large refactor |
| 3. Browser-test news/tenders | UI verification | Low — read-only |
| 4. Commit news/tenders | Staging + commit | Low — after verification |
| 5. Smoke-test Compass | UI verification | Low — already committed |
| 6. Push | Git push | Low — after all verification |
