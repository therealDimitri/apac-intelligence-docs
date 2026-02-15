# Product Library Enhancements

**Date:** 3 February 2026
**Status:** In Progress
**Component:** Guides & Resources → Products Tab

## Summary

Add 4 features to complete the Product Library:
1. Pain Point Categorisation — populate painPointCategories from key_drivers
2. Product Analytics — track views and searches
3. ChaSen AI Integration — natural language product queries
4. Pain Point Filtering — works once #1 is implemented

## Feature 1: Pain Point Categorisation

**Approach:** Compute on fetch (no schema changes)

**Changes to `useProductCatalog.ts`:**
- Add `key_drivers` to list query select

**Changes to `ProductLibrary.tsx`:**
- Import `categoriseProduct()` from `@/lib/product-icons`
- Apply to each product in `productsWithCategories` memo

**Result:** Pain point chips show accurate counts, filtering works.

## Feature 2: Product Analytics

**New Table:** `product_analytics`

```sql
CREATE TABLE product_analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type TEXT NOT NULL,  -- 'view', 'search', 'filter'
  product_id UUID REFERENCES product_catalog(id),
  search_query TEXT,
  filters JSONB,
  result_count INTEGER,
  user_email TEXT,
  session_id TEXT,
  referrer TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_product_analytics_event_type ON product_analytics(event_type);
CREATE INDEX idx_product_analytics_product_id ON product_analytics(product_id);
CREATE INDEX idx_product_analytics_created_at ON product_analytics(created_at);
```

**New Files:**
- `src/app/api/product-analytics/route.ts`
- `src/hooks/useProductAnalytics.ts`

**Integration:**
- `ProductLibrary.tsx` — trackSearch (debounced), trackFilter
- `guides/products/[id]/page.tsx` — trackView on mount

## Feature 3: ChaSen AI Integration

**New Endpoint:** `POST /api/chasen/product-search`

**Input:**
```json
{
  "query": "client struggling with documentation workflows",
  "limit": 5
}
```

**Output:**
```json
{
  "recommendations": [
    {
      "product": { "id": "...", "title": "...", ... },
      "matchScore": 0.95,
      "matchReason": "Addresses inefficient clinical documentation workflows",
      "matchedDrivers": ["Streamline Documentation", "Reduce Manual Entry"]
    }
  ]
}
```

**Command Palette Integration:**
- Detect natural language queries
- Debounce 500ms, call API
- Show AI results with match reasoning
- Fallback to Fuse.js on failure

## Feature 4: Pain Point Filtering

Already implemented in `ProductLibrary.tsx` — will work once Feature 1 populates data.

## Implementation Order

1. **Phase 1:** Pain Point Categorisation (enables filtering)
2. **Phase 2:** Product Analytics
3. **Phase 3:** ChaSen AI Integration

## Files Summary

| File | Action |
|------|--------|
| `src/hooks/useProductCatalog.ts` | Edit |
| `src/components/product-library/ProductLibrary.tsx` | Edit |
| `src/app/(dashboard)/guides/products/[id]/page.tsx` | Edit |
| `src/components/product-library/ProductCommandPalette.tsx` | Edit |
| `src/hooks/useProductAnalytics.ts` | New |
| `src/app/api/product-analytics/route.ts` | New |
| `src/app/api/chasen/product-search/route.ts` | New |
| `supabase/migrations/20260203_product_analytics.sql` | New |
