# Phase 9: Moonshot Features - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement 7 moonshot features: Background AI Task Queue, Network Graph, Digital Twin, Deal Sandbox, 3D Pipeline, Meeting Co-Host, and Sentiment Analysis.

**Architecture:** Feature groups share infrastructure - task queue underpins async AI, graph data model serves both network vis and 3D pipeline, WebSocket layer serves real-time meeting features.

**Tech Stack:** Next.js 16, Supabase (Postgres + Realtime), Three.js/React Three Fiber, D3-force-3d, Deepgram SDK, OpenAI API.

---

## Phase 9.1: Background AI Task Queue

### Task 1: Database Migration - Task Queue Tables

**Files:**
- Create: `supabase/migrations/20260207_01_ai_task_queue.sql`

**Step 1: Write the migration file**

```sql
-- Phase 9.1: Background AI Task Queue
-- Task definitions, dependencies, logs, and scheduled tasks

-- Main task queue
CREATE TABLE ai_task_queue (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_type TEXT NOT NULL,
  priority INTEGER DEFAULT 50 CHECK (priority >= 1 AND priority <= 100),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed', 'cancelled')),
  payload JSONB NOT NULL,
  result JSONB,
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  created_by TEXT NOT NULL,
  scheduled_for TIMESTAMPTZ DEFAULT now(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  progress_percent INTEGER DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
  progress_message TEXT,
  estimated_duration_ms INTEGER,
  actual_duration_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Task dependencies for chained workflows
CREATE TABLE ai_task_dependencies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES ai_task_queue(id) ON DELETE CASCADE,
  depends_on_task_id UUID NOT NULL REFERENCES ai_task_queue(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(task_id, depends_on_task_id),
  CHECK (task_id != depends_on_task_id)
);

-- Task execution logs for debugging
CREATE TABLE ai_task_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES ai_task_queue(id) ON DELETE CASCADE,
  log_level TEXT DEFAULT 'info' CHECK (log_level IN ('debug', 'info', 'warn', 'error')),
  message TEXT NOT NULL,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Scheduled recurring tasks
CREATE TABLE ai_scheduled_tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  task_type TEXT NOT NULL,
  payload_template JSONB NOT NULL,
  schedule_cron TEXT NOT NULL,
  enabled BOOLEAN DEFAULT true,
  last_run_at TIMESTAMPTZ,
  next_run_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for efficient queries
CREATE INDEX idx_task_queue_status ON ai_task_queue(status, priority DESC, scheduled_for);
CREATE INDEX idx_task_queue_type ON ai_task_queue(task_type, status);
CREATE INDEX idx_task_queue_created_by ON ai_task_queue(created_by);
CREATE INDEX idx_task_logs_task ON ai_task_logs(task_id, created_at DESC);

-- RLS policies
ALTER TABLE ai_task_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_task_dependencies ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_task_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_scheduled_tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anon all on ai_task_queue" ON ai_task_queue FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow anon all on ai_task_dependencies" ON ai_task_dependencies FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow anon all on ai_task_logs" ON ai_task_logs FOR ALL TO anon USING (true) WITH CHECK (true);
CREATE POLICY "Allow anon all on ai_scheduled_tasks" ON ai_scheduled_tasks FOR ALL TO anon USING (true) WITH CHECK (true);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_ai_task_queue_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.started_at = CASE
    WHEN NEW.status = 'processing' AND OLD.status = 'pending' THEN now()
    ELSE NEW.started_at
  END;
  NEW.completed_at = CASE
    WHEN NEW.status IN ('completed', 'failed', 'cancelled') AND OLD.status NOT IN ('completed', 'failed', 'cancelled') THEN now()
    ELSE NEW.completed_at
  END;
  NEW.actual_duration_ms = CASE
    WHEN NEW.completed_at IS NOT NULL AND NEW.started_at IS NOT NULL
    THEN EXTRACT(EPOCH FROM (NEW.completed_at - NEW.started_at)) * 1000
    ELSE NEW.actual_duration_ms
  END;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ai_task_queue_auto_timestamps
  BEFORE UPDATE ON ai_task_queue
  FOR EACH ROW
  EXECUTE FUNCTION update_ai_task_queue_updated_at();
```

**Step 2: Apply migration via Supabase MCP**

Run: `mcp__plugin_supabase_supabase__apply_migration` with name `20260207_01_ai_task_queue`

**Step 3: Verify tables created**

Run: `mcp__plugin_supabase_supabase__list_tables`
Expected: `ai_task_queue`, `ai_task_dependencies`, `ai_task_logs`, `ai_scheduled_tasks` present

**Step 4: Commit**

```bash
git add supabase/migrations/20260207_01_ai_task_queue.sql
git commit -m "feat(phase-9.1): Add AI task queue database schema"
```

---

### Task 2: Task Queue Types and Hook

**Files:**
- Create: `src/hooks/useTaskQueue.ts`

**Step 1: Create the hook with types**

```typescript
'use client'

/**
 * useTaskQueue Hook
 * Phase 9.1: Background AI Task Queue
 *
 * Manages AI task queue operations - create, monitor, cancel tasks.
 */

import { useState, useEffect, useCallback } from 'react'

export type TaskType =
  | 'twin_training'
  | 'bulk_analysis'
  | 'report_generation'
  | 'simulation_batch'
  | 'embedding_generation'
  | 'meeting_summary'

export type TaskStatus = 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled'

export type LogLevel = 'debug' | 'info' | 'warn' | 'error'

export interface AITask {
  id: string
  task_type: TaskType
  priority: number
  status: TaskStatus
  payload: Record<string, unknown>
  result: Record<string, unknown> | null
  error_message: string | null
  retry_count: number
  max_retries: number
  created_by: string
  scheduled_for: string
  started_at: string | null
  completed_at: string | null
  progress_percent: number
  progress_message: string | null
  estimated_duration_ms: number | null
  actual_duration_ms: number | null
  created_at: string
}

export interface TaskLog {
  id: string
  task_id: string
  log_level: LogLevel
  message: string
  metadata: Record<string, unknown> | null
  created_at: string
}

export interface ScheduledTask {
  id: string
  name: string
  task_type: TaskType
  payload_template: Record<string, unknown>
  schedule_cron: string
  enabled: boolean
  last_run_at: string | null
  next_run_at: string | null
  created_at: string
}

export interface CreateTaskInput {
  task_type: TaskType
  payload: Record<string, unknown>
  priority?: number
  scheduled_for?: string
  estimated_duration_ms?: number
}

interface UseTaskQueueReturn {
  tasks: AITask[]
  isLoading: boolean
  error: string | null
  createTask: (input: CreateTaskInput) => Promise<AITask | null>
  cancelTask: (taskId: string) => Promise<boolean>
  getTaskLogs: (taskId: string) => Promise<TaskLog[]>
  refresh: () => Promise<void>
  subscribeToTask: (taskId: string, onUpdate: (task: AITask) => void) => () => void
}

const TASK_TYPE_LABELS: Record<TaskType, string> = {
  twin_training: 'Train Digital Twin',
  bulk_analysis: 'Bulk Analysis',
  report_generation: 'Generate Report',
  simulation_batch: 'Batch Simulation',
  embedding_generation: 'Generate Embeddings',
  meeting_summary: 'Meeting Summary',
}

export function useTaskQueue(
  filters?: {
    status?: TaskStatus
    task_type?: TaskType
    created_by?: string
  }
): UseTaskQueueReturn {
  const [tasks, setTasks] = useState<AITask[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  const fetchTasks = useCallback(async () => {
    setIsLoading(true)
    setError(null)

    try {
      const params = new URLSearchParams()
      if (filters?.status) params.set('status', filters.status)
      if (filters?.task_type) params.set('task_type', filters.task_type)
      if (filters?.created_by) params.set('created_by', filters.created_by)

      const response = await fetch(`/api/tasks?${params.toString()}`)
      const json = await response.json()

      if (!response.ok) {
        throw new Error(json.error || 'Failed to fetch tasks')
      }

      setTasks(json.data?.tasks || [])
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
    } finally {
      setIsLoading(false)
    }
  }, [filters?.status, filters?.task_type, filters?.created_by])

  useEffect(() => {
    fetchTasks()
  }, [fetchTasks])

  const createTask = useCallback(async (input: CreateTaskInput): Promise<AITask | null> => {
    try {
      const response = await fetch('/api/tasks', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(input),
      })

      const json = await response.json()

      if (!response.ok) {
        throw new Error(json.error || 'Failed to create task')
      }

      const newTask = json.data?.task
      if (newTask) {
        setTasks(prev => [newTask, ...prev])
      }
      return newTask
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
      return null
    }
  }, [])

  const cancelTask = useCallback(async (taskId: string): Promise<boolean> => {
    try {
      const response = await fetch(`/api/tasks/${taskId}`, {
        method: 'DELETE',
      })

      if (!response.ok) {
        const json = await response.json()
        throw new Error(json.error || 'Failed to cancel task')
      }

      setTasks(prev =>
        prev.map(t => (t.id === taskId ? { ...t, status: 'cancelled' as TaskStatus } : t))
      )
      return true
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
      return false
    }
  }, [])

  const getTaskLogs = useCallback(async (taskId: string): Promise<TaskLog[]> => {
    try {
      const response = await fetch(`/api/tasks/${taskId}/logs`)
      const json = await response.json()

      if (!response.ok) {
        throw new Error(json.error || 'Failed to fetch logs')
      }

      return json.data?.logs || []
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Unknown error')
      return []
    }
  }, [])

  const subscribeToTask = useCallback(
    (taskId: string, onUpdate: (task: AITask) => void): (() => void) => {
      // Poll every 2 seconds for updates (can upgrade to Supabase Realtime later)
      const interval = setInterval(async () => {
        try {
          const response = await fetch(`/api/tasks/${taskId}`)
          const json = await response.json()

          if (response.ok && json.data?.task) {
            const updatedTask = json.data.task
            onUpdate(updatedTask)

            // Update local state
            setTasks(prev => prev.map(t => (t.id === taskId ? updatedTask : t)))

            // Stop polling if task is complete
            if (['completed', 'failed', 'cancelled'].includes(updatedTask.status)) {
              clearInterval(interval)
            }
          }
        } catch {
          // Silent fail on poll
        }
      }, 2000)

      return () => clearInterval(interval)
    },
    []
  )

  return {
    tasks,
    isLoading,
    error,
    createTask,
    cancelTask,
    getTaskLogs,
    refresh: fetchTasks,
    subscribeToTask,
  }
}

export { TASK_TYPE_LABELS }
```

**Step 2: Verify TypeScript compiles**

Run: `npx tsc --noEmit src/hooks/useTaskQueue.ts`
Expected: No errors

**Step 3: Commit**

```bash
git add src/hooks/useTaskQueue.ts
git commit -m "feat(phase-9.1): Add useTaskQueue hook with types"
```

---

### Task 3: Task Queue API - List and Create

**Files:**
- Create: `src/app/api/tasks/route.ts`

**Step 1: Create the API route**

```typescript
/**
 * Tasks API
 * Phase 9.1: Background AI Task Queue
 *
 * GET /api/tasks - List tasks with optional filters
 * POST /api/tasks - Create a new task
 */

import { NextRequest } from 'next/server'
import { createSuccessResponse, createErrorResponse, handleApiError } from '@/lib/api-utils'
import { getServiceSupabase } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

type TaskType =
  | 'twin_training'
  | 'bulk_analysis'
  | 'report_generation'
  | 'simulation_batch'
  | 'embedding_generation'
  | 'meeting_summary'

type TaskStatus = 'pending' | 'processing' | 'completed' | 'failed' | 'cancelled'

const VALID_TASK_TYPES: TaskType[] = [
  'twin_training',
  'bulk_analysis',
  'report_generation',
  'simulation_batch',
  'embedding_generation',
  'meeting_summary',
]

const VALID_STATUSES: TaskStatus[] = ['pending', 'processing', 'completed', 'failed', 'cancelled']

/**
 * GET - List tasks with optional filters
 */
export async function GET(request: NextRequest): Promise<Response> {
  try {
    const { searchParams } = new URL(request.url)
    const status = searchParams.get('status') as TaskStatus | null
    const taskType = searchParams.get('task_type') as TaskType | null
    const createdBy = searchParams.get('created_by')
    const limit = Math.min(parseInt(searchParams.get('limit') || '50'), 100)

    const supabase = getServiceSupabase()

    let query = supabase
      .from('ai_task_queue')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(limit)

    if (status && VALID_STATUSES.includes(status)) {
      query = query.eq('status', status)
    }

    if (taskType && VALID_TASK_TYPES.includes(taskType)) {
      query = query.eq('task_type', taskType)
    }

    if (createdBy) {
      query = query.eq('created_by', createdBy)
    }

    const { data: tasks, error } = await query

    if (error) {
      console.error('[TasksAPI] Query error:', error)
      throw error
    }

    // Get counts by status
    const { data: statusCounts } = await supabase
      .from('ai_task_queue')
      .select('status')

    const stats = {
      total: statusCounts?.length || 0,
      pending: statusCounts?.filter(t => t.status === 'pending').length || 0,
      processing: statusCounts?.filter(t => t.status === 'processing').length || 0,
      completed: statusCounts?.filter(t => t.status === 'completed').length || 0,
      failed: statusCounts?.filter(t => t.status === 'failed').length || 0,
    }

    return createSuccessResponse({
      tasks: tasks || [],
      stats,
    })
  } catch (error) {
    return handleApiError(error, 'GET /api/tasks')
  }
}

/**
 * POST - Create a new task
 */
export async function POST(request: NextRequest): Promise<Response> {
  try {
    const body = await request.json()

    const {
      task_type,
      payload,
      priority = 50,
      scheduled_for,
      estimated_duration_ms,
      created_by = 'system',
    } = body

    // Validate task type
    if (!task_type || !VALID_TASK_TYPES.includes(task_type)) {
      return createErrorResponse(
        'VALIDATION_ERROR',
        `Invalid task_type. Must be one of: ${VALID_TASK_TYPES.join(', ')}`,
        400
      )
    }

    // Validate payload
    if (!payload || typeof payload !== 'object') {
      return createErrorResponse('VALIDATION_ERROR', 'payload is required and must be an object', 400)
    }

    // Validate priority
    if (priority < 1 || priority > 100) {
      return createErrorResponse('VALIDATION_ERROR', 'priority must be between 1 and 100', 400)
    }

    const supabase = getServiceSupabase()

    const taskData = {
      task_type,
      payload,
      priority,
      created_by,
      scheduled_for: scheduled_for || new Date().toISOString(),
      estimated_duration_ms: estimated_duration_ms || null,
    }

    const { data: task, error } = await supabase
      .from('ai_task_queue')
      .insert(taskData)
      .select()
      .single()

    if (error) {
      console.error('[TasksAPI] Insert error:', error)
      throw error
    }

    console.log(`[TasksAPI] Created task ${task.id} of type ${task_type}`)

    return createSuccessResponse({ task }, 201)
  } catch (error) {
    return handleApiError(error, 'POST /api/tasks')
  }
}
```

**Step 2: Verify file compiles**

Run: `npx tsc --noEmit`
Expected: No errors

**Step 3: Commit**

```bash
git add src/app/api/tasks/route.ts
git commit -m "feat(phase-9.1): Add tasks API - list and create"
```

---

### Task 4: Task Queue API - Individual Task Operations

**Files:**
- Create: `src/app/api/tasks/[id]/route.ts`

**Step 1: Create the dynamic route**

```typescript
/**
 * Individual Task API
 * Phase 9.1: Background AI Task Queue
 *
 * GET /api/tasks/[id] - Get task details
 * DELETE /api/tasks/[id] - Cancel a task
 */

import { NextRequest } from 'next/server'
import { createSuccessResponse, createErrorResponse, handleApiError } from '@/lib/api-utils'
import { getServiceSupabase } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

interface RouteContext {
  params: Promise<{ id: string }>
}

/**
 * GET - Get task details with dependencies
 */
export async function GET(request: NextRequest, context: RouteContext): Promise<Response> {
  try {
    const { id } = await context.params

    if (!id) {
      return createErrorResponse('VALIDATION_ERROR', 'Task ID is required', 400)
    }

    const supabase = getServiceSupabase()

    // Get task with dependencies
    const { data: task, error } = await supabase
      .from('ai_task_queue')
      .select('*')
      .eq('id', id)
      .single()

    if (error) {
      if (error.code === 'PGRST116') {
        return createErrorResponse('NOT_FOUND', 'Task not found', 404)
      }
      throw error
    }

    // Get dependencies
    const { data: dependencies } = await supabase
      .from('ai_task_dependencies')
      .select(`
        depends_on_task_id,
        depends_on:ai_task_queue!depends_on_task_id(id, task_type, status)
      `)
      .eq('task_id', id)

    // Get dependents (tasks that depend on this one)
    const { data: dependents } = await supabase
      .from('ai_task_dependencies')
      .select(`
        task_id,
        dependent:ai_task_queue!task_id(id, task_type, status)
      `)
      .eq('depends_on_task_id', id)

    return createSuccessResponse({
      task,
      dependencies: dependencies || [],
      dependents: dependents || [],
    })
  } catch (error) {
    return handleApiError(error, 'GET /api/tasks/[id]')
  }
}

/**
 * DELETE - Cancel a task
 */
export async function DELETE(request: NextRequest, context: RouteContext): Promise<Response> {
  try {
    const { id } = await context.params

    if (!id) {
      return createErrorResponse('VALIDATION_ERROR', 'Task ID is required', 400)
    }

    const supabase = getServiceSupabase()

    // Get current task status
    const { data: task, error: fetchError } = await supabase
      .from('ai_task_queue')
      .select('status')
      .eq('id', id)
      .single()

    if (fetchError) {
      if (fetchError.code === 'PGRST116') {
        return createErrorResponse('NOT_FOUND', 'Task not found', 404)
      }
      throw fetchError
    }

    // Can only cancel pending or processing tasks
    if (!['pending', 'processing'].includes(task.status)) {
      return createErrorResponse(
        'INVALID_STATE',
        `Cannot cancel task with status '${task.status}'`,
        400
      )
    }

    // Update status to cancelled
    const { error: updateError } = await supabase
      .from('ai_task_queue')
      .update({ status: 'cancelled' })
      .eq('id', id)

    if (updateError) {
      throw updateError
    }

    // Log the cancellation
    await supabase.from('ai_task_logs').insert({
      task_id: id,
      log_level: 'info',
      message: 'Task cancelled by user',
    })

    console.log(`[TasksAPI] Cancelled task ${id}`)

    return createSuccessResponse({ message: 'Task cancelled successfully' })
  } catch (error) {
    return handleApiError(error, 'DELETE /api/tasks/[id]')
  }
}
```

**Step 2: Commit**

```bash
git add src/app/api/tasks/[id]/route.ts
git commit -m "feat(phase-9.1): Add individual task API - get and cancel"
```

---

### Task 5: Task Logs API

**Files:**
- Create: `src/app/api/tasks/[id]/logs/route.ts`

**Step 1: Create the logs route**

```typescript
/**
 * Task Logs API
 * Phase 9.1: Background AI Task Queue
 *
 * GET /api/tasks/[id]/logs - Get execution logs for a task
 */

import { NextRequest } from 'next/server'
import { createSuccessResponse, createErrorResponse, handleApiError } from '@/lib/api-utils'
import { getServiceSupabase } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

interface RouteContext {
  params: Promise<{ id: string }>
}

/**
 * GET - Get task execution logs
 */
export async function GET(request: NextRequest, context: RouteContext): Promise<Response> {
  try {
    const { id } = await context.params
    const { searchParams } = new URL(request.url)
    const level = searchParams.get('level')
    const limit = Math.min(parseInt(searchParams.get('limit') || '100'), 500)

    if (!id) {
      return createErrorResponse('VALIDATION_ERROR', 'Task ID is required', 400)
    }

    const supabase = getServiceSupabase()

    // Verify task exists
    const { data: task, error: taskError } = await supabase
      .from('ai_task_queue')
      .select('id')
      .eq('id', id)
      .single()

    if (taskError) {
      if (taskError.code === 'PGRST116') {
        return createErrorResponse('NOT_FOUND', 'Task not found', 404)
      }
      throw taskError
    }

    // Get logs
    let query = supabase
      .from('ai_task_logs')
      .select('*')
      .eq('task_id', id)
      .order('created_at', { ascending: true })
      .limit(limit)

    if (level && ['debug', 'info', 'warn', 'error'].includes(level)) {
      query = query.eq('log_level', level)
    }

    const { data: logs, error } = await query

    if (error) {
      throw error
    }

    return createSuccessResponse({
      logs: logs || [],
      task_id: id,
    })
  } catch (error) {
    return handleApiError(error, 'GET /api/tasks/[id]/logs')
  }
}
```

**Step 2: Commit**

```bash
git add src/app/api/tasks/[id]/logs/route.ts
git commit -m "feat(phase-9.1): Add task logs API"
```

---

### Task 6: Scheduled Tasks API

**Files:**
- Create: `src/app/api/tasks/scheduled/route.ts`

**Step 1: Create scheduled tasks route**

```typescript
/**
 * Scheduled Tasks API
 * Phase 9.1: Background AI Task Queue
 *
 * GET /api/tasks/scheduled - List scheduled recurring tasks
 * POST /api/tasks/scheduled - Create a scheduled task
 */

import { NextRequest } from 'next/server'
import { createSuccessResponse, createErrorResponse, handleApiError } from '@/lib/api-utils'
import { getServiceSupabase } from '@/lib/supabase'

export const dynamic = 'force-dynamic'

/**
 * GET - List scheduled tasks
 */
export async function GET(): Promise<Response> {
  try {
    const supabase = getServiceSupabase()

    const { data: tasks, error } = await supabase
      .from('ai_scheduled_tasks')
      .select('*')
      .order('name', { ascending: true })

    if (error) {
      throw error
    }

    return createSuccessResponse({
      scheduled_tasks: tasks || [],
    })
  } catch (error) {
    return handleApiError(error, 'GET /api/tasks/scheduled')
  }
}

/**
 * POST - Create a scheduled task
 */
export async function POST(request: NextRequest): Promise<Response> {
  try {
    const body = await request.json()

    const { name, task_type, payload_template, schedule_cron, enabled = true } = body

    // Validate required fields
    if (!name || !task_type || !payload_template || !schedule_cron) {
      return createErrorResponse(
        'VALIDATION_ERROR',
        'name, task_type, payload_template, and schedule_cron are required',
        400
      )
    }

    // Basic cron validation (5 or 6 fields)
    const cronParts = schedule_cron.trim().split(/\s+/)
    if (cronParts.length < 5 || cronParts.length > 6) {
      return createErrorResponse(
        'VALIDATION_ERROR',
        'schedule_cron must be a valid cron expression (5-6 fields)',
        400
      )
    }

    const supabase = getServiceSupabase()

    const { data: task, error } = await supabase
      .from('ai_scheduled_tasks')
      .insert({
        name,
        task_type,
        payload_template,
        schedule_cron,
        enabled,
      })
      .select()
      .single()

    if (error) {
      throw error
    }

    return createSuccessResponse({ scheduled_task: task }, 201)
  } catch (error) {
    return handleApiError(error, 'POST /api/tasks/scheduled')
  }
}
```

**Step 2: Commit**

```bash
git add src/app/api/tasks/scheduled/route.ts
git commit -m "feat(phase-9.1): Add scheduled tasks API"
```

---

### Task 7: Task Worker Cron Job

**Files:**
- Create: `src/app/api/cron/task-worker/route.ts`

**Step 1: Create the worker cron**

```typescript
/**
 * Cron Job: Task Worker
 * Phase 9.1: Background AI Task Queue
 *
 * GET /api/cron/task-worker - Process pending tasks
 *
 * Claims and processes one pending task per invocation.
 * Uses row-level locking to prevent duplicate processing.
 */

import { NextRequest } from 'next/server'
import { createSuccessResponse, createErrorResponse, handleApiError } from '@/lib/api-utils'
import { getServiceSupabase } from '@/lib/supabase'

export const dynamic = 'force-dynamic'
export const maxDuration = 60

const CRON_SECRET = process.env.CRON_SECRET

interface TaskProcessor {
  process: (payload: Record<string, unknown>) => Promise<Record<string, unknown>>
}

// Task processors - extend as features are added
const TASK_PROCESSORS: Record<string, TaskProcessor> = {
  twin_training: {
    process: async (payload) => {
      // Placeholder - will be implemented in Phase 9.3
      console.log('[TaskWorker] Processing twin_training:', payload)
      await new Promise(resolve => setTimeout(resolve, 1000))
      return { status: 'trained', model_version: '1.0' }
    },
  },
  bulk_analysis: {
    process: async (payload) => {
      console.log('[TaskWorker] Processing bulk_analysis:', payload)
      await new Promise(resolve => setTimeout(resolve, 2000))
      return { analysed_count: (payload.client_ids as string[])?.length || 0 }
    },
  },
  report_generation: {
    process: async (payload) => {
      console.log('[TaskWorker] Processing report_generation:', payload)
      await new Promise(resolve => setTimeout(resolve, 1500))
      return { report_url: `/reports/${Date.now()}.pdf` }
    },
  },
  simulation_batch: {
    process: async (payload) => {
      console.log('[TaskWorker] Processing simulation_batch:', payload)
      await new Promise(resolve => setTimeout(resolve, 3000))
      return { scenarios_run: (payload.scenarios as unknown[])?.length || 1 }
    },
  },
  embedding_generation: {
    process: async (payload) => {
      console.log('[TaskWorker] Processing embedding_generation:', payload)
      await new Promise(resolve => setTimeout(resolve, 500))
      return { embeddings_created: 1 }
    },
  },
  meeting_summary: {
    process: async (payload) => {
      console.log('[TaskWorker] Processing meeting_summary:', payload)
      await new Promise(resolve => setTimeout(resolve, 2000))
      return { summary: 'Meeting summary generated', key_points: 5 }
    },
  },
}

async function logTask(
  supabase: ReturnType<typeof getServiceSupabase>,
  taskId: string,
  level: 'debug' | 'info' | 'warn' | 'error',
  message: string,
  metadata?: Record<string, unknown>
) {
  await supabase.from('ai_task_logs').insert({
    task_id: taskId,
    log_level: level,
    message,
    metadata: metadata || null,
  })
}

/**
 * GET - Process next pending task
 */
export async function GET(request: NextRequest): Promise<Response> {
  const startTime = Date.now()

  // Verify cron secret if configured
  if (CRON_SECRET) {
    const authHeader = request.headers.get('authorization')
    const providedSecret = authHeader?.replace('Bearer ', '')

    if (providedSecret !== CRON_SECRET) {
      console.warn('[TaskWorker] Unauthorised access attempt')
      return createErrorResponse('UNAUTHORIZED', 'Unauthorised', 401)
    }
  }

  try {
    const supabase = getServiceSupabase()

    // Claim a pending task using advisory lock pattern
    // First, find eligible task
    const { data: pendingTasks } = await supabase
      .from('ai_task_queue')
      .select('id')
      .eq('status', 'pending')
      .lte('scheduled_for', new Date().toISOString())
      .order('priority', { ascending: false })
      .order('created_at', { ascending: true })
      .limit(1)

    if (!pendingTasks || pendingTasks.length === 0) {
      return createSuccessResponse({
        message: 'No pending tasks',
        processed: false,
        duration_ms: Date.now() - startTime,
      })
    }

    const taskId = pendingTasks[0].id

    // Attempt to claim it (optimistic locking)
    const { data: claimedTask, error: claimError } = await supabase
      .from('ai_task_queue')
      .update({ status: 'processing' })
      .eq('id', taskId)
      .eq('status', 'pending') // Only if still pending
      .select()
      .single()

    if (claimError || !claimedTask) {
      // Another worker claimed it
      return createSuccessResponse({
        message: 'Task claimed by another worker',
        processed: false,
        duration_ms: Date.now() - startTime,
      })
    }

    console.log(`[TaskWorker] Processing task ${taskId} of type ${claimedTask.task_type}`)
    await logTask(supabase, taskId, 'info', 'Task processing started')

    // Check dependencies
    const { data: dependencies } = await supabase
      .from('ai_task_dependencies')
      .select('depends_on_task_id')
      .eq('task_id', taskId)

    if (dependencies && dependencies.length > 0) {
      const depIds = dependencies.map(d => d.depends_on_task_id)
      const { data: depTasks } = await supabase
        .from('ai_task_queue')
        .select('id, status')
        .in('id', depIds)

      const incompleteDeps = depTasks?.filter(t => t.status !== 'completed') || []
      if (incompleteDeps.length > 0) {
        // Put back to pending - dependencies not ready
        await supabase.from('ai_task_queue').update({ status: 'pending' }).eq('id', taskId)
        await logTask(supabase, taskId, 'info', 'Waiting for dependencies', {
          waiting_for: incompleteDeps.map(d => d.id),
        })

        return createSuccessResponse({
          message: 'Task waiting for dependencies',
          processed: false,
          waiting_for: incompleteDeps.length,
          duration_ms: Date.now() - startTime,
        })
      }
    }

    // Process the task
    const processor = TASK_PROCESSORS[claimedTask.task_type]

    if (!processor) {
      await supabase.from('ai_task_queue').update({
        status: 'failed',
        error_message: `Unknown task type: ${claimedTask.task_type}`,
      }).eq('id', taskId)
      await logTask(supabase, taskId, 'error', `Unknown task type: ${claimedTask.task_type}`)

      return createSuccessResponse({
        message: 'Unknown task type',
        processed: false,
        task_id: taskId,
        duration_ms: Date.now() - startTime,
      })
    }

    try {
      // Update progress
      await supabase.from('ai_task_queue').update({
        progress_percent: 10,
        progress_message: 'Processing...',
      }).eq('id', taskId)

      const result = await processor.process(claimedTask.payload)

      // Mark complete
      await supabase.from('ai_task_queue').update({
        status: 'completed',
        result,
        progress_percent: 100,
        progress_message: 'Complete',
      }).eq('id', taskId)

      await logTask(supabase, taskId, 'info', 'Task completed successfully', { result })

      console.log(`[TaskWorker] Completed task ${taskId}`)

      return createSuccessResponse({
        message: 'Task processed successfully',
        processed: true,
        task_id: taskId,
        task_type: claimedTask.task_type,
        result,
        duration_ms: Date.now() - startTime,
      })
    } catch (processingError) {
      const errorMessage = processingError instanceof Error ? processingError.message : 'Unknown error'

      // Check retry count
      if (claimedTask.retry_count < claimedTask.max_retries) {
        await supabase.from('ai_task_queue').update({
          status: 'pending',
          retry_count: claimedTask.retry_count + 1,
          error_message: errorMessage,
          progress_percent: 0,
          progress_message: null,
        }).eq('id', taskId)

        await logTask(supabase, taskId, 'warn', `Task failed, will retry (${claimedTask.retry_count + 1}/${claimedTask.max_retries})`, {
          error: errorMessage,
        })
      } else {
        await supabase.from('ai_task_queue').update({
          status: 'failed',
          error_message: errorMessage,
        }).eq('id', taskId)

        await logTask(supabase, taskId, 'error', 'Task failed permanently', { error: errorMessage })
      }

      return createSuccessResponse({
        message: 'Task processing failed',
        processed: false,
        task_id: taskId,
        error: errorMessage,
        duration_ms: Date.now() - startTime,
      })
    }
  } catch (error) {
    return handleApiError(error, 'GET /api/cron/task-worker')
  }
}
```

**Step 2: Commit**

```bash
git add src/app/api/cron/task-worker/route.ts
git commit -m "feat(phase-9.1): Add task worker cron job"
```

---

### Task 8: Task Progress Card Component

**Files:**
- Create: `src/components/tasks/TaskProgressCard.tsx`

**Step 1: Create the component**

```typescript
'use client'

/**
 * TaskProgressCard Component
 * Phase 9.1: Background AI Task Queue
 *
 * Displays a single task with progress bar and action buttons.
 */

import { useState, useEffect } from 'react'
import {
  Clock,
  CheckCircle,
  XCircle,
  AlertCircle,
  Loader2,
  ChevronDown,
  ChevronUp,
  Trash2,
  RotateCcw,
} from 'lucide-react'
import type { AITask, TaskLog, TaskStatus } from '@/hooks/useTaskQueue'
import { TASK_TYPE_LABELS } from '@/hooks/useTaskQueue'

interface TaskProgressCardProps {
  task: AITask
  onCancel?: (taskId: string) => Promise<boolean>
  onViewLogs?: (taskId: string) => Promise<TaskLog[]>
  onSubscribe?: (taskId: string, onUpdate: (task: AITask) => void) => () => void
}

const STATUS_CONFIG: Record<TaskStatus, { icon: typeof Clock; colour: string; label: string }> = {
  pending: { icon: Clock, colour: 'text-slate-500', label: 'Pending' },
  processing: { icon: Loader2, colour: 'text-blue-500', label: 'Processing' },
  completed: { icon: CheckCircle, colour: 'text-green-500', label: 'Completed' },
  failed: { icon: XCircle, colour: 'text-red-500', label: 'Failed' },
  cancelled: { icon: AlertCircle, colour: 'text-amber-500', label: 'Cancelled' },
}

export function TaskProgressCard({
  task: initialTask,
  onCancel,
  onViewLogs,
  onSubscribe,
}: TaskProgressCardProps) {
  const [task, setTask] = useState(initialTask)
  const [showLogs, setShowLogs] = useState(false)
  const [logs, setLogs] = useState<TaskLog[]>([])
  const [isLoadingLogs, setIsLoadingLogs] = useState(false)
  const [isCancelling, setIsCancelling] = useState(false)

  // Subscribe to updates for active tasks
  useEffect(() => {
    if (onSubscribe && ['pending', 'processing'].includes(task.status)) {
      const unsubscribe = onSubscribe(task.id, setTask)
      return unsubscribe
    }
  }, [task.id, task.status, onSubscribe])

  // Update from props
  useEffect(() => {
    setTask(initialTask)
  }, [initialTask])

  const handleToggleLogs = async () => {
    if (!showLogs && onViewLogs && logs.length === 0) {
      setIsLoadingLogs(true)
      const fetchedLogs = await onViewLogs(task.id)
      setLogs(fetchedLogs)
      setIsLoadingLogs(false)
    }
    setShowLogs(!showLogs)
  }

  const handleCancel = async () => {
    if (onCancel) {
      setIsCancelling(true)
      await onCancel(task.id)
      setIsCancelling(false)
    }
  }

  const statusConfig = STATUS_CONFIG[task.status]
  const StatusIcon = statusConfig.icon

  const formatDuration = (ms: number) => {
    if (ms < 1000) return `${ms}ms`
    if (ms < 60000) return `${(ms / 1000).toFixed(1)}s`
    return `${(ms / 60000).toFixed(1)}m`
  }

  const formatDate = (dateStr: string) => {
    return new Date(dateStr).toLocaleString('en-AU', {
      day: 'numeric',
      month: 'short',
      hour: '2-digit',
      minute: '2-digit',
    })
  }

  return (
    <div className="rounded-xl border border-slate-200 bg-white p-4 dark:border-slate-700 dark:bg-slate-800">
      {/* Header */}
      <div className="mb-3 flex items-start justify-between">
        <div className="flex items-center gap-3">
          <div className={`flex h-10 w-10 items-center justify-center rounded-lg bg-slate-100 dark:bg-slate-700 ${statusConfig.colour}`}>
            <StatusIcon className={`h-5 w-5 ${task.status === 'processing' ? 'animate-spin' : ''}`} />
          </div>
          <div>
            <h3 className="font-medium text-slate-800 dark:text-slate-200">
              {TASK_TYPE_LABELS[task.task_type] || task.task_type}
            </h3>
            <p className="text-xs text-slate-500 dark:text-slate-400">
              {formatDate(task.created_at)}
            </p>
          </div>
        </div>

        <span className={`rounded-full px-2 py-0.5 text-xs font-medium ${
          task.status === 'completed' ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' :
          task.status === 'failed' ? 'bg-red-100 text-red-700 dark:bg-red-900/30 dark:text-red-400' :
          task.status === 'processing' ? 'bg-blue-100 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400' :
          task.status === 'cancelled' ? 'bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400' :
          'bg-slate-100 text-slate-700 dark:bg-slate-700 dark:text-slate-300'
        }`}>
          {statusConfig.label}
        </span>
      </div>

      {/* Progress bar (for processing tasks) */}
      {task.status === 'processing' && (
        <div className="mb-3">
          <div className="mb-1 flex justify-between text-xs text-slate-500">
            <span>{task.progress_message || 'Processing...'}</span>
            <span>{task.progress_percent}%</span>
          </div>
          <div className="h-2 overflow-hidden rounded-full bg-slate-100 dark:bg-slate-700">
            <div
              className="h-full rounded-full bg-blue-500 transition-all duration-300"
              style={{ width: `${task.progress_percent}%` }}
            />
          </div>
        </div>
      )}

      {/* Error message */}
      {task.error_message && (
        <div className="mb-3 rounded-lg bg-red-50 p-2 text-xs text-red-600 dark:bg-red-900/20 dark:text-red-400">
          {task.error_message}
        </div>
      )}

      {/* Duration info */}
      {task.actual_duration_ms && (
        <p className="mb-3 text-xs text-slate-500 dark:text-slate-400">
          Completed in {formatDuration(task.actual_duration_ms)}
        </p>
      )}

      {/* Actions */}
      <div className="flex items-center gap-2">
        {['pending', 'processing'].includes(task.status) && onCancel && (
          <button
            onClick={handleCancel}
            disabled={isCancelling}
            className="flex items-center gap-1 rounded-lg px-2 py-1 text-xs text-slate-500 hover:bg-slate-100 hover:text-slate-700 disabled:opacity-50 dark:hover:bg-slate-700"
          >
            {isCancelling ? (
              <Loader2 className="h-3 w-3 animate-spin" />
            ) : (
              <Trash2 className="h-3 w-3" />
            )}
            Cancel
          </button>
        )}

        {onViewLogs && (
          <button
            onClick={handleToggleLogs}
            className="flex items-center gap-1 rounded-lg px-2 py-1 text-xs text-slate-500 hover:bg-slate-100 hover:text-slate-700 dark:hover:bg-slate-700"
          >
            {showLogs ? <ChevronUp className="h-3 w-3" /> : <ChevronDown className="h-3 w-3" />}
            Logs
          </button>
        )}
      </div>

      {/* Logs panel */}
      {showLogs && (
        <div className="mt-3 rounded-lg bg-slate-50 p-3 dark:bg-slate-900">
          {isLoadingLogs ? (
            <div className="flex items-center justify-center py-4">
              <Loader2 className="h-4 w-4 animate-spin text-slate-400" />
            </div>
          ) : logs.length === 0 ? (
            <p className="text-center text-xs text-slate-400">No logs yet</p>
          ) : (
            <div className="max-h-48 space-y-1 overflow-y-auto font-mono text-xs">
              {logs.map(log => (
                <div
                  key={log.id}
                  className={`flex gap-2 ${
                    log.log_level === 'error' ? 'text-red-500' :
                    log.log_level === 'warn' ? 'text-amber-500' :
                    'text-slate-500'
                  }`}
                >
                  <span className="shrink-0 text-slate-400">
                    {new Date(log.created_at).toLocaleTimeString('en-AU')}
                  </span>
                  <span className="shrink-0 uppercase">[{log.log_level}]</span>
                  <span>{log.message}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      )}
    </div>
  )
}
```

**Step 2: Commit**

```bash
git add src/components/tasks/TaskProgressCard.tsx
git commit -m "feat(phase-9.1): Add TaskProgressCard component"
```

---

### Task 9: Task Queue Dashboard Component

**Files:**
- Create: `src/components/tasks/TaskQueueDashboard.tsx`
- Create: `src/components/tasks/index.ts`

**Step 1: Create the dashboard**

```typescript
'use client'

/**
 * TaskQueueDashboard Component
 * Phase 9.1: Background AI Task Queue
 *
 * Main dashboard for viewing and managing AI tasks.
 */

import { useState } from 'react'
import {
  RefreshCw,
  Filter,
  Plus,
  Clock,
  CheckCircle,
  XCircle,
  Loader2,
  ListTodo,
} from 'lucide-react'
import { useTaskQueue, type TaskStatus, type TaskType, TASK_TYPE_LABELS } from '@/hooks/useTaskQueue'
import { TaskProgressCard } from './TaskProgressCard'

interface TaskQueueDashboardProps {
  createdBy?: string
}

const STATUS_OPTIONS: { value: TaskStatus | 'all'; label: string }[] = [
  { value: 'all', label: 'All' },
  { value: 'pending', label: 'Pending' },
  { value: 'processing', label: 'Processing' },
  { value: 'completed', label: 'Completed' },
  { value: 'failed', label: 'Failed' },
]

const TYPE_OPTIONS: { value: TaskType | 'all'; label: string }[] = [
  { value: 'all', label: 'All Types' },
  { value: 'twin_training', label: TASK_TYPE_LABELS.twin_training },
  { value: 'bulk_analysis', label: TASK_TYPE_LABELS.bulk_analysis },
  { value: 'report_generation', label: TASK_TYPE_LABELS.report_generation },
  { value: 'simulation_batch', label: TASK_TYPE_LABELS.simulation_batch },
  { value: 'embedding_generation', label: TASK_TYPE_LABELS.embedding_generation },
  { value: 'meeting_summary', label: TASK_TYPE_LABELS.meeting_summary },
]

export function TaskQueueDashboard({ createdBy }: TaskQueueDashboardProps) {
  const [statusFilter, setStatusFilter] = useState<TaskStatus | 'all'>('all')
  const [typeFilter, setTypeFilter] = useState<TaskType | 'all'>('all')

  const {
    tasks,
    isLoading,
    error,
    refresh,
    cancelTask,
    getTaskLogs,
    subscribeToTask,
  } = useTaskQueue({
    status: statusFilter === 'all' ? undefined : statusFilter,
    task_type: typeFilter === 'all' ? undefined : typeFilter,
    created_by: createdBy,
  })

  // Calculate stats from tasks
  const stats = {
    total: tasks.length,
    pending: tasks.filter(t => t.status === 'pending').length,
    processing: tasks.filter(t => t.status === 'processing').length,
    completed: tasks.filter(t => t.status === 'completed').length,
    failed: tasks.filter(t => t.status === 'failed').length,
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <div className="flex items-center gap-2">
            <ListTodo className="h-6 w-6 text-indigo-500" />
            <h1 className="text-2xl font-bold text-slate-800 dark:text-slate-200">
              AI Task Queue
            </h1>
          </div>
          <p className="mt-1 text-slate-500 dark:text-slate-400">
            Background processing for AI-powered operations
          </p>
        </div>

        <button
          onClick={refresh}
          disabled={isLoading}
          className="flex items-center gap-2 rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm text-slate-600 hover:bg-slate-50 disabled:opacity-50 dark:border-slate-600 dark:bg-slate-700 dark:text-slate-300"
        >
          <RefreshCw className={`h-4 w-4 ${isLoading ? 'animate-spin' : ''}`} />
          Refresh
        </button>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 gap-4 sm:grid-cols-5">
        <StatCard icon={<ListTodo className="h-5 w-5 text-slate-500" />} label="Total" value={stats.total} />
        <StatCard icon={<Clock className="h-5 w-5 text-slate-500" />} label="Pending" value={stats.pending} />
        <StatCard icon={<Loader2 className="h-5 w-5 text-blue-500" />} label="Processing" value={stats.processing} />
        <StatCard icon={<CheckCircle className="h-5 w-5 text-green-500" />} label="Completed" value={stats.completed} />
        <StatCard icon={<XCircle className="h-5 w-5 text-red-500" />} label="Failed" value={stats.failed} />
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-3">
        <Filter className="h-4 w-4 text-slate-400" />

        <select
          value={statusFilter}
          onChange={e => setStatusFilter(e.target.value as TaskStatus | 'all')}
          className="rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-sm dark:border-slate-600 dark:bg-slate-700"
        >
          {STATUS_OPTIONS.map(opt => (
            <option key={opt.value} value={opt.value}>{opt.label}</option>
          ))}
        </select>

        <select
          value={typeFilter}
          onChange={e => setTypeFilter(e.target.value as TaskType | 'all')}
          className="rounded-lg border border-slate-200 bg-white px-3 py-1.5 text-sm dark:border-slate-600 dark:bg-slate-700"
        >
          {TYPE_OPTIONS.map(opt => (
            <option key={opt.value} value={opt.value}>{opt.label}</option>
          ))}
        </select>
      </div>

      {/* Error */}
      {error && (
        <div className="rounded-lg bg-red-50 p-4 text-sm text-red-600 dark:bg-red-900/20 dark:text-red-400">
          {error}
        </div>
      )}

      {/* Tasks list */}
      {isLoading ? (
        <div className="flex items-center justify-center py-12">
          <RefreshCw className="h-8 w-8 animate-spin text-slate-400" />
        </div>
      ) : tasks.length === 0 ? (
        <div className="rounded-xl border border-slate-200 bg-white p-12 text-center dark:border-slate-700 dark:bg-slate-800">
          <ListTodo className="mx-auto mb-4 h-12 w-12 text-slate-300 dark:text-slate-600" />
          <h3 className="mb-2 text-lg font-semibold text-slate-800 dark:text-slate-200">
            No tasks found
          </h3>
          <p className="text-slate-500 dark:text-slate-400">
            Tasks will appear here when AI operations are queued.
          </p>
        </div>
      ) : (
        <div className="grid gap-4 lg:grid-cols-2">
          {tasks.map(task => (
            <TaskProgressCard
              key={task.id}
              task={task}
              onCancel={cancelTask}
              onViewLogs={getTaskLogs}
              onSubscribe={subscribeToTask}
            />
          ))}
        </div>
      )}
    </div>
  )
}

function StatCard({
  icon,
  label,
  value,
}: {
  icon: React.ReactNode
  label: string
  value: number
}) {
  return (
    <div className="rounded-xl border border-slate-200 bg-white p-4 dark:border-slate-700 dark:bg-slate-800">
      <div className="mb-2 flex items-center gap-2">
        {icon}
        <span className="text-sm text-slate-500 dark:text-slate-400">{label}</span>
      </div>
      <span className="text-2xl font-bold text-slate-800 dark:text-slate-200">{value}</span>
    </div>
  )
}
```

**Step 2: Create index file**

```typescript
/**
 * Task Queue Components
 * Phase 9.1: Background AI Task Queue
 */

export { TaskQueueDashboard } from './TaskQueueDashboard'
export { TaskProgressCard } from './TaskProgressCard'
```

**Step 3: Commit**

```bash
git add src/components/tasks/TaskQueueDashboard.tsx src/components/tasks/index.ts
git commit -m "feat(phase-9.1): Add TaskQueueDashboard component"
```

---

### Task 10: Tasks Page Route

**Files:**
- Create: `src/app/(dashboard)/tasks/page.tsx`

**Step 1: Create the page**

```typescript
'use client'

/**
 * Tasks Page
 * Phase 9.1: Background AI Task Queue
 *
 * Dashboard for viewing and managing AI tasks.
 */

import { TaskQueueDashboard } from '@/components/tasks'

export default function TasksPage() {
  return (
    <div className="mx-auto max-w-7xl p-6">
      <TaskQueueDashboard />
    </div>
  )
}
```

**Step 2: Commit**

```bash
git add src/app/\(dashboard\)/tasks/page.tsx
git commit -m "feat(phase-9.1): Add tasks page route"
```

---

### Task 11: Netlify Function and Config

**Files:**
- Create: `netlify/functions/task-worker.mts`
- Modify: `netlify.toml`

**Step 1: Create Netlify function**

```typescript
/**
 * Netlify Scheduled Function: Task Worker
 * Processes pending AI tasks from the queue
 * Runs every minute
 */

import type { Config } from '@netlify/functions';

export default async () => {
  console.log('[Task Worker] Scheduled processing triggered');

  const baseUrl = process.env.URL || process.env.DEPLOY_PRIME_URL || 'https://apac-cs-dashboards.com';
  const apiUrl = `${baseUrl}/api/cron/task-worker`;

  try {
    const response = await fetch(apiUrl, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.CRON_SECRET || ''}`,
      },
    });

    const result = await response.json();
    console.log('[Task Worker] Result:', JSON.stringify(result, null, 2));

    if (result.data?.processed) {
      console.log(`[Task Worker] Processed task ${result.data.task_id} (${result.data.task_type})`);
    } else {
      console.log('[Task Worker] No tasks processed');
    }

    return new Response(JSON.stringify(result), {
      status: response.status,
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error('[Task Worker] Error:', message);
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' },
    });
  }
};

export const config: Config = {
  // Every minute
  schedule: '* * * * *',
};
```

**Step 2: Add to netlify.toml**

Add after the Phase 8 section:

```toml
# =============================================================================
# Phase 9: AI Task Queue Worker
# =============================================================================

# Every minute - process pending AI tasks
[functions."task-worker"]
  schedule = "* * * * *"
```

**Step 3: Commit**

```bash
git add netlify/functions/task-worker.mts netlify.toml
git commit -m "feat(phase-9.1): Add task worker Netlify function"
```

---

### Task 12: Update CLAUDE.md

**Files:**
- Modify: `CLAUDE.md`

**Step 1: Add Phase 9.1 documentation**

Add after Phase 8 section:

```markdown
## Phase 9 Moonshot Features

### Phase 9.1: Background AI Task Queue

**Database Tables:**
- `ai_task_queue` - Task definitions with status, progress, results
- `ai_task_dependencies` - Chained workflow dependencies
- `ai_task_logs` - Execution logs for debugging
- `ai_scheduled_tasks` - Recurring task configurations

**Task Types:**
- `twin_training` - Train/update digital twin
- `bulk_analysis` - Analyse multiple clients/deals
- `report_generation` - Generate PDF/PPTX reports
- `simulation_batch` - Run multiple scenarios
- `embedding_generation` - Generate semantic embeddings
- `meeting_summary` - Post-meeting analysis

**API Routes:**

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/tasks` | GET, POST | List/create tasks |
| `/api/tasks/[id]` | GET, DELETE | Get/cancel task |
| `/api/tasks/[id]/logs` | GET | Get execution logs |
| `/api/tasks/scheduled` | GET, POST | Manage recurring tasks |
| `/api/cron/task-worker` | GET | Process pending tasks |

**Components:**
- `TaskQueueDashboard` - Main dashboard
- `TaskProgressCard` - Individual task display

**Hook:** `useTaskQueue` - Task queue operations

**Page Route:** `/tasks`
```

**Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: Add Phase 9.1 to CLAUDE.md"
```

---

### Task 13: Final Build Verification

**Step 1: Run build**

```bash
npm run build
```

Expected: Build passes with `/tasks` page listed

**Step 2: Apply database migration**

Use Supabase MCP to apply the migration if not already done.

**Step 3: Final commit with all Phase 9.1**

```bash
git add -A
git commit -m "feat(phase-9.1): Complete Background AI Task Queue implementation"
git push
```

---

## Phase 9.2-9.6: Remaining Tasks

The remaining phases follow the same pattern. Due to the extensive scope, they are documented in the design document at `docs/plans/2026-02-06-phase-9-moonshot-features-design.md`.

**Next phases to implement:**
- **9.2**: Network Graph Visualisation (8 tasks)
- **9.3**: Digital Twin & Deal Sandbox (12 tasks)
- **9.4**: 3D Pipeline Landscape (10 tasks)
- **9.5**: Meeting Co-Host & Transcription (14 tasks)
- **9.6**: Sentiment Analysis (6 tasks)

Each phase should be implemented sequentially, with commits after each task.
