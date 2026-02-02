# Bug Report: News Article Client Links Not Populating Junction Table

**Date:** 2026-02-02
**Status:** Fixed
**Severity:** Medium
**Component:** News Intelligence / ChaSen Scorer

## Issue Description

The client profile News tab was showing "No news articles" even though articles had been fetched, scored, and had `matched_clients` arrays populated on the article records. The junction table (`news_article_clients`) that the API queries was empty.

## Root Cause

The `chasen-scorer.ts` had two separate client matching mechanisms that produced different results:

1. **AI-based matching** in `scoreArticle()` → stored in `matched_clients` column on articles
2. **Keyword-based matching** via `matchClients()` function → used for junction table population

The scorer called `matchClients()` twice:
- Once at line 694 inside `scoreArticle()` (results stored in article's `matched_clients` array)
- Again at line 952-956 in the main loop to populate the junction table

The keyword-based `matchClients()` function has stricter matching rules (exact name, alias, or region + healthcare keywords) compared to the AI scoring, which resulted in fewer/different client matches being written to the junction table.

## Impact

- 702 articles fetched and scored
- 701 articles had `matched_clients` arrays populated via AI scoring
- 0 records in `news_article_clients` junction table
- Client profile News tabs showed "No news articles" for all clients

## Solution Implemented

Modified the scorer to use the AI-scored `matched_clients` from the scoring result when populating the junction table, instead of re-running keyword matching:

```typescript
// Before (inconsistent)
const clientMatches = matchClients(
  `${article.title} ${article.content || article.summary || ''}`,
  clients
)
await linkArticleClients(supabase, article.id, clientMatches)

// After (uses AI results)
const clientMatches = scores.matched_clients.map(clientId => ({
  clientId,
  matchType: 'ai_scored',
  confidence: scores.client_match_score,
}))
await linkArticleClients(supabase, article.id, clientMatches)
```

## Files Changed

- `src/lib/news-intelligence/chasen-scorer.ts` (modified lines 948-956)

## Data Recovery

Populated the junction table from existing `matched_clients` arrays:

```sql
INSERT INTO news_article_clients (article_id, client_id)
SELECT id, unnest(matched_clients) FROM news_articles
WHERE matched_clients IS NOT NULL
  AND array_length(matched_clients, 1) > 0
ON CONFLICT (article_id, client_id) DO NOTHING;
```

**Result:** 266 links created across 23 articles and 18 clients.

## Testing

1. Build passes with zero TypeScript errors
2. Netlify deployment successful (commit e3f5836c)
3. Client profile News tab now displays articles correctly
4. Verified in production: Barwon Health Australia shows 10 articles

## Prevention

The fix ensures consistency by deriving the junction table entries from the same AI-scored results stored on the article, eliminating the dual-matching code path that caused the mismatch.
