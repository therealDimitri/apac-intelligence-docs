-- ============================================
-- Migration: Client Email Domain Mapping
-- Date: 9 January 2026
-- Purpose: Enable domain-based client identification for Outlook meeting import
-- ============================================

-- Description:
-- This migration creates a table to map email domains to clients.
-- When importing Outlook meetings, attendee email domains can be used
-- to automatically identify the client, even if the meeting subject
-- doesn't explicitly mention the client name.

-- Create the client_email_domains table
CREATE TABLE IF NOT EXISTS client_email_domains (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    domain VARCHAR(255) NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Ensure domain uniqueness (one domain can only belong to one client)
    UNIQUE(domain)
);

-- Create index for fast domain lookups
CREATE INDEX IF NOT EXISTS idx_client_email_domains_domain
ON client_email_domains(LOWER(domain));

CREATE INDEX IF NOT EXISTS idx_client_email_domains_client_id
ON client_email_domains(client_id);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_client_email_domains_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_client_email_domains_updated_at ON client_email_domains;
CREATE TRIGGER trigger_update_client_email_domains_updated_at
    BEFORE UPDATE ON client_email_domains
    FOR EACH ROW
    EXECUTE FUNCTION update_client_email_domains_updated_at();

-- Create RPC function to resolve client by email domain
CREATE OR REPLACE FUNCTION resolve_client_by_domain(p_domain TEXT)
RETURNS UUID AS $$
DECLARE
    v_client_id UUID;
BEGIN
    -- Normalise domain to lowercase
    SELECT client_id INTO v_client_id
    FROM client_email_domains
    WHERE LOWER(domain) = LOWER(p_domain)
    LIMIT 1;

    RETURN v_client_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- Create RPC function to resolve client from email address
CREATE OR REPLACE FUNCTION resolve_client_by_email(p_email TEXT)
RETURNS UUID AS $$
DECLARE
    v_domain TEXT;
    v_client_id UUID;
BEGIN
    -- Extract domain from email (everything after @)
    v_domain := SPLIT_PART(LOWER(p_email), '@', 2);

    IF v_domain IS NULL OR v_domain = '' THEN
        RETURN NULL;
    END IF;

    -- Try exact domain match first
    SELECT client_id INTO v_client_id
    FROM client_email_domains
    WHERE LOWER(domain) = v_domain
    LIMIT 1;

    -- If no exact match, try subdomain matching (e.g., ipro.sahealth.sa.gov.au matches sahealth.sa.gov.au)
    IF v_client_id IS NULL THEN
        SELECT client_id INTO v_client_id
        FROM client_email_domains
        WHERE v_domain LIKE '%' || LOWER(domain)
           OR LOWER(domain) LIKE '%' || v_domain
        ORDER BY LENGTH(domain) DESC -- Prefer more specific matches
        LIMIT 1;
    END IF;

    RETURN v_client_id;
END;
$$ LANGUAGE plpgsql STABLE;

-- Seed initial domain data for known clients
-- SA Health variants
INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'sahealth.sa.gov.au', true, 'SA Health main domain'
FROM clients WHERE canonical_name ILIKE '%SA Health%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'sa.gov.au', false, 'SA Government general domain'
FROM clients WHERE canonical_name ILIKE '%SA Health%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

-- Singapore Health Services (SingHealth)
INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'singhealth.com.sg', true, 'SingHealth primary domain'
FROM clients WHERE canonical_name ILIKE '%SingHealth%' OR canonical_name ILIKE '%Singapore Health%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'sgh.com.sg', false, 'Singapore General Hospital'
FROM clients WHERE canonical_name ILIKE '%SingHealth%' OR canonical_name ILIKE '%Singapore Health%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

-- Gippsland Health Alliance (GHA)
INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'gha.net.au', true, 'GHA primary domain'
FROM clients WHERE canonical_name ILIKE '%Gippsland%' OR canonical_name ILIKE '%GHA%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'lrh.com.au', false, 'Latrobe Regional Hospital'
FROM clients WHERE canonical_name ILIKE '%Gippsland%' OR canonical_name ILIKE '%GHA%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

-- Grampians Health
INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'grampians.net.au', true, 'Grampians Health primary domain'
FROM clients WHERE canonical_name ILIKE '%Grampians%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'bhs.org.au', false, 'Ballarat Health Services'
FROM clients WHERE canonical_name ILIKE '%Grampians%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

-- WA Health
INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'health.wa.gov.au', true, 'WA Health primary domain'
FROM clients WHERE canonical_name ILIKE '%WA Health%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

-- Epworth Healthcare
INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'epworth.org.au', true, 'Epworth primary domain'
FROM clients WHERE canonical_name ILIKE '%Epworth%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

-- St Luke's Medical Centre (Philippines)
INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'stlukes.com.ph', true, 'St Lukes primary domain'
FROM clients WHERE canonical_name ILIKE '%St Luke%' OR canonical_name ILIKE '%Saint Luke%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

-- GRMC (Guam)
INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'grmc.gu', true, 'GRMC primary domain'
FROM clients WHERE canonical_name ILIKE '%Guam%' OR canonical_name ILIKE '%GRMC%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

-- Northern Health
INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'nh.org.au', true, 'Northern Health primary domain'
FROM clients WHERE canonical_name ILIKE '%Northern Health%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

-- Austin Health
INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'austin.org.au', true, 'Austin Health primary domain'
FROM clients WHERE canonical_name ILIKE '%Austin Health%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

-- Albury Wodonga Health
INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'awh.org.au', true, 'AWH primary domain'
FROM clients WHERE canonical_name ILIKE '%Albury%' OR canonical_name ILIKE '%AWH%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

-- NCS / Ministry of Defence Singapore
INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'ncs.com.sg', true, 'NCS primary domain'
FROM clients WHERE canonical_name ILIKE '%NCS%' OR canonical_name ILIKE '%MinDef%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

INSERT INTO client_email_domains (client_id, domain, is_primary, notes)
SELECT id, 'defence.gov.sg', false, 'Singapore Ministry of Defence'
FROM clients WHERE canonical_name ILIKE '%NCS%' OR canonical_name ILIKE '%MinDef%' LIMIT 1
ON CONFLICT (domain) DO NOTHING;

-- Grant SELECT to anon and authenticated roles
GRANT SELECT ON client_email_domains TO anon;
GRANT SELECT ON client_email_domains TO authenticated;

-- Grant EXECUTE on functions
GRANT EXECUTE ON FUNCTION resolve_client_by_domain(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION resolve_client_by_domain(TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION resolve_client_by_email(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION resolve_client_by_email(TEXT) TO authenticated;

-- Enable RLS (allowing all authenticated users to read)
ALTER TABLE client_email_domains ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access to client_email_domains" ON client_email_domains
    FOR SELECT
    USING (true);

-- Add helpful comment
COMMENT ON TABLE client_email_domains IS 'Maps email domains to clients for automatic identification during Outlook import. One domain can only belong to one client.';
COMMENT ON FUNCTION resolve_client_by_domain(TEXT) IS 'Resolve a domain (e.g., sahealth.sa.gov.au) to a client UUID';
COMMENT ON FUNCTION resolve_client_by_email(TEXT) IS 'Resolve an email address (e.g., user@sahealth.sa.gov.au) to a client UUID, with subdomain matching support';
