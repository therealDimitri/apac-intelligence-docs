# Feature: @Mention Notification System

**Date:** 17 December 2025
**Status:** Implementation Complete (Requires Supabase Table Creation)
**Related:** FEATURE-20251217-comment-mentions.md

## Overview

Added a notification system to alert users when they are @mentioned in comments on Priority Matrix items.

## Features Implemented

### 1. Notifications API Route

- **Location:** `src/app/api/notifications/route.ts`
- GET: Fetch notifications by user email or userId
- POST: Create new notifications
- PATCH: Mark notifications as read (single or bulk)
- DELETE: Remove notifications (single or all)

### 2. useNotifications Hook

- **Location:** `src/hooks/useNotifications.ts`
- Fetches notifications from API
- Provides unread count for badge display
- Polling for real-time updates (30-second intervals)
- Mark as read functionality
- Delete notifications
- Helper function `createMentionNotification()` for easy notification creation

### 3. NotificationBell Component

- **Location:** `src/components/NotificationBell.tsx`
- Bell icon in sidebar with unread badge
- Dropdown showing notification list
- Notification items with:
  - User avatar or type icon
  - Title and message
  - Relative timestamp
  - Mark as read / Delete actions
- Click to navigate to linked item
- Mark all as read
- Clear all notifications

### 4. MatrixContext Integration

- **Location:** `src/components/priority-matrix/MatrixContext.tsx`
- Updated `addComment()` to trigger notifications for mentions
- Updated `addReply()` to trigger notifications for reply mentions
- Notifications include:
  - Item title for context
  - Comment preview (first 100 characters)
  - Direct link to the item

## Database Setup Required

The notifications table must be created in Supabase. Run the following SQL in the Supabase SQL Editor:

```sql
-- Create notifications table for @mentions and other notifications
CREATE TABLE IF NOT EXISTS notifications (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id text NOT NULL,
  user_email text,
  type text NOT NULL DEFAULT 'mention',
  title text NOT NULL,
  message text NOT NULL,
  link text,
  item_id text,
  comment_id text,
  triggered_by text NOT NULL,
  triggered_by_avatar text,
  read boolean DEFAULT false,
  read_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_email ON notifications(user_email);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Allow all select on notifications"
  ON notifications FOR SELECT USING (true);

CREATE POLICY "Allow all insert on notifications"
  ON notifications FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all update on notifications"
  ON notifications FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow all delete on notifications"
  ON notifications FOR DELETE USING (true);
```

## Notification Types

| Type         | Description                       |
| ------------ | --------------------------------- |
| `mention`    | User was @mentioned in a comment  |
| `reply`      | Someone replied to user's comment |
| `comment`    | New comment on user's item        |
| `like`       | Someone liked user's comment      |
| `assignment` | User was assigned to an item      |

## API Endpoints

### GET /api/notifications

Fetch notifications for a user.

**Query Parameters:**

- `email` (required\*): User's email address
- `userId` (required*): User ID (*one of email or userId required)
- `unreadOnly` (optional): Set to `true` to only fetch unread
- `limit` (optional): Number of notifications (default: 50)
- `offset` (optional): Pagination offset

**Response:**

```json
{
  "success": true,
  "notifications": [...],
  "total": 42,
  "unreadCount": 5,
  "limit": 50,
  "offset": 0
}
```

### POST /api/notifications

Create a new notification.

**Body:**

```json
{
  "user_id": "4",
  "user_email": "user@example.com",
  "type": "mention",
  "title": "John mentioned you",
  "message": "In \"Priority Item\": Check this out...",
  "link": "/?item=item-123",
  "item_id": "item-123",
  "comment_id": "comment-456",
  "triggered_by": "John Smith",
  "triggered_by_avatar": "https://..."
}
```

### PATCH /api/notifications

Mark notification(s) as read.

**Body (single/multiple):**

```json
{
  "ids": ["notification-id-1", "notification-id-2"]
}
```

**Body (mark all):**

```json
{
  "markAllRead": true,
  "userEmail": "user@example.com"
}
```

### DELETE /api/notifications

Delete notification(s).

**Query Parameters (single):**

- `id`: Notification ID to delete

**Query Parameters (clear all):**

- `clearAll=true`
- `email`: User's email address

## User Experience

1. User is @mentioned in a comment
2. Notification is automatically created via MatrixContext
3. Bell icon in sidebar shows unread badge
4. User clicks bell to see notification dropdown
5. Notification shows who mentioned them and where
6. Clicking notification navigates to the item and marks as read

## Files Changed

| File                                               | Changes                              |
| -------------------------------------------------- | ------------------------------------ |
| `src/app/api/notifications/route.ts`               | New API route                        |
| `src/hooks/useNotifications.ts`                    | New hook for notification management |
| `src/components/NotificationBell.tsx`              | New UI component                     |
| `src/components/layout/sidebar.tsx`                | Added NotificationBell to sidebar    |
| `src/components/priority-matrix/MatrixContext.tsx` | Integrated notification triggers     |

## Scripts

- `scripts/create-notifications-table.mjs` - Outputs SQL for table creation

## Future Enhancements

- Email notifications for mentions
- Teams/Slack integration
- Notification preferences per user
- Push notifications (browser/mobile)
- Notification grouping/batching
- Sound/visual alerts for new notifications
