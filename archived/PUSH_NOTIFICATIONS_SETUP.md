# Push Notifications Setup Guide

## Overview

This guide explains how to set up and use push notifications in the APAC Intelligence dashboard. The implementation uses Web Push API with Service Workers for cross-browser support.

## Prerequisites

1. **VAPID Keys**: Generate VAPID (Voluntary Application Server Identification) keys for secure push notifications
2. **HTTPS**: Push notifications require a secure context (HTTPS in production)
3. **Modern Browser**: Chrome, Firefox, Safari, Edge (latest versions)

## Step 1: Generate VAPID Keys

Run the following command to generate VAPID keys:

```bash
npx web-push generate-vapid-keys
```

This will output:

```
Public Key: <public-key>
Private Key: <private-key>
```

## Step 2: Configure Environment Variables

Add the following environment variables to your `.env.local` file:

```env
# VAPID Keys for Push Notifications
NEXT_PUBLIC_VAPID_PUBLIC_KEY=<your-public-key>
VAPID_PRIVATE_KEY=<your-private-key>
VAPID_SUBJECT=mailto:support@apac-intelligence.com
```

**Important**:
- `NEXT_PUBLIC_VAPID_PUBLIC_KEY` must be prefixed with `NEXT_PUBLIC_` to be accessible in the browser
- `VAPID_PRIVATE_KEY` should remain server-side only (no `NEXT_PUBLIC_` prefix)
- `VAPID_SUBJECT` should be a mailto: link or your website URL

## Step 3: Run Database Migration

Execute the migration to create the `push_subscriptions` table:

```bash
npm run migrate
```

Or manually run the migration file:

```bash
psql -h <host> -U <user> -d <database> -f docs/migrations/20260105_push_subscriptions_table.sql
```

## Step 4: Install Dependencies

Install the required npm package:

```bash
npm install
```

This will install `web-push` and its types.

## Architecture

### Files Created

1. **public/sw.js**
   - Service Worker that handles push events
   - Manages notification display and clicks
   - Caches static assets for offline support

2. **src/lib/push-notifications.ts**
   - Utility functions for managing push subscriptions
   - Service worker registration
   - Permission requests

3. **src/hooks/usePushNotifications.ts**
   - React hook for managing notification state
   - Provides subscribe/unsubscribe methods

4. **src/components/NotificationSettings.tsx**
   - UI component for user notification preferences
   - Toggle switch and test notification button

5. **src/app/api/push/subscribe/route.ts**
   - API endpoint to save/delete subscriptions in database

6. **src/app/api/push/send/route.ts**
   - API endpoint to send push notifications to users

7. **docs/migrations/20260105_push_subscriptions_table.sql**
   - Database schema for storing subscriptions

## Usage

### For Users

1. Navigate to Settings or Profile page
2. Locate the Notification Settings component
3. Toggle "Push Notifications" to enable
4. Grant permission when prompted by the browser
5. Click "Send Test" to verify it's working

### For Developers

#### Subscribe a User

```typescript
import { subscribeToPush } from '@/lib/push-notifications';

const subscription = await subscribeToPush('user-id', 'user@example.com');
```

#### Unsubscribe a User

```typescript
import { unsubscribeFromPush } from '@/lib/push-notifications';

await unsubscribeFromPush('user-id');
```

#### Send a Notification (Server-side)

```typescript
// API route or server action
const response = await fetch('/api/push/send', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    userId: 'user-id', // Send to specific user
    notification: {
      title: 'New Message',
      body: 'You have a new message from John',
      icon: '/altera-icon.png',
      badge: '/favicon.png',
      url: '/messages/123',
      tag: 'message-123',
      requireInteraction: false,
    },
  }),
});
```

#### Send to Multiple Users

```typescript
const response = await fetch('/api/push/send', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    userIds: ['user-1', 'user-2', 'user-3'], // Array of user IDs
    notification: {
      title: 'System Update',
      body: 'New features available now',
      url: '/whats-new',
    },
  }),
});
```

#### Send to All Users

```typescript
// Omit userId and userIds to send to all subscribed users
const response = await fetch('/api/push/send', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    notification: {
      title: 'Scheduled Maintenance',
      body: 'System will be down for maintenance at 2am',
      url: '/announcements',
      requireInteraction: true,
    },
  }),
});
```

### Using the React Hook

```tsx
import { usePushNotifications } from '@/hooks/usePushNotifications';

function MyComponent() {
  const {
    isSupported,
    permission,
    isSubscribed,
    isLoading,
    error,
    subscribe,
    unsubscribe,
    sendTest,
  } = usePushNotifications();

  const handleSubscribe = async () => {
    const success = await subscribe('user-id', 'user@example.com');
    if (success) {
      console.log('Subscribed successfully');
    }
  };

  return (
    <div>
      {isSupported && (
        <button onClick={handleSubscribe} disabled={isLoading}>
          {isSubscribed ? 'Unsubscribe' : 'Subscribe'}
        </button>
      )}
    </div>
  );
}
```

## Notification Payload Options

```typescript
interface PushNotificationPayload {
  title: string;                    // Required: Notification title
  body: string;                     // Required: Notification body text
  icon?: string;                    // Optional: Icon URL (default: /altera-icon.png)
  badge?: string;                   // Optional: Badge URL (default: /favicon.png)
  url?: string;                     // Optional: URL to open on click (default: /)
  tag?: string;                     // Optional: Notification tag for grouping
  requireInteraction?: boolean;     // Optional: Keep notification visible until user interacts
  actions?: Array<{                 // Optional: Action buttons
    action: string;
    title: string;
    icon?: string;
  }>;
  data?: Record<string, unknown>;   // Optional: Custom data
}
```

## Database Schema

### push_subscriptions Table

| Column       | Type         | Description                           |
|-------------|--------------|---------------------------------------|
| id          | uuid         | Primary key                           |
| user_id     | text         | User ID (unique)                      |
| user_email  | text         | User email address                    |
| subscription| jsonb        | Web Push subscription object          |
| created_at  | timestamptz  | Creation timestamp                    |
| updated_at  | timestamptz  | Last update timestamp                 |

### Row Level Security

- Users can only view/modify their own subscriptions
- Service role has full access for sending notifications
- Policies ensure data privacy and security

## Browser Support

| Browser         | Supported | Notes                                    |
|----------------|-----------|------------------------------------------|
| Chrome 50+     | Yes       | Full support                             |
| Firefox 44+    | Yes       | Full support                             |
| Safari 16+     | Yes       | Requires user interaction for permission |
| Edge 79+       | Yes       | Full support                             |
| Mobile Safari  | Yes       | iOS 16.4+ with PWA installation          |
| Mobile Chrome  | Yes       | Full support                             |

## Troubleshooting

### Permission Denied

If users deny permission, they must manually enable it in browser settings:

- **Chrome**: Settings > Privacy and Security > Site Settings > Notifications
- **Firefox**: Settings > Privacy & Security > Permissions > Notifications
- **Safari**: Settings > Websites > Notifications

### Service Worker Not Registering

1. Ensure you're on HTTPS (or localhost for development)
2. Check browser console for errors
3. Verify `/sw.js` is accessible at the root
4. Clear browser cache and try again

### Notifications Not Appearing

1. Check if permission is granted
2. Verify VAPID keys are correctly configured
3. Check if subscription exists in database
4. Look for errors in browser console and server logs
5. Test with the "Send Test" button in Notification Settings

### Subscription Failed to Save

1. Verify database migration was successful
2. Check Supabase connection and service role key
3. Review RLS policies on `push_subscriptions` table
4. Check API route logs for specific errors

## Security Considerations

1. **VAPID Keys**: Never commit private keys to version control
2. **HTTPS Required**: Push notifications only work over HTTPS
3. **User Consent**: Always request permission before subscribing
4. **Data Privacy**: Only send relevant notifications to users
5. **Rate Limiting**: Implement rate limiting on send API to prevent abuse

## Best Practices

1. **User Control**: Always provide easy unsubscribe option
2. **Relevant Content**: Only send valuable, timely notifications
3. **Frequency**: Don't overwhelm users with too many notifications
4. **Personalisation**: Customise notifications based on user preferences
5. **Testing**: Always test notifications before sending to all users
6. **Error Handling**: Handle expired subscriptions gracefully
7. **Analytics**: Track notification engagement and adjust strategy

## Integration Examples

### Send Notification on New Action

```typescript
// In your action creation logic
async function createAction(actionData) {
  const action = await saveAction(actionData);

  // Send notification to assigned user
  if (action.assignedTo) {
    await fetch('/api/push/send', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        userId: action.assignedTo,
        notification: {
          title: 'New Action Assigned',
          body: `You've been assigned: ${action.title}`,
          url: `/actions/${action.id}`,
          tag: `action-${action.id}`,
        },
      }),
    });
  }
}
```

### Send Notification on Meeting Reminder

```typescript
// In your scheduled job or cron function
async function sendMeetingReminders() {
  const upcomingMeetings = await getUpcomingMeetings();

  for (const meeting of upcomingMeetings) {
    await fetch('/api/push/send', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        userIds: meeting.attendees,
        notification: {
          title: 'Meeting Reminder',
          body: `${meeting.title} starts in 15 minutes`,
          url: `/meetings/${meeting.id}`,
          requireInteraction: true,
        },
      }),
    });
  }
}
```

## Future Enhancements

1. **Notification Preferences**: Allow users to customise notification types
2. **Quiet Hours**: Respect user's timezone and quiet hours
3. **Rich Notifications**: Add images and action buttons
4. **Notification History**: Store sent notifications for reference
5. **Analytics Dashboard**: Track notification engagement metrics
6. **A/B Testing**: Test different notification formats
7. **Scheduled Notifications**: Queue notifications for future delivery

## Support

For issues or questions about push notifications:
1. Check the troubleshooting section above
2. Review browser console and server logs
3. Verify environment variables are set correctly
4. Test in different browsers to isolate issues

## References

- [Web Push API Documentation](https://developer.mozilla.org/en-US/docs/Web/API/Push_API)
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [Notifications API](https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API)
- [web-push Library](https://github.com/web-push-libs/web-push)
- [VAPID Specification](https://datatracker.ietf.org/doc/html/draft-thomson-webpush-vapid)
