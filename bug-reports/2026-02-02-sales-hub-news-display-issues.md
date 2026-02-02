# Bug Report: Sales Hub News Display Issues

**Date:** 2 February 2026
**Status:** Fixed
**Severity:** Medium
**Component:** Sales Hub - News Intelligence

## Summary

Two issues prevented news articles from displaying in the Sales Hub:
1. Dashboard Industry News showed "(0)" despite having articles
2. Client-specific news showed "(0)" despite having matched articles

## Root Causes

### Issue 1: minScore Threshold Too High

**Location:** `src/components/sales-hub/DashboardView.tsx:19`

The dashboard fetched news with `minScore=50`, but available articles had relevance scores between 21-47. No articles met the threshold.

**Fix:** Changed `minScore=50` to `minScore=20`

### Issue 2: Incorrect API Response Property

**Location:** `src/components/sales-hub/ClientNewsSection.tsx:40, 88`

The component expected `json.data` but the API (`/api/sales-hub/news/client/[clientId]`) returns `json.articles`.

```typescript
// Before (incorrect)
if (json.success && json.data) {
  const newsArticles = json.data.map(...)

// After (correct)
if (json.success && json.articles) {
  const newsArticles = json.articles.map(...)
```

## Verification

1. Dashboard now displays 4 industry news articles
2. Client view (Barwon Health Australia) displays 3 matched articles with correct categories and relevance scores

## Files Changed

- `src/components/sales-hub/DashboardView.tsx`
- `src/components/sales-hub/ClientNewsSection.tsx`

## Commit

`cb489929` - fix(sales-hub): Fix news display issues in dashboard and client views
