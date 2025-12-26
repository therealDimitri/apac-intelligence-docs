-- Migration: ChaSen Document Folders
-- Date: 2025-12-07
-- Purpose: Create folder structure for organizing ChaSen documents by client/project
-- Features: Nested folders, client categorization, color tags

-- Create chasen_folders table
CREATE TABLE IF NOT EXISTS chasen_folders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  parent_id UUID REFERENCES chasen_folders(id) ON DELETE CASCADE,
  client_name TEXT,
  description TEXT,
  color TEXT DEFAULT '#3B82F6', -- Blue default
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Constraints
  CONSTRAINT chasen_folders_name_not_empty CHECK (LENGTH(TRIM(name)) > 0),
  CONSTRAINT chasen_folders_unique_name_per_parent UNIQUE (name, parent_id, client_name)
);

-- Add folder_id to chasen_documents table
ALTER TABLE chasen_documents
ADD COLUMN IF NOT EXISTS folder_id UUID REFERENCES chasen_folders(id) ON DELETE SET NULL;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS chasen_folders_parent_id_idx ON chasen_folders(parent_id);
CREATE INDEX IF NOT EXISTS chasen_folders_client_name_idx ON chasen_folders(client_name);
CREATE INDEX IF NOT EXISTS chasen_folders_created_at_idx ON chasen_folders(created_at DESC);
CREATE INDEX IF NOT EXISTS chasen_documents_folder_id_idx ON chasen_documents(folder_id);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_chasen_folders_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chasen_folders_updated_at_trigger
BEFORE UPDATE ON chasen_folders
FOR EACH ROW
EXECUTE FUNCTION update_chasen_folders_updated_at();

-- RLS Policies: Allow all authenticated users to manage folders
-- (Same permissions as chasen_documents)
ALTER TABLE chasen_folders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all authenticated users to view folders"
ON chasen_folders FOR SELECT
TO authenticated
USING (true);

CREATE POLICY "Allow all authenticated users to create folders"
ON chasen_folders FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "Allow all authenticated users to update folders"
ON chasen_folders FOR UPDATE
TO authenticated
USING (true);

CREATE POLICY "Allow all authenticated users to delete folders"
ON chasen_folders FOR DELETE
TO authenticated
USING (true);

-- Enable access for service role (bypass RLS for API routes)
GRANT ALL ON chasen_folders TO service_role;

-- Create default folders for major clients
INSERT INTO chasen_folders (name, client_name, description, color)
VALUES
  ('SA Health', 'SA Health', 'South Australian Health documents and meeting notes', '#10B981'),
  ('MINDEF', 'MINDEF', 'Ministry of Defence Singapore documents', '#EF4444'),
  ('Epworth HealthCare', 'Epworth HealthCare', 'Epworth HealthCare documents', '#8B5CF6'),
  ('Western Australia Health', 'Western Australia Health', 'WA Health documents', '#F59E0B'),
  ('General Documents', NULL, 'Uncategorized or general documents', '#6B7280')
ON CONFLICT (name, parent_id, client_name) DO NOTHING;

-- Add comments for documentation
COMMENT ON TABLE chasen_folders IS 'Organizational folders for ChaSen document management';
COMMENT ON COLUMN chasen_folders.parent_id IS 'Parent folder ID for nested structure (NULL = root folder)';
COMMENT ON COLUMN chasen_folders.client_name IS 'Associated client for folder categorization';
COMMENT ON COLUMN chasen_folders.color IS 'Hex color code for UI display';

COMMENT ON TABLE chasen_documents IS 'Uploaded documents for ChaSen AI analysis';
COMMENT ON COLUMN chasen_documents.folder_id IS 'Folder where document is stored (NULL = root)';
