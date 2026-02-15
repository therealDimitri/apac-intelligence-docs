# News Intelligence System - Phase 5: UI Components

**Date:** 2026-02-01
**Status:** Completed
**Type:** Enhancement

## Summary

Implemented the UI components for the News Intelligence System, adding a new "News Intelligence" tab to the Sales Hub with urgent alerts banner, news feed, and tender tracker functionality.

## Components Created

### 1. useNewsIntelligence Hook (`src/hooks/useNewsIntelligence.ts`)

Custom React hooks for fetching news intelligence data:

- **`useUrgentNews(since?)`** - Fetches high-priority urgent alerts
- **`useNewsFeed(options)`** - Paginated news feed with filtering (category, minScore, region, clientId, search)
- **`useTenders(options)`** - Tender opportunities with status filtering
- **`useClientNewsIntelligence(clientId)`** - Client-specific news articles and stakeholder mentions
- **`useNewsActions()`** - Actions for dismissing articles, assigning, creating tenders, updating tender status

### 2. NewsIntelligenceTab Component (`src/app/(dashboard)/sales-hub/components/NewsIntelligenceTab.tsx`)

Main tab component with:

- **Urgent Alerts Banner** - Red banner at top showing high-priority news (category=urgent_action, score>=50)
- **Sub-tabs** - Toggle between "News Feed" and "Tender Tracker"
- **News Feed** - Paginated article list with:
  - Category-coloured cards (red=urgent, green=opportunity, yellow=monitor, blue=fyi)
  - Relevance scores displayed
  - Source name and relative timestamps
  - Matched clients displayed
  - Recommended actions shown
  - Dismiss and external link buttons
- **Tender Tracker** - Pipeline view with:
  - Status filters (open, tracked, closed, all)
  - Closing soon indicators
  - One-click status updates
- **Detail Slideouts** - Full article/tender details in slide-out panels

### 3. Sales Hub Integration (`src/app/(dashboard)/sales-hub/page.tsx`)

- Added 'news' to TabKey type
- Added News Intelligence tab to TABS array with Newspaper icon
- Integrated NewsIntelligenceTab component with search query passthrough

## Features

| Feature | Description |
|---------|-------------|
| Urgent Alerts | Top banner highlighting critical news requiring immediate attention |
| Category Filtering | Filter by urgent_action, opportunity, monitor, fyi |
| Score Filtering | Filter by minimum relevance score (30, 50, 70) |
| Pagination | Navigate through paginated results |
| Article Dismiss | Archive articles from feed |
| Tender Tracking | Track and manage tender opportunities |
| Closing Soon | Visual indicator for tenders closing within 7 days |
| Detail Panels | Slide-out panels for full article/tender details |

## API Endpoints Used

- `GET /api/sales-hub/news/urgent` - Urgent alerts
- `GET /api/sales-hub/news/feed` - Paginated news feed
- `GET /api/sales-hub/news/tenders` - Tender opportunities
- `GET /api/sales-hub/news/client/:id` - Client-specific news
- `POST /api/sales-hub/news/:id/dismiss` - Dismiss article
- `POST /api/sales-hub/news/:id/assign` - Assign article
- `POST /api/sales-hub/tenders` - Create tender
- `POST /api/sales-hub/tenders/:id/track` - Update tender status

## Testing

- Verified locally via Playwright browser testing
- News Feed showing 35 scored articles
- Urgent alerts banner displaying 1 high-priority item
- Category badges and scores rendering correctly
- Pagination working (Page 1 of 2)
- Tender tracker sub-tab accessible

## Deployment

- Committed: `743d9e9e`
- Deployed to Netlify: ✅ Success
- Production URL: https://apac-cs-dashboards.com/sales-hub#news

## Files Changed

```
src/hooks/useNewsIntelligence.ts (new)
src/app/(dashboard)/sales-hub/components/NewsIntelligenceTab.tsx (new)
src/app/(dashboard)/sales-hub/page.tsx (modified)
```

## Next Steps (Phase 6)

- End-to-end testing with production data
- Monitor RSS fetch and scoring cron jobs
- Add more APAC news sources as needed
- Consider adding email digest for urgent alerts
