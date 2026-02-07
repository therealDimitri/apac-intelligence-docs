# Database Migrations

## Overview

- **Total migrations**: 71 files
- **Date range**: 2025-11-27 through 2026-02-08
- **Location**: `supabase/migrations/`
- **Schema references**: `docs/database-schema.md` (2026-02-06 snapshot), `docs/database-schema.json`

## Migration Timeline

### November 2025 (Foundation)
- Event tracking: `segmentation_events`, `tier_event_requirements`, `segmentation_event_types`
- Client ARR: `client_arr`

### January 2026 (Client Management)
- Client management: `client_name_aliases`, `client_sla_targets`, `client_products`, `client_segmentation` (extended)
- Sales Hub: `product_catalog`, `solution_bundles`, `product_analytics`

### February 2026 (Feature Explosion)
- News intelligence: `news_sources`, `news_articles`, `news_article_clients`, `tender_opportunities`
- Strategic planning: `company_goals`, `team_goals`, `goal_templates`, `goal_*` tables
- Phase 8 Automation: `relationship_autopilot_rules`, `scheduled_touchpoints`, `communication_drafts`, `recognition_occasions`
- Phase 9 Moonshot: `ai_task_queue`, `client_digital_twins`, `deal_sandboxes`, `meeting_sessions`, `sentiment_analysis`, `health_predictions`
- Phase 10 ChaSen AI: `graph_sync_status`, `portfolio_insights`, `user_digests`, `chasen_workflows` (extended)

## Key Migration Files

| Migration | Tables Created |
|-----------|---------------|
| `20260206_relationship_autopilot.sql` | autopilot_rules, touchpoints, communication_drafts, recognition tables |
| `20260207_01_ai_task_queue.sql` | ai_task_queue, dependencies, logs, scheduled_tasks |
| `20260207_02_relationship_graph.sql` | relationship_edges, visualisation_configs, graph_layout_cache |
| `20260207_04_digital_twins.sql` | client_digital_twins, simulation_scenarios, simulation_turns |
| `20260207_05_deal_sandbox.sql` | deal_sandboxes, sandbox_moves |
| `20260207_06_meeting_sessions.sql` | meeting_sessions, transcription_segments, cohost_suggestions |
| `20260207_07_sentiment_analysis.sql` | sentiment_snapshots, sentiment_alerts, thresholds |
| `20260208_chasen_ai_enhancements.sql` | graph_sync_status, health_predictions, portfolio_insights, user_digests |

## Tables Without Explicit CREATE

These tables were imported or created outside migrations:
- `actions`, `unified_meetings`, `nps_responses`, `topics`, `aging_accounts`, `notifications`, `portfolio_initiatives`

## Migration Workflow

No `exec_sql` RPC available. For manual migrations:

```bash
# Use pg client with direct connection
export DATABASE_URL_DIRECT="postgresql://..."
node -e "const { Client } = require('pg'); ..."
```

Or use the Supabase MCP tool: `mcp__plugin_supabase_supabase__apply_migration`

## Schema Documentation

- **Primary schema doc**: `docs/database-schema.md` — human-readable with row counts
- **Machine-readable**: `docs/database-schema.json` — for automated tooling
- **Architecture doc**: `docs/architecture/database-schema.md` — older snapshot (2025-12-24)
- **Column traps**: Documented in CLAUDE.md and `06-database/gotchas.md`
