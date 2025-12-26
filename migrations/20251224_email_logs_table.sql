-- Email Logs Table
-- Tracks all scheduled email sends for monitoring and auditing
-- Created: 24 December 2024

-- Create the email_logs table
CREATE TABLE IF NOT EXISTS email_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email_type VARCHAR(50) NOT NULL, -- 'monday', 'wednesday', 'friday', 'client_support', 'evp'
    recipient_name VARCHAR(255) NOT NULL,
    recipient_email VARCHAR(255) NOT NULL,
    subject VARCHAR(500),
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'sent', 'failed'
    error_message TEXT,
    external_email_id VARCHAR(255), -- ID from email service (e.g., Resend)
    sent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'::jsonb -- Additional data like CC list, etc.
);

-- Create indexes for efficient querying
CREATE INDEX IF NOT EXISTS idx_email_logs_email_type ON email_logs(email_type);
CREATE INDEX IF NOT EXISTS idx_email_logs_status ON email_logs(status);
CREATE INDEX IF NOT EXISTS idx_email_logs_created_at ON email_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_email_logs_recipient_email ON email_logs(recipient_email);

-- Create composite index for common queries
CREATE INDEX IF NOT EXISTS idx_email_logs_type_date ON email_logs(email_type, created_at DESC);

-- Enable RLS
ALTER TABLE email_logs ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read email logs
CREATE POLICY "Allow authenticated read access to email_logs"
ON email_logs FOR SELECT
TO authenticated
USING (true);

-- Allow service role full access
CREATE POLICY "Allow service role full access to email_logs"
ON email_logs FOR ALL
TO service_role
USING (true)
WITH CHECK (true);

-- Add comments
COMMENT ON TABLE email_logs IS 'Tracks all scheduled email sends for monitoring and auditing';
COMMENT ON COLUMN email_logs.email_type IS 'Type of email: monday, wednesday, friday, client_support, evp';
COMMENT ON COLUMN email_logs.status IS 'Email status: pending, sent, failed';
COMMENT ON COLUMN email_logs.external_email_id IS 'ID returned by email service (Resend)';
