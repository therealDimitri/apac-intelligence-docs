# Bug Report: News Intelligence False Positive Client Matches

**Date:** 2026-02-02
**Status:** Fixed
**Severity:** Medium
**Component:** News Intelligence System (`chasen-scorer.ts`, `news_article_clients` table)

## Problem

Generic healthcare news articles were incorrectly matched to multiple APAC clients. For example, Gippsland Health Alliance (GHA) showed 22 articles in their client news feed, but most articles were generic healthcare news matched to 12-18 clients simultaneously.

### Evidence

- GHA client profile showed 22 articles
- Articles included irrelevant content:
  - RingCentral sponsored whitepaper (advertisement)
  - "Supercharge your startup" (generic startup content)
  - Victorian healthcare articles matched to all Victorian clients
- Most articles were matched to 12-18 clients each (false positives)

## Root Cause

**Stale data from deprecated region-based matching logic.**

The scoring algorithm (`chasen-scorer.ts`) previously used region-based matching where any healthcare article from a region (e.g., Victoria) would match ALL clients in that region. This logic was disabled in a previous commit (lines 590-593), but the database still contained matches created before the fix:

```typescript
// Note: Region-based matching removed to prevent false positives
// Previously, ANY healthcare article from a region would match ALL clients in that region
// Now only articles that explicitly mention the client name/alias are linked
```

The algorithm itself was already correct - the issue was stale data.

## Solution

### Database Cleanup (executed 2026-02-02)

1. **Deleted advertisement articles** (2 articles)
   - "Health Tech Vendor Due Diligence: A HIPAA Security Guide for Medical Practices" (RingCentral sponsored)
   - "Supercharge your startup" (irrelevant content)

2. **Cleared generic article client matches** (19 articles)
   - Identified articles with `matched_clients` array containing >5 clients
   - Set `matched_clients = null` and `relevance_score = null` for these articles
   - Removed corresponding entries from `news_article_clients` junction table

### Cleanup Script

```javascript
// Delete obvious ads
await supabase.from('news_articles').delete().in('title', [
  'Health Tech Vendor Due Diligence: A HIPAA Security Guide for Medical Practices',
  'Supercharge your startup'
]);

// Clear generic articles (>5 client matches = false positive)
const { data: articles } = await supabase
  .from('news_articles')
  .select('id, matched_clients')
  .eq('is_active', true);

const genericIds = articles
  .filter(a => a.matched_clients && a.matched_clients.length > 5)
  .map(a => a.id);

for (const id of genericIds) {
  await supabase.from('news_articles')
    .update({ matched_clients: null, relevance_score: null })
    .eq('id', id);
  await supabase.from('news_article_clients')
    .delete()
    .eq('article_id', id);
}
```

## Verification

### After Cleanup

| Metric | Before | After |
|--------|--------|-------|
| GHA article count | 22 | 1 |
| Articles matched to >5 clients | 19 | 0 |
| Total clients with articles | Unknown | 3 |

### Current State (verified 2026-02-02)

```
=== NEWS ARTICLE DISTRIBUTION BY CLIENT ===

Barwon Health Australia: 9 articles (avg: 38.2)
Saint Luke's Medical Centre (SLMC): 2 articles (avg: 25.0)
Gippsland Health Alliance (GHA): 1 articles (avg: 60.0)

=== JUNCTION TABLE ===

✓ No articles linked to >5 clients
Article-client link distribution:
  1 client(s): 13 articles

Match type distribution:
  source_direct: 7
  ai_scored: 6
```

### Cron Endpoint Verification

- **news-fetch**: ✓ Returns 200, Tier 1 filters working
- **news-score**: ✓ Returns 200, Tier 2 gate at 100% pass rate
- No new multi-client matches being created

## Prevention

The current algorithm prevents this issue by:

1. **Strict word-boundary matching** - Client names must appear with word boundaries (not as substrings)
2. **Region matching disabled** - No longer matches articles to clients based solely on geographic region
3. **Tier 2 healthcare gate** - Filters non-healthcare content before expensive AI scoring
4. **Junction table source of truth** - `news_article_clients` is populated only by explicit matches

## Files Involved

- `src/lib/news-intelligence/chasen-scorer.ts` - Scoring algorithm (no changes needed - already correct)
- `src/app/api/sales-hub/news/client/[clientId]/route.ts` - Client news API
- Database tables: `news_articles`, `news_article_clients`

## Related Documentation

- `docs/plans/2026-02-01-news-intelligence-design.md` - System design
- `CLAUDE.md` - News Intelligence System section (lines 175-222)
