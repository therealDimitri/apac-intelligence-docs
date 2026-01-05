# BURC Automated Sync Pipeline - Quick Start Guide

## Overview

The BURC Automated Sync Pipeline provides a complete solution for automatically syncing BURC Excel files to the database with validation, monitoring, and notifications.

## Components

1. **File Watcher** - Detects changes in BURC files automatically
2. **Validation Layer** - Checks data quality before importing
3. **Sync Orchestrator** - Coordinates sync operations with status tracking
4. **API Endpoint** - Provides programmatic access to sync operations
5. **Database Tables** - Tracks sync status, file changes, and validation rules

## Quick Start

### 1. Install & Setup

```bash
# 1. Run database migration
npm run migrate:service-role

# 2. Verify environment variables are set
# Required: NEXT_PUBLIC_SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY
# Optional: SLACK_WEBHOOK_URL, TEAMS_WEBHOOK_URL
```

### 2. Run Your First Sync

```bash
# Option A: Validate data first
npm run burc:validate

# Option B: Trigger a sync manually
npm run burc:sync:all

# Option C: Start automated file watcher
npm run burc:watch
```

## Common Commands

### Validation

```bash
# Validate all BURC files
npm run burc:validate

# Validate specific year
node scripts/burc-validate-sync.mjs --year 2026

# Strict mode (fail on warnings)
node scripts/burc-validate-sync.mjs --strict

# Save report to file
node scripts/burc-validate-sync.mjs --report /tmp/validation.json
```

### Manual Sync

```bash
# Sync all data
npm run burc:sync:all

# Sync monthly data only
npm run burc:sync:monthly

# Sync historical data
npm run burc:sync:historical

# Sync comprehensive (all worksheets)
npm run burc:sync:comprehensive

# Sync specific year
node scripts/burc-sync-orchestrator.mjs --scope all --year 2026

# Skip validation (not recommended)
node scripts/burc-sync-orchestrator.mjs --skip-validation

# Skip notifications
node scripts/burc-sync-orchestrator.mjs --skip-notify
```

### File Watcher

```bash
# Start file watcher (production)
npm run burc:watch

# Test without actually syncing
npm run burc:watch:dry-run

# Custom debounce delay (10 seconds)
node scripts/watch-burc-auto.mjs --debounce 10000

# Custom log file
node scripts/watch-burc-auto.mjs --log-file /path/to/log

# Skip validation and notifications
node scripts/watch-burc-auto.mjs --no-validate --no-notify
```

## Production Deployment

### Using PM2 (Recommended)

```bash
# Install PM2 globally
npm install -g pm2

# Start file watcher as daemon
pm2 start npm --name "burc-watcher" -- run burc:watch

# View logs
pm2 logs burc-watcher

# Monitor status
pm2 monit

# Restart
pm2 restart burc-watcher

# Stop
pm2 stop burc-watcher

# Save config for auto-start on boot
pm2 save
pm2 startup
```

### Using nohup (Alternative)

```bash
# Start in background
nohup npm run burc:watch > logs/burc-watcher-output.log 2>&1 &

# View logs
tail -f logs/burc-watcher.log

# Stop (find PID and kill)
ps aux | grep watch-burc-auto
kill <PID>
```

## API Usage

### Get Sync History

```bash
# Get recent syncs (last 20)
curl http://localhost:3000/api/burc/sync

# Get more records
curl http://localhost:3000/api/burc/sync?limit=50

# Get specific sync
curl http://localhost:3000/api/burc/sync?id=<sync_id>
```

### Get Statistics

```bash
# Get sync stats (last 30 days)
curl http://localhost:3000/api/burc/sync?action=stats

# Get file changes
curl http://localhost:3000/api/burc/sync?action=files
```

### Trigger Manual Sync

```bash
# Basic sync
curl -X POST http://localhost:3000/api/burc/sync \
  -H "Content-Type: application/json" \
  -d '{"scope": "all", "triggeredBy": "admin@example.com"}'

# Sync specific year
curl -X POST http://localhost:3000/api/burc/sync \
  -H "Content-Type: application/json" \
  -d '{
    "scope": "all",
    "year": 2026,
    "skipValidation": false,
    "skipNotify": false,
    "triggeredBy": "admin@example.com"
  }'
```

### Cancel Running Sync

```bash
curl -X DELETE "http://localhost:3000/api/burc/sync?id=<sync_id>"
```

## Monitoring

### Database Queries

```sql
-- View recent syncs
SELECT * FROM burc_sync_recent LIMIT 10;

-- Get sync statistics
SELECT * FROM burc_sync_stats;

-- Check file changes
SELECT * FROM burc_file_changes;

-- Find running syncs
SELECT * FROM burc_sync_status
WHERE status = 'running'
ORDER BY started_at DESC;

-- Get sync success rate
SELECT
  sync_type,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE status = 'completed') as successful,
  ROUND(
    COUNT(*) FILTER (WHERE status = 'completed')::NUMERIC / COUNT(*) * 100,
    2
  ) as success_rate_percent
FROM burc_sync_status
WHERE started_at > NOW() - INTERVAL '7 days'
GROUP BY sync_type;
```

### Log Files

```bash
# Watch file watcher logs
tail -f logs/burc-watcher.log

# Search for errors
grep ERROR logs/burc-watcher.log

# Filter by date
grep "2026-01-05" logs/burc-watcher.log
```

## Troubleshooting

### Sync Keeps Failing

```bash
# 1. Run validation to see what's wrong
npm run burc:validate

# 2. Check sync status in database
# Look at errors and warnings columns

# 3. Try skipping validation if it's a false positive
node scripts/burc-sync-orchestrator.mjs --skip-validation

# 4. Check logs
tail -n 100 logs/burc-watcher.log
```

### File Watcher Not Detecting Changes

```bash
# 1. Check if watcher is running
ps aux | grep watch-burc-auto

# 2. Verify file paths are correct
# Edit scripts/watch-burc-auto.mjs if BURC folder moved

# 3. Check for Excel temp files
# Make sure you're not just opening/closing the file

# 4. Test in dry-run mode
npm run burc:watch:dry-run
# Then modify a file and watch logs
```

### API Returns 409 (Sync Already Running)

```bash
# 1. Check current running sync
curl http://localhost:3000/api/burc/sync

# 2. If it's stuck, cancel it
curl -X DELETE "http://localhost:3000/api/burc/sync?id=<sync_id>"

# 3. Or manually update in database
# UPDATE burc_sync_status
# SET status = 'failed', completed_at = NOW()
# WHERE status = 'running';
```

### Validation Warnings vs Errors

**Errors** (will block sync):
- Negative revenue values
- Missing required fields (fiscal year)
- Invalid data types

**Warnings** (won't block sync):
- Revenue spikes (>2x previous month)
- Unusually high values
- Quarterly totals slightly off (<1%)

To fail on warnings:
```bash
npm run burc:validate -- --strict
```

## Configuration

### Validation Rules

Edit rules in database:

```sql
-- View all rules
SELECT * FROM burc_validation_rules WHERE enabled = TRUE;

-- Change spike threshold
UPDATE burc_validation_rules
SET rule_config = jsonb_set(
  rule_config,
  '{threshold_multiplier}',
  '3.0'
)
WHERE rule_name = 'revenue_spike_detection';

-- Disable a rule
UPDATE burc_validation_rules
SET enabled = FALSE
WHERE rule_name = 'headcount_reasonable_range';

-- Add custom rule
INSERT INTO burc_validation_rules (
  rule_name, rule_type, table_name,
  rule_config, severity, description
) VALUES (
  'custom_check',
  'range',
  'burc_monthly_metrics',
  '{"min": 0, "max": 1000000}',
  'warning',
  'My custom validation rule'
);
```

### Notifications

Set environment variables:

```bash
# Slack
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

# Microsoft Teams
export TEAMS_WEBHOOK_URL="https://outlook.office.com/webhook/YOUR/WEBHOOK/URL"
```

Test notifications:

```bash
# Trigger a sync and check if notification arrives
npm run burc:sync:all
```

## File Structure

```
apac-intelligence-v2/
├── scripts/
│   ├── burc-validate-sync.mjs          # Validation layer
│   ├── burc-sync-orchestrator.mjs      # Sync coordinator
│   └── watch-burc-auto.mjs             # File watcher
├── src/app/api/burc/sync/
│   └── route.ts                        # API endpoints
├── docs/
│   ├── migrations/
│   │   └── 20260105_burc_sync_automation.sql
│   ├── guides/
│   │   └── BURC-AUTOMATED-SYNC-GUIDE.md (this file)
│   └── bug-reports/
│       └── FEATURE-20260105-burc-automated-sync-pipeline.md
└── logs/
    └── burc-watcher.log                # File watcher logs
```

## Performance Expectations

- **Validation**: 2-5 seconds per file
- **Sync (all)**: 20-40 seconds
- **Sync (monthly)**: 5-10 seconds
- **Change detection**: <1 second
- **File watcher CPU**: <1%
- **File watcher RAM**: ~50MB

## Best Practices

1. **Always validate before production sync**
   ```bash
   npm run burc:validate && npm run burc:sync:all
   ```

2. **Monitor sync status regularly**
   ```bash
   curl http://localhost:3000/api/burc/sync?action=stats
   ```

3. **Use PM2 for production file watcher**
   ```bash
   pm2 start npm --name "burc-watcher" -- run burc:watch
   ```

4. **Review validation warnings**
   - Don't ignore warnings - they often indicate real issues
   - Update validation rules if you get too many false positives

5. **Keep logs for audit trail**
   - File watcher logs: `logs/burc-watcher.log`
   - Sync status: `burc_sync_status` table
   - File changes: `burc_file_audit` table

6. **Test in dry-run mode first**
   ```bash
   npm run burc:watch:dry-run
   ```

7. **Set up notifications**
   - Configure Slack or Teams webhooks
   - Get notified immediately when syncs fail

## Support & Documentation

- **Detailed docs**: `/docs/bug-reports/FEATURE-20260105-burc-automated-sync-pipeline.md`
- **Database schema**: `/docs/database-schema.md`
- **Migration file**: `/docs/migrations/20260105_burc_sync_automation.sql`

## Version History

- **v1.0** (2026-01-05): Initial release
  - File watcher with checksum-based change detection
  - Validation layer with 5 default rules
  - Sync orchestrator with status tracking
  - RESTful API endpoints
  - Database tables and views
  - 8 npm scripts for convenience

---

**Questions?** Check the detailed documentation or run with `--help` flag.

**Need help?** Check logs and database sync_status table for errors.
