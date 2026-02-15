# BURC Alerts - Quick Reference

**Last Updated**: 2026-01-05

---

## Alert Types at a Glance

| Alert | Trigger | Severity | Action Required |
|-------|---------|----------|-----------------|
| **NRR Decline** | ≥5% MoM drop | Critical/High | Analyse churn, create retention plan |
| **Renewal Risk** | <60 days + low engagement | Critical/High/Medium | Schedule QBR, prepare value report |
| **Pipeline Gap** | Coverage <3x target | Critical/High | Accelerate pipeline development |
| **Revenue Concentration** | Top 3 clients >40% | Critical/High | Diversify revenue base |
| **Collections Aging** | $100K+ in 90+ days | Critical/High | Escalate to finance, payment plan |
| **PS Margin Erosion** | Margin <20% | Critical/High | Review pricing, improve efficiency |

---

## Daily Workflow

### For CSEs

1. **Morning** (9:00 AM)
   - Check BURC Alerts Dashboard
   - Review new critical/high alerts
   - Acknowledge active alerts

2. **Action**
   - Follow recommended next steps
   - Document actions taken
   - Update alert status

3. **End of Day**
   - Close resolved alerts
   - Set follow-ups for next day

### For Leadership

1. **Weekly Review**
   - Check alert trends
   - Review response times
   - Adjust thresholds if needed

2. **Monthly**
   - Analyse alert effectiveness
   - Review false positive rate
   - Plan strategic interventions

---

## Quick Commands

### View Active Alerts

```sql
SELECT * FROM v_burc_alerts_summary;
```

### Check Alert History

```sql
SELECT * FROM burc_alert_history
ORDER BY detection_date DESC
LIMIT 7;
```

### Update Thresholds

```sql
UPDATE burc_alert_thresholds
SET renewal_days_critical = 45
WHERE is_active = true;
```

---

## API Quick Reference

### Get Alerts

```bash
GET /api/alerts/persisted?status=active&severity=critical
```

### Acknowledge Alert

```bash
PATCH /api/alerts/persisted/{alertId}
Body: { "status": "acknowledged" }
```

### Trigger Detection

```bash
POST /api/cron/burc-alerts
Header: Authorization: Bearer ${CRON_SECRET}
```

---

## Severity Guide

| Severity | Response Time | Escalation |
|----------|---------------|------------|
| **Critical** | <4 hours | Immediate to leadership |
| **High** | <24 hours | Within 48 hours |
| **Medium** | <3 days | As needed |
| **Low** | <1 week | Optional |

---

## Common Scenarios

### Scenario: NRR Dropped 6%

**Alert**: NRR Decline - Critical
**Action**:
1. Review churn report
2. Identify lost clients
3. Analyse contraction reasons
4. Schedule leadership meeting
5. Create retention strategy

---

### Scenario: Client Renewal in 45 Days, Only 1 Meeting

**Alert**: Renewal Risk - High
**Action**:
1. Schedule urgent QBR
2. Prepare value realisation report
3. Send renewal outreach email
4. Engage executive sponsor
5. Document concerns

---

### Scenario: $150K Overdue 120+ Days

**Alert**: Collections Aging - Critical
**Action**:
1. Escalate to Finance immediately
2. Schedule client payment discussion
3. Review payment history
4. Create payment plan
5. Consider service hold

---

## Configuration Locations

| Setting | Location |
|---------|----------|
| Alert Thresholds | `burc_alert_thresholds` table |
| User Preferences | `user_alert_preferences` table |
| Cron Schedule | `vercel.json` |
| Detection Logic | `/src/lib/burc-alert-detection.ts` |
| Dashboard UI | `/src/components/alerts/BURCAlertsDashboard.tsx` |

---

## Troubleshooting

### Alerts Not Appearing

1. Check cron job ran: `SELECT * FROM burc_alert_history`
2. Verify data sources exist
3. Review threshold configuration
4. Check error logs

### Too Many Alerts

1. Adjust detection thresholds
2. Review deduplication logic
3. Update user preferences
4. Consider digest mode

### Notifications Not Received

1. Check user preferences
2. Verify email configuration
3. Review notification table
4. Test notification endpoint

---

## Key Metrics to Monitor

1. **Alert Volume** - Total alerts per day
2. **Response Time** - Hours to acknowledgment
3. **Resolution Rate** - % of alerts resolved
4. **False Positive Rate** - % of dismissed alerts
5. **Action Creation** - Auto-actions generated

---

## Best Practices

✅ **DO**:
- Check alerts daily
- Acknowledge within SLA
- Document actions taken
- Follow recommendations
- Update status promptly

❌ **DON'T**:
- Ignore critical alerts
- Dismiss without investigation
- Let alerts pile up
- Skip recommended actions
- Forget to close resolved alerts

---

## Support

**Documentation**: `/docs/guides/BURC-PROACTIVE-ALERTS-GUIDE.md`
**Enhancement Report**: `/docs/bug-reports/ENHANCEMENT-20260105-burc-proactive-alerts.md`
**Migration**: `/docs/migrations/20260105_burc_alert_types.sql`

---

*Quick Reference - Keep this handy!*
