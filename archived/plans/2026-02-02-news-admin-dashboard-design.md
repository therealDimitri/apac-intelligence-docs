# News Admin Dashboard Design

> **For Claude:** Use this design to implement the News Admin Dashboard at `/settings/news-intelligence`

**Goal:** Full admin control over the News Intelligence system - monitoring, source management, content review.

**Location:** `/settings/news-intelligence` (add card to Settings page)

---

## Architecture

### New Files
- `src/app/(dashboard)/settings/news-intelligence/page.tsx` - Main dashboard
- `src/app/api/admin/news/status/route.ts` - Pipeline health metrics
- `src/app/api/admin/news/sources/route.ts` - Source CRUD
- `src/app/api/admin/news/sources/[id]/route.ts` - Single source operations
- `src/app/api/admin/news/sources/[id]/test/route.ts` - Test fetch
- `src/app/api/admin/news/articles/route.ts` - Article list with filters
- `src/app/api/admin/news/articles/[id]/route.ts` - Article updates

### Database
- Uses existing: `news_sources`, `news_articles`, `news_article_clients`
- No new tables required (fetch stats derived from existing data)

---

## Tab 1: Pipeline Health (Default)

### Stats Cards (4)
| Card | Query |
|------|-------|
| Sources Active | `SELECT COUNT(*) FROM news_sources WHERE is_active = true` |
| Articles Today | `SELECT COUNT(*) FROM news_articles WHERE created_at >= CURRENT_DATE` |
| Success Rate | Derived from sources with recent successful fetches |
| Avg Score | `SELECT AVG(relevance_score) FROM news_articles WHERE created_at >= CURRENT_DATE` |

### Recent Activity Feed
- Last 10 fetch operations across all sources
- Shows: source name, time, articles found/inserted, errors

### Error Panel
- Sources where last fetch failed or returned 0 articles
- Quick "Test Now" action

---

## Tab 2: Source Management

### Table Columns
- Status (active/inactive/error indicator)
- Name
- Type (rss/scrape/tender badge)
- URL (truncated)
- Last Fetch (relative time)
- Articles (7-day count)
- Actions (Edit/Toggle/Test)

### Expandable Row Details
- Full URL, scrape config, linked client, recent fetch history

### Actions
- Add Source modal
- Edit Source modal (URL, config, frequency)
- Toggle active/inactive
- Test fetch (inline result)

---

## Tab 3: Content Review

### Filters
- Date range, score range, source, client, search

### Table Columns
- Title, Source, Published, Score, Clients, Category

### Detail Panel
- Full article details
- Editable: score override, client links
- Re-score action

---

## Integration

Add to `/settings/page.tsx`:
```typescript
{
  title: 'News Intelligence',
  description: 'Monitor news pipeline, manage sources, review article quality.',
  href: '/settings/news-intelligence',
  icon: <Newspaper className="h-6 w-6" />,
  status: 'available',
  category: 'admin',
}
```
