# Feature: ChaSen AI Comprehensive Data Access

**Date:** 27 December 2025
**Type:** Enhancement
**Commit:** `ee23cf6`

## Summary

ChaSen AI now has comprehensive access to all dashboard data through 12 additional data source integrations. This significantly expands ChaSen's knowledge base, enabling it to answer questions about the entire platform.

## New Data Sources

### 1. Aging Accounts (Working Capital)
- **Table:** `aging_accounts`
- **Data:** Current AR data, total outstanding, overdue amounts, bucket breakdowns
- **Context Added:** Working capital summary with top outstanding accounts

### 2. Health Status Alerts
- **Table:** `health_status_alerts`
- **Data:** Unacknowledged client status changes (health score transitions)
- **Context Added:** Recent status changes showing direction and score deltas

### 3. NPS Period Configuration
- **Table:** `nps_period_config`
- **Data:** Survey cycle information, active periods, surveys sent
- **Context Added:** Current and historical NPS survey periods

### 4. NPS Topic Classifications
- **Table:** `nps_topic_classifications`
- **Data:** AI-classified NPS feedback topics with sentiment analysis
- **Context Added:** Aggregated sentiment by topic (positive/negative/neutral rates)

### 5. Tier Requirements
- **Table:** `tier_requirements`
- **Data:** Compliance event requirements by client tier
- **Context Added:** Event requirements grouped by tier (e.g., Tier 1: QBR(4), Check-in(12))

### 6. Portfolio Initiatives
- **Table:** `portfolio_initiatives`
- **Data:** Active client initiatives and projects
- **Context Added:** Current year initiatives with status and category

### 7. Comments/Discussions
- **Table:** `comments`
- **Data:** Team discussions on clients, meetings, and actions
- **Context Added:** Recent 7-day team discussions with snippets

### 8. Notifications
- **Table:** `notifications`
- **Data:** User notifications (unread)
- **Context Added:** Unread notification count and recent items

### 9. Email Logs
- **Table:** `email_logs`
- **Data:** Email activity tracking (sent/failed)
- **Context Added:** 30-day email summary with recent sends

### 10. Webhook Logs
- **Table:** `webhook_logs`
- **Data:** Integration webhook activity
- **Context Added:** Success/failure rates, recent failures

### 11. Aged Accounts History
- **Table:** `aged_accounts_history`
- **Data:** Historical AR snapshots and compliance trends
- **Context Added:** Under-60 and Under-90 compliance trends

### 12. Saved Views
- **Table:** `saved_views`
- **Data:** User-saved dashboard views
- **Context Added:** Available saved views with types

## Previously Existing Data Sources

ChaSen already had access to:
- `client_health_history` - Client health scores and status
- `nps_responses` - Individual NPS survey responses
- `client_segmentation` - Client tiers and CSE assignments
- `unified_meetings` - Meeting records and AI summaries
- `actions` - Open and overdue actions

## Technical Implementation

All data is fetched within the `getLiveDashboardContext()` function in `src/app/api/chasen/stream/route.ts`. Each query includes:
- Appropriate filtering (e.g., unread only, recent timeframes)
- Sensible limits to prevent context overflow
- Error handling for missing/empty tables
- Formatted output with icons and links

## Example Questions ChaSen Can Now Answer

1. "What's our current AR position?"
2. "Which clients have had health status changes?"
3. "When did the Q4 NPS survey run?"
4. "What topics are causing negative sentiment in NPS feedback?"
5. "What compliance events are required for Tier 1 clients?"
6. "What initiatives are active for Epworth?"
7. "What has the team been discussing about SingHealth?"
8. "Do I have any unread notifications?"
9. "How many emails were sent in the last month?"
10. "Are any webhook integrations failing?"
11. "What's the AR compliance trend?"
12. "What saved views do I have available?"

## Impact

- ChaSen now has full visibility across the platform
- Users can ask natural language questions about any dashboard data
- Reduces need to navigate between multiple pages
- Enables comprehensive portfolio analysis in conversations
