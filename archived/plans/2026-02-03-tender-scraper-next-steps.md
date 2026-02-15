# Tender Scraper Next Steps Plan

**Date:** 2026-02-03
**Status:** Ready for implementation
**Depends on:** Tender scraper infrastructure (completed)

---

## Phase 1: GitHub PAT Configuration (Required)

### Task 1.1: Create GitHub Personal Access Token
- [ ] Go to GitHub → Settings → Developer Settings → Personal Access Tokens → Fine-grained tokens
- [ ] Create new token with:
  - **Name:** `apac-intelligence-workflow-dispatch`
  - **Expiration:** 90 days (or custom)
  - **Repository access:** `therealDimitri/apac-intelligence-v2` only
  - **Permissions:** Actions (Read and Write)
- [ ] Copy the token immediately (only shown once)

### Task 1.2: Add to Local Environment
- [ ] Add to `.env.local`:
  ```
  GITHUB_PAT=github_pat_xxxxx
  GITHUB_REPO_OWNER=therealDimitri
  GITHUB_REPO_NAME=apac-intelligence-v2
  ```

### Task 1.3: Add to Netlify Production
- [ ] Go to Netlify → Site settings → Environment variables
- [ ] Add:
  - `GITHUB_PAT` = (paste token)
  - `GITHUB_REPO_OWNER` = `therealDimitri`
  - `GITHUB_REPO_NAME` = `apac-intelligence-v2`
- [ ] Trigger redeploy to pick up new env vars

---

## Phase 2: UI Integration

### Task 2.1: Add "Fetch Tenders" Button
**File:** `src/app/(dashboard)/settings/news-intelligence/page.tsx`

Add a new section to the News Intelligence settings page:

```typescript
// Components needed:
// - Button with loading state
// - Status indicator (last run, success/failure)
// - Portal selection dropdown (optional)

// API calls:
// GET /api/admin/trigger-tender-scrape → check workflow status
// POST /api/admin/trigger-tender-scrape → trigger new run
```

**UI Elements:**
- [ ] "Fetch Tenders Now" button
- [ ] Last fetch timestamp
- [ ] Recent run status (success/failed/running)
- [ ] Link to GitHub Actions for detailed logs

### Task 2.2: Add Tender Source Status Display
**File:** `src/app/(dashboard)/settings/news-intelligence/page.tsx`

Show status of each tender portal:
- [ ] Portal name
- [ ] Last fetched timestamp
- [ ] Last run result (tenders found/inserted)
- [ ] Error message if any

---

## Phase 3: RSS Feed Monitoring (Optional Enhancement)

### Task 3.1: Research RSS Availability
- [ ] Check each portal for RSS/Atom feeds:
  - AusTender: `/rss`, `/feed`, check docs
  - Victoria: Check site footer/header
  - NSW: Check buy.nsw.gov.au for feeds
  - QLD: Check QTenders for alerts/feeds

### Task 3.2: Implement RSS Fetcher
If RSS feeds exist:
- [ ] Add RSS source entries to `news_sources` table
- [ ] Extend existing `rss-fetcher.ts` for tender parsing
- [ ] Map RSS items to `tender_opportunities` schema

**Benefit:** RSS is lightweight, runs frequently, catches new tenders faster than full scrape.

---

## Phase 4: Monitoring & Maintenance

### Task 4.1: Set Up Scraper Monitoring
- [ ] Create view/query to track scraper success rate over time
- [ ] Add alert if scraper fails 3+ times consecutively
- [ ] Weekly review of tenders found vs inserted (detect selector drift)

### Task 4.2: Selector Maintenance Process
When a portal stops returning results:
1. Check GitHub Actions logs for errors
2. Download debug screenshots from artifacts
3. Manually inspect portal for HTML changes
4. Update selectors in `scripts/tender-scraper/scrapers/*.ts`
5. Test locally before pushing

---

## Implementation Order

| Priority | Task | Effort | Impact |
|----------|------|--------|--------|
| 1 | Phase 1: GitHub PAT | 10 min | Required for everything |
| 2 | Task 2.1: Fetch button | 1 hour | User can trigger scrapes |
| 3 | Task 2.2: Status display | 30 min | Visibility into scraper health |
| 4 | Phase 3: RSS feeds | 2-3 hours | Faster tender detection |
| 5 | Phase 4: Monitoring | 1 hour | Long-term reliability |

---

## Verification

After Phase 1:
```bash
# Test API trigger locally
curl -X POST http://localhost:3001/api/admin/trigger-tender-scrape \
  -H "Content-Type: application/json" \
  -d '{"portals": "austender"}'
```

After Phase 2:
- Visit /settings/news-intelligence
- Click "Fetch Tenders Now"
- Verify workflow triggers in GitHub Actions
