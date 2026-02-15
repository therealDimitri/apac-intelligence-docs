# Bug Report: News Source URL and Bot Protection Fixes

**Date:** 2026-02-02
**Status:** Fixed
**Component:** News Intelligence System

## Problem

Several news sources were returning errors during fetch operations:

1. **Victorian Dept of Health** - 404 error (wrong URL path)
2. **SA Health** - 403 Forbidden (bot protection)
3. **Barwon Health** - 0 articles found (incorrect scrape selectors)
4. **Pulse+IT** - Using old domain (pulseitmagazine.com.au)
5. **Epworth Healthcare Newsroom** - 403 Forbidden (strong bot protection)
6. **Western Health News** - 403 Forbidden (strong bot protection)

## Root Cause

- **Victorian Dept of Health:** URL changed from `/news` to `/media-centre/media-releases`
- **SA Health:** Server blocks requests without browser-like User-Agent headers
- **Barwon Health:** HTML structure changed; selectors outdated in database config
- **Pulse+IT:** Domain changed to pulseit.news
- **Epworth/Western Health:** Sites have aggressive bot protection that blocks all programmatic access

## Solution

### Code Changes

1. **`src/lib/news-intelligence/web-scraper.ts`**
   - Updated User-Agent to Chrome-like browser string
   - Updated Barwon Health SITE_CONFIGS with correct selectors

2. **`src/lib/news-intelligence/rss-fetcher.ts`**
   - Updated User-Agent to match web scraper

3. **`supabase/migrations/20260202_add_source_direct_match_type.sql`**
   - Added `source_direct` and `ai_scored` to allowed match_type values

### Database Updates

1. **Victorian Dept of Health:** Updated URL to `/media-centre/media-releases`
2. **SA Health:** Works with new User-Agent (no DB change needed)
3. **Barwon Health:** Updated scrapeConfig in database with correct selectors:
   - articleSelector: `.news-slide, .posts-inner`
   - titleSelector: `h3`
   - linkSelector: `a.ip-post-title, a[href*="/news/"]`
4. **Pulse+IT:** Updated URL to `https://www.pulseit.news/feed/`
5. **Epworth Healthcare Newsroom:** Marked as `is_active = false` with note about bot protection
6. **Western Health News:** Marked as `is_active = false` with note about bot protection

### Alternative Sources Added

For sites with permanent bot protection, added alternative coverage sources:

1. **APHA News** (`https://www.apha.org.au/feed/`)
   - RSS feed from Australian Private Hospitals Association
   - Covers Epworth and other private hospitals
   - Authority score: 70

2. **VHBA Health Building News** (`https://www.vhba.vic.gov.au`)
   - Victorian Health Building Authority website
   - Covers Western Health, Footscray Hospital
   - Authority score: 75

## Verification

All fixes tested and confirmed working:

| Source | Status | Test Result |
|--------|--------|-------------|
| Victorian Dept of Health | ✓ Fixed | RSS accessible |
| SA Health | ✓ Fixed | RSS accessible |
| Barwon Health | ✓ Fixed | 9 articles scraped |
| Pulse+IT | ✓ Fixed | 11 items in feed |
| APHA News | ✓ New | 12 items in feed |
| VHBA | ✓ New | Website accessible |

## Files Changed

- `src/lib/news-intelligence/web-scraper.ts`
- `src/lib/news-intelligence/rss-fetcher.ts`
- `supabase/migrations/20260202_add_source_direct_match_type.sql`

## Related

- Client-direct source auto-linking feature
- ChaSen Scorer AI matching system
- `news_article_clients` junction table (277 links created via backfill)
