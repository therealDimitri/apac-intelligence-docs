# BURC Proactive Alerts System - Complete Guide

**Created**: 2026-01-05
**Status**: Enhancement Complete
**Related Feature**: BURC Intelligence Dashboard

---

## Overview

The BURC Proactive Alerts System provides automated, intelligent monitoring of critical business metrics with actionable recommendations. This system proactively identifies risks before they become critical issues, enabling timely intervention and strategic decision-making.

## Alert Types

### 1. NRR Decline Alerts

**Purpose**: Detect significant month-over-month declines in Net Revenue Retention

**Triggers**:
- NRR drops ≥5% month-over-month
- NRR falls below 90% (critical threshold)

**Data Source**: `burc_nrr` table

**Recommended Actions**:
- Analyse churn and contraction drivers
- Review at-risk accounts
- Implement retention strategies
- Schedule leadership review

**Severity Levels**:
- **Critical**: NRR < 90%
- **High**: NRR ≥ 90% but declined ≥5%

---

### 2. Renewal Risk Alerts

**Purpose**: Identify clients approaching renewal with concerning indicators

**Triggers**:
- Contract renewal within 60 days (critical) or 90 days (warning)
- Low engagement: <2 meetings in last 90 days
- Poor health score: <60

**Data Sources**:
- `burc_arr` (contract dates)
- `unified_meetings` (engagement tracking)
- `client_health_history` (health scores)

**Recommended Actions**:
- Schedule renewal QBR immediately
- Prepare value realisation report
- Address any outstanding concerns
- Engage executive sponsors

**Severity Levels**:
- **Critical**: <60 days + (low engagement OR poor health)
- **High**: <60 days
- **Medium**: <90 days with low engagement

---

### 3. Pipeline Gap Alerts

**Purpose**: Alert when pipeline coverage falls below target

**Triggers**:
- Pipeline coverage <3x target (minimum)
- Pipeline coverage <2x target (critical)

**Data Source**: `burc_pipeline` table

**Recommended Actions**:
- Accelerate pipeline development
- Focus on expansion opportunities
- Review pipeline quality
- Schedule pipeline review meeting

**Severity Levels**:
- **Critical**: Coverage <2x
- **High**: Coverage <3x

---

### 4. Revenue Concentration Alerts

**Purpose**: Identify when too much revenue depends on too few clients

**Triggers**:
- Top 3 clients represent ≥40% of revenue (critical)
- Top 3 clients represent ≥30% of revenue (warning)

**Data Source**: `burc_arr` table

**Recommended Actions**:
- Create revenue diversification plan
- Ensure top clients are healthy
- Accelerate new client acquisition
- Expand smaller accounts

**Severity Levels**:
- **Critical**: ≥40% concentration
- **High**: ≥30% concentration

---

### 5. Collections Aging Alerts

**Purpose**: Flag clients with significant overdue amounts

**Triggers**:
- ≥$100K in 90+ day aging buckets
- ≥$200K triggers critical severity

**Data Source**: `aging_accounts` table

**Recommended Actions**:
- Escalate to Finance team
- Schedule payment plan discussion
- Consider service hold if necessary
- Document collection strategy

**Severity Levels**:
- **Critical**: ≥$200K in 90+ days
- **High**: ≥$100K in 90+ days

---

### 6. PS Margin Erosion Alerts

**Purpose**: Alert when Professional Services margins fall below targets

**Triggers**:
- PS margin <20% (warning)
- PS margin <15% (critical)

**Data Source**: `burc_ps_margins` table

**Recommended Actions**:
- Review project scope and pricing
- Identify efficiency opportunities
- Consider rate adjustments
- Analyse cost drivers

**Severity Levels**:
- **Critical**: Margin <15%
- **High**: Margin <20%

---

## System Architecture

### Detection Flow

```
┌─────────────────────────────────────────┐
│   Daily Cron Job (6:00 AM)              │
│   /api/cron/burc-alerts                 │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│   Alert Detection Engine                │
│   /lib/burc-alert-detection.ts          │
│                                          │
│   • detectNRRDecline()                  │
│   • detectRenewalRisks()                │
│   • detectPipelineGap()                 │
│   • detectRevenueConcentration()        │
│   • detectCollectionsIssues()           │
│   • detectPSMarginIssues()              │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│   Alert Persistence Layer               │
│   /lib/alert-system.ts                  │
│                                          │
│   • Deduplication                       │
│   • Database storage                    │
│   • Action creation                     │
└─────────────┬───────────────────────────┘
              │
              ▼
┌─────────────────────────────────────────┐
│   Notification System                   │
│                                          │
│   • In-app notifications                │
│   • Email alerts (optional)             │
│   • User preferences                    │
└─────────────────────────────────────────┘
```

### Database Schema

**Core Tables**:

1. **`alerts`** - Stores all detected alerts
2. **`burc_alert_thresholds`** - Configuration thresholds
3. **`burc_alert_history`** - Historical trends
4. **`user_alert_preferences`** - User notification settings
5. **`alert_acknowledgments`** - Audit trail

### Key Files

| File | Purpose |
|------|---------|
| `/src/lib/burc-alert-detection.ts` | Alert detection logic |
| `/src/lib/alert-system.ts` | Alert persistence and notification |
| `/src/app/api/cron/burc-alerts/route.ts` | Scheduled job |
| `/src/components/alerts/BURCAlertsDashboard.tsx` | UI dashboard |
| `/docs/migrations/20260105_burc_alert_types.sql` | Database schema |

---

## Configuration

### Threshold Configuration

Thresholds are stored in the `burc_alert_thresholds` table and can be customised:

```sql
-- View current thresholds
SELECT * FROM burc_alert_thresholds WHERE is_active = true;

-- Update NRR thresholds
UPDATE burc_alert_thresholds
SET
  nrr_decline_threshold = 7.0,  -- Trigger at 7% decline instead of 5%
  nrr_critical_level = 85.0      -- Critical level at 85% instead of 90%
WHERE is_active = true;
```

### Default Thresholds

| Metric | Warning | Critical |
|--------|---------|----------|
| NRR Decline | 5% MoM | <90% NRR |
| Renewal Risk | 90 days | 60 days |
| Pipeline Coverage | <3x | <2x |
| Revenue Concentration | 30% | 40% |
| Collections Aging | - | $100K in 90+ days |
| PS Margin | 20% | 15% |

---

## Usage

### Viewing Alerts

**Dashboard Access**: Navigate to `/alerts` (BURC-specific view)

**Filtering**:
- By severity: Critical, High, Medium, Low
- By category: NRR, Renewal, Pipeline, etc.
- By status: Active, Acknowledged, Resolved, Dismissed

### Managing Alerts

**Acknowledge**: Mark alert as seen and being handled
**Dismiss**: Mark as not requiring action
**Resolve**: Mark as addressed and resolved

### Notifications

Users can configure notification preferences:

```sql
-- Enable/disable BURC alerts for a user
INSERT INTO user_alert_preferences (
  user_id,
  user_email,
  receive_burc_alerts,
  email_notifications,
  severity_threshold
) VALUES (
  'user-123',
  'user@example.com',
  true,
  true,
  'high'  -- Only notify for high and critical
);
```

---

## Cron Job Setup

### Vercel Cron Configuration

Add to `vercel.json`:

```json
{
  "crons": [
    {
      "path": "/api/cron/burc-alerts",
      "schedule": "0 6 * * *"
    }
  ]
}
```

### Manual Triggering

```bash
# Trigger alert detection manually
curl -X POST https://your-app.vercel.app/api/cron/burc-alerts \
  -H "Authorization: Bearer YOUR_CRON_SECRET"

# Check last run results
curl https://your-app.vercel.app/api/cron/burc-alerts
```

---

## Monitoring and Analytics

### Alert Trends

View historical alert patterns:

```sql
-- Alert volume trends
SELECT
  detection_date,
  total_alerts,
  critical_count,
  high_count,
  actions_created
FROM burc_alert_history
ORDER BY detection_date DESC
LIMIT 30;
```

### Response Metrics

Track how quickly alerts are addressed:

```sql
-- Average response time by category
SELECT * FROM v_alert_response_metrics
ORDER BY alert_date DESC;
```

### Active Alerts Summary

```sql
-- Current active alerts by category
SELECT * FROM v_burc_alerts_summary;
```

---

## Best Practices

### For CSEs

1. **Check alerts daily** - Review BURC alerts dashboard each morning
2. **Prioritise critical alerts** - Address critical alerts within 24 hours
3. **Document actions** - Add notes when acknowledging alerts
4. **Follow recommendations** - Use suggested next steps as a guide

### For Leadership

1. **Review weekly summaries** - Monitor alert trends and patterns
2. **Adjust thresholds** - Fine-tune based on business context
3. **Track response times** - Ensure timely alert handling
4. **Celebrate wins** - Recognise when alerts lead to prevented issues

### For Developers

1. **Monitor cron job** - Ensure daily detection runs successfully
2. **Check error logs** - Review failed detections
3. **Update thresholds** - Adjust based on business feedback
4. **Test new alert types** - Validate before deploying

---

## Troubleshooting

### Common Issues

**Issue**: Alerts not being detected

**Solutions**:
1. Check cron job is running: `SELECT * FROM burc_alert_history ORDER BY detection_date DESC LIMIT 5`
2. Verify data sources exist: Check `burc_nrr`, `burc_arr`, etc.
3. Review threshold configuration
4. Check error logs in cron job response

---

**Issue**: Too many duplicate alerts

**Solutions**:
1. Review fingerprint logic in `/lib/alert-system.ts`
2. Adjust detection frequency
3. Modify deduplication window

---

**Issue**: Notifications not being sent

**Solutions**:
1. Check user preferences: `SELECT * FROM user_alert_preferences`
2. Verify notification table: `SELECT * FROM notifications ORDER BY created_at DESC`
3. Review email service configuration

---

## API Reference

### Get Alerts

```typescript
GET /api/alerts/persisted?status=active&severity=critical&category=nrr_decline

Response:
{
  "alerts": [
    {
      "id": "...",
      "category": "nrr_decline",
      "severity": "critical",
      "title": "NRR Declined 7.2% MoM",
      "description": "...",
      "clientName": "Portfolio-wide",
      "cseName": "CS Leadership",
      "detectedAt": "2026-01-05T06:00:00Z",
      "status": "active",
      "metadata": { ... },
      "actions": [ ... ]
    }
  ],
  "count": 1
}
```

### Acknowledge Alert

```typescript
PATCH /api/alerts/persisted/{alertId}

Body:
{
  "status": "acknowledged",
  "notes": "Meeting scheduled with top 3 clients"
}

Response:
{
  "success": true,
  "alert": { ... }
}
```

### Trigger Manual Detection

```typescript
POST /api/cron/burc-alerts

Response:
{
  "success": true,
  "summary": {
    "alerts_detected": 12,
    "alerts_persisted": 12,
    "new_alerts": 5,
    "duplicates": 7,
    "critical_alerts": 2,
    "high_alerts": 5,
    "medium_alerts": 3,
    "low_alerts": 2
  },
  "duration_ms": 2341
}
```

---

## Performance Considerations

### Optimisation Tips

1. **Use indexes** - Ensure proper indexes on:
   - `alerts.category`
   - `alerts.severity`
   - `alerts.status`
   - `alerts.detected_at`

2. **Batch operations** - Detection runs in parallel for efficiency

3. **Cache thresholds** - Configuration loaded once per detection cycle

4. **Limit history** - Archive old alerts periodically

---

## Future Enhancements

### Planned Features

1. **Machine Learning Integration**
   - Churn prediction scoring
   - Anomaly detection
   - Predictive renewal risk

2. **Advanced Notifications**
   - Slack/Teams integration
   - SMS for critical alerts
   - Custom webhook support

3. **Alert Workflows**
   - Automated action creation
   - Escalation paths
   - SLA tracking

4. **Analytics Dashboard**
   - Alert effectiveness metrics
   - False positive tracking
   - ROI measurement

---

## Support

For questions or issues:

1. Check this guide first
2. Review error logs in Supabase
3. Contact development team
4. Submit GitHub issue

---

## Changelog

### Version 1.0.0 (2026-01-05)

**Added**:
- 7 BURC-specific alert types
- Configurable thresholds system
- Alert dashboard UI
- Daily cron job detection
- User notification preferences
- Historical trend tracking
- Response metrics

**Database**:
- `burc_alert_thresholds` table
- `burc_alert_history` table
- `user_alert_preferences` table
- `alert_acknowledgments` table
- 2 analytical views

**API**:
- `/api/cron/burc-alerts` endpoint
- Enhanced `/api/alerts/persisted` with BURC filters

---

*End of Guide*
