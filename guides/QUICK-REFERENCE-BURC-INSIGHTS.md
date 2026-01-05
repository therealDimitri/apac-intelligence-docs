# Quick Reference: BURC AI Insights Engine

**Last Updated**: 2026-01-05

---

## Overview

The BURC AI Insights Engine automatically analyses financial data and generates actionable insights with natural language explanations and recommendations.

---

## Key Features

### 1. Automatic Insight Generation
- Analyses revenue, retention, PS, collections, and comprehensive metrics
- Detects anomalies using statistical methods (Z-score analysis)
- Identifies trends with linear regression
- Generates natural language descriptions
- Assigns severity levels and confidence scores

### 2. Insight Types

| Type | Description | Example |
|------|-------------|---------|
| **Revenue** | Revenue growth/decline analysis | "Revenue grew 12% driven by Maintenance" |
| **Retention** | NRR/GRR trends and churn | "NRR declined 3% - 2 clients reduced ARR" |
| **Risk** | Attrition, over-utilisation warnings | "3 contracts renewing with low NPS" |
| **Opportunity** | Capacity, expansion possibilities | "PS utilisation at 85% - room for 2 projects" |
| **Trend** | Long-term pattern identification | "Collections improved 8 days YoY" |
| **Anomaly** | Unusual metric deviations | "Revenue spike 45% above expected" |
| **Correlation** | Cross-metric relationships | "High NRR correlates with PS satisfaction" |

### 3. Categories

- **Revenue**: Total revenue, ARR, Maintenance, PS revenue
- **Retention**: NRR, GRR, churn analysis
- **Risk**: Attrition, contract renewals, client health
- **Opportunity**: Expansion, capacity, new business
- **Operations**: PS utilisation, project margins, resource planning
- **Collections**: DSO, aging accounts, payment patterns
- **PS Margins**: Project profitability, cost management

### 4. Severity Levels

| Severity | Color | Criteria | Action Required |
|----------|-------|----------|-----------------|
| 🔴 **Critical** | Red | Revenue drop >10%, NRR <95%, Attrition >$2M | Immediate |
| 🟠 **High** | Orange | Revenue drop 5-10%, NRR 95-100%, DSO +10 days | Within 24h |
| 🟡 **Medium** | Amber | Moderate changes, utilisation issues | Within 1 week |
| 🔵 **Low** | Blue | Minor trends, monitoring needed | Review monthly |
| ⚪ **Info** | Grey | Positive developments, FYI | None required |

---

## Using the Dashboard Widget

**Location**: Dashboard → Data Insights Section

**Features**:
- Shows top 3 unacknowledged insights
- Displays critical/high severity counts
- Auto-refreshes every 5 minutes
- Click insight for details
- Links to full financials page

**Actions**:
- View full details → Click on insight
- See all insights → Click "View All"
- Dismiss insight → Click X icon

---

## Using the Full Panel

**Location**: Financials → BURC Insights (or dedicated page)

**Filters**:
- **Category**: Revenue, Retention, Risk, Opportunity, etc.
- **Severity**: Critical, High, Medium, Low, Info
- **Acknowledged**: Show/hide acknowledged insights

**Actions**:
- **Refresh**: Reload latest insights
- **Generate New**: Create fresh insights from current data
- **Acknowledge**: Mark insight as reviewed
- **Dismiss**: Remove insight from view

**Use Cases**:
- Weekly financial review: Filter by Critical + High
- Monthly operations review: Filter by Operations category
- Quarterly planning: Review all Opportunity insights
- Risk management: Filter by Risk category

---

## ChaSen AI Integration

### Query Examples

**Show Insights**:
```
"Show BURC insights"
"What are the latest financial insights?"
"Any AI insights about our finances?"
```

**Explanatory Queries**:
```
"Why did NRR drop this month?"
"What caused the revenue decline?"
"Explain the revenue trend"
```

**Category-Specific**:
```
"Show revenue insights"
"What are the retention risks?"
"Any opportunities in the pipeline?"
```

**ChaSen Response Format**:
```
🤖 AI-Generated BURC Insights

1. 🔴 NRR declined 3% - 2 clients reduced ARR significantly
   Net Revenue Retention dropped from 101% to 98%...
   💡 Recommended Action: Conduct retention interviews with affected clients

2. 🟠 Collections deteriorated 12 days this quarter
   DSO increased from 45 to 57 days...
   💡 Recommended Action: Review AR aging and follow up on overdue invoices
```

---

## API Usage

### Get Insights

```bash
# Get all unacknowledged insights
GET /api/burc/insights?acknowledged=false

# Filter by category
GET /api/burc/insights?category=revenue

# Filter by severity
GET /api/burc/insights?severity=critical

# Combine filters
GET /api/burc/insights?category=risk&severity=high&limit=10
```

### Generate New Insights

```bash
# Generate insights (respects 1-hour cache)
POST /api/burc/insights
{
  "scope": "all"
}

# Force regeneration
POST /api/burc/insights
{
  "scope": "all",
  "force": true
}
```

### Acknowledge Insight

```bash
PATCH /api/burc/insights
{
  "id": "uuid-here",
  "acknowledged": true,
  "acknowledged_by": "user@example.com"
}
```

### Delete Expired Insights

```bash
# Delete all expired insights
DELETE /api/burc/insights

# Delete specific insight
DELETE /api/burc/insights?id=uuid-here
```

---

## Insight Structure

### Data Points
Each insight includes supporting data:

```json
{
  "metric": "NRR",
  "current": 98,
  "previous": 101,
  "change": -3,
  "change_pct": -2.97,
  "period": "Dec 2025"
}
```

### Recommendations
Actionable next steps with priorities:

```json
{
  "action": "Conduct retention interviews with affected clients",
  "priority": "critical",
  "impact": "Prevent further downgrades and churn"
}
```

### Metadata
- **Confidence Score**: 0.0-1.0 (AI confidence in insight)
- **Related Metrics**: Array of connected KPIs
- **Tags**: Categorisation labels (e.g., "Q4_2025", "retention")
- **Expires At**: When insight becomes stale

---

## Common Workflows

### 1. Weekly Financial Review
1. Open dashboard
2. Check BURC Insights widget for critical items
3. Click "View All" for full list
4. Filter by Critical + High severity
5. Review each insight and acknowledge
6. Create actions based on recommendations

### 2. Monthly Operations Review
1. Navigate to financials page
2. Open BURC Insights panel
3. Filter by Operations category
4. Review PS utilisation insights
5. Check capacity planning recommendations
6. Update resource allocation plans

### 3. Quarterly Planning
1. Generate fresh insights (force refresh)
2. Filter by Opportunity + Info
3. Review expansion possibilities
4. Identify growth trends
5. Plan Q2 initiatives based on insights

### 4. Risk Management
1. Filter by Risk + Critical/High
2. Review attrition warnings
3. Check contract renewal insights
4. Prioritise retention actions
5. Monitor NRR/GRR trends

---

## Troubleshooting

### No Insights Displayed

**Possible Causes**:
- All insights acknowledged → Uncheck "Show Acknowledged"
- Filters too restrictive → Reset to "All Categories" / "All Severities"
- No data in period → Generate new insights
- BURC sync not completed → Check sync status

### Insights Not Updating

**Solutions**:
1. Click "Refresh" button
2. Generate new insights (POST to API)
3. Check BURC data sync status
4. Verify last sync completed successfully

### Low Confidence Scores

**Reasons**:
- Limited historical data (< 6 months)
- High data volatility
- Missing metrics in period
- Seasonal variations

**Mitigation**:
- Wait for more data accumulation
- Review underlying data quality
- Consider context when acting on low-confidence insights

---

## Best Practices

### 1. Regular Review Cadence
- **Daily**: Check critical insights
- **Weekly**: Review all unacknowledged
- **Monthly**: Generate fresh insights
- **Quarterly**: Comprehensive review of all categories

### 2. Action Tracking
- Acknowledge after reviewing
- Create actions for high-priority recommendations
- Link insights to priority matrix items
- Track outcomes of actions taken

### 3. Team Communication
- Share critical insights in team meetings
- Use ChaSen to explain insights to stakeholders
- Reference insights in client reviews
- Document lessons learned

### 4. Continuous Improvement
- Provide feedback on insight accuracy
- Suggest new insight types
- Report false positives
- Request custom thresholds

---

## Integration Points

### With ChaSen AI
- Conversational queries about insights
- Natural language explanations
- Context-aware responses
- Recommendation elaboration

### With Priority Matrix
- Convert high-priority recommendations to matrix items
- Link insights to existing actions
- Track mitigation progress
- Monitor risk resolution

### With Client Health
- Client-specific insights (future)
- Health score correlation
- NPS impact analysis
- Retention prediction

### With Alerts System
- Trigger notifications for critical insights (future)
- Email digests of new insights
- Slack integration for urgent items
- Mobile push notifications

---

## Performance Tips

### 1. Filtering
Use filters to focus on relevant insights:
- Start with Critical/High severity
- Filter by current sprint focus (e.g., Collections)
- Hide acknowledged to see new items

### 2. Batch Actions
- Review and acknowledge in batches
- Generate insights during off-peak hours
- Use API for bulk operations

### 3. Caching
- Widget auto-refreshes every 5 minutes
- API respects 1-hour cache unless `force=true`
- Manual refresh available anytime

---

## Database Tables

### `burc_generated_insights`
Main insights storage with columns:
- `id`, `insight_type`, `category`, `severity`
- `title`, `description`
- `data_points`, `recommendations` (JSONB)
- `confidence_score`, `related_metrics`, `tags`
- `generated_at`, `expires_at`
- `acknowledged`, `acknowledged_by`, `acknowledged_at`

### Views
- `burc_insights_active`: Non-expired, unacknowledged
- `burc_insights_summary`: Counts by category/severity

---

## Support

**Questions?**
- Check ChaSen: "How do I use BURC insights?"
- Review documentation: `/docs/bug-reports/BUG-REPORT-20260105-burc-ai-insights-engine.md`
- API reference: OpenAPI spec (if available)

**Issues?**
- Report bugs via issue tracker
- Suggest improvements to product team
- Request new insight types

---

## Version History

- **v1.0** (2026-01-05): Initial release
  - Automatic insight generation
  - Dashboard widget
  - ChaSen integration
  - API endpoints
  - Full panel view

---

**Remember**: Insights are AI-generated guidance, not absolute truth. Always validate critical insights with underlying data and business context before taking major actions.
