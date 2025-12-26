-- Migration: Create portfolio_initiatives table
-- Date: 2025-12-17
-- Purpose: Store portfolio initiatives for CSE client management
-- Replaces mock data in usePortfolioInitiatives hook

-- Create the portfolio_initiatives table
CREATE TABLE IF NOT EXISTS portfolio_initiatives (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  client_name text NOT NULL,
  cse_name text NOT NULL,
  year integer NOT NULL,
  status text NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'in-progress', 'completed', 'cancelled')),
  category text NOT NULL,
  start_date date,
  completion_date date,
  description text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_portfolio_initiatives_client ON portfolio_initiatives(client_name);
CREATE INDEX IF NOT EXISTS idx_portfolio_initiatives_cse ON portfolio_initiatives(cse_name);
CREATE INDEX IF NOT EXISTS idx_portfolio_initiatives_year ON portfolio_initiatives(year);
CREATE INDEX IF NOT EXISTS idx_portfolio_initiatives_status ON portfolio_initiatives(status);
CREATE INDEX IF NOT EXISTS idx_portfolio_initiatives_category ON portfolio_initiatives(category);

-- Enable Row Level Security
ALTER TABLE portfolio_initiatives ENABLE ROW LEVEL SECURITY;

-- Create RLS policies (allow all access for now, can be tightened later)
CREATE POLICY "Allow all select on portfolio_initiatives"
  ON portfolio_initiatives FOR SELECT USING (true);

CREATE POLICY "Allow all insert on portfolio_initiatives"
  ON portfolio_initiatives FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow all update on portfolio_initiatives"
  ON portfolio_initiatives FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow all delete on portfolio_initiatives"
  ON portfolio_initiatives FOR DELETE USING (true);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_portfolio_initiatives_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_portfolio_initiatives_updated_at
  BEFORE UPDATE ON portfolio_initiatives
  FOR EACH ROW
  EXECUTE FUNCTION update_portfolio_initiatives_updated_at();

-- Add comments
COMMENT ON TABLE portfolio_initiatives IS 'Stores portfolio initiatives for CSE client management';
COMMENT ON COLUMN portfolio_initiatives.status IS 'Initiative status: planned, in-progress, completed, or cancelled';
COMMENT ON COLUMN portfolio_initiatives.category IS 'Category such as Training, Optimization, Integration, Support, etc.';

-- Insert some sample data for testing (can be removed in production)
INSERT INTO portfolio_initiatives (name, client_name, cse_name, year, status, category, start_date, completion_date, description)
VALUES
  ('Q1 Product Training Series', 'SA Health', 'Laura Messing', 2024, 'completed', 'Training', '2024-01-15', '2024-03-15', 'Comprehensive product training for clinical staff'),
  ('Clinical Workflow Optimisation', 'SA Health', 'Laura Messing', 2024, 'completed', 'Optimisation', '2024-02-01', '2024-04-20', 'Streamline clinical documentation workflows'),
  ('Integration Enhancement Project', 'SA Health', 'Laura Messing', 2024, 'in-progress', 'Integration', '2024-05-01', NULL, 'Enhance integration with third-party systems'),
  ('User Adoption Programme', 'SA Health', 'Laura Messing', 2025, 'planned', 'Training', NULL, NULL, 'Increase user adoption across departments'),
  ('System Performance Review', 'Hunter New England Health', 'Jimmy Leimonitis', 2024, 'completed', 'Support', '2024-03-01', '2024-05-30', 'Comprehensive performance audit and optimisation'),
  ('Reporting Dashboard Upgrade', 'Hunter New England Health', 'Jimmy Leimonitis', 2024, 'in-progress', 'Integration', '2024-07-01', NULL, 'Upgrade analytics and reporting capabilities'),
  ('Staff Training Refresh', 'SingHealth', 'Lawrence Foo', 2024, 'completed', 'Training', '2024-02-15', '2024-04-15', 'Refresher training for existing staff'),
  ('Data Migration Project', 'SingHealth', 'Lawrence Foo', 2024, 'in-progress', 'Integration', '2024-06-01', NULL, 'Migrate historical data to new system');
