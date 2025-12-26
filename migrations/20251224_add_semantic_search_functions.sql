-- Migration: Add Semantic Search RPC Functions
-- Date: 2024-12-24
-- Description: Creates the match_documents and match_conversation_embeddings functions
--              required for ChaSen AI semantic search and workflows

-- Enable pgvector extension if not already enabled
CREATE EXTENSION IF NOT EXISTS vector;

-- ============================================================================
-- Function: match_documents
-- Description: Search for similar documents using vector similarity
-- Used by: semantic-search.ts -> searchSimilarDocuments()
-- ============================================================================

CREATE OR REPLACE FUNCTION match_documents(
  query_embedding vector(1536),
  match_threshold float DEFAULT 0.7,
  match_count int DEFAULT 10,
  filter_content_type text DEFAULT NULL,
  filter_client text DEFAULT NULL
)
RETURNS TABLE (
  id uuid,
  content text,
  content_type text,
  source_table text,
  source_id text,
  client_name text,
  metadata jsonb,
  similarity float
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    de.id,
    de.content,
    de.content_type,
    de.source_table,
    de.source_id,
    de.client_name,
    de.metadata,
    1 - (de.embedding <=> query_embedding) as similarity
  FROM document_embeddings de
  WHERE
    (filter_content_type IS NULL OR de.content_type = filter_content_type)
    AND (filter_client IS NULL OR de.client_name ILIKE '%' || filter_client || '%')
    AND 1 - (de.embedding <=> query_embedding) > match_threshold
  ORDER BY de.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Add comment for documentation
COMMENT ON FUNCTION match_documents IS 'Search for similar documents using cosine similarity on embeddings. Used by ChaSen AI semantic search.';

-- ============================================================================
-- Function: match_conversation_embeddings
-- Description: Search for similar past conversations
-- Used by: embeddings.ts -> findSimilarConversations()
-- ============================================================================

-- First, ensure conversation_embeddings table exists
CREATE TABLE IF NOT EXISTS conversation_embeddings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id text NOT NULL,
  message_role text NOT NULL,
  message_content text NOT NULL,
  embedding vector(1536),
  created_at timestamptz DEFAULT now()
);

-- Create index for vector similarity search
CREATE INDEX IF NOT EXISTS conversation_embeddings_embedding_idx
ON conversation_embeddings
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Create the match function
CREATE OR REPLACE FUNCTION match_conversation_embeddings(
  query_embedding vector(1536),
  match_threshold float DEFAULT 0.75,
  match_count int DEFAULT 5
)
RETURNS TABLE (
  id uuid,
  conversation_id uuid,
  message_role text,
  message_content text,
  similarity float
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT
    ce.id,
    ce.conversation_id,
    ce.message_role,
    ce.message_content,
    1 - (ce.embedding <=> query_embedding) as similarity
  FROM conversation_embeddings ce
  WHERE 1 - (ce.embedding <=> query_embedding) > match_threshold
  ORDER BY ce.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

COMMENT ON FUNCTION match_conversation_embeddings IS 'Search for similar past conversations using cosine similarity. Used by ChaSen AI for conversation context.';

-- ============================================================================
-- Grant permissions
-- ============================================================================

GRANT EXECUTE ON FUNCTION match_documents TO authenticated, anon, service_role;
GRANT EXECUTE ON FUNCTION match_conversation_embeddings TO authenticated, anon, service_role;
GRANT ALL ON TABLE conversation_embeddings TO authenticated, service_role;
GRANT SELECT ON TABLE conversation_embeddings TO anon;

-- ============================================================================
-- Verify document_embeddings has proper index
-- ============================================================================

-- Create index if not exists (for efficient vector search)
CREATE INDEX IF NOT EXISTS document_embeddings_embedding_idx
ON document_embeddings
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
