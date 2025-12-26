# Email Tracking Quick Start Guide

## Setup

### 1. Run Database Migration

Execute the migration to create the tracking tables:

```bash
# Connect to your Supabase project and run:
psql $DATABASE_URL < docs/migrations/20251224_email_tracking.sql
```

Or via Supabase Dashboard:
1. Go to SQL Editor
2. Copy contents of `docs/migrations/20251224_email_tracking.sql`
3. Click "Run"

### 2. Install Dependencies

Already installed if you're using this project. The system uses:
- `ua-parser-js` - For parsing user agent strings
- `@supabase/supabase-js` - For database access

### 3. Environment Variables

Ensure these are set in your `.env.local`:

```bash
NEXT_PUBLIC_APP_URL=https://yourdomain.com
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

## Basic Usage

### Send a Tracked Email

```typescript
import { recordEmailSend, generateTrackingPixelUrl, generateTrackedLinkUrl } from '@/lib/emails/tracking';

async function sendEmail() {
  // 1. Record the email
  const { success, tracking_id } = await recordEmailSend({
    email_type: 'weekly_digest',
    subject: 'Your Weekly Update',
    recipient_email: 'user@example.com',
    recipient_name: 'John Doe',
    recipient_role: 'cse',
    cse_name: 'John Doe'
  });

  if (!success) {
    throw new Error('Failed to record email');
  }

  // 2. Generate tracking URLs
  const config = {
    baseUrl: process.env.NEXT_PUBLIC_APP_URL!
  };

  const pixelUrl = generateTrackingPixelUrl(tracking_id, config);
  const actionLinkUrl = generateTrackedLinkUrl(
    'https://yourdomain.com/actions',
    tracking_id,
    'view_actions',
    config
  );

  // 3. Build email HTML
  const html = `
    <html>
      <body>
        <h1>Your Weekly Update</h1>
        <p>Hello John,</p>
        <a href="${actionLinkUrl}">View Your Actions</a>
        <img src="${pixelUrl}" width="1" height="1" alt="" />
      </body>
    </html>
  `;

  // 4. Send via your email provider
  // await sendWithProvider(recipientEmail, subject, html);

  return tracking_id;
}
```

### View Analytics

```typescript
'use client';

import { useEmailAnalytics } from '@/hooks/useEmailAnalytics';

export default function EmailAnalytics() {
  const { performanceMetrics, loading } = useEmailAnalytics({
    daysBack: 7
  });

  if (loading) return <div>Loading...</div>;

  return (
    <div>
      <h1>Email Performance (Last 7 Days)</h1>
      <div>
        <p>Total Sent: {performanceMetrics.totalSent}</p>
        <p>Open Rate: {performanceMetrics.openRate}%</p>
        <p>Click Rate: {performanceMetrics.clickRate}%</p>
        <p>Bounce Rate: {performanceMetrics.bounceRate}%</p>
      </div>
    </div>
  );
}
```

## Testing

### Test the Tracking Pixel

1. Open browser to: `http://localhost:3000/api/emails/track?id=test123&event=open`
2. Should return a 1x1 transparent PNG
3. Check `email_events` table for the record

### Test Click Tracking

1. Visit: `http://localhost:3000/api/emails/track?id=test123&event=click&url=https://google.com`
2. Should redirect to Google
3. Check `email_events` table for click record

## Common Patterns

### Pattern 1: Weekly Digest Email

```typescript
import { recordEmailSend } from '@/lib/emails/tracking';

async function sendWeeklyDigest(cseName: string, clientData: any[]) {
  const { tracking_id } = await recordEmailSend({
    email_type: 'weekly_digest',
    subject: `Weekly Summary - ${new Date().toLocaleDateString()}`,
    recipient_email: 'cse@example.com',
    recipient_name: cseName,
    recipient_role: 'cse',
    cse_name: cseName,
    metadata: {
      client_count: clientData.length,
      week_ending: new Date().toISOString()
    }
  });

  // Generate email with tracking...
}
```

### Pattern 2: Action Reminder

```typescript
async function sendActionReminder(actionId: string, ownerEmail: string) {
  const { tracking_id } = await recordEmailSend({
    email_type: 'action_reminder',
    subject: 'Action Due Soon',
    recipient_email: ownerEmail,
    recipient_role: 'cse',
    metadata: {
      action_id: actionId,
      reminder_type: 'due_soon'
    }
  });

  // Generate email with tracking...
}
```

### Pattern 3: Health Status Alert

```typescript
async function sendHealthAlert(clientName: string, cseEmail: string) {
  const { tracking_id } = await recordEmailSend({
    email_type: 'health_alert',
    subject: `Client Health Alert: ${clientName}`,
    recipient_email: cseEmail,
    recipient_role: 'cse',
    client_name: clientName,
    metadata: {
      alert_type: 'status_change',
      severity: 'high'
    }
  });

  // Generate email with tracking...
}
```

## Next Steps

1. **Integrate with Email Provider**: Connect to SendGrid, Mailgun, or your email service
2. **Create Email Templates**: Build reusable templates with tracking built-in
3. **Set Up Cron Jobs**: Schedule regular refresh of analytics
4. **Build Dashboard**: Create visualisations for email performance
5. **Configure Alerts**: Set up notifications for low engagement

## Troubleshooting

**Problem**: Tracking pixel not recording opens
**Solution**: Ensure anonymous access is enabled in RLS policies

**Problem**: Rate limit errors
**Solution**: Increase rate limit in `/api/emails/track/route.ts` or implement Redis-based limiting

**Problem**: Slow analytics queries
**Solution**: Refresh materialized view more frequently

## Support

For detailed documentation, see:
- [Full Email Tracking Documentation](./EMAIL_TRACKING_SYSTEM.md)
- [Database Schema](../database-schema.md)
- [API Reference](../API.md)
