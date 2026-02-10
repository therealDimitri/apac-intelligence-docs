# Navigation Map

## Sidebar Groups (8)

| # | Group | Icon | Pages |
|---|-------|------|-------|
| 1 | Command Centre | Home | Dashboard (`/`), CS Operating Rhythm (`/operating-rhythm`), Daily Digest (`/digest`) |
| 2 | Success Plans | Target | Account Planning (`/planning`), Goals & Projects (`/goals-initiatives`), Approvals (`/goals-initiatives/approvals`), Autopilot (`/planning/autopilot`), Recognition (`/planning/recognition`) |
| 3 | Clients | Users | Portfolio Health (`/client-profiles`), Segmentation Progress (`/compliance`) |
| 4 | Action Hub | Handshake | Meetings (`/meetings`), Actions & Tasks (`/actions`), AI Task Queue (`/tasks`) |
| 5 | Analytics | LineChart | CS Team Performance (`/team-performance`), NPS (`/nps`), Support Health (`/support`), Working Capital (`/aging-accounts`) |
| 6 | AI Lab | Bot | Digital Twins (`/twins`), Deal Sandbox (`/sandbox`) |
| 7 | Visualisations | Network | Network Graph (`/visualisation/network`), 3D Pipeline (`/visualisation/pipeline`) |
| 8 | Resources | Cog | Sales Hub (`/sales-hub`), Guides & Templates (`/guides`) |

## Sidebar Features
- All groups collapsible with localStorage persistence (`sidebar-expanded-groups`)
- Active page detection with visual indicators (white background, emerald dot)
- Universal search palette (Cmd+K)
- ChaSen AI quick access at top
- User profile section at bottom

## Full Route Inventory (60+ routes)

### Primary Pages (in sidebar)
```
/                              Command Centre dashboard
/operating-rhythm              CS Operating Rhythm orbit view
/planning                      Account Planning Coach (My Plans, Planning Coach, Performance tabs)
/planning/autopilot            Relationship Autopilot
/planning/recognition          Recognition Program
/digest                        Daily Digest
/goals-initiatives             Goals & Projects hub (9 tabs: Overview, Dashboard, Strategy Map, Pillar, BU Goals, Team, Projects, Timeline, Workload)
/goals-initiatives/approvals   Approval workflow
/client-profiles               Portfolio Health grid
/compliance                    Segmentation Progress
/meetings                      Meeting management
/actions                       Actions & Tasks (Kanban + Inbox views)
/actions/[id]                  Action detail (context-aware back nav via ?from= params)
/tasks                         AI Task Queue
/team-performance              CS Team Performance
/nps                           NPS Analytics
/support                       Support Health
/aging-accounts                Working Capital
/twins                         Digital Twins
/sandbox                       Deal Sandbox
/visualisation/network         Network Graph
/visualisation/pipeline        3D Pipeline
/sales-hub                     Sales Resource Hub
/guides                        Guides & Templates
```

### Detail/Sub-Pages
```
/clients/[clientId]/v2         Client detail (three-column layout)
/clients/[clientId]/nps-analysis  NPS analysis tab
/clients/[clientId]/portfolio  Portfolio analysis tab
/meetings/[id]                 Meeting detail
/meetings/[id]/live            Meeting Co-Host (live)
/meetings/calendar             Calendar view
/planning/strategic            Strategic plans
/planning/strategic/new        Multi-step wizard (sub-step sidebar nav, ChaSen AI Coach)
/planning/strategic/[id]       Plan detail (approval workflow, rename)
/goals-initiatives/[type]/[id] Goal detail
/goals-initiatives/new         Create goal
/goals-initiatives/dashboard   Goals dashboard
/guides/products/[id]          Product guide
/guides/email-templates/[id]/edit  Email template editor
```

### Admin Routes (hidden from standard users)
```
/admin/ms-graph-role-mapping   User role sync
/admin/data-quality            Data reconciliation
/admin/audit-log               Audit trail
/admin/integrations            Integration status + sync triggers (Aged Accounts via Invoice Tracker)
/admin/pipeline-reconciliation Pipeline checks
/admin/form-builder            Form builder
/admin/users                   User management
/admin/data-lineage            Data lineage
/admin/data-sync               Sync dashboard — summary cards, source rows with Sync Now, history table
```

### Settings Routes
```
/settings                      Settings hub
/settings/news-intelligence    News config
/settings/sales-hub            Sales Hub config
/settings/product-analytics    Product analytics config
/settings/system               System settings
/settings/chasen               ChaSen AI settings
/settings/knowledge            Knowledge base
/settings/automations          Automation rules
```

### Orphaned Routes (exist but not in sidebar)
- `/apac` — Regional view
- `/pipeline` — Pipeline management
- `/burc` — BURC financial dashboard
- `/financials` — Financial analytics
- `/alerts` — Alert centre
- `/internal-ops` — Internal operations
- `/benchmarking` — Benchmarking
- `/priority-matrix` — Priority matrix
- `/segmentation` — Segmentation management
- `/ai` — ChaSen AI lab

### Internal/Dev Pages (hide in production)
- `/test-ai` — AI feature testing
- `/test-charts` — Chart component testing
- `/chasen-icons` — Design system icon reference

## Client Detail Layout

Three-column layout at `/clients/[clientId]/v2`:
- **Left**: Client overview, profile, metadata
- **Centre**: Activity feed, meetings, notes, comments
- **Right**: UnifiedSidebar context (emerging details)

Deep linking via URL params: `?section=...&highlight=...&tab=...`
