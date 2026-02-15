# Feature: ChaSen Auto-Discovery System

**Date:** 27 December 2025
**Type:** Enhancement
**Status:** Active
**Commits:** `ee23cf6`, `c4fdf20`, `c7d712e`

## Overview

ChaSen AI now automatically discovers and integrates new database tables without manual code changes. This system ensures ChaSen always has access to the latest data across the entire platform.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     ChaSen Auto-Discovery                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌─────────────┐    ┌──────────────────┐    ┌────────────────┐  │
│  │  Scheduled  │───▶│  API Endpoint    │───▶│  Supabase DB   │  │
│  │  Function   │    │  /api/cron/...   │    │                │  │
│  │  (Daily)    │    │                  │    │  chasen_data   │  │
│  └─────────────┘    └──────────────────┘    │  _sources      │  │
│                                              └────────────────┘  │
│         │                                           │            │
│         ▼                                           ▼            │
│  ┌─────────────┐                           ┌────────────────┐   │
│  │  Notify     │                           │  ChaSen Chat   │   │
│  │  Admins     │                           │  Context       │   │
│  └─────────────┘                           └────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Components

### 1. Configuration Table (`chasen_data_sources`)

Stores configuration for each data source ChaSen can access.

**Schema:**
| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key |
| `table_name` | TEXT | Database table name |
| `display_name` | TEXT | Human-readable name |
| `description` | TEXT | Table description |
| `category` | TEXT | client, operations, analytics, system |
| `is_enabled` | BOOLEAN | Whether source is active |
| `priority` | INTEGER | 1-100, higher = more important |
| `select_columns` | TEXT[] | Columns to include |
| `order_by` | TEXT | Sort order (e.g., 'created_at DESC') |
| `limit_rows` | INTEGER | Max rows to fetch |
| `filter_condition` | TEXT | WHERE clause filter |
| `time_filter_column` | TEXT | Column for time filtering |
| `time_filter_days` | INTEGER | Filter to last N days |
| `section_emoji` | TEXT | Emoji for section header |
| `section_title` | TEXT | Override display name |
| `include_link` | TEXT | Dashboard link to include |
| `row_count` | INTEGER | Cached row count |
| `last_synced_at` | TIMESTAMPTZ | Last sync time |

### 2. Dynamic Context Loader (`chasen-dynamic-context.ts`)

**Location:** `src/lib/chasen-dynamic-context.ts`

Functions:
- `getDataSourceConfigs()` - Fetch all enabled configurations
- `getDynamicDashboardContext()` - Build context from all sources
- `discoverNewTables()` - Find unconfigured tables
- `suggestNewDataSources()` - Generate configs for new tables
- `addDataSource()` - Add a new data source
- `syncRowCounts()` - Update row counts for all sources

### 3. Scheduled Function

**Location:** `netlify/functions/chasen-auto-discover.mts`

**Schedule:** Daily at 5:00 AM Sydney time (6:00 PM UTC)

**Actions:**
1. Discovers new database tables
2. Analyses columns and structure
3. Generates appropriate configurations
4. Adds tables to ChaSen's knowledge
5. Notifies admins of discoveries
6. Syncs row counts for existing sources

### 4. Management API

**Endpoint:** `/api/chasen/data-sources`

| Method | Action | Description |
|--------|--------|-------------|
| GET | - | List all configured data sources |
| POST | `discover` | Find new unconfigured tables |
| POST | `add` | Add a single data source |
| POST | `add-all` | Add all discovered tables |
| POST | `toggle` | Enable/disable a source |
| POST | `update` | Update source configuration |
| POST | `delete` | Remove a data source |
| POST | `sync` | Sync row counts |

### 5. CLI Script

**Location:** `scripts/chasen-auto-discover.mjs`

```bash
# List new tables (discovery only)
node scripts/chasen-auto-discover.mjs

# Add all discovered tables
node scripts/chasen-auto-discover.mjs --add

# Show current status
node scripts/chasen-auto-discover.mjs --status

# Sync row counts
node scripts/chasen-auto-discover.mjs --sync
```

## Data Sources

### Currently Configured (18 sources)

#### Client Data (Priority 85-95)
| Table | Display Name | Rows |
|-------|--------------|------|
| `client_health_history` | Client Health History | 540 |
| `nps_responses` | NPS Responses | 199 |
| `health_status_alerts` | Health Alerts | 1 |
| `client_segmentation` | Client Segmentation | 26 |

#### Operations (Priority 60-85)
| Table | Display Name | Rows |
|-------|--------------|------|
| `actions` | Actions & Tasks | 90 |
| `unified_meetings` | Meetings | 138 |
| `portfolio_initiatives` | Portfolio Initiatives | 6 |
| `comments` | Comments | 12 |

#### Analytics (Priority 65-75)
| Table | Display Name | Rows |
|-------|--------------|------|
| `aging_accounts` | Aging Accounts | 20 |
| `aged_accounts_history` | AR History | 427 |
| `nps_topic_classifications` | NPS Topics | 194 |

#### System (Priority 30-60)
| Table | Display Name | Rows |
|-------|--------------|------|
| `nps_period_config` | NPS Periods | 5 |
| `tier_requirements` | Tier Requirements | 0 |
| `notifications` | Notifications | 15 |
| `chasen_knowledge` | ChaSen Knowledge | 20 |
| `email_logs` | Email Tracking | 0 |
| `webhook_logs` | Webhook Logs | 0 |
| `saved_views` | Saved Views | 0 |

## Category Detection

New tables are automatically categorised based on naming patterns:

| Pattern | Category | Emoji |
|---------|----------|-------|
| `client*`, `nps*`, `health*` | client | 👥 |
| `action*`, `meeting*`, `comment*`, `task*` | operations | ⚙️ |
| `aging*`, `*history*`, `*analytics*`, `topic*` | analytics | 📊 |
| Everything else | system | 🔧 |

## Excluded Tables

The following tables are never auto-discovered:
- `schema_migrations`
- `spatial_ref_sys`
- `geography_columns`
- `geometry_columns`
- `raster_columns`
- `raster_overviews`
- Tables starting with `_`
- Tables with 0 rows

## Notifications

When new tables are discovered, admins receive notifications:
- **Type:** System notification
- **Recipients:** Users with manager, executive, or admin roles
- **Content:** List of newly connected tables
- **Link:** `/api/chasen/data-sources`

## Usage Examples

### Adding a New Table Manually

```typescript
import { addDataSource } from '@/lib/chasen-dynamic-context'

await addDataSource({
  table_name: 'new_feature_table',
  display_name: 'New Feature Data',
  category: 'operations',
  priority: 60,
  select_columns: ['id', 'name', 'created_at'],
  order_by: 'created_at DESC',
  limit_rows: 10,
  section_emoji: '🆕',
})
```

### API: Discover New Tables

```bash
curl -X POST https://your-domain/api/chasen/data-sources \
  -H "Content-Type: application/json" \
  -d '{"action": "discover"}'
```

### API: Add All Discovered Tables

```bash
curl -X POST https://your-domain/api/chasen/data-sources \
  -H "Content-Type: application/json" \
  -d '{"action": "add-all"}'
```

### API: Toggle a Data Source

```bash
curl -X POST https://your-domain/api/chasen/data-sources \
  -H "Content-Type: application/json" \
  -d '{"action": "toggle", "config": {"id": "uuid-here", "is_enabled": false}}'
```

## Migration

To enable auto-discovery on a new environment:

1. Run the migration:
   ```sql
   -- docs/migrations/20251227_chasen_data_sources_config.sql
   ```

2. Verify configuration:
   ```bash
   node scripts/chasen-auto-discover.mjs --status
   ```

3. The scheduled function will run automatically on Netlify

## Troubleshooting

### Tables Not Being Discovered

1. Check if table has rows: `SELECT COUNT(*) FROM table_name`
2. Verify table is in public schema
3. Ensure table name doesn't start with `_`
4. Check it's not in the excluded list

### ChaSen Not Using New Data

1. Verify `is_enabled = true` in `chasen_data_sources`
2. Check `select_columns` includes relevant columns
3. Ensure no filter is excluding all data
4. Run sync: `node scripts/chasen-auto-discover.mjs --sync`

### Scheduled Function Not Running

1. Check Netlify function logs
2. Verify `netlify.toml` has correct schedule
3. Test manually: `curl https://your-domain/api/cron/chasen-auto-discover`

## Related Files

- `src/lib/chasen-dynamic-context.ts` - Dynamic loader
- `src/app/api/chasen/data-sources/route.ts` - Management API
- `src/app/api/cron/chasen-auto-discover/route.ts` - Cron endpoint
- `netlify/functions/chasen-auto-discover.mts` - Scheduled function
- `scripts/chasen-auto-discover.mjs` - CLI tool
- `docs/migrations/20251227_chasen_data_sources_config.sql` - Migration
