/**
 * Example: Sending Push Notifications
 *
 * These examples demonstrate how to send push notifications in various scenarios
 */

// =============================================================================
// Example 1: Send notification to a specific user
// =============================================================================

export async function notifyUserOfNewAction(userId: string, actionTitle: string) {
  try {
    const response = await fetch('/api/push/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        userId: userId,
        notification: {
          title: 'New Action Assigned',
          body: `You've been assigned: ${actionTitle}`,
          icon: '/altera-icon.png',
          badge: '/favicon.png',
          url: '/actions',
          tag: 'new-action',
          requireInteraction: false,
        },
      }),
    });

    if (!response.ok) {
      console.error('Failed to send notification');
      return false;
    }

    const result = await response.json();
    console.log('Notification sent:', result);
    return true;
  } catch (error) {
    console.error('Error sending notification:', error);
    return false;
  }
}

// =============================================================================
// Example 2: Send notification to multiple users
// =============================================================================

export async function notifyTeamOfMeeting(userIds: string[], meetingTitle: string, meetingTime: string) {
  try {
    const response = await fetch('/api/push/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        userIds: userIds,
        notification: {
          title: 'Meeting Reminder',
          body: `${meetingTitle} starts at ${meetingTime}`,
          icon: '/altera-icon.png',
          badge: '/favicon.png',
          url: '/meetings',
          tag: 'meeting-reminder',
          requireInteraction: true, // Keep notification visible
        },
      }),
    });

    const result = await response.json();
    console.log(`Notification sent to ${result.details?.successful} users`);
    return result.details?.successful > 0;
  } catch (error) {
    console.error('Error sending meeting notification:', error);
    return false;
  }
}

// =============================================================================
// Example 3: Send notification to all users
// =============================================================================

export async function broadcastAnnouncement(title: string, message: string) {
  try {
    const response = await fetch('/api/push/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        // No userId or userIds = send to all subscribed users
        notification: {
          title: title,
          body: message,
          icon: '/altera-icon.png',
          badge: '/favicon.png',
          url: '/announcements',
          tag: 'announcement',
          requireInteraction: true,
        },
      }),
    });

    const result = await response.json();
    console.log(`Broadcast sent to ${result.details?.total} users`);
    return result;
  } catch (error) {
    console.error('Error broadcasting announcement:', error);
    return null;
  }
}

// =============================================================================
// Example 4: Send notification with action buttons
// =============================================================================

export async function notifyUserOfApprovalRequest(userId: string, requestTitle: string, requestId: string) {
  try {
    const response = await fetch('/api/push/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        userId: userId,
        notification: {
          title: 'Approval Required',
          body: `Please review: ${requestTitle}`,
          icon: '/altera-icon.png',
          badge: '/favicon.png',
          url: `/approvals/${requestId}`,
          tag: `approval-${requestId}`,
          requireInteraction: true,
          actions: [
            {
              action: 'approve',
              title: 'Approve',
            },
            {
              action: 'view',
              title: 'View Details',
            },
          ],
          data: {
            requestId: requestId,
            type: 'approval',
          },
        },
      }),
    });

    return response.ok;
  } catch (error) {
    console.error('Error sending approval notification:', error);
    return false;
  }
}

// =============================================================================
// Example 5: Send notification from a server action (Next.js)
// =============================================================================

'use server';

export async function sendActionCompleteNotification(userId: string, actionId: string) {
  // This runs on the server, so we can use the full URL
  const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000';

  try {
    const response = await fetch(`${baseUrl}/api/push/send`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        userId: userId,
        notification: {
          title: 'Action Completed',
          body: 'An action you created has been marked as complete',
          url: `/actions/${actionId}`,
          tag: `action-complete-${actionId}`,
        },
      }),
    });

    return response.ok;
  } catch (error) {
    console.error('Error sending server notification:', error);
    return false;
  }
}

// =============================================================================
// Example 6: Schedule notification (pseudo-code for future implementation)
// =============================================================================

export async function scheduleNotification(
  userId: string,
  notification: {
    title: string;
    body: string;
    url?: string;
  },
  scheduledTime: Date
) {
  // This would require a job queue or scheduled task system
  // For example, using Supabase Edge Functions with pg_cron

  console.log('Scheduling notification for:', scheduledTime);

  // Store in database with scheduled_time
  // Then have a cron job that checks for scheduled notifications
  // and sends them at the right time

  // Pseudo-code:
  // await db.scheduledNotifications.insert({
  //   user_id: userId,
  //   notification: notification,
  //   scheduled_time: scheduledTime,
  //   sent: false,
  // });

  return true;
}

// =============================================================================
// Example 7: Send notification with error handling and retry
// =============================================================================

export async function sendNotificationWithRetry(
  userId: string,
  notification: {
    title: string;
    body: string;
    url?: string;
  },
  maxRetries = 3
) {
  let lastError: Error | null = null;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch('/api/push/send', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          userId: userId,
          notification: notification,
        }),
      });

      if (response.ok) {
        console.log(`Notification sent successfully on attempt ${attempt}`);
        return true;
      }

      const error = await response.json();
      lastError = new Error(error.message || 'Unknown error');

      // Wait before retrying (exponential backoff)
      if (attempt < maxRetries) {
        await new Promise(resolve => setTimeout(resolve, Math.pow(2, attempt) * 1000));
      }
    } catch (error) {
      lastError = error as Error;
      console.error(`Attempt ${attempt} failed:`, error);

      if (attempt < maxRetries) {
        await new Promise(resolve => setTimeout(resolve, Math.pow(2, attempt) * 1000));
      }
    }
  }

  console.error('All retry attempts failed:', lastError);
  return false;
}

// =============================================================================
// Example 8: Send notification from webhook
// =============================================================================

export async function handleWebhookNotification(payload: {
  userId: string;
  event: string;
  data: Record<string, unknown>;
}) {
  // Map webhook events to notification content
  const notificationMap: Record<string, { title: string; body: string; url?: string }> = {
    'form.submitted': {
      title: 'New Form Submission',
      body: 'A new form has been submitted and requires review',
      url: '/forms/submissions',
    },
    'comment.mentioned': {
      title: 'You were mentioned',
      body: `Someone mentioned you in a comment`,
      url: '/notifications',
    },
    'report.generated': {
      title: 'Report Ready',
      body: 'Your requested report is ready to view',
      url: '/reports',
    },
  };

  const notification = notificationMap[payload.event];

  if (!notification) {
    console.warn(`No notification mapping for event: ${payload.event}`);
    return false;
  }

  return await fetch('/api/push/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      userId: payload.userId,
      notification: {
        ...notification,
        data: payload.data,
        tag: `webhook-${payload.event}`,
      },
    }),
  }).then(res => res.ok);
}
