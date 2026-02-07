# Sync Architecture

## Overview

Data flows from OneDrive Excel files through Node.js scripts into Supabase PostgreSQL. The pipeline is **local-only** — Netlify cannot sync Excel data. All sync operations run on the developer's macOS machine.

```
[OneDrive Excel Files]
        |
        v
[scripts/*.mjs] ──sync──> [Supabase PostgreSQL]
        |                          |
[lib/onedrive-paths.mjs]          v
                          [Next.js API Routes]
                                  |
                                  v
                          [React Dashboard UI]
```

## Data Sources

| Source | Script | Tables | Trigger | Frequency |
|--------|--------|--------|---------|-----------|
| BURC Excel | `sync-burc-data-supabase.mjs` | 12 `burc_*` tables | launchd plist | Every 1 hour |
| Activity Register | `sync-excel-activities.mjs` | `segmentation_events`, compliance | Manual CLI | On file change |
| NPS Survey | `import-global-nps.mjs` | `nps_responses` | Manual CLI | Quarterly |
| Sales Budget | `sync-sales-budget-2026-v2.mjs` | `pipeline_deals`, `quote_tracking` | Manual CLI | On file change |
| News Intelligence | RSS/scrape/tender fetchers | `news_articles`, `tender_opportunities` | Cron API | Daily |
| Support Cases | External API | `support_case_details` | Semi-manual | As needed |

## Automation Status

### Fully Automated
- **BURC Excel Sync** — launchd every 1 hour (`scripts/launchd/com.altera.burc-sync.plist`)
- **News Intelligence** — Daily cron via external scheduler
- **Knowledge Graph** — Daily cron (`/api/cron/graph-embed`)
- **Sentiment Analysis** — Daily cron (`/api/cron/sentiment-snapshot`)
- **User Digests** — Morning cron (`/api/cron/daily-digest`)

### Semi-Automated
- **Activity Register** — Manual CLI trigger; API callable but not scheduled
- **Sales Budget** — Manual trigger when file updated
- **Compliance Sync** — Triggered on activity creation; no separate schedule

### Manual
- **NPS Imports** — Manual trigger after quarterly survey closes
- **Support Cases** — Manual entry or external ticketing sync
- **Invoice Data** — Skeleton script only (`scripts/api-invoice-sync.mjs`)
- **Client Name Aliases** — Manual data entry in admin UI

## Netlify Constraints

Production (Netlify) **cannot** sync Excel data:
- `POST /api/analytics/burc/sync` returns last sync info from DB only
- Local dev: spawns child process (timeout: 55s)
- All Excel-based imports require developer's local machine

## Launchd Configuration

**Plist**: `scripts/launchd/com.altera.burc-sync.plist`
- **Interval**: 3600 seconds (1 hour)
- **Entry point**: `sync-burc-data-supabase.mjs`
- **Logs**: `/tmp/burc-sync.log` (stdout), `/tmp/burc-sync-error.log` (stderr)
- **Working directory**: App root (enables relative paths)

## Script Execution Pattern

```bash
# Always run from the v2 directory
cd apac-intelligence-v2/
node scripts/sync-burc-data-supabase.mjs

# Environment loaded from parent
dotenv.config({ path: path.join(__dirname, '..', '.env.local') })
```

## Cron API Routes

| Route | Method | Purpose | Schedule |
|-------|--------|---------|----------|
| `/api/cron/news-fetch` | GET | Fetch news from RSS/scrape/tender | Daily |
| `/api/cron/graph-embed` | POST | Sync knowledge graph | Daily |
| `/api/cron/sentiment-snapshot` | GET | Daily sentiment analysis | Daily |
| `/api/cron/daily-digest` | GET | User digest generation | Morning |
| `/api/cron/predictive-forecast` | GET | Health prediction run | Daily |
| `/api/cron/portfolio-patterns` | GET | Cross-client pattern detection | Weekly |
| `/api/cron/autopilot-evaluate` | GET | Autopilot rule evaluation | Daily |
| `/api/cron/recognition-detect` | GET | Recognition opportunity detection | Weekly |
| `/api/cron/task-worker` | GET | Process pending AI tasks | On-demand |
| `/api/cron/ms-graph-sync` | GET | MS Graph user/role sync | Daily 2 AM |
