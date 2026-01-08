-- Migration: Enable historical data tracking for support_sla_metrics
-- Date: 2026-01-08
-- Purpose: Add composite unique constraint and indexes for efficient trend queries
--
-- Run this SQL in Supabase SQL Editor: https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/sql/new

-- 1. Add composite unique constraint to prevent duplicate client+period combinations
-- This allows appending monthly records instead of overwriting
ALTER TABLE support_sla_metrics
ADD CONSTRAINT support_sla_metrics_client_period_unique
UNIQUE (client_name, period_end);

-- 2. Add indexes for efficient trend queries

-- Index for filtering by client
CREATE INDEX IF NOT EXISTS idx_support_metrics_client
ON support_sla_metrics (client_name);

-- Index for sorting by period (most recent first)
CREATE INDEX IF NOT EXISTS idx_support_metrics_period
ON support_sla_metrics (period_end DESC);

-- Composite index for client trend queries (e.g., "get last 6 months for client X")
CREATE INDEX IF NOT EXISTS idx_support_metrics_client_period
ON support_sla_metrics (client_name, period_end DESC);

-- Index for health score queries (find at-risk clients)
CREATE INDEX IF NOT EXISTS idx_support_metrics_health_score
ON support_sla_metrics (resolution_sla_percent)
WHERE resolution_sla_percent IS NOT NULL;

-- 3. Verify migration
SELECT
  'support_sla_metrics' as table_name,
  COUNT(*) as record_count,
  COUNT(DISTINCT client_name) as unique_clients,
  COUNT(DISTINCT period_end) as unique_periods
FROM support_sla_metrics;

-- Show constraint was added
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'support_sla_metrics'
AND constraint_type IN ('UNIQUE', 'PRIMARY KEY');
