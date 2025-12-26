# Slow Query Alert System - Configuration Guide

**Last Updated**: December 2, 2025
**Version**: 1.0.0
**Status**: Production Ready

## Overview

The Slow Query Alert System provides real-time monitoring and notifications for database queries that exceed performance thresholds. It integrates seamlessly with the performance monitoring dashboard and supports multiple notification channels.

## Features

- ✅ **Automatic Detection** - Monitors all queries, alerts on slow execution (>500ms)
- ✅ **Severity Classification** - Warning (500-2000ms) and Critical (>2000ms) levels
- ✅ **Multi-Channel Notifications** - Console, Slack, Email
- ✅ **Alert Throttling** - Prevents notification spam
- ✅ **Daily Summaries** - Aggregated reports for trend analysis
- ✅ **Database Persistence** - Full alert history with analytics

## Architecture

```
┌─────────────────────┐
│  Query Execution    │
└─────────┬───────────┘
          │
          ▼
┌─────────────────────┐
│ Performance Monitor │ (monitors execution time)
└─────────┬───────────┘
          │
          ▼ (if slow_query = true)
┌─────────────────────┐
│  Alert Detection    │ (classifies severity)
└─────────┬───────────┘
          │
          ├──────────────┬──────────────┬──────────────┐
          ▼              ▼              ▼              ▼
    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
    │ Console │    │  Slack  │    │  Email  │    │Database │
    └─────────┘    └─────────┘    └─────────┘    └─────────┘
```

## Configuration

### 1. Alert Thresholds

**File**: `src/lib/slow-query-alerts.ts`

```typescript
export const ALERT_CONFIG = {
  // Thresholds
  SLOW_QUERY_THRESHOLD_MS: 500, // Warning level
  CRITICAL_QUERY_THRESHOLD_MS: 2000, // Critical level

  // Alert frequency (prevent spam)
  MIN_ALERT_INTERVAL_MS: 5 * 60 * 1000, // 5 minutes between alerts

  // ... other config
}
```

**Recommendations**:

- **Development**: 500ms/2000ms (current defaults)
- **Production**: 300ms/1000ms (more aggressive)
- **High-traffic**: 1000ms/3000ms (reduce noise)

### 2. Notification Channels

#### Console Logging (Development)

Always enabled for development and debugging.

```typescript
ENABLE_CONSOLE_ALERTS: true
```

**Output Example**:

```
⚠️ [SLOW QUERY ALERT] WARNING
Query: fetch_client_nps_data
Execution Time: 1250ms
Table: nps_responses
Timestamp: 2025-12-02T10:30:45.123Z
```

#### Slack Webhook (Recommended for Production)

1. **Create Slack Webhook**:
   - Go to https://api.slack.com/apps
   - Create new app → "Incoming Webhooks"
   - Add to your workspace
   - Copy webhook URL

2. **Configure Environment**:

   ```bash
   # .env.local
   NEXT_PUBLIC_SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
   ```

3. **Enable in Code**:
   ```typescript
   ENABLE_WEBHOOK_ALERTS: true
   ```

**Slack Message Format**:

```
🚨 Slow Query Alert - CRITICAL

Query:         fetch_client_nps_data
Execution Time: 2500ms
Table:         nps_responses
Timestamp:     Dec 2, 2025 10:30 AM

View details in the Performance Dashboard
```

#### Email Alerts (Optional)

Requires setting up a Supabase Edge Function or external email service.

1. **Option A: Supabase Edge Function** (Recommended)

   Create file: `supabase/functions/send-alert-email/index.ts`

   ```typescript
   import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
   import { SmtpClient } from 'https://deno.land/x/smtp@v0.7.0/mod.ts'

   serve(async req => {
     const { to, subject, alert } = await req.json()

     const client = new SmtpClient()
     await client.connectTLS({
       hostname: Deno.env.get('SMTP_HOSTNAME')!,
       port: 587,
       username: Deno.env.get('SMTP_USERNAME')!,
       password: Deno.env.get('SMTP_PASSWORD')!,
     })

     await client.send({
       from: 'alerts@alteradigitalhealth.com',
       to,
       subject,
       content: `
         Slow Query Alert
   
         Query: ${alert.query_name}
         Execution Time: ${alert.execution_time_ms}ms
         Severity: ${alert.severity}
         Table: ${alert.table_name || 'N/A'}
         Timestamp: ${alert.timestamp}
   
         View details: ${Deno.env.get('APP_URL')}/performance
       `,
     })

     await client.close()
     return new Response('Email sent', { status: 200 })
   })
   ```

2. **Option B: External Service** (SendGrid, AWS SES, etc.)

   Update `sendEmailAlert()` method in `slow-query-alerts.ts` to use your preferred service.

3. **Configure Environment**:

   ```bash
   ALERT_EMAIL=engineering@alteradigitalhealth.com
   ```

4. **Enable in Code**:
   ```typescript
   ENABLE_EMAIL_ALERTS: true
   ```

### 3. Database Setup

**Deploy Migration**:

```sql
-- Run in Supabase SQL Editor
-- File: docs/migrations/20251202_create_slow_query_alerts_table.sql
```

**Verify Setup**:

```sql
-- Check table exists
SELECT tablename FROM pg_tables WHERE tablename = 'slow_query_alerts';

-- Check indexes (should return 5)
SELECT COUNT(*) FROM pg_indexes
WHERE tablename = 'slow_query_alerts' AND indexname LIKE 'idx_%';

-- Check views (should return 3)
SELECT viewname FROM pg_views
WHERE viewname IN ('recent_critical_alerts', 'alert_summary_by_table', 'daily_alert_summary');
```

## Usage

### Automatic Integration

Alerts are triggered automatically when queries exceed thresholds:

```typescript
// In your query code - no changes needed!
// The performance monitor handles everything automatically

const data = await supabase.from('nps_responses').select('*') // If this takes >500ms, alert is triggered
```

### Manual Alert Triggering

```typescript
import { slowQueryAlerts } from '@/lib/slow-query-alerts'

// Manually trigger alert
await slowQueryAlerts.checkAndAlert({
  timestamp: new Date().toISOString(),
  query_name: 'custom_query',
  query_type: 'SELECT',
  table_name: 'nps_responses',
  execution_time_ms: 1500,
  cache_hit: false,
  user_id: null,
  error_occurred: false,
  error_message: null,
  query_params: null,
  slow_query: true,
})
```

### Generate Daily Summary

```typescript
import { slowQueryAlerts } from '@/lib/slow-query-alerts'

// Generate summary for today
const summary = await slowQueryAlerts.generateDailySummary()

// Send summary via configured channels
await slowQueryAlerts.sendDailySummaryReport(summary)
```

**Summary Output**:

```
📊 [DAILY SUMMARY] Slow Query Report - 2025-12-02
Total Slow Queries: 45
Critical Queries: 3
Avg Time: 850ms
Affected Tables: nps_responses, unified_meetings, actions
Slowest Query: fetch_client_nps_data (2450ms)
```

### Query Alert History

```sql
-- Recent critical alerts (last 24 hours)
SELECT * FROM recent_critical_alerts;

-- Alert summary by table (last 7 days)
SELECT * FROM alert_summary_by_table;

-- Daily alert trends (last 30 days)
SELECT * FROM daily_alert_summary;

-- Get unnotified alerts
SELECT * FROM get_unnotified_alerts('critical', 50);

-- Mark alert as notified
SELECT mark_alert_notified('uuid-here', ARRAY['slack', 'email']);
```

## Alert Workflow

### 1. Real-Time Alerts (Production)

**Critical Queries** (>2000ms):

- Immediate notification to Slack
- Console log
- Database record created
- No throttling - always alert

**Warning Queries** (500-2000ms):

- Throttled notifications (5 min intervals)
- Console log always shown
- Database record created

### 2. Daily Summaries (Scheduled)

Run daily at 9am to provide trend analysis:

```typescript
// In cron job or scheduled task
import { slowQueryAlerts } from '@/lib/slow-query-alerts'

const summary = await slowQueryAlerts.generateDailySummary()
await slowQueryAlerts.sendDailySummaryReport(summary)
```

**Summary includes**:

- Total slow query count
- Critical query count
- Average execution time
- Affected tables
- Slowest query details

### 3. Historical Analysis

Use the Performance Dashboard (`/performance`) to:

- View slow query trends
- Identify problematic tables
- Compare performance over time
- Analyze cache effectiveness

## Monitoring & Maintenance

### Daily Tasks

1. **Review Alert Dashboard** (`/performance`)
   - Check for patterns in slow queries
   - Identify tables needing optimization

2. **Check Slack Notifications**
   - Respond to critical alerts
   - Track alert frequency

### Weekly Tasks

1. **Analyze Trends**

   ```sql
   SELECT * FROM daily_alert_summary
   WHERE date >= CURRENT_DATE - INTERVAL '7 days';
   ```

2. **Identify Top Offenders**

   ```sql
   SELECT * FROM alert_summary_by_table
   ORDER BY total_alerts DESC
   LIMIT 10;
   ```

3. **Adjust Thresholds** if needed
   - Too many alerts? Increase thresholds
   - Missing slow queries? Decrease thresholds

### Monthly Tasks

1. **Database Cleanup**

   ```sql
   -- Clean up old alerts (>90 days)
   SELECT cleanup_old_slow_query_alerts();
   ```

2. **Review Alert Effectiveness**
   - Were alerts actionable?
   - Did they lead to optimizations?
   - Adjust notification channels if needed

## Troubleshooting

### Issue: No Alerts Being Triggered

**Check 1**: Verify alert system is enabled

```typescript
// In src/lib/slow-query-alerts.ts
ENABLE_CONSOLE_ALERTS: true // Should be true
```

**Check 2**: Verify integration with performance monitor

```typescript
// In src/lib/performance-monitor.ts
// Should have slow query alert integration code
```

**Check 3**: Check database table exists

```sql
SELECT * FROM slow_query_alerts LIMIT 1;
```

### Issue: Too Many Alerts (Spam)

**Solution 1**: Increase throttling interval

```typescript
MIN_ALERT_INTERVAL_MS: 10 * 60 * 1000 // 10 minutes instead of 5
```

**Solution 2**: Increase thresholds

```typescript
SLOW_QUERY_THRESHOLD_MS: 1000 // Was 500ms
CRITICAL_QUERY_THRESHOLD_MS: 3000 // Was 2000ms
```

**Solution 3**: Disable warnings, keep critical only

```typescript
// In sendAlert() method, add condition:
if (severity === 'warning') return // Skip warning alerts
```

### Issue: Slack Webhook Not Working

**Check 1**: Verify webhook URL is set

```bash
echo $NEXT_PUBLIC_SLACK_WEBHOOK_URL
```

**Check 2**: Test webhook manually

```bash
curl -X POST $NEXT_PUBLIC_SLACK_WEBHOOK_URL \
  -H 'Content-Type: application/json' \
  -d '{"text":"Test alert from APAC Intelligence Dashboard"}'
```

**Check 3**: Check webhook is enabled

```typescript
ENABLE_WEBHOOK_ALERTS: true
```

### Issue: Performance Impact from Alerting

**Solution**: Alerts are async and non-blocking by design, but if issues persist:

1. **Disable database logging**:

   ```typescript
   // In checkAndAlert() method
   // Comment out: await this.logAlert(alert)
   ```

2. **Reduce notification frequency**:
   ```typescript
   MIN_ALERT_INTERVAL_MS: 15 * 60 * 1000 // 15 minutes
   ```

## Best Practices

### 1. Start Conservative, Tune Over Time

- Begin with default thresholds (500ms/2000ms)
- Monitor for 1 week
- Adjust based on alert volume and usefulness

### 2. Use Different Thresholds Per Environment

```typescript
const isDevelopment = process.env.NODE_ENV === 'development'
const isProduction = process.env.NODE_ENV === 'production'

export const ALERT_CONFIG = {
  SLOW_QUERY_THRESHOLD_MS: isDevelopment ? 500 : 300,
  CRITICAL_QUERY_THRESHOLD_MS: isDevelopment ? 2000 : 1000,
  // ...
}
```

### 3. Regular Optimization Sprints

- Weekly: Fix 1-2 critical queries
- Monthly: Analyze trends, plan optimizations
- Quarterly: Major performance review

### 4. Alert Fatigue Prevention

- Don't alert on every slow query
- Use throttling to batch similar alerts
- Focus on critical alerts for immediate action
- Use daily summaries for trend analysis

## Integration Examples

### Custom Alert Handler

```typescript
import { slowQueryAlerts } from '@/lib/slow-query-alerts'

// Custom handler for specific query
export async function trackExpensiveQuery() {
  const start = performance.now()

  // Your expensive operation
  const result = await someComplexQuery()

  const duration = performance.now() - start

  // Manually trigger alert if needed
  if (duration > 1000) {
    await slowQueryAlerts.checkAndAlert({
      timestamp: new Date().toISOString(),
      query_name: 'expensive_analytics_query',
      query_type: 'SELECT',
      table_name: 'analytics',
      execution_time_ms: duration,
      cache_hit: false,
      user_id: 'system',
      error_occurred: false,
      error_message: null,
      query_params: {
        /* ... */
      },
      slow_query: true,
    })
  }

  return result
}
```

### Scheduled Daily Summary

```typescript
// In a cron job, Edge Function, or scheduled task

export async function sendDailyPerformanceReport() {
  const summary = await slowQueryAlerts.generateDailySummary()

  // Send to Slack
  await slowQueryAlerts.sendDailySummaryReport(summary)

  // Also send to email if critical issues found
  if (summary.critical_queries > 10) {
    // Trigger email alert
    await notifyEngineering(summary)
  }
}

// Schedule: Run daily at 9am
// Vercel Cron: "0 9 * * *"
// Supabase: pg_cron.schedule('daily-summary', '0 9 * * *', 'SELECT ...')
```

## References

- Performance Monitoring: `docs/PERFORMANCE_MONITORING_GUIDE.md` (to be created)
- Migration SQL: `docs/migrations/20251202_create_slow_query_alerts_table.sql`
- Alert System Code: `src/lib/slow-query-alerts.ts`
- Performance Monitor: `src/lib/performance-monitor.ts`
- Dashboard UI: `src/app/(dashboard)/performance/page.tsx`

## Support

For issues or questions:

- GitHub Issues: https://github.com/your-repo/issues
- Slack: #engineering channel
- Email: engineering@alteradigitalhealth.com

---

**Last Updated**: December 2, 2025
**Maintained By**: APAC Engineering Team
