-- Migration: CSE Profiles Role Column
-- Date: 2025-12-07
-- Purpose: Add role column to cse_profiles table and seed with team data
-- Affects: User profile role detection (removes hardcoded EMAIL_TO_CSE_MAP)

-- Add role column if it doesn't exist
ALTER TABLE cse_profiles
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'cse'
CHECK (role IN ('cse', 'manager', 'admin', 'executive'));

-- Add index for role-based queries
CREATE INDEX IF NOT EXISTS idx_cse_profiles_role ON cse_profiles(role);

-- Seed existing CSE data (from hardcoded EMAIL_TO_CSE_MAP)
-- This ensures all current team members are in the database
INSERT INTO cse_profiles (email, full_name, first_name, role)
VALUES
  ('tracey.bland@alterahealth.com', 'Tracey Bland', 'Tracey', 'cse'),
  ('jonathan.salisbury@alterahealth.com', 'Jonathan Salisbury', 'Jonathan', 'cse'),
  ('jimmy.leimonitis@alterahealth.com', 'Jimmy Leimonitis', 'Jimmy', 'manager'),
  ('ben.williams@alterahealth.com', 'Ben Williams', 'Ben', 'cse'),
  ('oscar.jimenez@alterahealth.com', 'Oscar Jimenez', 'Oscar', 'cse'),
  ('jenny.hall@alterahealth.com', 'Jenny Hall', 'Jenny', 'cse'),
  ('michael.chen@alterahealth.com', 'Michael Chen', 'Michael', 'cse'),
  ('sarah.thompson@alterahealth.com', 'Sarah Thompson', 'Sarah', 'cse'),
  ('david.lee@alterahealth.com', 'David Lee', 'David', 'cse'),
  ('emily.rodriguez@alterahealth.com', 'Emily Rodriguez', 'Emily', 'cse'),
  ('james.wilson@alterahealth.com', 'James Wilson', 'James', 'cse'),
  ('lisa.anderson@alterahealth.com', 'Lisa Anderson', 'Lisa', 'cse'),
  ('robert.martinez@alterahealth.com', 'Robert Martinez', 'Robert', 'cse'),
  ('jennifer.garcia@alterahealth.com', 'Jennifer Garcia', 'Jennifer', 'cse'),
  ('william.brown@alterahealth.com', 'William Brown', 'William', 'cse'),
  ('patricia.davis@alterahealth.com', 'Patricia Davis', 'Patricia', 'cse'),
  ('richard.miller@alterahealth.com', 'Richard Miller', 'Richard', 'cse'),
  ('linda.taylor@alterahealth.com', 'Linda Taylor', 'Linda', 'cse')
ON CONFLICT (email) DO UPDATE SET
  role = EXCLUDED.role,
  full_name = COALESCE(EXCLUDED.full_name, cse_profiles.full_name),
  first_name = COALESCE(EXCLUDED.first_name, cse_profiles.first_name),
  updated_at = NOW();

-- Add updated_at trigger if not exists
CREATE OR REPLACE FUNCTION update_cse_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS cse_profiles_updated_at ON cse_profiles;
CREATE TRIGGER cse_profiles_updated_at
  BEFORE UPDATE ON cse_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_cse_profiles_updated_at();

-- Add comment
COMMENT ON COLUMN cse_profiles.role IS 'User role in the organization: cse (Client Success Executive), manager, admin, or executive';
