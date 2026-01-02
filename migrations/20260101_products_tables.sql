-- Products and Client Products Tables
-- Created: 1 January 2026
-- Purpose: Store product information and client-product mappings

-- Products table
CREATE TABLE IF NOT EXISTS products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT,
  icon TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Client products mapping table
CREATE TABLE IF NOT EXISTS client_products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_name TEXT NOT NULL,
  product_code TEXT NOT NULL,
  implementation_date DATE,
  status TEXT DEFAULT 'active',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(client_name, product_code)
);

-- Enable RLS
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_products ENABLE ROW LEVEL SECURITY;

-- Allow read access for authenticated users
DROP POLICY IF EXISTS "Allow read access" ON products;
CREATE POLICY "Allow read access" ON products FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow read access" ON client_products;
CREATE POLICY "Allow read access" ON client_products FOR SELECT USING (true);

-- Insert products
INSERT INTO products (code, name, category, description, icon) VALUES
  ('medsuite', 'MedSuite Enterprise', 'Clinical', 'Comprehensive clinical information system for hospitals', 'heart-pulse'),
  ('labconnect', 'LabConnect Pro', 'Laboratory', 'Laboratory information and workflow management system', 'flask'),
  ('patient-portal', 'PatientPortal', 'Engagement', 'Patient engagement and self-service portal', 'users'),
  ('analytics', 'Analytics Plus', 'Analytics', 'Business intelligence and reporting platform', 'bar-chart'),
  ('mobile', 'Mobile Health', 'Mobile', 'Mobile applications for clinicians and patients', 'smartphone'),
  ('radiology', 'RadConnect', 'Imaging', 'Radiology information and PACS integration', 'scan'),
  ('pharmacy', 'PharmaSuite', 'Pharmacy', 'Pharmacy management and medication tracking', 'pill')
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  category = EXCLUDED.category,
  description = EXCLUDED.description,
  icon = EXCLUDED.icon,
  updated_at = now();

-- Insert client-product mappings
INSERT INTO client_products (client_name, product_code, status) VALUES
  -- SA Health - full suite
  ('Minister for Health aka South Australia Health', 'medsuite', 'active'),
  ('Minister for Health aka South Australia Health', 'labconnect', 'active'),
  ('Minister for Health aka South Australia Health', 'patient-portal', 'active'),
  ('Minister for Health aka South Australia Health', 'analytics', 'active'),
  ('Minister for Health aka South Australia Health', 'radiology', 'active'),
  ('Minister for Health aka South Australia Health', 'pharmacy', 'active'),
  -- SingHealth
  ('Singapore Health Services Pte Ltd', 'medsuite', 'active'),
  ('Singapore Health Services Pte Ltd', 'labconnect', 'active'),
  ('Singapore Health Services Pte Ltd', 'analytics', 'active'),
  ('Singapore Health Services Pte Ltd', 'mobile', 'active'),
  -- Grampians
  ('Grampians Health Alliance', 'medsuite', 'active'),
  ('Grampians Health Alliance', 'patient-portal', 'active'),
  ('Grampians Health Alliance', 'analytics', 'active'),
  -- WA Health
  ('Western Australia Department Of Health', 'medsuite', 'active'),
  ('Western Australia Department Of Health', 'labconnect', 'active'),
  ('Western Australia Department Of Health', 'radiology', 'active'),
  -- St Luke's
  ('St Luke''s Medical Center Global City Inc', 'medsuite', 'active'),
  ('St Luke''s Medical Center Global City Inc', 'patient-portal', 'active'),
  ('St Luke''s Medical Center Global City Inc', 'pharmacy', 'active'),
  -- GRMC
  ('GRMC (Guam Regional Medical Centre)', 'medsuite', 'active'),
  ('GRMC (Guam Regional Medical Centre)', 'labconnect', 'active'),
  -- Epworth
  ('Epworth Healthcare', 'medsuite', 'active'),
  ('Epworth Healthcare', 'patient-portal', 'active'),
  ('Epworth Healthcare', 'analytics', 'active'),
  -- Waikato
  ('Te Whatu Ora Waikato', 'medsuite', 'active'),
  ('Te Whatu Ora Waikato', 'labconnect', 'active'),
  -- Barwon
  ('Barwon Health Australia', 'medsuite', 'active'),
  ('Barwon Health Australia', 'analytics', 'active'),
  -- Western Health
  ('Western Health', 'medsuite', 'active'),
  ('Western Health', 'patient-portal', 'active'),
  -- RVEEH
  ('The Royal Victorian Eye and Ear Hospital', 'medsuite', 'active'),
  -- GHA Regional
  ('Gippsland Health Alliance', 'medsuite', 'active'),
  ('Gippsland Health Alliance', 'analytics', 'active'),
  -- MINDEF
  ('Ministry of Defence, Singapore', 'medsuite', 'active'),
  ('Ministry of Defence, Singapore', 'mobile', 'active'),
  -- Mount Alvernia
  ('Mount Alvernia Hospital', 'medsuite', 'active'),
  ('Mount Alvernia Hospital', 'patient-portal', 'active'),
  -- Albury Wodonga
  ('Albury Wodonga Health', 'medsuite', 'active'),
  -- DoH Victoria
  ('Department of Health - Victoria', 'medsuite', 'active'),
  ('Department of Health - Victoria', 'analytics', 'active'),
  -- Northern Health
  ('Northern Health', 'medsuite', 'active'),
  ('Northern Health', 'patient-portal', 'active'),
  -- Austin Health
  ('Austin Health', 'medsuite', 'active'),
  ('Austin Health', 'labconnect', 'active'),
  ('Austin Health', 'analytics', 'active'),
  -- Mercy
  ('Mercy Aged Care', 'medsuite', 'active')
ON CONFLICT (client_name, product_code) DO UPDATE SET
  status = EXCLUDED.status,
  updated_at = now();
