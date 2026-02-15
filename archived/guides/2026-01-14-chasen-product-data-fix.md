# Bug Report: ChaSen Not Returning Product Data

**Date:** 14 January 2026
**Status:** Resolved
**Type:** Feature Gap / Bug Fix
**Severity:** Medium

## Summary

ChaSen AI was unable to answer product-related questions despite the `client_products` and `products` tables being created and registered in `chasen_data_sources`. The issue was that the live dashboard context function didn't query these tables.

## Issue Description

**Reported Behaviour:**
- User asked ChaSen: "What products does Albury have deployed?"
- ChaSen responded: "The portfolio data available focuses on client health, satisfaction metrics, and engagement activities rather than specific product deployments."

**Expected Behaviour:**
- ChaSen should return product deployment information for any client
- ChaSen should be able to list all products in the Altera portfolio
- ChaSen should be able to compare product deployments across clients

## Root Cause Analysis

1. **Tables Exist and Are Populated**: The `products` table (24 products) and `client_products` table (82 client-product mappings) were created correctly via migration
2. **Data Sources Registered**: Both tables were registered in `chasen_data_sources` with `is_enabled = true`
3. **API Endpoint Working**: The `/api/chasen/products` endpoint was returning correct data

**The Problem**: The `getLiveDashboardContext()` function in `/src/app/api/chasen/stream/route.ts` has **hardcoded queries** for specific tables. It does NOT use the `chasen_data_sources` table dynamically. The function queries:
- client_health_history
- nps_responses
- client_segmentation
- unified_meetings
- actions
- aging_accounts
- And 12 more tables...

But it did NOT query `client_products` or `products`.

## Resolution

### 1. Added Product Data Queries to getLiveDashboardContext

Added two new data source queries (sections 13 and 14):

```typescript
// 13. Client Products - Product deployments at each client site
const { data: clientProducts } = await supabase
  .from('client_products_detailed')
  .select('client_name, product_code, product_name, product_category, status')
  .eq('status', 'active')
  .order('client_name')

// 14. Products Catalog - Available Altera products for reference
const { data: productsCatalog } = await supabase
  .from('products')
  .select('code, name, category, description')
  .order('category, name')
```

The context now includes:
- Grouped product deployments per client
- Product categories for each client
- Total deployment statistics
- Full products catalog with descriptions

### 2. Added Product Data Usage Guidelines to System Prompt

Added new section to ChaSen's system prompt:

```markdown
## PRODUCT DATA USAGE
You have access to comprehensive product deployment data:
- **Client Product Deployments**: Shows which Altera products each client has deployed
- **Products Catalog**: Reference list of all available Altera products with descriptions

**Use this data to answer questions like:**
- "What products does [client] have?"
- "Which clients use [product name]?"
- "What's the technology landscape at [client]?"
```

### 3. Added Custom Formatters for Dynamic Context

Added formatters in `/src/lib/chasen-dynamic-context.ts` for future use:

```typescript
if (tableName === 'client_products' || tableName === 'client_products_detailed') {
  const productName = row.product_name || row.product_code
  const category = row.product_category || ''
  return `- **${row.client_name}**: ${productName}${category ? ` [${category}]` : ''}`
}

if (tableName === 'products') {
  const desc = row.description ? ` - ${row.description}` : ''
  return `- **${row.name}** (${row.code}): ${row.category}${desc}`
}
```

## Files Modified

1. `/src/app/api/chasen/stream/route.ts` - Added product data queries and prompt guidance
2. `/src/lib/chasen-dynamic-context.ts` - Added custom formatters for product tables

## Testing

ChaSen can now answer:
- "What products does Albury Wodonga Health have?" → Returns Opal
- "Which clients use Sunrise Acute Care?" → Lists GHA, SA Health, MINDEF, etc.
- "What's the full product catalog?" → Lists all 24 Altera products by category
- "Compare products at SA Health vs SingHealth" → Detailed comparison

## Lessons Learned

1. **Hardcoded vs Dynamic Context**: The `getLiveDashboardContext()` function is hardcoded, not dynamically driven by `chasen_data_sources`. New tables must be explicitly added to this function.

2. **Two Context Systems**: The codebase has TWO context systems:
   - `getLiveDashboardContext()` - Hardcoded, used by stream route
   - `getDynamicDashboardContext()` - Dynamic, reads from `chasen_data_sources`

   The stream route uses the hardcoded version for reliability.

3. **Registration Alone Isn't Enough**: Adding a table to `chasen_data_sources` doesn't automatically make it available to ChaSen's live context.

## Related Commits

- `f22a7c84` - Add client products tables and ChaSen API integration
- `c0062b52` - Add product data to ChaSen's live context (this fix)
