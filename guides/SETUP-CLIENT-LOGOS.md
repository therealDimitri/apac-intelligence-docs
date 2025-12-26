# Client Logo Setup Guide

**Date:** 2025-11-26
**Purpose:** Enable client logos to display in dashboard
**Status:** ⚠️ Requires manual Supabase configuration

---

## Current Status

✅ **Code is ready** - The application code has been updated to query and display client logos
❌ **Database columns missing** - The `logo_url` and `brand_color` columns don't exist yet
✅ **Storage bucket exists** - `client-logos` bucket is already created
✅ **Fallback working** - Colored initials display when logos aren't available

---

## Quick Setup (3 Steps)

### Step 1: Add Database Columns

1. Go to [Supabase Dashboard](https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn)
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy and paste this SQL:

```sql
-- Add logo_url and brand_color columns
ALTER TABLE nps_clients
  ADD COLUMN IF NOT EXISTS logo_url TEXT,
  ADD COLUMN IF NOT EXISTS brand_color VARCHAR(7);

-- Add column documentation
COMMENT ON COLUMN nps_clients.logo_url IS 'URL to client logo in Supabase Storage (client-logos bucket)';
COMMENT ON COLUMN nps_clients.brand_color IS 'Client brand colour in hex format (e.g., #1e40af)';
```

5. Click **Run** (or press Ctrl/Cmd + Enter)
6. Verify success: You should see "Success. No rows returned"

### Step 2: Upload Client Logos

1. In Supabase Dashboard, navigate to **Storage**
2. Click on `client-logos` bucket
3. Click **Upload File**
4. Upload client logo images (PNG, JPG, SVG recommended)
5. **Naming convention**: Use client name in lowercase with hyphens
   - Example: `epworth-healthcare.png`
   - Example: `barwon-health.png`
   - Example: `sa-health.svg`

### Step 3: Update Database with Logo URLs

After uploading logos, update the database with their URLs:

```sql
-- Get the public URL format:
-- https://usoyxsunetvxdjdglkmn.supabase.co/storage/v1/object/public/client-logos/{filename}

-- Update each client with their logo URL
UPDATE nps_clients
SET logo_url = 'https://usoyxsunetvxdjdglkmn.supabase.co/storage/v1/object/public/client-logos/epworth-healthcare.png'
WHERE client_name = 'Epworth Healthcare';

UPDATE nps_clients
SET logo_url = 'https://usoyxsunetvxdjdglkmn.supabase.co/storage/v1/object/public/client-logos/st-lukes-medical-centre.png'
WHERE client_name = 'St Luke''s Medical Center Global City Inc';

UPDATE nps_clients
SET logo_url = 'https://usoyxsunetvxdjdglkmn.supabase.co/storage/v1/object/public/client-logos/sa-health.png'
WHERE client_name = 'SA Health';

UPDATE nps_clients
SET logo_url = 'https://usoyxsunetvxdjdglkmn.supabase.co/storage/v1/object/public/client-logos/barwon-health.png'
WHERE client_name = 'Barwon Health Australia';

-- Repeat for all clients...
```

---

## Optional: Add Brand Colors

You can also set custom brand colours for each client (overrides the auto-generated colours):

```sql
UPDATE nps_clients
SET brand_color = '#1e40af'  -- Blue
WHERE client_name = 'Epworth Healthcare';

UPDATE nps_clients
SET brand_color = '#059669'  -- Green
WHERE client_name = 'Barwon Health Australia';

-- etc.
```

**Hex Color Format:** Use 7-character hex codes (e.g., `#1e40af`, `#dc2626`, `#059669`)

---

## Verification

After completing the steps above:

1. **Refresh the dashboard**: Hard refresh (Ctrl+Shift+R or Cmd+Shift+R)
2. **Check NPS Analytics page**: Navigate to `/nps`
3. **Look for logos**: Client logos should appear in:
   - Client Scores & Trends section
   - Recent Feedback by Client section
4. **Check console**: No errors should appear (previously had PGRST204 errors)

---

## How It Works

### Before Setup (Current State)

- Code queries `nps_clients` table for logo URLs
- Column doesn't exist → SQL error caught by fallback
- Displays coloured initials (e.g., "EH" for Epworth Healthcare)
- Uses auto-generated colours based on client name

### After Setup (Target State)

- Code queries `nps_clients` table for logo URLs
- Column exists and has URLs → Fetches successfully
- Displays actual client logos from Supabase Storage
- Uses custom brand colours if set, otherwise auto-generated

### Code Architecture

**File: `src/lib/client-logos-supabase.ts`**

- Line 73: Queries `client_name, logo_url, brand_color`
- Line 76-84: Fallback if columns don't exist (queries just `client_name`)
- Line 163-182: Tries to fetch brand_color, falls back to generated colour

**Component: `src/components/ClientLogoDisplay.tsx`**

- Fetches logo URL for each client
- Displays image if URL exists
- Falls back to coloured initials if not

---

## Bulk Upload Helper Script

To upload multiple logos at once, you can use this bash script:

```bash
#!/bin/bash

# Array of client names and their logo files
declare -A clients=(
  ["Epworth Healthcare"]="epworth-healthcare.png"
  ["St Luke's Medical Center Global City Inc"]="st-lukes-medical-centre.png"
  ["SA Health"]="sa-health.png"
  ["Barwon Health Australia"]="barwon-health.png"
)

SUPABASE_URL="https://usoyxsunetvxdjdglkmn.supabase.co"
SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVzb3l4c3VuZXR2eGRqZGdsa21uIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MDc2OTY0OSwiZXhwIjoyMDc2MzQ1NjQ5fQ.zQN6yqzOXv68xNxhQa7suGssDmRBd5RXjB9s1i3z-KQ"

for client in "${!clients[@]}"; do
  file="${clients[$client]}"
  echo "Uploading $file for $client..."

  curl -X POST "$SUPABASE_URL/storage/v1/object/client-logos/$file" \
    -H "Authorization: Bearer $SERVICE_KEY" \
    -H "Content-Type: image/png" \
    --data-binary "@/path/to/logos/$file"

  echo "✅ Uploaded $file"
done
```

---

## Troubleshooting

### Logos Still Not Showing

1. **Check browser console** for errors
2. **Verify logo URLs** are correct and accessible
3. **Hard refresh** the page (Ctrl+Shift+R)
4. **Check file names** match exactly (case-sensitive)
5. **Verify storage bucket** is public

### SQL Error When Querying

If you get `column does not exist` errors:

- Run Step 1 again to add columns
- Check the SQL ran successfully
- Refresh the schema cache in Supabase

### Storage Upload Fails

- Check file size (max 5MB for client-logos bucket)
- Verify file format (PNG, JPG, SVG recommended)
- Ensure bucket is public
- Check service role key has storage permissions

---

## Migration File

The SQL migration is saved at:

```
supabase/migrations/add_logo_columns.sql
```

You can run this file directly if using Supabase CLI:

```bash
supabase db push
```

---

## Related Documentation

- [BUG-REPORT-SUPABASE-SCHEMA-CONSOLE-ERRORS.md](./BUG-REPORT-SUPABASE-SCHEMA-CONSOLE-ERRORS.md) - Previous schema mismatch fixes
- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
- [Supabase SQL Editor](https://supabase.com/docs/guides/database/overview#the-sql-editor)

---

**Setup completed?** ✅ Once you've run the SQL and uploaded logos, the dashboard will automatically display them!
