# News Intelligence Expansion Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Expand news coverage with web scraping and tender portals, plus enhance client matching and briefing features.

**Architecture:** Add parallel fetching pipelines for scrape/tender sources alongside existing RSS. Enhance ChaSen scorer to write client/stakeholder links to junction tables. Add briefing API with user-scoped storage.

**Tech Stack:** Cheerio (HTML parsing), existing rss-parser, Supabase, ChaSen AI (Claude), React

---

## Phase A: Expand News Coverage

### Task 1: Create Web Scraper Module

**Files:**
- Create: `src/lib/news-intelligence/web-scraper.ts`
- Modify: `src/app/api/cron/news-fetch/route.ts`
- Test: Manual testing via API endpoint

**Context:** 39 scrape-type sources exist with configs like `{"client":"SingHealth"}`. Each source has a unique URL structure requiring CSS selector configuration.

**Step 1: Create scraper module with Cheerio**

```typescript
// src/lib/news-intelligence/web-scraper.ts
import * as cheerio from 'cheerio'
import { SupabaseClient } from '@supabase/supabase-js'

interface ScrapeConfig {
  articleSelector: string      // CSS selector for article containers
  titleSelector: string        // Selector within article for title
  linkSelector: string         // Selector for article link
  dateSelector?: string        // Optional date selector
  summarySelector?: string     // Optional summary selector
}

// Default configs for common CMS patterns
const DEFAULT_CONFIGS: Record<string, ScrapeConfig> = {
  wordpress: {
    articleSelector: 'article, .post, .news-item',
    titleSelector: 'h2 a, h3 a, .entry-title a',
    linkSelector: 'h2 a, h3 a, .entry-title a',
    dateSelector: 'time, .date, .published',
    summarySelector: '.excerpt, .summary, p',
  },
  generic: {
    articleSelector: '.news-item, .article, .post, article',
    titleSelector: 'h2, h3, .title',
    linkSelector: 'a',
    dateSelector: '.date, time',
    summarySelector: 'p, .summary',
  },
}

export async function scrapeNewsPage(
  url: string,
  config: ScrapeConfig = DEFAULT_CONFIGS.generic
): Promise<ParsedArticle[]> {
  // Implementation: fetch page, parse with Cheerio, extract articles
}

export async function fetchAllDueScrapeSources(
  supabase: SupabaseClient,
  options?: { maxSources?: number; dryRun?: boolean }
): Promise<FetchResult> {
  // Get scrape sources due for fetch, scrape each, store articles
}
```

**Step 2: Add scraper configs to news_sources**

Create a migration to add `scrape_config` JSONB column or use existing `config` field with structure:

```json
{
  "client": "SingHealth",
  "scrapeConfig": {
    "articleSelector": ".news-list-item",
    "titleSelector": "h3 a",
    "linkSelector": "h3 a"
  }
}
```

**Step 3: Integrate scraper into fetch cron**

Modify `src/app/api/cron/news-fetch/route.ts` to call both RSS and scrape fetchers:

```typescript
// After RSS fetch
const scrapeResults = await fetchAllDueScrapeSources(supabase, { maxSources: 10 })
```

**Step 4: Test with 3 pilot sources**

Test with: SingHealth Newsroom, Barwon Health News, SA Health Media Releases

**Step 5: Commit**

```bash
git add src/lib/news-intelligence/web-scraper.ts src/app/api/cron/news-fetch/route.ts
git commit -m "feat(news): add web scraper for scrape-type sources"
```

---

### Task 2: Configure Scrape Selectors for Top Sources

**Files:**
- Modify: Database `news_sources.config` via script
- Create: `scripts/configure-scrape-sources.mjs`

**Context:** Need to analyse each hospital website's news page structure and configure CSS selectors.

**Step 1: Analyse top 10 scrape sources manually**

Visit each URL and identify:
- Article container selector
- Title selector
- Link selector
- Date format

**Step 2: Create configuration script**

```javascript
// scripts/configure-scrape-sources.mjs
const scrapeConfigs = {
  'SingHealth Newsroom': {
    articleSelector: '.views-row',
    titleSelector: 'h3 a',
    linkSelector: 'h3 a',
    dateSelector: '.date-display-single',
  },
  'Barwon Health News': {
    articleSelector: '.news-item',
    titleSelector: 'h3 a',
    linkSelector: 'h3 a',
  },
  // ... more configs
}
```

**Step 3: Run configuration update**

**Step 4: Commit**

---

### Task 3: Create Tender Portal Fetcher

**Files:**
- Create: `src/lib/news-intelligence/tender-fetcher.ts`
- Create: `src/app/api/cron/tender-fetch/route.ts`
- Create: `netlify/functions/tender-fetch.mts`

**Context:** 12 tender portal sources (AusTender, Tenders.vic, NSW eTendering, etc.). Most have APIs or structured search pages. `tender_opportunities` table already exists.

**Step 1: Create tender fetcher module**

```typescript
// src/lib/news-intelligence/tender-fetcher.ts
interface TenderResult {
  tender_reference: string
  issuing_body: string
  title: string
  description: string
  region: string
  close_date: Date | null
  estimated_value: string | null
  source_url: string
}

// AusTender has an API: https://www.tenders.gov.au/api/
export async function fetchAusTenderResults(keywords: string[]): Promise<TenderResult[]>

// Victorian tenders - scrape search results
export async function fetchVicTenderResults(): Promise<TenderResult[]>

// Main function
export async function fetchAllDueTenderSources(supabase: SupabaseClient): Promise<{
  tenders: TenderResult[]
  inserted: number
}>
```

**Step 2: Create cron endpoint**

```typescript
// src/app/api/cron/tender-fetch/route.ts
// GET endpoint with CRON_SECRET auth
// Calls fetchAllDueTenderSources, stores in tender_opportunities
```

**Step 3: Create Netlify scheduled function**

```typescript
// netlify/functions/tender-fetch.mts
// Schedule: Every 4 hours
```

**Step 4: Test with AusTender**

**Step 5: Commit**

---

### Task 4: Create Netlify Scheduled Function for Scraping

**Files:**
- Create: `netlify/functions/news-scrape.mts`
- Modify: `netlify.toml` (add schedule)

**Step 1: Create scheduled function**

```typescript
// netlify/functions/news-scrape.mts
import type { Config, Context } from '@netlify/functions'

export default async (req: Request, context: Context) => {
  const response = await fetch(`${process.env.URL}/api/cron/news-fetch?type=scrape`, {
    headers: { Authorization: `Bearer ${process.env.CRON_SECRET}` },
  })
  return new Response(JSON.stringify(await response.json()))
}

export const config: Config = {
  schedule: '30 */2 * * *', // Every 2 hours at minute 30
}
```

**Step 2: Update fetch route to accept type parameter**

**Step 3: Test locally, then deploy**

**Step 4: Commit**

---

## Phase B: Enhance News Intelligence

### Task 5: Implement Client Matching in Scorer

**Files:**
- Modify: `src/lib/news-intelligence/chasen-scorer.ts`
- Table: `news_article_clients` (exists)

**Context:** ChaSen scorer already detects `matched_clients` array but doesn't persist to junction table. Need to write matches to `news_article_clients` with match_type and confidence.

**Step 1: Add client link persistence function**

```typescript
// In chasen-scorer.ts
async function persistClientMatches(
  supabase: SupabaseClient,
  articleId: number,
  matchedClients: Array<{
    clientId: number
    matchType: 'name_mention' | 'region' | 'topic' | 'stakeholder'
    confidence: number
    matchedEntity: string
  }>
): Promise<void> {
  // Upsert to news_article_clients
}
```

**Step 2: Call persistence after scoring**

In `scoreArticle()` function, after calculating `matched_clients`, call `persistClientMatches()`.

**Step 3: Test with sample articles**

Query `news_article_clients` to verify links are being created.

**Step 4: Commit**

---

### Task 6: Implement Stakeholder Mention Detection

**Files:**
- Modify: `src/lib/news-intelligence/chasen-scorer.ts`
- Table: `news_stakeholder_mentions` (exists)

**Context:** Client contacts are in `client_contacts` table. Need to detect when article mentions a contact name and link to `news_stakeholder_mentions`.

**Step 1: Load stakeholders for matching**

```typescript
async function loadStakeholders(supabase: SupabaseClient): Promise<Stakeholder[]> {
  const { data } = await supabase
    .from('client_contacts')
    .select('contact_name, client_id, client:nps_clients(client_name)')
  return data
}
```

**Step 2: Detect mentions in article content**

```typescript
function detectStakeholderMentions(
  content: string,
  stakeholders: Stakeholder[]
): Array<{ stakeholder: Stakeholder; contextSnippet: string }> {
  // For each stakeholder, check if name appears in content
  // Extract surrounding context (±100 chars)
}
```

**Step 3: Persist stakeholder mentions**

```typescript
async function persistStakeholderMentions(
  supabase: SupabaseClient,
  articleId: number,
  mentions: Array<{ stakeholderName: string; clientId: number; contextSnippet: string }>
): Promise<void>
```

**Step 4: Test with known stakeholder names**

**Step 5: Commit**

---

### Task 7: Create Briefing API

**Files:**
- Create: `src/app/api/sales-hub/briefings/route.ts`
- Create: Migration for `user_briefings` table

**Context:** "Add to briefing" button exists but is non-functional. Need user-scoped briefing storage.

**Step 1: Create briefings table migration**

```sql
CREATE TABLE user_briefings (
  id SERIAL PRIMARY KEY,
  user_email TEXT NOT NULL,
  article_id INT REFERENCES news_articles(id) ON DELETE CASCADE,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_email, article_id)
);

CREATE INDEX idx_user_briefings_email ON user_briefings(user_email);
```

**Step 2: Create API endpoint**

```typescript
// GET /api/sales-hub/briefings - List user's briefing items
// POST /api/sales-hub/briefings - Add article to briefing
// DELETE /api/sales-hub/briefings/:id - Remove from briefing
```

**Step 3: Test endpoints**

**Step 4: Commit**

---

### Task 8: Integrate Briefing UI

**Files:**
- Modify: `src/components/sales-hub/NewsCard.tsx`
- Modify: `src/app/(dashboard)/sales-hub/page.tsx` (add briefing panel)
- Create: `src/components/sales-hub/BriefingPanel.tsx`

**Step 1: Make "Add to briefing" button functional**

```typescript
// In NewsCard.tsx
const handleAddToBriefing = async () => {
  await fetch('/api/sales-hub/briefings', {
    method: 'POST',
    body: JSON.stringify({ articleId: article.id }),
  })
  toast.success('Added to briefing')
}
```

**Step 2: Create BriefingPanel component**

Shows saved articles with ability to:
- View saved items
- Add notes
- Remove items
- Export as summary

**Step 3: Add briefing panel to Sales Hub sidebar**

**Step 4: Test end-to-end**

**Step 5: Commit**

---

### Task 9: Add Client News Filter to Sales Hub

**Files:**
- Modify: `src/app/(dashboard)/sales-hub/page.tsx`
- Create: `src/app/api/sales-hub/news/route.ts`

**Context:** When a client is selected in Sales Hub, news should filter to show only articles linked to that client via `news_article_clients`.

**Step 1: Create news API with client filter**

```typescript
// GET /api/sales-hub/news?clientId=123
// Returns articles linked to client via news_article_clients
```

**Step 2: Update Sales Hub to use filtered news**

When `selectedClient` changes, refetch news for that client.

**Step 3: Test with Barwon Health (has direct scrape source)**

**Step 4: Commit**

---

### Task 10: Add News Tab to Client Profile

**Files:**
- Modify: `src/app/(dashboard)/client-profiles/[id]/page.tsx`
- Create: `src/components/client-profile/ClientNewsTab.tsx`

**Context:** Client profile pages should show news related to that client.

**Step 1: Create ClientNewsTab component**

```typescript
// Shows news articles linked to this client
// Uses news_article_clients junction table
// Displays stakeholder mentions if any
```

**Step 2: Add tab to client profile page**

**Step 3: Test with a client that has linked articles**

**Step 4: Commit**

---

## Execution Order

1. **Task 1** - Web scraper module (foundation)
2. **Task 2** - Configure scrape selectors (makes scraper useful)
3. **Task 4** - Netlify scheduled function (automates scraping)
4. **Task 5** - Client matching persistence (enables filtering)
5. **Task 6** - Stakeholder detection (enhances intelligence)
6. **Task 7** - Briefing API (backend for UI)
7. **Task 8** - Briefing UI (user-facing feature)
8. **Task 9** - Client news filter (Sales Hub integration)
9. **Task 3** - Tender fetcher (parallel track, lower priority)
10. **Task 10** - Client profile news tab (polish)

---

## Dependencies

```
Task 1 → Task 2 → Task 4
Task 5 → Task 9 → Task 10
Task 7 → Task 8
Task 6 (independent after Task 5)
Task 3 (independent)
```

## Testing Checklist

- [ ] Web scraper extracts articles from SingHealth Newsroom
- [ ] Scrape cron runs every 2 hours on Netlify
- [ ] Client matches persist to news_article_clients
- [ ] Stakeholder mentions detected and stored
- [ ] Briefing API creates/lists/deletes user items
- [ ] "Add to briefing" button works in NewsCard
- [ ] News filters by selected client in Sales Hub
- [ ] Tender fetcher retrieves AusTender results
