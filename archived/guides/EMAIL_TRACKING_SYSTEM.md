# Email Tracking System

## Overview

The email tracking system provides comprehensive analytics for all emails sent through the APAC Intelligence platform. It tracks opens, clicks, device information, geographic data, and provides detailed performance metrics.

## Architecture

### Database Tables

#### `email_sends`
Stores a record for each email sent with delivery status and metadata.

**Key Columns:**
- `id` - Unique identifier
- `tracking_id` - Unique tracking ID for URLs
- `email_type` - Type of email (weekly_digest, action_reminder, etc.)
- `subject` - Email subject line
- `recipient_email` - Recipient's email address
- `recipient_role` - Role (cse, client, admin, etc.)
- `client_name` - Associated client
- `cse_name` - Associated CSE
- `sent_at` - Timestamp when email was sent
- `delivery_status` - Status (sent, delivered, bounced, failed)
- `provider_message_id` - External provider's message ID
- `metadata` - JSONB field for additional data

#### `email_events`
Tracks all interaction events (opens, clicks, bounces, etc.)

**Key Columns:**
- `id` - Unique identifier
- `email_send_id` - Foreign key to email_sends
- `tracking_id` - Tracking ID (denormalised for performance)
- `event_type` - Type of event (open, click, bounce, etc.)
- `event_timestamp` - When the event occurred
- `clicked_url` - Original URL clicked (for click events)
- `link_identifier` - Identifier for the link
- `user_agent` - Browser user agent string
- `device_type` - Device type (desktop, mobile, tablet)
- `browser` - Browser name
- `operating_system` - OS name
- `country`, `region`, `city` - Geographic data

#### `email_analytics_summary` (Materialized View)
Pre-aggregated analytics for fast dashboard queries.

**Refresh:**
```sql
-- Refresh the materialized view
SELECT refresh_email_analytics_summary();
```

**Schedule:** Should be refreshed periodically (e.g., hourly) via cron job.

### API Endpoints

#### `GET /api/emails/track`

**Parameters:**
- `id` (required) - Tracking ID
- `event` (required) - Event type ('open' or 'click')
- `url` (for clicks) - Target URL to redirect to
- `link` (optional) - Link identifier

**Responses:**

1. **Open Event**
   - Returns: 1x1 transparent PNG pixel
   - Status: 200
   - Headers: No-cache directives

2. **Click Event**
   - Returns: 302 redirect to target URL
   - Records click event asynchronously
   - Validates and sanitises URL

**Rate Limiting:**
- 100 requests per minute per IP address
- Returns 429 with Retry-After header when exceeded

**Security:**
- Validates tracking ID format
- Sanitises URLs (only http/https protocols)
- Prevents open redirects

## Usage

### 1. Recording an Email Send

```typescript
import { recordEmailSend } from '@/lib/emails/tracking';

const result = await recordEmailSend({
  email_type: 'weekly_digest',
  subject: 'Your Weekly Client Summary',
  recipient_email: 'user@example.com',
  recipient_name: 'John Smith',
  recipient_role: 'cse',
  client_name: 'ABC Hospital',
  cse_name: 'Jane Doe',
  template_version: 'v2.0',
  metadata: {
    additional: 'data'
  }
});

if (result.success) {
  console.log('Email recorded with tracking ID:', result.tracking_id);
}
```

### 2. Generating Tracking Pixel

```typescript
import { generateTrackingPixelUrl, TrackingConfig } from '@/lib/emails/tracking';

const config: TrackingConfig = {
  baseUrl: 'https://yourdomain.com',
  trackingEndpoint: '/api/emails/track' // Optional, defaults to this
};

const pixelUrl = generateTrackingPixelUrl(trackingId, config);

// In your email HTML:
// <img src="${pixelUrl}" width="1" height="1" alt="" />
```

### 3. Generating Tracked Links

```typescript
import { generateTrackedLinkUrl } from '@/lib/emails/tracking';

const trackedUrl = generateTrackedLinkUrl(
  'https://yourdomain.com/actions/123',
  trackingId,
  'view_action_button', // Link identifier
  config
);

// In your email HTML:
// <a href="${trackedUrl}">View Action</a>
```

### 4. Adding UTM Parameters

```typescript
import { generateUTMParams, appendUTMParams } from '@/lib/emails/tracking';

const utmParams = generateUTMParams(
  'weekly_digest',
  { role: 'cse', client_name: 'ABC Hospital' }
);

const urlWithUTM = appendUTMParams(
  'https://yourdomain.com/dashboard',
  utmParams
);

// Result: https://yourdomain.com/dashboard?utm_source=apac-intelligence&utm_medium=email&utm_campaign=weekly_digest&utm_content=cse&utm_term=abc-hospital
```

### 5. Fetching Analytics with React Hook

```typescript
import { useEmailAnalytics } from '@/hooks/useEmailAnalytics';

function EmailAnalyticsDashboard() {
  const {
    loading,
    error,
    performanceMetrics,
    deviceStats,
    browserStats,
    geographicStats,
    performanceByType,
    refresh
  } = useEmailAnalytics({
    emailType: 'weekly_digest', // Optional filter
    daysBack: 30 // Last 30 days
  });

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <div>
      <h2>Email Performance</h2>
      <p>Open Rate: {performanceMetrics.openRate}%</p>
      <p>Click Rate: {performanceMetrics.clickRate}%</p>
      <p>Total Sent: {performanceMetrics.totalSent}</p>

      <h3>Device Breakdown</h3>
      {deviceStats.map(stat => (
        <div key={stat.device_type}>
          {stat.device_type}: {stat.percentage}%
        </div>
      ))}

      <button onClick={refresh}>Refresh</button>
    </div>
  );
}
```

### 6. Fetching Individual Email Details

```typescript
import { useEmailDetail } from '@/hooks/useEmailAnalytics';

function EmailDetailView({ trackingId }: { trackingId: string }) {
  const { loading, error, email, events, refresh } = useEmailDetail(trackingId);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;
  if (!email) return <div>Email not found</div>;

  return (
    <div>
      <h2>Email Details</h2>
      <p>Subject: {email.subject}</p>
      <p>Sent to: {email.recipient_email}</p>
      <p>Sent at: {new Date(email.sent_at).toLocaleDateString()}</p>
      <p>Opened: {email.opened ? 'Yes' : 'No'}</p>
      <p>Clicked: {email.clicked ? 'Yes' : 'No'}</p>

      <h3>Events ({events.length})</h3>
      {events.map(event => (
        <div key={event.id}>
          {event.event_type} at {new Date(event.event_timestamp).toLocaleString()}
          {event.device_type && ` (${event.device_type})`}
        </div>
      ))}
    </div>
  );
}
```

## Email Template Integration

### Example: Adding Tracking to Email Templates

```typescript
import {
  generateTrackingPixelUrl,
  generateTrackedLinkUrl,
  generateUTMParams,
  appendUTMParams,
  recordEmailSend
} from '@/lib/emails/tracking';

async function sendWeeklyDigest(recipientEmail: string, cseName: string) {
  // 1. Record the email send
  const { success, tracking_id } = await recordEmailSend({
    email_type: 'weekly_digest',
    subject: 'Your Weekly Summary',
    recipient_email: recipientEmail,
    recipient_role: 'cse',
    cse_name: cseName
  });

  if (!success || !tracking_id) {
    throw new Error('Failed to record email send');
  }

  // 2. Generate tracking URLs
  const config = {
    baseUrl: process.env.NEXT_PUBLIC_APP_URL!,
  };

  const trackingPixel = generateTrackingPixelUrl(tracking_id, config);

  // 3. Generate UTM parameters
  const utmParams = generateUTMParams('weekly_digest', { role: 'cse' });

  // 4. Create tracked links
  const dashboardUrl = appendUTMParams(
    'https://yourdomain.com/dashboard',
    utmParams
  );

  const trackedDashboardUrl = generateTrackedLinkUrl(
    dashboardUrl,
    tracking_id,
    'dashboard_link',
    config
  );

  const actionsUrl = appendUTMParams(
    'https://yourdomain.com/actions',
    utmParams
  );

  const trackedActionsUrl = generateTrackedLinkUrl(
    actionsUrl,
    tracking_id,
    'actions_link',
    config
  );

  // 5. Build email HTML with tracking
  const emailHtml = `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <title>Your Weekly Summary</title>
      </head>
      <body>
        <h1>Weekly Summary</h1>
        <p>Hello ${cseName},</p>
        <p>Here's your weekly summary...</p>

        <a href="${trackedDashboardUrl}">View Dashboard</a>
        <br>
        <a href="${trackedActionsUrl}">View Actions</a>

        <!-- Tracking pixel (must be at the end) -->
        <img src="${trackingPixel}" width="1" height="1" alt="" style="display:none;" />
      </body>
    </html>
  `;

  // 6. Send email via your provider (SendGrid, etc.)
  await sendEmailViaProvider(recipientEmail, 'Your Weekly Summary', emailHtml);

  return { tracking_id };
}
```

## Analytics Queries

### Get Performance by Email Type

```sql
SELECT * FROM get_email_performance_by_type('weekly_digest', 30);
```

### Get Recent Sends with Engagement

```sql
SELECT
  es.id,
  es.subject,
  es.recipient_email,
  es.sent_at,
  COUNT(DISTINCT CASE WHEN ee.event_type = 'open' THEN ee.id END) as opens,
  COUNT(DISTINCT CASE WHEN ee.event_type = 'click' THEN ee.id END) as clicks
FROM email_sends es
LEFT JOIN email_events ee ON es.id = ee.email_send_id
WHERE es.sent_at >= NOW() - INTERVAL '7 days'
GROUP BY es.id, es.subject, es.recipient_email, es.sent_at
ORDER BY es.sent_at DESC;
```

### Get Click Heatmap (Most Clicked Links)

```sql
SELECT
  clicked_url,
  link_identifier,
  COUNT(*) as click_count,
  COUNT(DISTINCT email_send_id) as unique_emails
FROM email_events
WHERE event_type = 'click'
  AND event_timestamp >= NOW() - INTERVAL '30 days'
GROUP BY clicked_url, link_identifier
ORDER BY click_count DESC
LIMIT 20;
```

## Maintenance

### Cleanup Old Data (GDPR Compliance)

```sql
-- Delete data older than 365 days
SELECT * FROM cleanup_old_email_tracking_data(365);
```

### Refresh Analytics View

```sql
-- Refresh materialized view
SELECT refresh_email_analytics_summary();
```

**Recommended Schedule:**
- Refresh materialized view: Every hour
- Cleanup old data: Monthly

### Create Cron Jobs

Add to your cron jobs:

```typescript
// /api/cron/email-analytics/route.ts
import { NextResponse } from 'next/server';
import { getServiceSupabase } from '@/lib/supabase';

export async function GET() {
  try {
    const supabase = getServiceSupabase();

    // Refresh materialized view
    await supabase.rpc('refresh_email_analytics_summary');

    return NextResponse.json({
      success: true,
      message: 'Email analytics refreshed'
    });
  } catch (error) {
    return NextResponse.json(
      { error: 'Failed to refresh analytics' },
      { status: 500 }
    );
  }
}
```

## Security Considerations

1. **Rate Limiting**: The tracking endpoint implements rate limiting to prevent abuse
2. **URL Validation**: All redirect URLs are validated and sanitised
3. **RLS Policies**: Database has Row Level Security enabled
4. **Anonymous Access**: Only tracking endpoints allow anonymous access
5. **No PII in URLs**: Never include sensitive data in tracking URLs

## Performance Optimisation

1. **Materialized View**: Pre-aggregated analytics reduce query time
2. **Indexes**: Comprehensive indexes on commonly queried fields
3. **Async Recording**: Events are recorded asynchronously to not block responses
4. **Caching**: Use materialized view for dashboard queries
5. **Denormalisation**: Tracking ID is denormalised in events table for faster lookups

## Troubleshooting

### Email Opens Not Tracking

1. Check if recipient's email client loads images
2. Verify tracking pixel URL is correct
3. Check browser console for errors
4. Verify RLS policies allow anonymous access

### Clicks Not Recording

1. Verify URL encoding is correct
2. Check that redirect URL is valid (http/https only)
3. Review rate limiting - may be blocking requests
4. Check email_events table for errors

### Low Open Rates

1. Check spam folder placement
2. Verify email authentication (SPF, DKIM, DMARC)
3. Review subject lines and sender name
4. Check device types - some email clients don't load images

## Best Practices

1. **Always include tracking pixel** in email templates
2. **Use meaningful link identifiers** for better analytics
3. **Add UTM parameters** to all links for attribution
4. **Refresh materialized view regularly** for up-to-date dashboard
5. **Monitor bounce rates** and clean email lists
6. **Test emails** in multiple clients before sending
7. **Respect privacy** - comply with GDPR/privacy laws
8. **Document email types** - maintain consistent naming

## Future Enhancements

- [ ] A/B testing support
- [ ] Automated email warmup
- [ ] Predictive send time optimisation
- [ ] Advanced segmentation based on engagement
- [ ] Email client fingerprinting
- [ ] Spam score prediction
- [ ] Deliverability monitoring
- [ ] Engagement scoring
- [ ] Automated follow-ups based on engagement
- [ ] Integration with email service providers (SendGrid, Mailgun, etc.)

## Related Documentation

- [Email Templates](./EMAIL_TEMPLATES.md)
- [Database Schema](../database-schema.md)
- [API Documentation](../API.md)
- [Analytics Dashboard](./ANALYTICS_DASHBOARD.md)
