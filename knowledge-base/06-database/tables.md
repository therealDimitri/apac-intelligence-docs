# Database Tables

> 70+ tables, 5+ materialised views, 4+ RPC functions, 71 migrations
> Supabase project: `usoyxsunetvxdjdglkmn` (ap-south-1)

## Table Groups

### 1. Core Client Data (8 tables)

| Table | Rows | Purpose |
|-------|------|---------|
| `portfolio_clients` | 27 | Master client list with health scores, CSE assignment, segment tier |
| `client_arr` | 19 | FY2026 recognised revenue per client |
| `client_products` | 30 | Product ownership per client |
| `client_segmentation` | ~27 | Segment tier with engagement scores |
| `client_health_history` | 671 | Historical health snapshots with multi-dimension scoring |
| `health_status_alerts` | 1 | Health score change alerts |
| `client_sla_targets` | ? | CSE-specific SLA targets |
| `client_name_aliases` | 116+ | Display name to canonical name mappings (materialised view) |

### 2. Actions & Activities (5 tables)

| Table | Rows | Purpose |
|-------|------|---------|
| `actions` | 91 | Action items (CAPITALIZED columns: `Action_ID`, `Status`, `Due_Date`) |
| `action_comments` | ? | Comments on actions |
| `action_relations` | ? | Parent-child action relationships |
| `notifications` | 75 | User notifications |
| `portfolio_initiatives` | 6 | Consolidated initiative table |

### 3. Meetings (5 tables)

| Table | Rows | Purpose |
|-------|------|---------|
| `unified_meetings` | 276 | Core meetings with AI fields (`sentiment_*`, `effectiveness_*`) |
| `topics` | 30 | Meeting topics (CAPITALIZED: `Meeting_Date`, `Topic_Title`) |
| `meeting_sessions` | ? | Phase 9: Real-time co-host sessions |
| `transcription_segments` | ? | Live transcription with speaker ID |
| `cohost_suggestions` | ? | AI coaching suggestions |

### 4. NPS & Customer Voice (4 tables)

| Table | Rows | Purpose |
|-------|------|---------|
| `nps_responses` | 199 | NPS scores (0-10) with feedback |
| `nps_topic_classifications` | 204 | AI-classified feedback topics |
| `nps_period_config` | 5 | Survey period configuration |
| `client_sentiment_snapshots` | ? | Aggregated daily/weekly sentiment |

### 5. Financial / BURC (7+ tables)

| Table | Purpose |
|-------|---------|
| `burc_annual_financials` | **AUTHORITATIVE** source for financial totals |
| `aging_accounts` | AR aging buckets (18-20 rows) |
| `burc_ebita_monthly` | Monthly EBITA amounts and margin % |
| `burc_opex_monthly` | OPEX by department per month (CS, R&D, PS, Sales, G&A, total) |
| `burc_cogs_monthly` | COGS breakdown per month (licence, PS, maintenance, hardware, total) |
| `burc_net_revenue_monthly` | Net revenue by type per month (licence, PS, maintenance, hardware, total) |
| `burc_gross_revenue_monthly` | Gross revenue by type per month (licence, PS, maintenance, hardware, total) |
| `burc_*` detail tables | Additional monthly breakdowns (CSI ratios, waterfall, client maintenance, etc.) |

### 6. Goals & Strategic Planning (8 tables)

| Table | Purpose |
|-------|---------|
| `company_goals` | Top-level strategic objectives |
| `team_goals` | Department objectives linked to company goals |
| `goal_templates` | Reusable templates (5 seeded) |
| `goal_check_ins` | Progress updates |
| `goal_dependencies` | Blocking relationships |
| `goal_approvals` | Change approval workflow |
| `goal_audit_log` | Full audit trail |
| `goal_progress_rollup` | Materialised view for aggregated progress |

### 7. ChaSen AI (7 tables)

| Table | Rows | Purpose |
|-------|------|---------|
| `chasen_knowledge` | 124 | Knowledge base for RAG |
| `chasen_knowledge_suggestions` | 14 | Auto-generated knowledge entries |
| `chasen_feedback` | 24 | User feedback on responses |
| `chasen_conversations` | 183 | Conversation history |
| `chasen_folders` | 7 | Folder organisation |
| `chasen_learning_patterns` | 0 | Learning from dismissals |
| `chasen_workflows` | ? | NL automation rules |

### 8. Sales Hub (6 tables)

| Table | Purpose |
|-------|---------|
| `product_catalog` | Product inventory |
| `solution_bundles` | Bundled product offers |
| `toolkits` | Vertical-specific sales kits |
| `value_wedges` | Product family templates |
| `saved_recommendations` | User-saved AI recommendations |
| `recommendation_analytics` | Recommendation engagement tracking |

### 9. News Intelligence (4 tables)

| Table | Rows | Purpose |
|-------|------|---------|
| `news_sources` | 61+ | APAC news source configurations |
| `news_articles` | ? | Articles with AI relevance scores |
| `news_article_clients` | ? | **SOURCE OF TRUTH** for article-client mapping |
| `tender_opportunities` | ? | Government tender portal scraping |

### 10. Phase 8: Relationship Automation (6 tables)

| Table | Purpose |
|-------|---------|
| `relationship_autopilot_rules` | Automated touchpoint rules |
| `scheduled_touchpoints` | Pending suggestions |
| `communication_drafts` | AI email drafts |
| `recognition_occasions` | Client recognition opportunities |
| `recognition_suggestions` | Suggestions per occasion |
| `client_milestones` | Recurring milestone tracking |

### 11. Phase 9: Moonshot (19+ tables)

Includes: `ai_task_queue`, `ai_task_dependencies`, `ai_task_logs`, `ai_scheduled_tasks`, `relationship_edges`, `visualisation_configs`, `graph_layout_cache`, `client_digital_twins`, `simulation_scenarios`, `simulation_turns`, `deal_sandboxes`, `sandbox_moves`, `health_predictions`, `portfolio_insights`, `user_digests`, `sentiment_alerts`, `sentiment_thresholds`, and more.

### 12. Segmentation & Events (4 tables + 1 view)

| Table | Purpose |
|-------|---------|
| `segmentation_events` | Operating Rhythm event tracking (UNIQUE on `client_name, event_type_id, event_date`) |
| `segmentation_event_types` | Event type templates |
| `tier_event_requirements` | Annual targets per tier |
| `segmentation_compliance_scores` | Historical compliance snapshots |
| `event_compliance_summary` | Materialised view for completion % |

**`segmentation_events` dedup columns:**
- `content_hash` (TEXT, NOT NULL) — MD5 of `client_name:event_type_id:event_date:source`, auto-computed by `compute_content_hash()` trigger
- `source` (TEXT, NOT NULL, default `'dashboard'`) — CHECK constraint: `dashboard`, `excel`, `bulk_import`, `briefing_room`, `api`

### 13. RBAC & User Management (4 tables)

| Table | Rows | Purpose |
|-------|------|---------|
| `custom_roles` | 5 | System roles (Exec, Team Lead, CSE, Contributor, View Only) |
| `user_role_assignments` | 0 | User-to-role mapping |
| `role_mapping_rules` | 0 | Auto-assign from MS Graph |
| `ms_graph_sync_log` | 0 | Sync history |

## Key Views & Functions

### Materialised Views
1. `event_compliance_summary` — Completion % aggregation
2. `client_health_summary` — Current health snapshot
3. `client_canonical_lookup` — 116+ client name aliases
4. `goal_progress_rollup` — Child goal aggregation
5. `support_sla_latest` — Latest SLA metrics

### Database Functions
1. `resolve_client_name(name)` — Fuzzy client matching (1.0→0.4 confidence)
2. `scan_client_name_mismatches()` — Find unresolved names
3. `clean_expired_graph_cache()` — Expire D3 layout cache
4. `upsert_segmentation_event(...)` — Atomic INSERT ... ON CONFLICT for dedup with source-priority logic
5. `compute_content_hash()` — BEFORE INSERT/UPDATE trigger on `segmentation_events`
4. `get_connected_nodes(type, id, depth)` — Graph traversal

## Primary FK Chains

```
portfolio_clients (id)
  <- actions (client_id)
  <- unified_meetings (implicit via client_name)
  <- nps_responses (client_id, client_uuid)
  <- client_health_history (client_id)
  <- segmentation_events (client_name)

unified_meetings (id, INTEGER)
  <- meeting_sessions (meeting_id → INTEGER, NOT UUID)
  <- transcription_segments (session_id)
  <- cohost_suggestions (session_id)

news_articles (id)
  <- news_article_clients (article_id) → portfolio_clients (client_id)

client_digital_twins (id)
  <- simulation_scenarios (twin_id)
  <- simulation_turns (scenario_id)
```
