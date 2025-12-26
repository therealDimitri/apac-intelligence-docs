/*
 * Internal Operations & Client Work Integration - Phase 1
 * Migration: Data Model Enhancement
 *
 * Purpose: Add structured department and activity type tracking,
 *          enable client impact linkage for internal work
 *
 * Author: Claude Code
 * Date: 2025-12-05
 * Version: 1.0
 */

-- ============================================================================
-- STEP 1: CREATE REFERENCE TABLES
-- ============================================================================

-- Departments lookup table
CREATE TABLE IF NOT EXISTS departments (
  id SERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  icon VARCHAR(50), -- Lucide icon name
  color VARCHAR(20), -- Tailwind color
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE departments IS 'Reference table for organizational departments';
COMMENT ON COLUMN departments.code IS 'Unique department code (e.g., CLIENT_SUCCESS)';
COMMENT ON COLUMN departments.icon IS 'Lucide React icon name for UI display';
COMMENT ON COLUMN departments.color IS 'Tailwind color class for visual identification';

-- Activity types lookup table
CREATE TABLE IF NOT EXISTS activity_types (
  id SERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  category VARCHAR(20) NOT NULL CHECK (category IN ('client_facing', 'internal_ops')),
  shows_on_client_profile BOOLEAN DEFAULT false,
  color VARCHAR(20),
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE activity_types IS 'Reference table for activity type classification';
COMMENT ON COLUMN activity_types.category IS 'Either client_facing or internal_ops';
COMMENT ON COLUMN activity_types.shows_on_client_profile IS 'Whether to display on client profile pages';

-- Client impact tracking junction table
CREATE TABLE IF NOT EXISTS client_impact_links (
  id SERIAL PRIMARY KEY,
  source_type VARCHAR(20) NOT NULL CHECK (source_type IN ('action', 'meeting')),
  source_id INTEGER NOT NULL,
  client_id INTEGER NOT NULL,
  impact_area VARCHAR(50), -- 'NPS', 'Health', 'Adoption', 'Onboarding', 'Retention'
  impact_description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(source_type, source_id, client_id)
);

COMMENT ON TABLE client_impact_links IS 'Links internal work (actions/meetings) to impacted clients';
COMMENT ON COLUMN client_impact_links.source_type IS 'Type of source: action or meeting';
COMMENT ON COLUMN client_impact_links.impact_area IS 'Area of client impact: NPS, Health, Adoption, etc.';

-- Cross-functional initiatives tracking
CREATE TABLE IF NOT EXISTS initiatives (
  id SERIAL PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  description TEXT,
  owner_department VARCHAR(50) REFERENCES departments(code),
  involved_departments TEXT[], -- Array of department codes
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('planning', 'active', 'completed', 'cancelled')),
  priority VARCHAR(20) CHECK (priority IN ('critical', 'high', 'medium', 'low')),
  start_date DATE,
  target_completion_date DATE,
  actual_completion_date DATE,
  impacts_clients BOOLEAN DEFAULT false,
  client_impact_description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE initiatives IS 'Cross-functional initiatives and projects';
COMMENT ON COLUMN initiatives.involved_departments IS 'Array of department codes participating in initiative';

-- ============================================================================
-- STEP 2: POPULATE REFERENCE DATA
-- ============================================================================

-- Insert Departments
INSERT INTO departments (code, name, description, icon, color, sort_order) VALUES
-- Client-Facing Teams (sort_order 1-3)
('CLIENT_SUCCESS', 'Client Success', 'Client Success Engineering and account management', 'Users', 'purple', 1),
('CLIENT_SUPPORT', 'Client Support', 'Technical support and issue resolution', 'Headphones', 'blue', 2),
('PROFESSIONAL_SERVICES', 'Professional Services', 'Implementation and consulting', 'Briefcase', 'indigo', 3),

-- Product & Delivery (sort_order 4-6)
('RD', 'R&D', 'Research and Development, product engineering', 'Cpu', 'green', 4),
('PROGRAM_DELIVERY', 'Program Delivery', 'Program and project management', 'Target', 'teal', 5),
('TECHNICAL_SERVICES', 'Technical Services', 'Infrastructure and technical operations', 'Server', 'cyan', 6),

-- Business Functions (sort_order 7-10)
('MARKETING', 'Marketing', 'Marketing, communications, and demand generation', 'Megaphone', 'pink', 7),
('SALES_SOLUTIONS', 'Sales & Solutions', 'Sales, solutions architecture, and business development', 'TrendingUp', 'orange', 8),
('BUSINESS_OPS', 'Business Ops', 'Business operations and process management', 'BarChart3', 'gray', 9),
('COMMERCIAL_OPS', 'Commercial Ops', 'Commercial operations, contracts, and finance', 'DollarSign', 'yellow', 10);

-- Insert Activity Types
INSERT INTO activity_types (code, name, description, category, shows_on_client_profile, color, sort_order) VALUES
-- Client-Facing Activities (sort_order 1-6)
('IMPLEMENTATION', 'Implementation', 'System implementation and configuration', 'client_facing', true, 'blue', 1),
('TRAINING', 'Training', 'User training and education', 'client_facing', true, 'green', 2),
('SUPPORT', 'Support', 'Technical support and troubleshooting', 'client_facing', true, 'orange', 3),
('OPTIMIZATION', 'Optimization', 'System optimization and tuning', 'client_facing', true, 'purple', 4),
('STRATEGIC_REVIEW', 'Strategic Review', 'Business review and strategic planning', 'client_facing', true, 'indigo', 5),
('HEALTH_CHECK', 'Health Check', 'Account health assessment', 'client_facing', true, 'teal', 6),

-- Internal Operations (sort_order 7-13)
('PLANNING', 'Planning', 'Strategic and tactical planning', 'internal_ops', false, 'gray', 7),
('PROCESS_IMPROVEMENT', 'Process Improvement', 'Process optimization and efficiency', 'internal_ops', false, 'yellow', 8),
('TEAM_DEVELOPMENT', 'Team Development', 'Team training and skill development', 'internal_ops', false, 'pink', 9),
('REPORTING', 'Reporting', 'Reporting and analytics', 'internal_ops', false, 'cyan', 10),
('GOVERNANCE', 'Governance', 'Governance and compliance', 'internal_ops', false, 'red', 11),
('CLIENT_ENABLEMENT', 'Client Enablement', 'Internal work that enables better client service', 'internal_ops', true, 'purple', 12),
('RESEARCH', 'Research', 'Market research and analysis', 'internal_ops', false, 'blue', 13);

-- ============================================================================
-- STEP 3: ADD NEW COLUMNS TO EXISTING TABLES
-- ============================================================================

-- Add columns to unified_meetings
ALTER TABLE unified_meetings
ADD COLUMN IF NOT EXISTS department_code VARCHAR(50) REFERENCES departments(code),
ADD COLUMN IF NOT EXISTS activity_type_code VARCHAR(50) REFERENCES activity_types(code),
ADD COLUMN IF NOT EXISTS is_internal BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS cross_functional BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS linked_initiative_id INTEGER REFERENCES initiatives(id);

COMMENT ON COLUMN unified_meetings.department_code IS 'FK to departments table';
COMMENT ON COLUMN unified_meetings.activity_type_code IS 'FK to activity_types table';
COMMENT ON COLUMN unified_meetings.is_internal IS 'True if this is an internal meeting (not client-facing)';
COMMENT ON COLUMN unified_meetings.cross_functional IS 'True if multiple departments involved';

-- Add columns to actions
ALTER TABLE actions
ADD COLUMN IF NOT EXISTS department_code VARCHAR(50) REFERENCES departments(code),
ADD COLUMN IF NOT EXISTS activity_type_code VARCHAR(50) REFERENCES activity_types(code),
ADD COLUMN IF NOT EXISTS is_internal BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS cross_functional BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS linked_initiative_id INTEGER REFERENCES initiatives(id);

COMMENT ON COLUMN actions.department_code IS 'FK to departments table';
COMMENT ON COLUMN actions.activity_type_code IS 'FK to activity_types table';
COMMENT ON COLUMN actions.is_internal IS 'True if this is an internal action (not client-specific)';
COMMENT ON COLUMN actions.cross_functional IS 'True if multiple departments involved';

-- ============================================================================
-- STEP 4: CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Meetings indexes
CREATE INDEX IF NOT EXISTS idx_meetings_department ON unified_meetings(department_code);
CREATE INDEX IF NOT EXISTS idx_meetings_activity_type ON unified_meetings(activity_type_code);
CREATE INDEX IF NOT EXISTS idx_meetings_internal ON unified_meetings(is_internal);
CREATE INDEX IF NOT EXISTS idx_meetings_initiative ON unified_meetings(linked_initiative_id);

-- Actions indexes
CREATE INDEX IF NOT EXISTS idx_actions_department ON actions(department_code);
CREATE INDEX IF NOT EXISTS idx_actions_activity_type ON actions(activity_type_code);
CREATE INDEX IF NOT EXISTS idx_actions_internal ON actions(is_internal);
CREATE INDEX IF NOT EXISTS idx_actions_initiative ON actions(linked_initiative_id);

-- Client impact links indexes
CREATE INDEX IF NOT EXISTS idx_impact_source ON client_impact_links(source_type, source_id);
CREATE INDEX IF NOT EXISTS idx_impact_client ON client_impact_links(client_id);
CREATE INDEX IF NOT EXISTS idx_impact_area ON client_impact_links(impact_area);

-- ============================================================================
-- STEP 5: CREATE COMPATIBILITY VIEWS FOR LEGACY CODE
-- ============================================================================

-- Actions with enhanced data
CREATE OR REPLACE VIEW actions_enhanced AS
SELECT
  a.*,
  d.name AS department_name,
  d.icon AS department_icon,
  d.color AS department_color,
  at.name AS activity_type_name,
  at.category AS activity_category,
  at.color AS activity_color,
  at.shows_on_client_profile,
  i.name AS initiative_name,
  i.status AS initiative_status,
  -- Count of linked clients for internal actions
  (SELECT COUNT(*) FROM client_impact_links cil
   WHERE cil.source_type = 'action' AND cil.source_id = a.id) AS impacted_client_count
FROM actions a
LEFT JOIN departments d ON a.department_code = d.code
LEFT JOIN activity_types at ON a.activity_type_code = at.code
LEFT JOIN initiatives i ON a.linked_initiative_id = i.id;

COMMENT ON VIEW actions_enhanced IS 'Actions with department, activity type, and initiative details';

-- Meetings with enhanced data
CREATE OR REPLACE VIEW meetings_enhanced AS
SELECT
  m.*,
  d.name AS department_name,
  d.icon AS department_icon,
  d.color AS department_color,
  at.name AS activity_type_name,
  at.category AS activity_category,
  at.color AS activity_color,
  at.shows_on_client_profile,
  i.name AS initiative_name,
  i.status AS initiative_status,
  -- Count of linked clients for internal meetings
  (SELECT COUNT(*) FROM client_impact_links cil
   WHERE cil.source_type = 'meeting' AND cil.source_id = m.id) AS impacted_client_count
FROM unified_meetings m
LEFT JOIN departments d ON m.department_code = d.code
LEFT JOIN activity_types at ON m.activity_type_code = at.code
LEFT JOIN initiatives i ON m.linked_initiative_id = i.id;

COMMENT ON VIEW meetings_enhanced IS 'Meetings with department, activity type, and initiative details';

-- ============================================================================
-- STEP 6: DATA MIGRATION HELPERS
-- ============================================================================

-- Function to auto-classify existing Internal meetings
CREATE OR REPLACE FUNCTION migrate_internal_meetings() RETURNS INTEGER AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  -- Mark meetings with client_name = 'Internal' or 'Internal Meeting'
  UPDATE unified_meetings
  SET is_internal = true
  WHERE LOWER(client_name) LIKE '%internal%'
  AND is_internal IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;

  -- If meeting_dept is populated, try to map to department_code
  UPDATE unified_meetings m
  SET department_code = 'CLIENT_SUCCESS'
  WHERE m.meeting_dept = 'Client Success'
  AND m.is_internal = true
  AND m.department_code IS NULL;

  RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION migrate_internal_meetings() IS 'Auto-classifies existing internal meetings';

-- Function to auto-classify existing Internal actions
CREATE OR REPLACE FUNCTION migrate_internal_actions() RETURNS INTEGER AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  -- Mark actions with client = 'Internal'
  UPDATE actions
  SET is_internal = true
  WHERE LOWER(client) LIKE '%internal%'
  AND is_internal IS NULL;

  GET DIAGNOSTICS updated_count = ROW_COUNT;

  RETURN updated_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION migrate_internal_actions() IS 'Auto-classifies existing internal actions';

-- ============================================================================
-- STEP 7: RUN INITIAL DATA MIGRATION
-- ============================================================================

-- Execute migration functions
SELECT migrate_internal_meetings() AS meetings_migrated;
SELECT migrate_internal_actions() AS actions_migrated;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify reference data
SELECT 'Departments created:' AS info, COUNT(*) AS count FROM departments;
SELECT 'Activity types created:' AS info, COUNT(*) AS count FROM activity_types;

-- Verify migrations
SELECT 'Internal meetings marked:' AS info, COUNT(*) AS count FROM unified_meetings WHERE is_internal = true;
SELECT 'Internal actions marked:' AS info, COUNT(*) AS count FROM actions WHERE is_internal = true;

-- Show sample data
SELECT 'Sample enhanced actions:' AS info;
SELECT id, title, department_name, activity_type_name, is_internal
FROM actions_enhanced
WHERE is_internal = true
LIMIT 5;

/*
 * ============================================================================
 * ROLLBACK INSTRUCTIONS (if needed)
 * ============================================================================
 *
 * To rollback this migration:
 *
 * DROP VIEW IF EXISTS meetings_enhanced;
 * DROP VIEW IF EXISTS actions_enhanced;
 * DROP FUNCTION IF EXISTS migrate_internal_actions();
 * DROP FUNCTION IF EXISTS migrate_internal_meetings();
 * DROP TABLE IF EXISTS client_impact_links CASCADE;
 * DROP TABLE IF EXISTS initiatives CASCADE;
 * ALTER TABLE unified_meetings DROP COLUMN IF EXISTS department_code;
 * ALTER TABLE unified_meetings DROP COLUMN IF EXISTS activity_type_code;
 * ALTER TABLE unified_meetings DROP COLUMN IF EXISTS is_internal;
 * ALTER TABLE unified_meetings DROP COLUMN IF EXISTS cross_functional;
 * ALTER TABLE unified_meetings DROP COLUMN IF EXISTS linked_initiative_id;
 * ALTER TABLE actions DROP COLUMN IF EXISTS department_code;
 * ALTER TABLE actions DROP COLUMN IF EXISTS activity_type_code;
 * ALTER TABLE actions DROP COLUMN IF EXISTS is_internal;
 * ALTER TABLE actions DROP COLUMN IF EXISTS cross_functional;
 * ALTER TABLE actions DROP COLUMN IF EXISTS linked_initiative_id;
 * DROP TABLE IF EXISTS activity_types CASCADE;
 * DROP TABLE IF EXISTS departments CASCADE;
 *
 * ============================================================================
 */
