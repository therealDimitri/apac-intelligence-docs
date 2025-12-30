-- Priority Matrix Assignments Table
-- Stores owner assignments and quadrant positions for priority matrix items
-- Replaces browser localStorage with database persistence for cross-device sync

-- Create the table
CREATE TABLE IF NOT EXISTS public.priority_matrix_assignments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_id TEXT NOT NULL UNIQUE,
    owner TEXT,
    quadrant TEXT,
    client_assignments JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index on item_id for fast lookups
CREATE INDEX IF NOT EXISTS idx_priority_matrix_assignments_item_id
ON public.priority_matrix_assignments(item_id);

-- Create index on owner for filtering by assignee
CREATE INDEX IF NOT EXISTS idx_priority_matrix_assignments_owner
ON public.priority_matrix_assignments(owner);

-- Enable RLS
ALTER TABLE public.priority_matrix_assignments ENABLE ROW LEVEL SECURITY;

-- RLS Policies for anon access (consistent with other tables)
CREATE POLICY "Allow anon read priority_matrix_assignments"
    ON public.priority_matrix_assignments
    FOR SELECT
    TO anon
    USING (true);

CREATE POLICY "Allow anon insert priority_matrix_assignments"
    ON public.priority_matrix_assignments
    FOR INSERT
    TO anon
    WITH CHECK (true);

CREATE POLICY "Allow anon update priority_matrix_assignments"
    ON public.priority_matrix_assignments
    FOR UPDATE
    TO anon
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow anon delete priority_matrix_assignments"
    ON public.priority_matrix_assignments
    FOR DELETE
    TO anon
    USING (true);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_priority_matrix_assignments_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_priority_matrix_assignments_updated_at
ON public.priority_matrix_assignments;

CREATE TRIGGER trigger_update_priority_matrix_assignments_updated_at
    BEFORE UPDATE ON public.priority_matrix_assignments
    FOR EACH ROW
    EXECUTE FUNCTION update_priority_matrix_assignments_updated_at();

-- Comments
COMMENT ON TABLE public.priority_matrix_assignments IS 'Stores owner and position assignments for priority matrix items';
COMMENT ON COLUMN public.priority_matrix_assignments.item_id IS 'Unique identifier for the matrix item (e.g., renewal-ClientName, action-ACT-123)';
COMMENT ON COLUMN public.priority_matrix_assignments.owner IS 'Assigned CSE name';
COMMENT ON COLUMN public.priority_matrix_assignments.quadrant IS 'Current quadrant position (do-now, plan, delegate, eliminate)';
COMMENT ON COLUMN public.priority_matrix_assignments.client_assignments IS 'Per-client owner assignments for multi-client items';
