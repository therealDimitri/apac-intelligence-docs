-- Migration: Add organisational structure columns to cse_profiles
-- Date: 2025-12-27
-- Description: Adds reports_to (manager email) and is_global_role columns

-- Add reports_to column (email of manager)
ALTER TABLE cse_profiles
ADD COLUMN IF NOT EXISTS reports_to TEXT;

-- Add is_global_role column (true for global roles like Cristina, Todd Duncan)
ALTER TABLE cse_profiles
ADD COLUMN IF NOT EXISTS is_global_role BOOLEAN DEFAULT FALSE;

-- Add comments
COMMENT ON COLUMN cse_profiles.reports_to IS 'Email of the manager this person reports to';
COMMENT ON COLUMN cse_profiles.is_global_role IS 'True if this is a global role (not APAC-specific)';

-- Populate the organisational structure
-- Todd Haebich (EVP APAC) - reports to nobody in APAC
UPDATE cse_profiles SET reports_to = NULL, is_global_role = FALSE
WHERE email = 'todd.haebich@alterahealth.com';

-- Direct reports to Todd Haebich
UPDATE cse_profiles SET reports_to = 'todd.haebich@alterahealth.com', is_global_role = FALSE
WHERE email IN (
  'dimitri.leimonitis@alterahealth.com',
  'corey.popelier@alterahealth.com',
  'ben.stevenson@alterahealth.com',
  'christina.tan@alterahealth.com',
  'cara.cortese@alterahealth.com',
  'kenny.gan@alterahealth.com',
  'dominic.wilson-ing@alterahealth.com'
);

-- Cristina Ortenzi - Global role
UPDATE cse_profiles SET reports_to = NULL, is_global_role = TRUE
WHERE email = 'cristina.ortenzi@alterahealth.com';

-- Todd Duncan - Global role, reports to Cristina
UPDATE cse_profiles SET reports_to = 'cristina.ortenzi@alterahealth.com', is_global_role = TRUE
WHERE email = 'todd.duncan@alterahealth.com';

-- Priscilla Lynch - reports to Todd Duncan
UPDATE cse_profiles SET reports_to = 'todd.duncan@alterahealth.com', is_global_role = FALSE
WHERE email = 'priscilla.lynch@alterahealth.com';

-- Reports to Ben Stevenson
UPDATE cse_profiles SET reports_to = 'ben.stevenson@alterahealth.com', is_global_role = FALSE
WHERE email IN (
  'tash.kowalczuk@alterahealth.com',
  'carol-lynne.lloyd@alterahealth.com'
);

-- Reports to Dominic Wilson-Ing
UPDATE cse_profiles SET reports_to = 'dominic.wilson-ing@alterahealth.com', is_global_role = FALSE
WHERE email IN (
  'keryn.kondoprias@alterahealth.com',
  'stephen.oster@alterahealth.com'
);

-- Reports to Dimitri Leimonitis (CSEs and CAMs)
UPDATE cse_profiles SET reports_to = 'dimitri.leimonitis@alterahealth.com', is_global_role = FALSE
WHERE email IN (
  'gilbert.so@alterahealth.com',
  'tracey.bland@alterahealth.com',
  'laura.messing@alterahealth.com',
  'boonteck.lim@alterahealth.com',
  'john.salisbury@alterahealth.com',
  'nikki.wei@alterahealth.com',
  'anupama.pradhan@alterahealth.com'
);

-- Soumiya Mani - assuming reports to Dimitri (operations support for CS)
UPDATE cse_profiles SET reports_to = 'dimitri.leimonitis@alterahealth.com', is_global_role = FALSE
WHERE email = 'soumiya.mani@alterahealth.com';
