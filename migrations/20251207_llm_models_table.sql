-- Migration: Create LLM Models Table for Dynamic Model Management
-- Date: 2025-12-07
-- Purpose: Store available LLM models from MatchAI API with auto-refresh capability

-- Create llm_models table
CREATE TABLE IF NOT EXISTS llm_models (
  id SERIAL PRIMARY KEY,
  matcha_llm_id INTEGER UNIQUE NOT NULL, -- MatchAI's LLM ID (e.g., 28 for Claude Sonnet 4)
  model_name TEXT NOT NULL, -- Human-readable name (e.g., "Claude 3.7 Sonnet")
  model_key TEXT NOT NULL, -- Model identifier key (e.g., "claude-3-7-sonnet")
  provider TEXT, -- AI provider (e.g., "anthropic", "openai", "google")
  capabilities JSONB DEFAULT '{}', -- Model capabilities (context window, features, etc.)
  is_active BOOLEAN DEFAULT true, -- Whether model is currently available
  is_default BOOLEAN DEFAULT false, -- Default model for new conversations
  display_order INTEGER DEFAULT 999, -- Sort order in dropdown (lower = higher)
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_synced_at TIMESTAMPTZ DEFAULT NOW() -- Last time synced from MatchAI API
);

-- Create index on matcha_llm_id for fast lookups
CREATE INDEX IF NOT EXISTS idx_llm_models_matcha_id ON llm_models(matcha_llm_id);

-- Create index on is_active for filtering active models
CREATE INDEX IF NOT EXISTS idx_llm_models_active ON llm_models(is_active);

-- Insert initial seed data (current hardcoded models)
-- Note: matcha_llm_id values need to be verified against MatchAI API
INSERT INTO llm_models (matcha_llm_id, model_name, model_key, provider, is_default, display_order, capabilities)
VALUES
  (71, 'Claude Sonnet 4.5', 'claude-sonnet-4-5', 'anthropic', true, 1, '{"context_window": 200000, "supports_vision": false, "supports_tools": true, "supports_websearch": true}'),
  (28, 'Claude 3.7 Sonnet', 'claude-3-7-sonnet', 'anthropic', false, 2, '{"context_window": 200000, "supports_vision": false, "supports_tools": true}'),
  (25, 'Claude 3.5 Sonnet', 'claude-3-5-sonnet', 'anthropic', false, 3, '{"context_window": 200000, "supports_vision": false, "supports_tools": true}'),
  (30, 'Claude Opus 4.1', 'claude-3-opus-4-1', 'anthropic', false, 4, '{"context_window": 200000, "supports_vision": false, "supports_tools": true}'),
  (35, 'Gemini 2.5 Flash-Lite', 'gemini-2-5-flash-lite', 'google', false, 5, '{"context_window": 128000, "supports_vision": true, "supports_tools": true}'),
  (40, 'GPT-4o', 'gpt-4o', 'openai', false, 6, '{"context_window": 128000, "supports_vision": true, "supports_tools": true, "supports_files": true}')
ON CONFLICT (matcha_llm_id) DO NOTHING;

-- Add RLS (Row Level Security) policies
ALTER TABLE llm_models ENABLE ROW LEVEL SECURITY;

-- Allow all authenticated users to read active models
CREATE POLICY "Allow read access to active models" ON llm_models
  FOR SELECT
  USING (is_active = true);

-- Only service role can insert/update/delete (API management only)
CREATE POLICY "Service role can manage models" ON llm_models
  FOR ALL
  USING (auth.jwt()->>'role' = 'service_role');

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_llm_models_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
DROP TRIGGER IF EXISTS trigger_llm_models_updated_at ON llm_models;
CREATE TRIGGER trigger_llm_models_updated_at
  BEFORE UPDATE ON llm_models
  FOR EACH ROW
  EXECUTE FUNCTION update_llm_models_updated_at();

-- Add helpful comment
COMMENT ON TABLE llm_models IS 'Stores available LLM models from MatchAI API. Auto-refreshed periodically to stay in sync with MatchAI platform.';
COMMENT ON COLUMN llm_models.matcha_llm_id IS 'MatchAI platform LLM ID - used when calling /v1/completions endpoint';
COMMENT ON COLUMN llm_models.model_key IS 'Frontend identifier key - used in UI and API requests';
COMMENT ON COLUMN llm_models.capabilities IS 'JSON object storing model capabilities (context_window, supports_vision, etc.)';
