# Product Library Redesign

**Date:** 2 February 2026
**Status:** Design Complete
**Component:** Guides & Resources → Products Tab

## Summary

Redesign the Products section in Guides & Resources to replace mock data with real product data from `product_catalog` (94 active products). Implements a modern, Stripe/Vercel-inspired UI with multi-modal discovery (search, filters, categories, command palette) and ChaSen AI integration for semantic product matching.

## Goals

1. **Fast product lookup** — Users can quickly find specific products by name
2. **Pain-point discovery** — Users can find products based on customer needs and challenges
3. **Full sales playbook access** — Deep-dive into value propositions, competitive analysis, objection handling
4. **AI-powered recommendations** — ChaSen integration for semantic matching

## Data Source

**Table:** `product_catalog` (94 active products)

**Product Families:** Sunrise, Paragon, dbMotion, TouchWorks, Opal, Provation, STAR, Ventus, Altera Cloud, Managed Services, Other

**Content Types:** sales_brief, datasheet, brochure, door_opener, one_pager

**Key Fields for Discovery:**
- `elevator_pitch` — Quick summary
- `key_drivers[]` — Customer pain points (title + description)
- `target_triggers[]` — Sales trigger scenarios
- `value_propositions[]` — Value prop cards
- `competitive_analysis[]` — Competitor comparisons
- `objection_handling[]` — Objection → Response pairs

## Architecture

### Page Structure

```
/guides (products tab)     → Discovery hub with search, filters, categories, cards
/guides/products/[id]      → Full-page product detail with sales playbook
```

### Components

```
src/
├── app/(dashboard)/guides/
│   └── products/
│       └── [id]/
│           └── page.tsx          # Product detail page
├── components/
│   └── product-library/
│       ├── ProductLibrary.tsx    # Main container
│       ├── ProductCard.tsx       # Individual product card
│       ├── ProductFilters.tsx    # Sidebar filters
│       ├── ProductSearch.tsx     # Search bar component
│       ├── PainPointChips.tsx    # Category filter chips
│       └── ProductCommandPalette.tsx  # Cmd+K overlay
├── hooks/
│   └── useProductSearch.ts       # Fuzzy search + filtering logic
├── lib/
│   └── product-icons.ts          # Icon mapping utility
└── public/
    └── images/
        └── product-icons/        # Brand icons from OneDrive
```

## UI Design

### Discovery Hub Layout

```
┌─────────────────────────────────────────────────────────────────────┐
│  🔍 Search products, pain points, or solutions...          ⌘K      │
├─────────────────────────────────────────────────────────────────────┤
│  Pain Point Categories (horizontal scroll chips):                   │
│  [All] [Workflow Efficiency] [Compliance & Security] [Revenue]      │
│  [Interoperability] [Patient Engagement] [Clinical Accuracy]        │
├────────────┬────────────────────────────────────────────────────────┤
│  FILTERS   │  Product Grid                                          │
│            │  ┌──────────┐ ┌──────────┐ ┌──────────┐               │
│  Family    │  │ Product  │ │ Product  │ │ Product  │               │
│  ☑ Sunrise │  │ Card     │ │ Card     │ │ Card     │               │
│  ☑ Paragon │  └──────────┘ └──────────┘ └──────────┘               │
│  ☐ dbMotion│                                                        │
│            │  Showing 24 of 94 products                             │
│  Type      │                                                        │
│  ☑ Sales   │                                                        │
│  ☐ Datasheet                                                        │
└────────────┴────────────────────────────────────────────────────────┘
```

### Product Card

```
┌────────────────────────────────────────────────┐
│ ┌──────────────────────────────────────────┐   │
│ │  gradient header bar (product family)    │   │
│ └──────────────────────────────────────────┘   │
│                                                │
│  [Icon] Product Name                           │
│  ─────────────────────────────                 │
│  Content Type                                  │
│                                                │
│  "Elevator pitch text truncated to 2 lines    │
│  showing the key value proposition..."         │
│                                                │
│  Pain Points Addressed:                        │
│  [Workflow Efficiency] [Compliance]            │
│                                                │
│  [View Details →]                    [⬇ PDF]  │
└────────────────────────────────────────────────┘
```

### Product Detail Page

**Tabs:**
1. **Overview** — Solution overview, pricing, version requirements, target triggers
2. **Value Propositions** — Cards for each value prop
3. **Pain Points** — Key drivers as problem → solution pairs
4. **Competitive Analysis** — Comparison table
5. **Objection Handling** — Accordion Q&A
6. **FAQ** — Collapsible Q&A (if exists)

### Command Palette (Cmd+K)

```
┌─────────────────────────────────────────────────────────────────┐
│  🔍 Search products, pain points, or client needs...            │
├─────────────────────────────────────────────────────────────────┤
│  RECENT                                                         │
│  ├─ 📦 Sunrise Medical Photography                              │
│                                                                 │
│  PRODUCTS                                                       │
│  ├─ 📦 Sunrise Acute Care            Sunrise · Sales Brief     │
│  ├─ 📦 dbMotion Health Connect       dbMotion · Datasheet      │
│                                                                 │
│  PAIN POINTS                                                    │
│  ├─ 🎯 "Workflow Efficiency"         12 products               │
│                                                                 │
│  ↑↓ Navigate  ⏎ Select  ⎋ Close                                │
└─────────────────────────────────────────────────────────────────┘
```

## Visual Style

**Stripe/Vercel-inspired:**
- Frosted glass search bar (`backdrop-blur-xl`)
- Gradient category chips with hover transitions
- Cards with subtle gradient borders, elevation on hover
- Glassmorphism info sections
- Smooth animated tab transitions
- Framer Motion micro-interactions

**Product Family Colour Palette:**

| Family | Gradient |
|--------|----------|
| Sunrise | Purple → Violet |
| Paragon | Blue → Cyan |
| dbMotion | Emerald → Teal |
| TouchWorks | Orange → Amber |
| Provation | Rose → Pink |
| STAR | Indigo → Blue |
| Ventus | Sky → Cyan |
| Altera Cloud | Slate → Gray |
| Managed Services | Green → Emerald |
| Other | Gray → Slate |

**Product Icons:**
Source: `/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/Marketing - Altera Templates & Tools/BU Logos`

Copy to `public/images/product-icons/`:
- `Altera-App-Icon_Sun.svg` → `sunrise.svg`
- `Altera-App-Icon_Par-1.svg` → `paragon.svg`
- `Altera-App-Icon_dbM.svg` → `dbmotion.svg`
- `Altera-App-Icon_TW.svg` → `touchworks.svg`
- `Altera-App-Icon_Opal.svg` → `opal.svg`
- `Altera-App-Icon_CD.svg` → `clinical-docs.svg`
- `Altera-App-Icons_Ven.png` → `ventus.png`
- `Altera-App-Icons_CFX.png` → `cfx.png`

## ChaSen AI Integration

### 1. New Intent: `product_recommendation`

Add to `chasen-intent-classifier.ts`:
```typescript
product_recommendation: {
  keywords: ['product', 'recommend', 'solution', 'sell', 'upsell', 'cross-sell',
             'pain point', 'struggle', 'challenge', 'need'],
  phrases: ['what product', 'which product', 'recommend for', 'solution for',
            'client struggling with', 'address their', 'pain point'],
  weight: 0.9,
}
```

### 2. Product Search API

**Endpoint:** `POST /api/chasen/product-search`

**Input:**
```json
{
  "query": "client struggling with documentation workflows",
  "clientName": "Optional client context"
}
```

**Process:**
1. ChaSen analyses query semantically
2. Matches against `key_drivers`, `target_triggers`, `elevator_pitch`
3. Returns ranked recommendations with match reasoning

**Output:**
```json
{
  "recommendations": [
    {
      "product": { ... },
      "matchScore": 0.98,
      "matchReason": "Addresses 'Inefficient Clinical Workflows'",
      "matchedKeyDriver": "Inefficient Clinical Workflows"
    }
  ]
}
```

### 3. Command Palette Integration

When user types natural language query:
- Debounce 300ms, then call `/api/chasen/product-search`
- Display AI-powered results with match reasoning
- Fallback to fuzzy search if ChaSen unavailable

### 4. Contextual Suggestions

On Product Detail Page, ChaSen suggests:
- Related products for the same pain points
- Client-specific recommendations based on portfolio

## Pain Point Categories

Derived from analysing all `key_drivers` across 94 products:

1. **Workflow Efficiency** — Clinical workflows, documentation, time management
2. **Compliance & Security** — HIPAA, audit trails, data protection
3. **Revenue Optimisation** — Reimbursement, billing, financial performance
4. **Interoperability & Integration** — System connectivity, data exchange
5. **Patient Engagement** — Patient access, communication, self-service
6. **Clinical Accuracy** — Diagnostic confidence, standardisation
7. **Resource Management** — Staff efficiency, cost control

## Dependencies

```json
{
  "fuse.js": "^7.0.0",      // Fuzzy search
  "cmdk": "^1.0.0",         // Command palette
  "framer-motion": "^11.0"  // Animations (likely already installed)
}
```

## Implementation Order

1. **Phase 1: Foundation**
   - Copy product icons to public folder
   - Create `product-icons.ts` utility
   - Create `useProductSearch.ts` hook with Fuse.js

2. **Phase 2: Discovery Hub**
   - Replace mock Products section with `ProductLibrary`
   - Implement `ProductCard`, `ProductFilters`, `PainPointChips`
   - Add search bar with fuzzy matching

3. **Phase 3: Product Detail Page**
   - Create `/guides/products/[id]/page.tsx`
   - Implement tabbed layout with all sales playbook sections
   - Add Stripe-style visual polish

4. **Phase 4: Command Palette**
   - Implement `ProductCommandPalette` with cmdk
   - Add global Cmd+K shortcut
   - Integrate recent products tracking (localStorage)

5. **Phase 5: ChaSen Integration**
   - Add `product_recommendation` intent
   - Create `/api/chasen/product-search` endpoint
   - Wire AI search into command palette
   - Add contextual suggestions on detail page

## Success Criteria

- [ ] All 94 products display with real data
- [ ] Filter by product family and content type works
- [ ] Pain point category filtering works
- [ ] Fuzzy search returns relevant results
- [ ] Command palette opens with Cmd+K
- [ ] Product detail page shows full sales playbook
- [ ] ChaSen can recommend products based on pain points
- [ ] Product icons display correctly
- [ ] Stripe/Vercel visual polish achieved
- [ ] Mobile responsive
