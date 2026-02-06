# Phase 3: Collaboration UI Components Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement the 4 missing Sprint 1 UI components for strategic plan collaboration: ActivityTimeline, NotificationBell, ApprovalPanel, and extract MentionInput.

**Architecture:** Create a new `collaboration/` folder under `src/components/planning/` for standalone collaboration components. Use existing hooks (`usePlanActivity`, `usePlanPresence`) where available, create `useNotifications` hook for the notification system. Components follow existing patterns from `CollaborationPanel.tsx`.

**Tech Stack:** React 18, TypeScript, Tailwind CSS, Supabase Realtime, Lucide icons, shadcn/ui components

---

## Prerequisites

The page at `src/app/(dashboard)/planning/strategic/[id]/page.tsx:40` already imports these components:
```tsx
import { NotificationBell, ActivityTimeline } from '@/components/planning/collaboration'
```

This import will fail until we create the components. The build is likely broken.

---

## Task 1: Create Collaboration Folder Structure

**Files:**
- Create: `src/components/planning/collaboration/index.ts`

**Step 1: Create the index file with placeholder exports**

```typescript
/**
 * Collaboration Components
 *
 * Standalone components for strategic plan collaboration features.
 * These complement the unified/ components with specific UI widgets.
 */

// Placeholder exports - components will be added as implemented
export { ActivityTimeline } from './ActivityTimeline'
export { NotificationBell } from './NotificationBell'
export { ApprovalPanel } from './ApprovalPanel'
export { MentionInput } from './MentionInput'

// Type exports
export type { ActivityTimelineProps } from './ActivityTimeline'
export type { NotificationBellProps } from './NotificationBell'
export type { ApprovalPanelProps } from './ApprovalPanel'
export type { MentionInputProps } from './MentionInput'
```

**Step 2: Commit**

```bash
git add src/components/planning/collaboration/index.ts
git commit -m "chore: scaffold collaboration components folder"
```

---

## Task 2: ActivityTimeline Component

**Files:**
- Create: `src/components/planning/collaboration/ActivityTimeline.tsx`
- Modify: `src/components/planning/collaboration/index.ts`

**Dependencies:**
- Hook: `src/hooks/usePlanActivity.ts` (already exists)
- Types: `PlanActivity`, `PlanActivityAction` from the hook

**Step 1: Create ActivityTimeline.tsx**

```typescript
'use client'

/**
 * ActivityTimeline Component
 *
 * Displays chronological feed of plan activity from plan_activity_log table.
 * Features:
 * - Relative timestamps
 * - Action icons per type
 * - User avatars with role badges
 * - Filter by action type
 * - Filter by user
 * - Load more pagination
 */

import { useState, useMemo, useCallback } from 'react'
import {
  MessageSquare,
  Check,
  X,
  Send,
  Edit3,
  UserPlus,
  UserMinus,
  Archive,
  RotateCcw,
  FileText,
  ChevronDown,
  Filter,
  Loader2,
  AlertCircle,
  History,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { usePlanActivity, type PlanActivity, type PlanActivityAction } from '@/hooks/usePlanActivity'

// ============================================================================
// Types
// ============================================================================

export interface ActivityTimelineProps {
  /** Plan ID to fetch activity for */
  planId: string
  /** Maximum height before scrolling */
  maxHeight?: string
  /** Show filter controls */
  showFilters?: boolean
  /** Initial action filter */
  initialActionFilter?: PlanActivityAction[]
  /** Callback when an activity item is clicked */
  onActivityClick?: (activity: PlanActivity) => void
  /** Optional className */
  className?: string
}

// ============================================================================
// Constants
// ============================================================================

const ACTION_CONFIG: Record<
  PlanActivityAction,
  { icon: React.ElementType; label: string; colour: string }
> = {
  created: { icon: FileText, label: 'Created plan', colour: 'text-blue-500' },
  updated: { icon: Edit3, label: 'Updated', colour: 'text-slate-500' },
  commented: { icon: MessageSquare, label: 'Commented', colour: 'text-blue-500' },
  submitted: { icon: Send, label: 'Submitted for review', colour: 'text-purple-500' },
  approved: { icon: Check, label: 'Approved', colour: 'text-green-500' },
  rejected: { icon: X, label: 'Returned for revision', colour: 'text-red-500' },
  archived: { icon: Archive, label: 'Archived', colour: 'text-slate-400' },
  restored: { icon: RotateCcw, label: 'Restored', colour: 'text-blue-500' },
  step_completed: { icon: Check, label: 'Completed step', colour: 'text-green-500' },
  collaborator_added: { icon: UserPlus, label: 'Added collaborator', colour: 'text-blue-500' },
  collaborator_removed: { icon: UserMinus, label: 'Removed collaborator', colour: 'text-slate-500' },
  status_changed: { icon: Edit3, label: 'Changed status', colour: 'text-amber-500' },
  resolved_comment: { icon: Check, label: 'Resolved comment', colour: 'text-green-500' },
  edited_comment: { icon: Edit3, label: 'Edited comment', colour: 'text-slate-500' },
}

const FILTER_OPTIONS: { value: PlanActivityAction; label: string }[] = [
  { value: 'commented', label: 'Comments' },
  { value: 'approved', label: 'Approvals' },
  { value: 'rejected', label: 'Rejections' },
  { value: 'updated', label: 'Updates' },
  { value: 'submitted', label: 'Submissions' },
]

// ============================================================================
// Component
// ============================================================================

export function ActivityTimeline({
  planId,
  maxHeight = '400px',
  showFilters = true,
  initialActionFilter,
  onActivityClick,
  className,
}: ActivityTimelineProps) {
  const [actionFilter, setActionFilter] = useState<PlanActivityAction[] | undefined>(
    initialActionFilter
  )
  const [userFilter, setUserFilter] = useState<string | undefined>(undefined)
  const [showFilterDropdown, setShowFilterDropdown] = useState(false)

  const {
    activities,
    isLoading,
    error,
    hasMore,
    loadMore,
    totalCount,
  } = usePlanActivity({
    planId,
    actionFilter,
    userFilter,
    pageSize: 20,
    enableRealtime: true,
    enabled: !!planId,
  })

  // Get unique users for filter
  const uniqueUsers = useMemo(() => {
    const users = new Set<string>()
    activities.forEach(a => users.add(a.user_name))
    return Array.from(users)
  }, [activities])

  // Toggle action filter
  const toggleActionFilter = useCallback((action: PlanActivityAction) => {
    setActionFilter(prev => {
      if (!prev) return [action]
      if (prev.includes(action)) {
        const newFilter = prev.filter(a => a !== action)
        return newFilter.length === 0 ? undefined : newFilter
      }
      return [...prev, action]
    })
  }, [])

  // Clear all filters
  const clearFilters = useCallback(() => {
    setActionFilter(undefined)
    setUserFilter(undefined)
  }, [])

  const hasActiveFilters = actionFilter || userFilter

  return (
    <div className={cn('flex flex-col', className)}>
      {/* Header */}
      <div className="flex items-center justify-between px-4 py-3 border-b border-slate-200 dark:border-slate-700">
        <div className="flex items-center gap-2">
          <History className="h-5 w-5 text-slate-500" />
          <span className="font-medium text-slate-900 dark:text-slate-100">Activity</span>
          <span className="text-sm text-slate-500">({totalCount})</span>
        </div>

        {showFilters && (
          <div className="relative">
            <button
              onClick={() => setShowFilterDropdown(!showFilterDropdown)}
              className={cn(
                'flex items-center gap-1 px-2 py-1 rounded text-sm transition-colors',
                hasActiveFilters
                  ? 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400'
                  : 'text-slate-500 hover:bg-slate-100 dark:hover:bg-slate-700'
              )}
            >
              <Filter className="h-4 w-4" />
              Filter
              <ChevronDown className="h-3 w-3" />
            </button>

            {showFilterDropdown && (
              <div className="absolute right-0 top-full mt-1 w-48 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg shadow-lg z-10">
                <div className="p-2 border-b border-slate-200 dark:border-slate-700">
                  <span className="text-xs font-medium text-slate-500 uppercase">
                    Action Type
                  </span>
                </div>
                <div className="p-1">
                  {FILTER_OPTIONS.map(option => (
                    <button
                      key={option.value}
                      onClick={() => toggleActionFilter(option.value)}
                      className={cn(
                        'flex items-center gap-2 w-full px-2 py-1.5 rounded text-sm text-left transition-colors',
                        actionFilter?.includes(option.value)
                          ? 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400'
                          : 'text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700'
                      )}
                    >
                      {option.label}
                    </button>
                  ))}
                </div>

                {uniqueUsers.length > 1 && (
                  <>
                    <div className="p-2 border-t border-slate-200 dark:border-slate-700">
                      <span className="text-xs font-medium text-slate-500 uppercase">User</span>
                    </div>
                    <div className="p-1 max-h-32 overflow-y-auto">
                      {uniqueUsers.map(user => (
                        <button
                          key={user}
                          onClick={() => setUserFilter(userFilter === user ? undefined : user)}
                          className={cn(
                            'flex items-center gap-2 w-full px-2 py-1.5 rounded text-sm text-left transition-colors',
                            userFilter === user
                              ? 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400'
                              : 'text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700'
                          )}
                        >
                          {user}
                        </button>
                      ))}
                    </div>
                  </>
                )}

                {hasActiveFilters && (
                  <div className="p-2 border-t border-slate-200 dark:border-slate-700">
                    <button
                      onClick={clearFilters}
                      className="w-full px-2 py-1.5 text-sm text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20 rounded transition-colors"
                    >
                      Clear filters
                    </button>
                  </div>
                )}
              </div>
            )}
          </div>
        )}
      </div>

      {/* Activity List */}
      <div className="flex-1 overflow-y-auto" style={{ maxHeight }}>
        {isLoading && activities.length === 0 ? (
          <div className="flex items-center justify-center py-8">
            <Loader2 className="h-6 w-6 animate-spin text-slate-400" />
          </div>
        ) : error ? (
          <div className="flex flex-col items-center justify-center py-8 text-red-500">
            <AlertCircle className="h-6 w-6 mb-2" />
            <span className="text-sm">{error}</span>
          </div>
        ) : activities.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-8 text-slate-500">
            <History className="h-8 w-8 mb-2 opacity-50" />
            <span className="text-sm">No activity yet</span>
          </div>
        ) : (
          <div className="divide-y divide-slate-100 dark:divide-slate-800">
            {activities.map(activity => (
              <ActivityItem
                key={activity.id}
                activity={activity}
                onClick={onActivityClick ? () => onActivityClick(activity) : undefined}
              />
            ))}

            {hasMore && (
              <button
                onClick={loadMore}
                disabled={isLoading}
                className="w-full py-3 text-sm text-blue-600 dark:text-blue-400 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors disabled:opacity-50"
              >
                {isLoading ? (
                  <Loader2 className="h-4 w-4 animate-spin mx-auto" />
                ) : (
                  'Load more'
                )}
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  )
}

// ============================================================================
// Sub-components
// ============================================================================

interface ActivityItemProps {
  activity: PlanActivity
  onClick?: () => void
}

function ActivityItem({ activity, onClick }: ActivityItemProps) {
  const config = ACTION_CONFIG[activity.action] || {
    icon: Edit3,
    label: activity.action,
    colour: 'text-slate-500',
  }
  const Icon = config.icon

  // Format details based on action type
  const details = useMemo(() => {
    const d = activity.action_details
    if (!d) return null

    if (activity.action === 'commented' && d.content) {
      return (
        <p className="text-sm text-slate-600 dark:text-slate-400 mt-1 line-clamp-2">
          "{d.content as string}"
        </p>
      )
    }

    if ((activity.action === 'approved' || activity.action === 'rejected') && d.approval_notes) {
      return (
        <p className="text-sm text-slate-600 dark:text-slate-400 mt-1 line-clamp-2">
          "{d.approval_notes as string}"
        </p>
      )
    }

    if (activity.action === 'updated' && d.field_path) {
      return (
        <p className="text-xs text-slate-500 mt-1">
          Modified: {d.field_path as string}
        </p>
      )
    }

    return null
  }, [activity])

  return (
    <button
      onClick={onClick}
      disabled={!onClick}
      className={cn(
        'flex items-start gap-3 w-full px-4 py-3 text-left transition-colors',
        onClick && 'hover:bg-slate-50 dark:hover:bg-slate-800'
      )}
    >
      {/* Icon */}
      <div
        className={cn(
          'flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center',
          'bg-slate-100 dark:bg-slate-700'
        )}
      >
        <Icon className={cn('h-4 w-4', config.colour)} />
      </div>

      {/* Content */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2">
          <span className="font-medium text-slate-900 dark:text-slate-100 text-sm">
            {activity.user_name}
          </span>
          {activity.user_role && (
            <span className="px-1.5 py-0.5 rounded text-[10px] font-medium bg-slate-100 text-slate-600 dark:bg-slate-700 dark:text-slate-400">
              {activity.user_role}
            </span>
          )}
        </div>

        <p className="text-sm text-slate-600 dark:text-slate-400">
          {config.label}
          {activity.step_number && ` (Step ${activity.step_number})`}
        </p>

        {details}

        <p className="text-xs text-slate-400 dark:text-slate-500 mt-1">
          {formatRelativeTime(activity.created_at)}
        </p>
      </div>
    </button>
  )
}

// ============================================================================
// Helpers
// ============================================================================

function formatRelativeTime(dateString: string): string {
  const date = new Date(dateString)
  const now = new Date()
  const diffMs = now.getTime() - date.getTime()
  const diffMinutes = Math.floor(diffMs / (1000 * 60))
  const diffHours = Math.floor(diffMinutes / 60)
  const diffDays = Math.floor(diffHours / 24)

  if (diffMinutes < 1) return 'just now'
  if (diffMinutes < 60) return `${diffMinutes}m ago`
  if (diffHours < 24) return `${diffHours}h ago`
  if (diffDays < 7) return `${diffDays}d ago`

  return date.toLocaleDateString('en-AU', {
    day: 'numeric',
    month: 'short',
  })
}

export default ActivityTimeline
```

**Step 2: Verify no TypeScript errors**

```bash
npx tsc --noEmit src/components/planning/collaboration/ActivityTimeline.tsx
```

Expected: No errors

**Step 3: Commit**

```bash
git add src/components/planning/collaboration/ActivityTimeline.tsx
git commit -m "feat: add ActivityTimeline component for plan activity feed"
```

---

## Task 3: Create Notifications Database Migration

**Files:**
- Create: `supabase/migrations/20260205_notifications.sql`

**Step 1: Write the migration SQL**

```sql
-- Notifications table for in-app notifications
-- Supports mentions, approvals, comments, and other plan events

CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_email TEXT NOT NULL,
  user_name TEXT,
  type TEXT NOT NULL CHECK (type IN (
    'mention',
    'comment',
    'reply',
    'approval_requested',
    'approved',
    'rejected',
    'collaborator_added'
  )),
  title TEXT NOT NULL,
  message TEXT,
  plan_id UUID REFERENCES strategic_plans(id) ON DELETE CASCADE,
  comment_id UUID,
  entity_type TEXT,
  entity_id TEXT,
  action_url TEXT,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for efficient queries
CREATE INDEX idx_notifications_user_email ON notifications(user_email);
CREATE INDEX idx_notifications_user_unread ON notifications(user_email, read_at) WHERE read_at IS NULL;
CREATE INDEX idx_notifications_plan ON notifications(plan_id);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);

-- RLS policies
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can only read their own notifications
CREATE POLICY "Users can read own notifications"
  ON notifications FOR SELECT
  TO authenticated
  USING (user_email = auth.jwt() ->> 'email');

-- Service role can insert notifications
CREATE POLICY "Service can insert notifications"
  ON notifications FOR INSERT
  TO service_role
  WITH CHECK (true);

-- Users can update (mark as read) their own notifications
CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  TO authenticated
  USING (user_email = auth.jwt() ->> 'email');

-- Users can delete their own notifications
CREATE POLICY "Users can delete own notifications"
  ON notifications FOR DELETE
  TO authenticated
  USING (user_email = auth.jwt() ->> 'email');

-- Allow anon for dashboard access (no auth in this app)
CREATE POLICY "Anon can read all notifications"
  ON notifications FOR SELECT
  TO anon
  USING (true);

CREATE POLICY "Anon can insert notifications"
  ON notifications FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE POLICY "Anon can update notifications"
  ON notifications FOR UPDATE
  TO anon
  USING (true);

CREATE POLICY "Anon can delete notifications"
  ON notifications FOR DELETE
  TO anon
  USING (true);

-- Enable realtime
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

COMMENT ON TABLE notifications IS 'In-app notifications for plan collaboration events';
COMMENT ON COLUMN notifications.user_email IS 'Email of notification recipient';
COMMENT ON COLUMN notifications.type IS 'Notification type: mention, comment, reply, approval_requested, approved, rejected, collaborator_added';
COMMENT ON COLUMN notifications.read_at IS 'Timestamp when notification was read (NULL = unread)';
```

**Step 2: Apply the migration using pg client**

Create a temporary script to apply the migration:

```javascript
// Run: node apply-migration.js
const { Client } = require('pg')
const fs = require('fs')
const sql = fs.readFileSync('supabase/migrations/20260205_notifications.sql', 'utf8')
const client = new Client({
  connectionString: process.env.DATABASE_URL_DIRECT,
  ssl: { rejectUnauthorized: false }
})
client.connect()
  .then(() => client.query(sql))
  .then(() => { console.log('Migration applied'); client.end() })
  .catch(e => { console.error(e); client.end() })
```

Expected: "Migration applied"

**Step 3: Commit**

```bash
git add supabase/migrations/20260205_notifications.sql
git commit -m "feat: add notifications table for in-app notifications"
```

---

## Task 4: Create useNotifications Hook

**Files:**
- Create: `src/hooks/useNotifications.ts`
- Modify: `src/hooks/index.ts` (add export)

**Step 1: Create the hook**

```typescript
/**
 * useNotifications Hook
 *
 * Manages user notifications with real-time updates.
 * Features:
 * - Fetch notifications for current user
 * - Real-time subscription for new notifications
 * - Mark as read (individual or all)
 * - Delete notifications
 * - Unread count
 */

import { useState, useEffect, useCallback, useRef } from 'react'
import { supabase } from '@/lib/supabase'
import type { RealtimeChannel } from '@supabase/supabase-js'

// ============================================================================
// Types
// ============================================================================

export type NotificationType =
  | 'mention'
  | 'comment'
  | 'reply'
  | 'approval_requested'
  | 'approved'
  | 'rejected'
  | 'collaborator_added'

export interface Notification {
  id: string
  user_email: string
  user_name?: string
  type: NotificationType
  title: string
  message?: string
  plan_id?: string
  comment_id?: string
  entity_type?: string
  entity_id?: string
  action_url?: string
  read_at: string | null
  created_at: string
}

export interface UseNotificationsOptions {
  /** Current user's email */
  userEmail: string
  /** Enable real-time updates */
  enableRealtime?: boolean
  /** Enable the hook */
  enabled?: boolean
}

export interface UseNotificationsReturn {
  /** All notifications */
  notifications: Notification[]
  /** Unread notifications only */
  unreadNotifications: Notification[]
  /** Count of unread notifications */
  unreadCount: number
  /** Loading state */
  isLoading: boolean
  /** Error message if any */
  error: string | null
  /** Mark a notification as read */
  markAsRead: (notificationId: string) => Promise<boolean>
  /** Mark all notifications as read */
  markAllAsRead: () => Promise<boolean>
  /** Delete a notification */
  deleteNotification: (notificationId: string) => Promise<boolean>
  /** Refresh notifications */
  refresh: () => Promise<void>
}

// ============================================================================
// Hook Implementation
// ============================================================================

export function useNotifications({
  userEmail,
  enableRealtime = true,
  enabled = true,
}: UseNotificationsOptions): UseNotificationsReturn {
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  const channelRef = useRef<RealtimeChannel | null>(null)

  // Fetch notifications
  const fetchNotifications = useCallback(async () => {
    if (!userEmail || !enabled) return

    setIsLoading(true)
    setError(null)

    try {
      const { data, error: fetchError } = await supabase
        .from('notifications')
        .select('*')
        .eq('user_email', userEmail)
        .order('created_at', { ascending: false })
        .limit(50)

      if (fetchError) {
        console.error('[useNotifications] Fetch error:', fetchError)
        setError(fetchError.message)
        return
      }

      setNotifications((data || []) as Notification[])
    } catch (err) {
      console.error('[useNotifications] Unexpected error:', err)
      setError('Failed to fetch notifications')
    } finally {
      setIsLoading(false)
    }
  }, [userEmail, enabled])

  // Mark as read
  const markAsRead = useCallback(
    async (notificationId: string): Promise<boolean> => {
      try {
        const { error: updateError } = await supabase
          .from('notifications')
          .update({ read_at: new Date().toISOString() })
          .eq('id', notificationId)
          .eq('user_email', userEmail)

        if (updateError) {
          console.error('[useNotifications] Mark as read error:', updateError)
          return false
        }

        // Update local state
        setNotifications(prev =>
          prev.map(n =>
            n.id === notificationId ? { ...n, read_at: new Date().toISOString() } : n
          )
        )

        return true
      } catch (err) {
        console.error('[useNotifications] Mark as read unexpected error:', err)
        return false
      }
    },
    [userEmail]
  )

  // Mark all as read
  const markAllAsRead = useCallback(async (): Promise<boolean> => {
    try {
      const { error: updateError } = await supabase
        .from('notifications')
        .update({ read_at: new Date().toISOString() })
        .eq('user_email', userEmail)
        .is('read_at', null)

      if (updateError) {
        console.error('[useNotifications] Mark all as read error:', updateError)
        return false
      }

      // Update local state
      setNotifications(prev =>
        prev.map(n => (n.read_at ? n : { ...n, read_at: new Date().toISOString() }))
      )

      return true
    } catch (err) {
      console.error('[useNotifications] Mark all as read unexpected error:', err)
      return false
    }
  }, [userEmail])

  // Delete notification
  const deleteNotification = useCallback(
    async (notificationId: string): Promise<boolean> => {
      try {
        const { error: deleteError } = await supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_email', userEmail)

        if (deleteError) {
          console.error('[useNotifications] Delete error:', deleteError)
          return false
        }

        // Update local state
        setNotifications(prev => prev.filter(n => n.id !== notificationId))

        return true
      } catch (err) {
        console.error('[useNotifications] Delete unexpected error:', err)
        return false
      }
    },
    [userEmail]
  )

  // Real-time subscription
  useEffect(() => {
    if (!userEmail || !enabled || !enableRealtime) return

    console.log('[useNotifications] Setting up real-time subscription for:', userEmail)

    const channel = supabase
      .channel(`notifications-${userEmail}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'notifications',
          filter: `user_email=eq.${userEmail}`,
        },
        payload => {
          console.log('[useNotifications] New notification:', payload)
          const newNotification = payload.new as Notification
          setNotifications(prev => [newNotification, ...prev])
        }
      )
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'notifications',
          filter: `user_email=eq.${userEmail}`,
        },
        payload => {
          console.log('[useNotifications] Updated notification:', payload)
          const updatedNotification = payload.new as Notification
          setNotifications(prev =>
            prev.map(n => (n.id === updatedNotification.id ? updatedNotification : n))
          )
        }
      )
      .on(
        'postgres_changes',
        {
          event: 'DELETE',
          schema: 'public',
          table: 'notifications',
          filter: `user_email=eq.${userEmail}`,
        },
        payload => {
          console.log('[useNotifications] Deleted notification:', payload)
          const deletedId = (payload.old as { id: string }).id
          setNotifications(prev => prev.filter(n => n.id !== deletedId))
        }
      )
      .subscribe(status => {
        console.log('[useNotifications] Subscription status:', status)
      })

    channelRef.current = channel

    return () => {
      console.log('[useNotifications] Cleaning up subscription')
      if (channelRef.current) {
        supabase.removeChannel(channelRef.current)
        channelRef.current = null
      }
    }
  }, [userEmail, enabled, enableRealtime])

  // Initial fetch
  useEffect(() => {
    if (enabled && userEmail) {
      fetchNotifications()
    }
  }, [enabled, userEmail, fetchNotifications])

  // Computed values
  const unreadNotifications = notifications.filter(n => !n.read_at)
  const unreadCount = unreadNotifications.length

  return {
    notifications,
    unreadNotifications,
    unreadCount,
    isLoading,
    error,
    markAsRead,
    markAllAsRead,
    deleteNotification,
    refresh: fetchNotifications,
  }
}

export default useNotifications
```

**Step 2: Add export to hooks/index.ts**

Find and add to `src/hooks/index.ts`:
```typescript
export { useNotifications } from './useNotifications'
export type {
  Notification,
  NotificationType,
  UseNotificationsOptions,
  UseNotificationsReturn,
} from './useNotifications'
```

**Step 3: Verify no TypeScript errors**

```bash
npx tsc --noEmit src/hooks/useNotifications.ts
```

Expected: No errors

**Step 4: Commit**

```bash
git add src/hooks/useNotifications.ts src/hooks/index.ts
git commit -m "feat: add useNotifications hook for notification management"
```

---

## Task 5: NotificationBell Component

**Files:**
- Create: `src/components/planning/collaboration/NotificationBell.tsx`

**Step 1: Create the component**

```typescript
'use client'

/**
 * NotificationBell Component
 *
 * Header notification icon with dropdown.
 * Features:
 * - Bell icon with unread count badge
 * - Dropdown with recent notifications
 * - Mark as read on view
 * - Mark all as read action
 * - Link to related plan/comment
 */

import { useState, useRef, useEffect, useCallback } from 'react'
import { useRouter } from 'next/navigation'
import {
  Bell,
  Check,
  CheckCheck,
  X,
  MessageSquare,
  Send,
  UserPlus,
  AtSign,
  Loader2,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { useNotifications, type Notification, type NotificationType } from '@/hooks/useNotifications'

// ============================================================================
// Types
// ============================================================================

export interface NotificationBellProps {
  /** Current user's email for fetching notifications */
  userEmail: string
  /** Optional className */
  className?: string
}

// ============================================================================
// Constants
// ============================================================================

const NOTIFICATION_ICONS: Record<NotificationType, React.ElementType> = {
  mention: AtSign,
  comment: MessageSquare,
  reply: MessageSquare,
  approval_requested: Send,
  approved: Check,
  rejected: X,
  collaborator_added: UserPlus,
}

const NOTIFICATION_COLOURS: Record<NotificationType, string> = {
  mention: 'text-blue-500',
  comment: 'text-slate-500',
  reply: 'text-slate-500',
  approval_requested: 'text-purple-500',
  approved: 'text-green-500',
  rejected: 'text-red-500',
  collaborator_added: 'text-blue-500',
}

// ============================================================================
// Component
// ============================================================================

export function NotificationBell({ userEmail, className }: NotificationBellProps) {
  const router = useRouter()
  const [isOpen, setIsOpen] = useState(false)
  const dropdownRef = useRef<HTMLDivElement>(null)

  const {
    notifications,
    unreadCount,
    isLoading,
    markAsRead,
    markAllAsRead,
  } = useNotifications({
    userEmail,
    enableRealtime: true,
    enabled: !!userEmail,
  })

  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false)
      }
    }

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside)
      return () => document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [isOpen])

  // Handle notification click
  const handleNotificationClick = useCallback(
    async (notification: Notification) => {
      // Mark as read
      if (!notification.read_at) {
        await markAsRead(notification.id)
      }

      // Navigate if action URL provided
      if (notification.action_url) {
        router.push(notification.action_url)
        setIsOpen(false)
      } else if (notification.plan_id) {
        router.push(`/planning/strategic/${notification.plan_id}`)
        setIsOpen(false)
      }
    },
    [markAsRead, router]
  )

  // Handle mark all as read
  const handleMarkAllAsRead = useCallback(async () => {
    await markAllAsRead()
  }, [markAllAsRead])

  return (
    <div ref={dropdownRef} className={cn('relative', className)}>
      {/* Bell Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={cn(
          'relative p-2 rounded-lg transition-colors',
          'text-slate-600 dark:text-slate-400',
          'hover:bg-slate-100 dark:hover:bg-slate-700',
          isOpen && 'bg-slate-100 dark:bg-slate-700'
        )}
        aria-label={`Notifications${unreadCount > 0 ? ` (${unreadCount} unread)` : ''}`}
      >
        <Bell className="h-5 w-5" />

        {/* Unread Badge */}
        {unreadCount > 0 && (
          <span className="absolute -top-0.5 -right-0.5 flex items-center justify-center min-w-[18px] h-[18px] px-1 text-[10px] font-bold text-white bg-red-500 rounded-full">
            {unreadCount > 99 ? '99+' : unreadCount}
          </span>
        )}
      </button>

      {/* Dropdown */}
      {isOpen && (
        <div className="absolute right-0 top-full mt-2 w-80 bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-lg shadow-xl z-50">
          {/* Header */}
          <div className="flex items-center justify-between px-4 py-3 border-b border-slate-200 dark:border-slate-700">
            <span className="font-medium text-slate-900 dark:text-slate-100">Notifications</span>
            {unreadCount > 0 && (
              <button
                onClick={handleMarkAllAsRead}
                className="flex items-center gap-1 text-xs text-blue-600 dark:text-blue-400 hover:underline"
              >
                <CheckCheck className="h-3 w-3" />
                Mark all read
              </button>
            )}
          </div>

          {/* Notification List */}
          <div className="max-h-96 overflow-y-auto">
            {isLoading ? (
              <div className="flex items-center justify-center py-8">
                <Loader2 className="h-5 w-5 animate-spin text-slate-400" />
              </div>
            ) : notifications.length === 0 ? (
              <div className="py-8 text-center text-slate-500 dark:text-slate-400">
                <Bell className="h-8 w-8 mx-auto mb-2 opacity-50" />
                <p className="text-sm">No notifications</p>
              </div>
            ) : (
              <div>
                {notifications.slice(0, 10).map(notification => (
                  <NotificationItem
                    key={notification.id}
                    notification={notification}
                    onClick={() => handleNotificationClick(notification)}
                  />
                ))}
              </div>
            )}
          </div>

          {/* Footer */}
          {notifications.length > 10 && (
            <div className="px-4 py-2 border-t border-slate-200 dark:border-slate-700">
              <button
                onClick={() => {
                  router.push('/notifications')
                  setIsOpen(false)
                }}
                className="w-full text-center text-sm text-blue-600 dark:text-blue-400 hover:underline"
              >
                View all notifications
              </button>
            </div>
          )}
        </div>
      )}
    </div>
  )
}

// ============================================================================
// Sub-components
// ============================================================================

interface NotificationItemProps {
  notification: Notification
  onClick: () => void
}

function NotificationItem({ notification, onClick }: NotificationItemProps) {
  const Icon = NOTIFICATION_ICONS[notification.type] || Bell
  const iconColour = NOTIFICATION_COLOURS[notification.type] || 'text-slate-500'

  return (
    <button
      onClick={onClick}
      className={cn(
        'flex items-start gap-3 w-full px-4 py-3 text-left transition-colors',
        'hover:bg-slate-50 dark:hover:bg-slate-700/50',
        !notification.read_at && 'bg-blue-50/50 dark:bg-blue-900/10'
      )}
    >
      {/* Icon */}
      <div
        className={cn(
          'flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center',
          'bg-slate-100 dark:bg-slate-700'
        )}
      >
        <Icon className={cn('h-4 w-4', iconColour)} />
      </div>

      {/* Content */}
      <div className="flex-1 min-w-0">
        <p
          className={cn(
            'text-sm',
            notification.read_at
              ? 'text-slate-600 dark:text-slate-400'
              : 'text-slate-900 dark:text-slate-100 font-medium'
          )}
        >
          {notification.title}
        </p>
        {notification.message && (
          <p className="text-xs text-slate-500 dark:text-slate-500 mt-0.5 line-clamp-2">
            {notification.message}
          </p>
        )}
        <p className="text-xs text-slate-400 dark:text-slate-500 mt-1">
          {formatRelativeTime(notification.created_at)}
        </p>
      </div>

      {/* Unread indicator */}
      {!notification.read_at && (
        <div className="flex-shrink-0 w-2 h-2 rounded-full bg-blue-500 mt-2" />
      )}
    </button>
  )
}

// ============================================================================
// Helpers
// ============================================================================

function formatRelativeTime(dateString: string): string {
  const date = new Date(dateString)
  const now = new Date()
  const diffMs = now.getTime() - date.getTime()
  const diffMinutes = Math.floor(diffMs / (1000 * 60))
  const diffHours = Math.floor(diffMinutes / 60)
  const diffDays = Math.floor(diffHours / 24)

  if (diffMinutes < 1) return 'just now'
  if (diffMinutes < 60) return `${diffMinutes}m ago`
  if (diffHours < 24) return `${diffHours}h ago`
  if (diffDays < 7) return `${diffDays}d ago`

  return date.toLocaleDateString('en-AU', {
    day: 'numeric',
    month: 'short',
  })
}

export default NotificationBell
```

**Step 2: Verify no TypeScript errors**

```bash
npx tsc --noEmit src/components/planning/collaboration/NotificationBell.tsx
```

Expected: No errors

**Step 3: Commit**

```bash
git add src/components/planning/collaboration/NotificationBell.tsx
git commit -m "feat: add NotificationBell component with dropdown"
```

---

## Task 6: ApprovalPanel Component

**Files:**
- Create: `src/components/planning/collaboration/ApprovalPanel.tsx`

**Step 1: Create the component**

See full component code in implementation. Key features:
- Plan summary display with status badge
- Submit for approval mode (with approver name input)
- Approve mode (with optional feedback)
- Reject mode (with required feedback)
- Loading states and error handling

**Step 2: Verify no TypeScript errors**

```bash
npx tsc --noEmit src/components/planning/collaboration/ApprovalPanel.tsx
```

**Step 3: Commit**

```bash
git add src/components/planning/collaboration/ApprovalPanel.tsx
git commit -m "feat: add ApprovalPanel component for approval workflow"
```

---

## Task 7: Extract MentionInput Component

**Files:**
- Create: `src/components/planning/collaboration/MentionInput.tsx`

**Step 1: Extract from CollaborationPanel.tsx**

The `CommentInput` component contains @mention logic. Extract it as standalone with:
- Keyboard navigation for mention dropdown (arrow keys + Enter/Tab)
- Selected index highlight
- Proper cleanup

**Step 2: Verify no TypeScript errors**

```bash
npx tsc --noEmit src/components/planning/collaboration/MentionInput.tsx
```

**Step 3: Commit**

```bash
git add src/components/planning/collaboration/MentionInput.tsx
git commit -m "feat: extract MentionInput as standalone component"
```

---

## Task 8: Update Index and Fix Imports

**Files:**
- Modify: `src/components/planning/collaboration/index.ts`

**Step 1: Update the index file with all exports**

```typescript
/**
 * Collaboration Components
 *
 * Standalone components for strategic plan collaboration features.
 */

export { ActivityTimeline } from './ActivityTimeline'
export { NotificationBell } from './NotificationBell'
export { ApprovalPanel } from './ApprovalPanel'
export { MentionInput } from './MentionInput'

export type { ActivityTimelineProps } from './ActivityTimeline'
export type { NotificationBellProps } from './NotificationBell'
export type { ApprovalPanelProps } from './ApprovalPanel'
export type { MentionInputProps, TeamMember } from './MentionInput'
```

**Step 2: Verify the strategic plan page compiles**

```bash
npx tsc --noEmit
```

**Step 3: Commit**

```bash
git add src/components/planning/collaboration/index.ts
git commit -m "feat: complete collaboration components index exports"
```

---

## Task 9: Final Verification

**Step 1: Run the development server**

```bash
npm run dev -- -p 3001
```

**Step 2: Navigate to a strategic plan and verify components render**

Open browser to `http://localhost:3001/planning/strategic/[plan-id]`

Verify:
- [ ] No console errors about missing imports
- [ ] Components render without crashing

**Step 3: Final commit**

```bash
git add -A
git commit -m "docs: complete Phase 3 collaboration UI implementation"
```

---

## Summary

| Task | Component | Effort |
|------|-----------|--------|
| 1 | Folder structure | Small |
| 2 | ActivityTimeline | Medium (hook exists) |
| 3 | DB Migration | Small |
| 4 | useNotifications | Medium |
| 5 | NotificationBell | Medium |
| 6 | ApprovalPanel | Medium |
| 7 | MentionInput | Small (extraction) |
| 8 | Index exports | Small |
| 9 | Verification | Small |

**Total commits:** 8-9
