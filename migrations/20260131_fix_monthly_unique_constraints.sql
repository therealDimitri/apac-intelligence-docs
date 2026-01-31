-- ============================================================================
-- Fix Monthly UNIQUE Constraints for Multi-Year Support
-- Created: 31 January 2026
-- Purpose: Allow storing 2025 + 2026 data simultaneously in monthly tables
-- ============================================================================

-- ============================================================
-- 1. FIX burc_monthly_ebita
-- Old: UNIQUE(month) - only allows one row per calendar date
-- New: UNIQUE(fiscal_year, fiscal_month) - allows multi-year storage
-- ============================================================

-- Drop the old constraint
ALTER TABLE burc_monthly_ebita
  DROP CONSTRAINT IF EXISTS burc_monthly_ebita_month_key;

-- Add the new constraint that properly supports multi-year data
ALTER TABLE burc_monthly_ebita
  ADD CONSTRAINT burc_monthly_ebita_year_month_key
  UNIQUE(fiscal_year, fiscal_month);

-- Add index for better query performance on year-based lookups
CREATE INDEX IF NOT EXISTS idx_monthly_ebita_fiscal_year
  ON burc_monthly_ebita(fiscal_year);

-- ============================================================
-- 2. FIX burc_monthly_revenue
-- Old: UNIQUE(month, revenue_type, revenue_category) - uses DATE month
-- New: UNIQUE(fiscal_year, fiscal_month, revenue_type, revenue_category)
-- ============================================================

-- Drop the old constraint
ALTER TABLE burc_monthly_revenue
  DROP CONSTRAINT IF EXISTS burc_monthly_revenue_month_revenue_type_revenue_category_key;

-- Add the new constraint
ALTER TABLE burc_monthly_revenue
  ADD CONSTRAINT burc_monthly_revenue_year_month_type_cat_key
  UNIQUE(fiscal_year, fiscal_month, revenue_type, revenue_category);

-- Add index for better query performance
CREATE INDEX IF NOT EXISTS idx_monthly_revenue_fiscal_year
  ON burc_monthly_revenue(fiscal_year);

-- ============================================================
-- 3. VERIFY: burc_monthly_metrics already has correct constraint
-- UNIQUE(fiscal_year, month_num, metric_name) - no changes needed
-- ============================================================

-- ============================================================
-- 4. COMMENTS
-- ============================================================
COMMENT ON CONSTRAINT burc_monthly_ebita_year_month_key ON burc_monthly_ebita IS
  'Allows one EBITA record per fiscal year/month combination, enabling multi-year storage';

COMMENT ON CONSTRAINT burc_monthly_revenue_year_month_type_cat_key ON burc_monthly_revenue IS
  'Allows one revenue record per fiscal year/month/type/category combination, enabling multi-year storage';
