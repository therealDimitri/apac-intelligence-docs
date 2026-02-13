# Domain Feature Reference

> Detailed developer reference for cross-cutting domain features: Sales Hub, News Intelligence, Goals & Initiatives, Operating Rhythm, Unified Actions, and Export Branding.

## Sales Hub

### Database Tables

`product_catalog`, `solution_bundles`, `toolkits`, `value_wedges`, `saved_recommendations`, `recommendation_analytics`

- **Product Family dropdown**: Edit `PRODUCT_FAMILIES` array in `src/components/ProductModal.tsx` (shared modal, not in sales-hub folder)
- `industry_news`: Seed data has NULL `source_url` values; external link icons only show when URL exists
- Knowledge sync: Uses `chasen_knowledge` table with `knowledge_key` = `product_{id}`
- All admin endpoints require auth (`/api/sales-hub/*`)

### Recommendations System

- **RecommendationsTab**: `src/app/(dashboard)/sales-hub/components/RecommendationsTab.tsx`
- **EvidenceCard**: `src/components/sales-hub/EvidenceCard.tsx` — scoring breakdown
- **recommendation-evidence.ts**: `src/lib/recommendation-evidence.ts` — 5 scoring factors (topic 30pts, NPS 20pts, health 20pts, ARR 10pts, stack gap 10pts, base 10pts)

### Value Wedges

- Structure: `unique_how`, `important_wow`, `defensible_proof`, `target_personas`, `competitive_positioning`
- Matched to products via `product_family` field
- Seed script: `scripts/seed-value-wedges.mjs`

### NPS Keyword Matching

- 68 healthcare-specific keywords in `calculateNpsMatch()`
- Categories: clinical, technology, workflow, reporting, mobile, revenue, support, compliance, UX

### API Route Patterns

- **CRUD on same path**: GET/POST/DELETE handlers in single route file
- **Sync knowledge API**: GET = bulk sync all products, POST = single product (requires `productId` in body)
- **Always validate DELETE inputs**: Missing validation causes silent failures
- **Check res.ok before UI updates**: Prevent optimistic updates on failed requests

---

## News Intelligence

### Tables

`news_sources`, `news_articles`, `news_article_clients`, `news_stakeholder_mentions`, `tender_opportunities`

### Key Files

- **RSS Fetcher**: `src/lib/news-intelligence/rss-fetcher.ts`
- **Web Scraper**: `src/lib/news-intelligence/web-scraper.ts`
- **Tender Fetcher**: `src/lib/news-intelligence/tender-fetcher.ts`
- **ChaSen Scorer**: `src/lib/news-intelligence/chasen-scorer.ts` — AI scoring, client matching, junction table population
- **Fetch API**: `src/app/api/cron/news-fetch/route.ts` (type=rss|scrape|tender)
- **Client News UI**: `src/app/(dashboard)/clients/[clientId]/components/v2/ClientNewsSection.tsx`
- **News API**: `src/app/api/sales-hub/news/route.ts`
- **Seed script**: `scripts/seed-news-sources.mjs` (61 APAC sources)

### Scoring Formula (0-100)

```
RELEVANCE = CLIENT_MATCH*0.30 + TOPIC*0.25 + ACTION*0.20 + AUTHORITY*0.15 + RECENCY*0.10
```

### Enum Values

- **Categories**: `urgent_action`, `opportunity`, `monitor`, `fyi`
- **Fetch Frequency**: `hourly`, `every_2_hours`, `every_4_hours`, `every_6_hours`, `daily`, `weekly`
- **Source Types**: `rss`, `scrape`, `api`, `tender_portal`
- **Source Categories**: `client_direct`, `healthcare_it`, `industry_body`, `government`, `tender`, `general`

### Junction Table

- **Source of truth**: `news_article_clients` junction table (populated by `chasen-scorer.ts`)
- **Client News API** queries junction table, NOT `matched_clients` array on articles
- **Bug pattern**: Don't compute client matches twice (AI vs keyword) — single source of truth

---

## Goals & Initiatives

### Hierarchy

- **3-tier**: company_goals -> team_goals -> portfolio_initiatives -> actions
- **Initiative FK**: `actions.linked_initiative_id` -> `portfolio_initiatives.id` (UUID)
- **Column naming**: portfolio_initiatives uses `name` (not `title`), `goal_status` (not `status`), `completion_date` (not `target_completion_date`)
- **DEPRECATED**: `initiatives` table — use `portfolio_initiatives` instead

### Database Tables

| Table | Purpose |
|-------|---------|
| `company_goals` | Top-level strategic objectives (UUID) |
| `team_goals` | Department objectives linked to company goals |
| `portfolio_initiatives` | Consolidated initiative table |
| `goal_templates` | Reusable templates with suggested metrics |
| `goal_check_ins` | Weekly/fortnightly check-in entries |
| `goal_dependencies` | Blocking/related-to relationships |
| `goal_approvals` | Change approval workflow |
| `goal_audit_log` | Full audit trail |
| `custom_roles` | RBAC roles with JSONB permissions |
| `user_role_assignments` | User-to-role mapping |
| `role_mapping_rules` | Auto-assign from MS Graph |
| `ms_graph_sync_log` | Sync history |
| `goal_progress_rollup` | Materialised view |

### API Routes

| Route | Methods | Purpose |
|-------|---------|---------|
| `/api/goals` | GET, POST | List with filters, create any tier |
| `/api/goals/[id]` | GET, PATCH, DELETE | Detail (requires `?goal_type=`) |
| `/api/goals/[id]/hierarchy` | GET | Tree, ancestors, child count (`?mode=`) |
| `/api/goals/[id]/check-in` | GET, POST | Check-ins |
| `/api/goals/[id]/dependencies` | GET, POST, DELETE | Blocking relationships |
| `/api/goals/initiatives` | GET, POST | Initiative picker + quick-create |
| `/api/actions/link-progress` | GET | Mapping stats (total/linked/orphaned) |
| `/api/actions/bulk-link` | POST | Bulk-link actions to initiative |
| `/api/goals/dashboard/activity` | GET | Recent goal activity (check-ins, status updates) for dashboard timeline |
| `/api/chasen/suggest-initiative` | POST | AI initiative matching |
| `/api/ms-graph/sync` | GET, POST | MS Graph sync status/trigger |
| `/api/ms-graph/mapping-rules` | GET, POST | Mapping rules CRUD |
| `/api/ms-graph/mapping-rules/[id]` | GET, PUT, DELETE | Individual rule |
| `/api/cron/ms-graph-sync` | GET | Daily automated role sync |
| `/api/admin/roles` | GET | List custom roles |

### Key Files

- **Types**: `src/types/goals.ts`
- **Progress**: `src/lib/goals/progress.ts` — calculateProgress(), deriveStatus()
- **Permissions**: `src/lib/goals/permissions.ts` — RBAC resolution
- **Hierarchy**: `src/lib/goals/hierarchy.ts`
- **Components**: `src/components/goals/` (GanttView, GoalKanbanBoard, StrategyMap, GoalsDashboard, GoalDrillDownDrawer, GoalDrillDownRow, CheckInSuggestButton)
- **Labels**: `src/lib/goals/labels.ts` — GOAL_TYPE_LABELS, GOAL_TYPE_SHORT_LABELS, GOAL_TYPE_PLURAL_LABELS
- **Gantt hook**: `src/hooks/useGanttData.ts` — hierarchical DFS sort, default collapsed
- **Link Tab**: `src/components/unified-actions/LinkToInitiativeTab.tsx`
- **Action editing**: Reuses `ActionSlideOutEdit` from `src/components/modern-actions/` on goal detail page
- **Pages**: `src/app/(dashboard)/goals-initiatives/`
- **MS Graph**: `src/lib/ms-graph/role-sync.ts`, `src/components/ms-graph/`, `src/hooks/useMSGraphSync.ts`

### Dashboard Drill-Down Drawer

- **Components**: `GoalDrillDownDrawer` (shell + data fetch) + `GoalDrillDownRow` (compact goal card)
- **DrillContext** discriminated union — 3 modes: `list` (filtered goals), `single` (goal detail), `actions` (pre-loaded action items)
- **Triggers**: Every dashboard widget fires `setDrillContext()` — KPI cards, status pie legend, owner bar chart, overdue rows, freshness cards, linked actions stats, activity entries
- **Actions mode**: Uses pre-loaded `allActions` from `useActions()` hook — no extra fetch. Action items navigate to `/actions/{numericId}` (NOT `Action_ID`)
- **Portal rendering**: `createPortal(document.body)` with framer-motion spring animation (damping 30, stiffness 300)
- **Keyboard**: Escape to close via `useHotkeys`, focus return to trigger element on close
- **Status changes**: Inline status dropdown in list mode, `handleDrillStatusChange` PATCHes API then increments `refreshKey` to re-fetch dashboard
- **Design doc**: `docs/plans/2026-02-13-goals-dashboard-drilldown-design.md`

### RBAC Roles

| Role | Create | Edit | Delete |
|------|--------|------|--------|
| Executive Leadership | All tiers | All | All |
| Team Lead | Team + Initiative | Team scope | Team scope |
| CSE | Initiative only | Own | Own |
| Cross-Functional Contributor | None | Assigned | None |
| View Only | None | None | None |

### Progress Methods

- `auto`: Rollup average from children
- `manual`: User-entered percentage
- `target_value`: current / target * 100
- `boolean`: 0% or 100%

---

## Operating Rhythm Orbit Views

### Components

`src/components/operating-rhythm/AnnualOrbitView.tsx`, `CSEOrbitView.tsx`

### Data Flow

`segmentation_events` -> `event_compliance_summary` (materialised view) -> `useEventCompliance` -> `useOperatingRhythmData` -> `AnnualOrbitView`

- Only count events where `completed === true` AND `event_date <= now()`
- If completion % > 100%, check for `completed = true` with future `event_date`

### SVG Orbit Layer Radii

| Layer | Radius |
|-------|--------|
| Activity bubbles | 85 |
| Clients (CSE view) | 130 |
| Milestones | 180 |
| Month indicator dots | 195 |
| Month labels | 210 |

### Gotchas

- **Z-index on hover**: `zIndex: isHovered || isSelected ? 50 : 1`
- **Clip path sizing**: Must match containing circle radius exactly
- **By Month vs By CSE consistency**: Milestone buttons `w-14 h-14 text-[10px]` in both
- **Client bubbles**: `bubbleRadius = 18`, clip path = 16, image = 32x32 `preserveAspectRatio="xMidYMid slice"`
- **Layout shift on selection**: Main flex container needs `lg:items-start`

---

## Unified Actions

- **Follow-up workflow**: `ACTION_FOLLOWUP` source, `FollowupTemplateSelector`, `action_relations` table pre-built
- **ActionProvider wiring**: New features need callbacks in `ActionProvider.tsx` (e.g., `onCreateFollowup`)
- **Parent-child**: `POST /api/actions/[id]/relations` with `relation_type: 'parent_of'` or `'child_of'`

---

## Product Icons & Branding

- **Config**: `src/lib/product-icons.ts` — maps product families to icons, colours, fallbacks
- **Logos**: `/public/images/products/` (PNG)
- **Colour scheme**: Each family has gradient, border, bg, text, accent Tailwind classes

---

## Export Branding (2026 Altera)

### Module Locations

- **PDF branding**: `src/lib/pdf/altera-branding.ts`
- **PDF fonts**: `src/lib/pdf/montserrat-font.ts` (Base64 Montserrat TTF)
- **PDF cover pages**: `src/lib/pdf/cover-page.ts` — `generateCoverPage()`
- **PPTX slide masters**: `src/lib/pptx/altera-slides.ts` — 8 branded layouts

### Brand Colours

- Primary purple: `#383392`, Coral: `#F56E7B`, Teal: `#00BBBA`
- Source: `/Marketing - Altera Templates & Tools/Altera_Library_2026.pptx`
- Extract: `unzip -p template.pptx ppt/theme/theme1.xml | grep srgbClr`

### jsPDF Pattern

```typescript
pdf.addFileToVFS('Font-Regular.ttf', base64String)
pdf.addFont('Font-Regular.ttf', 'FontName', 'normal')
pdf.setFont('FontName', 'normal')
```

### PptxGenJS Pattern

```typescript
defineAlteraSlideMasters(pptx)
const slide = pptx.addSlide({ masterName: 'TITLE_CONTENT' })
slide.addText('Title', { placeholder: 'title' })
```

---

## Tender Scraper

- **Location**: `scripts/tender-scraper/`
- **AusTender date format**: `DD-MMM-YYYY`
- **Pagination**: Uses ">" for next page, not "Next"
- **DB**: `tender_opportunities` — no `source_url` column, use `notes` field
- **Run**: `export $(cat .env.local | grep -v '^#' | xargs) && PORTALS=austender npx tsx scripts/tender-scraper/index.ts`
- **Playwright**: When selectors timeout, use `page.evaluate()` to find/click by visibility
