# Sales Hub Design Document

**Date:** 31 January 2026
**Status:** Implementation In Progress

## Overview

The Sales Hub is a comprehensive sales enablement feature for the CS Intelligence dashboard that provides CSEs and CAMs with easy access to product collateral, solution bundles, and AI-powered content recommendations.

## Data Architecture

### Database Tables

Four new tables have been created:

#### 1. `product_catalog`
Individual products (sales briefs, datasheets, brochures, door openers, one-pagers)

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| product_family | TEXT | Sunrise, Paragon, TouchWorks, etc. |
| product_name | TEXT | Thread AI, CarePath, Acute Care |
| content_type | TEXT | sales_brief, datasheet, brochure, door_opener, one_pager |
| regions | TEXT[] | APAC, ANZ, UK, US, Global |
| title | TEXT | Display title |
| elevator_pitch | TEXT | 1-2 sentence summary |
| solution_overview | TEXT | Detailed description |
| value_propositions | JSONB | [{title, description}] |
| key_drivers | JSONB | [{title, description}] |
| target_triggers | TEXT[] | When to pitch this product |
| competitive_analysis | JSONB | [{competitor, our_advantage}] |
| objection_handling | JSONB | [{objection, response}] |
| faq | JSONB | [{question, answer}] |
| pricing_summary | TEXT | Brief pricing info |
| version_requirements | TEXT | Required software versions |
| asset_url | TEXT | SharePoint URL to original document |
| asset_filename | TEXT | Original filename |

#### 2. `solution_bundles`
Combined product offerings from toolkits with persona-specific messaging

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| bundle_name | TEXT | Bundle display name |
| tagline | TEXT | Short description |
| product_ids | UUID[] | References to product_catalog |
| what_it_is | TEXT | Product bundle description |
| what_it_does | TEXT | Functionality description |
| what_it_means | JSONB | {financial: [], clinical: [], operational: []} |
| kpis | JSONB | [{metric, target, proof}] |
| market_drivers | TEXT[] | Why customers need this |
| persona_notes | JSONB | {cfo: [], cmio: [], cio: [], cnio: []} |
| grabber_examples | TEXT[] | Conversation starters |
| regions | TEXT[] | Regional availability |
| asset_url | TEXT | Source toolkit URL |

#### 3. `value_wedges`
Detailed value propositions linked to products (Unique/Important/Defensible)

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| product_catalog_id | UUID | FK to product_catalog |
| unique_how | TEXT[] | Differentiating capabilities |
| important_wow | TEXT[] | Key benefits |
| defensible_proof | TEXT[] | Evidence/case studies |
| target_personas | TEXT[] | CFO, CMIO, CIO |
| competitive_positioning | TEXT | Against competitors |

#### 4. `toolkits`
Parent documents linking multiple solution bundles

| Field | Type | Description |
|-------|------|-------------|
| id | UUID | Primary key |
| name | TEXT | Toolkit name |
| description | TEXT | Toolkit description |
| version | TEXT | January 2026, etc. |
| bundle_ids | UUID[] | References to solution_bundles |
| regions | TEXT[] | Regional scope |
| asset_url | TEXT | Original toolkit PDF URL |

## UI Design

### Navigation Structure

```
/sales-hub
├── /browse          — Card grid with filters (default view)
├── /bundles         — Solution bundles/plays
├── /search          — Full-text + semantic search
└── /recommendations — AI-suggested content based on client context
```

### Browse View (`/sales-hub/browse`)

**Filter Bar (horizontal, sticky)**
- Product Family: `[All] [Sunrise] [Paragon] [TouchWorks] [dbMotion]...`
- Content Type: `[All] [Sales Brief] [Datasheet] [Brochure] [Door Opener]`
- Region: `[All] [APAC] [ANZ] [ASIA] [US]`

**Card Grid (responsive)**
Each card shows:
- Product family badge (colour-coded)
- Title
- Content type icon
- Elevator pitch (truncated)
- Region tags
- "View Details" → Slide-out panel
- "Open Asset" → Direct link to PDF/video

### Solution Bundles View (`/sales-hub/bundles`)

Larger cards with:
- Bundle name + tagline
- Products included (linked chips)
- "What it means" preview (Financial/Clinical/Operational tabs)
- Persona quick-links (CFO | CMIO | CIO)
- KPIs summary

### Slide-Out Detail Panel

When clicking "View Details":
- Full content (all fields from product_catalog)
- Value Wedge section (if exists)
- Related bundles
- "Ask ChaSen about this product" button
- Download/open asset button

## ChaSen AI Integration

### Automatic Knowledge Sync

Products are automatically synced to `chasen_knowledge` for AI context injection:

```typescript
function syncToChaSenKnowledge(product: ProductCatalog) {
  const knowledgeContent = `
## ${product.title}

**Product Family:** ${product.product_family}
**Regions:** ${product.regions.join(', ')}

### Elevator Pitch
${product.elevator_pitch}

### Value Propositions
${product.value_propositions?.map(v => `- **${v.title}**: ${v.description}`).join('\n')}

### When to Pitch
${product.target_triggers?.map(t => `- ${t}`).join('\n')}

### Objection Handling
${product.objection_handling?.map(o => `**"${o.objection}"** → ${o.response}`).join('\n')}

**Asset URL:** ${product.asset_url}
  `.trim();

  return upsertKnowledge({
    category: 'products',
    knowledge_key: `product_${product.id}`,
    title: product.title,
    content: knowledgeContent,
    metadata: { product_id: product.id },
    priority: product.content_type === 'sales_brief' ? 10 : 5
  });
}
```

### Priority Levels

| Content Type | Priority |
|-------------|----------|
| Sales Brief | 10 |
| Solution Bundle | 9 |
| Value Wedge | 8 |
| Datasheet | 6 |
| Brochure | 5 |
| Door Opener | 4 |
| Video | 3 |

## Import Process

### Scripts Created

1. **`scripts/apply-sales-hub-migration.mjs`** - Creates database tables
2. **`scripts/import-sales-hub-content.mjs`** - Imports PDFs from OneDrive
3. **`scripts/enrich-sales-hub-content.mjs`** - Adds AI-extracted content

### Import Statistics

| Content Type | Count |
|-------------|-------|
| Sales Briefs | 7 |
| Datasheets | 44 |
| Door Openers | 38 |
| Brochures | 1 |
| One-Pagers | 4 |
| Toolkits | 11 |
| **Total** | **105** |

### SharePoint URL Mapping

Local OneDrive paths are converted to SharePoint URLs:

```
Local:  /Users/.../OneDrive-AlteraDigitalHealth/Marketing - Marketing Collateral/Altera Content/...
Web:    https://alteradh.sharepoint.com/sites/Marketing/Shared%20Documents/Marketing%20Collateral/Altera%20Content/...
```

## Admin Interface

Located at `/settings/sales-hub`:

**Tabs:**
1. **Products** — CRUD for product_catalog
2. **Bundles** — CRUD for solution_bundles
3. **Toolkits** — CRUD for toolkits
4. **Value Wedges** — CRUD for value_wedges
5. **Import** — Bulk import wizard
6. **Sync Status** — ChaSen knowledge sync health

## Implementation Status

- [x] Database migration created
- [x] Tables created in Supabase
- [x] Import script created
- [x] 105 products imported
- [x] AI enrichment script created
- [ ] AI enrichment running (81 products)
- [ ] Sales Hub UI pages
- [ ] Admin interface
- [ ] ChaSen knowledge sync trigger
- [ ] Search functionality
