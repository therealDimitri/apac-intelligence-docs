-- ChaSen Knowledge Base Table
-- Created: 2024-12-18
-- Purpose: Store dynamic knowledge entries that ChaSen can query at runtime
-- This allows updating ChaSen's knowledge without code deploys

-- Create the chasen_knowledge table
CREATE TABLE IF NOT EXISTS chasen_knowledge (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

    -- Category for organising knowledge (e.g., 'business_rules', 'formulas', 'processes', 'definitions')
    category TEXT NOT NULL,

    -- Unique key within category for easy lookup (e.g., 'health_score_formula', 'nps_schedule')
    knowledge_key TEXT NOT NULL,

    -- Human-readable title
    title TEXT NOT NULL,

    -- The actual knowledge content (can be markdown)
    content TEXT NOT NULL,

    -- Optional metadata (JSON) for additional structured data
    metadata JSONB DEFAULT '{}'::jsonb,

    -- Priority for ordering (higher = more important, shown first)
    priority INTEGER DEFAULT 0,

    -- Whether this knowledge is active and should be included in prompts
    is_active BOOLEAN DEFAULT true,

    -- Version tracking
    version INTEGER DEFAULT 1,

    -- Audit fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by TEXT,
    updated_by TEXT,

    -- Ensure unique key per category
    UNIQUE(category, knowledge_key)
);

-- Create index for efficient querying
CREATE INDEX IF NOT EXISTS idx_chasen_knowledge_category ON chasen_knowledge(category);
CREATE INDEX IF NOT EXISTS idx_chasen_knowledge_active ON chasen_knowledge(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_chasen_knowledge_priority ON chasen_knowledge(priority DESC);

-- Enable RLS
ALTER TABLE chasen_knowledge ENABLE ROW LEVEL SECURITY;

-- RLS Policies - Knowledge is readable by all authenticated users
CREATE POLICY "chasen_knowledge_select_policy" ON chasen_knowledge
    FOR SELECT TO authenticated
    USING (is_active = true);

-- Only service role can insert/update/delete (admin only)
CREATE POLICY "chasen_knowledge_insert_policy" ON chasen_knowledge
    FOR INSERT TO service_role
    WITH CHECK (true);

CREATE POLICY "chasen_knowledge_update_policy" ON chasen_knowledge
    FOR UPDATE TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "chasen_knowledge_delete_policy" ON chasen_knowledge
    FOR DELETE TO service_role
    USING (true);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_chasen_knowledge_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.version = OLD.version + 1;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER chasen_knowledge_updated_at_trigger
    BEFORE UPDATE ON chasen_knowledge
    FOR EACH ROW
    EXECUTE FUNCTION update_chasen_knowledge_updated_at();

-- Insert initial knowledge entries
INSERT INTO chasen_knowledge (category, knowledge_key, title, content, priority, metadata) VALUES
(
    'formulas',
    'health_score',
    'Client Health Score Formula',
    '**Health Score Calculation (2-Component System)**

The health score is calculated using two components:

1. **NPS Score Component (40 points max)**
   - Formula: ((nps_score + 100) / 200) * 40
   - Converts NPS range (-100 to +100) to 0-40 points
   - Example: NPS of +50 = ((50 + 100) / 200) * 40 = 30 points

2. **Segmentation Compliance Component (60 points max)**
   - Formula: (compliance_percentage / 100) * 60
   - Directly proportional to event completion rate
   - Capped at 100% compliance to prevent overflow

**Thresholds:**
- Healthy: >= 70 points
- At-Risk: 60-69 points
- Focus Required: < 60 points

**Last Updated:** December 2024 (Simplified from previous 5-component system)',
    100,
    '{"version": "2.0", "components": ["nps", "compliance"], "weights": {"nps": 40, "compliance": 60}}'::jsonb
),
(
    'business_rules',
    'nps_schedule',
    'NPS Survey Schedule',
    '**NPS Survey Timing**

NPS surveys are conducted **twice per year** only:
- Q2 (April-June)
- Q4 (October-December)

**Important Implications:**
- NPS data will NOT be available for "last 30 days" queries - this is impossible
- Lack of recent NPS responses is NORMAL and EXPECTED
- Never recommend collecting more frequent NPS data
- Focus on quarter-over-quarter trends (Q2 vs Q4) not monthly/daily trends
- Latest NPS data is always from the most recent survey period',
    90,
    '{"survey_quarters": ["Q2", "Q4"], "frequency": "biannual"}'::jsonb
),
(
    'definitions',
    'client_segments',
    'Client Segment Definitions',
    '**Client Segments**

1. **Giant** - Largest enterprise clients with complex needs
2. **Large** - Significant accounts requiring dedicated attention
3. **Medium** - Mid-tier clients with standard engagement
4. **Small** - Smaller accounts with lighter touch engagement
5. **NZ** - New Zealand specific clients
6. **Dormant** - Inactive or minimal engagement clients

Each segment has specific compliance event requirements defined in the segmentation_events table.',
    80,
    '{"segments": ["Giant", "Large", "Medium", "Small", "NZ", "Dormant"]}'::jsonb
),
(
    'processes',
    'engagement_events',
    'Engagement Event Types',
    '**Required Engagement Events by Type**

- **QBR (Quarterly Business Review)** - Strategic review meeting
- **EBR (Executive Business Review)** - Executive-level strategic discussion
- **Regular Check-in** - Routine engagement touchpoint
- **Training** - Product or process training session
- **Support Review** - Review of support tickets and issues
- **Go-Live** - Implementation milestone meeting
- **Planning** - Forward-looking strategy session

Each segment has different required frequencies for these events.',
    70,
    '{"event_types": ["QBR", "EBR", "Regular Check-in", "Training", "Support Review", "Go-Live", "Planning"]}'::jsonb
),
(
    'definitions',
    'aging_compliance',
    'Aging Accounts Compliance',
    '**Accounts Receivable Aging Goals**

- **Target:** 100% of receivables under 90 days old
- **Secondary Target:** 90% of receivables under 60 days old

**Aging Buckets:**
- Current (0-30 days)
- 31-60 days
- 61-90 days
- 91-120 days
- Over 120 days

CSEs are measured on their portfolio aging compliance, with focus on minimising receivables over 90 days.',
    60,
    '{"targets": {"under_90_days": 100, "under_60_days": 90}}'::jsonb
)
ON CONFLICT (category, knowledge_key) DO UPDATE SET
    title = EXCLUDED.title,
    content = EXCLUDED.content,
    priority = EXCLUDED.priority,
    metadata = EXCLUDED.metadata,
    updated_at = NOW();

-- Add comment to table
COMMENT ON TABLE chasen_knowledge IS 'Dynamic knowledge base for ChaSen AI assistant. Allows updating AI knowledge without code deploys.';
