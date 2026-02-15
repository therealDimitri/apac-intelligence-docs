# Invoice Data Integration Guide

Guide for extracting invoice data from `https://invoice.alteraapacai.dev/` and syncing to Supabase.

## Table of Contents

1. [Integration Options](#integration-options)
2. [Setup Instructions](#setup-instructions)
3. [Testing & Debugging](#testing--debugging)
4. [Automation](#automation)
5. [Analytics & Reporting](#analytics--reporting)

---

## Integration Options

### Option 1: API Integration (Recommended)

**Best for:** Production use, reliability, real-time sync

**Pros:**

- ✓ Most reliable and maintainable
- ✓ Real-time data updates
- ✓ No scraping complexity
- ✓ Better performance

**Cons:**

- ✗ Requires API access/credentials
- ✗ May need vendor cooperation

### Option 2: Web Scraping

**Best for:** When no API is available

**Pros:**

- ✓ Works without API access
- ✓ Can extract any visible data
- ✓ Flexible data extraction

**Cons:**

- ✗ Brittle (breaks if UI changes)
- ✗ Slower than API
- ✗ May require authentication handling

### Option 3: CSV/Excel Import

**Best for:** One-time or manual imports

**Pros:**

- ✓ Simple and straightforward
- ✓ Good for initial data load
- ✓ No automation needed

**Cons:**

- ✗ Manual process
- ✗ Not real-time
- ✗ Prone to human error

---

## Setup Instructions

### Step 1: Install Dependencies

```bash
npm install playwright
```

### Step 2: Create Supabase Table

Run the table setup script:

```bash
node scripts/setup-invoices-table.mjs
```

This creates:

- `invoices` table with proper schema
- Indexes for performance
- Materialized view for analytics
- Auto-update triggers

### Step 3: Configure Environment Variables

Add to `.env.local`:

```env
# Invoice System Credentials (if authentication required)
INVOICE_EMAIL=your-email@alteradigitalhealth.com
INVOICE_PASSWORD=your-password

# Invoice API (if available)
INVOICE_API_KEY=your-api-key
INVOICE_API_URL=https://invoice.alteraapacai.dev/api
```

### Step 4: Customize Scraper Selectors

Before running the scraper, you need to inspect the invoice page and update the selectors in `scripts/scrape-invoices.mjs`:

```javascript
// Update these selectors based on actual page structure:
const invoices = await page.evaluate(() => {
  const invoiceRows = document.querySelectorAll('.invoice-row') // ← Update this

  return Array.from(invoiceRows).map(row => {
    return {
      invoice_id: row.querySelector('.invoice-number')?.textContent?.trim(), // ← Update
      client_name: row.querySelector('.client-name')?.textContent?.trim(), // ← Update
      amount: parseFloat(row.querySelector('.amount')?.textContent?.replace(/[^0-9.]/g, '')),
      // ... etc
    }
  })
})
```

**To find the correct selectors:**

1. Open https://invoice.alteraapacai.dev/ in Chrome
2. Right-click on an invoice row → Inspect
3. Note the class names or data attributes
4. Update the selectors in the script

### Step 5: Test the Scraper

Run in dry-run mode (doesn't sync to DB):

```bash
# First run - generates debug files
node scripts/scrape-invoices.mjs
```

Check the generated files:

- `invoice-page-debug.png` - Screenshot of the page
- `invoice-page-debug.html` - Page HTML for inspection

Update selectors based on these files, then test again.

### Step 6: Run Full Sync

Once selectors are correct:

```bash
node scripts/scrape-invoices.mjs
```

---

## Testing & Debugging

### Verify Data in Supabase

```sql
-- Check if invoices were imported
SELECT COUNT(*) FROM invoices;

-- View recent invoices
SELECT * FROM invoices ORDER BY created_at DESC LIMIT 10;

-- Check client totals
SELECT * FROM invoice_analytics ORDER BY total_amount DESC;
```

### Common Issues

**Issue: "No invoices found"**

- Check the debug screenshot/HTML
- Update CSS selectors to match actual page structure
- Ensure page is fully loaded (increase `waitForLoadState` timeout)

**Issue: "Login failed"**

- Verify credentials in `.env.local`
- Check if login form selectors are correct
- May need to handle 2FA or captcha

**Issue: "Data not syncing to Supabase"**

- Check `SUPABASE_SERVICE_ROLE_KEY` is set
- Verify table exists: `SELECT * FROM invoices LIMIT 1;`
- Check error logs for Supabase permissions issues

---

## Automation

### Option A: Cron Job (Server)

Add to your server's crontab:

```bash
# Sync invoices every day at 2 AM
0 2 * * * cd /path/to/project && node scripts/scrape-invoices.mjs >> logs/invoice-sync.log 2>&1
```

### Option B: GitHub Actions (CI/CD)

Create `.github/workflows/sync-invoices.yml`:

```yaml
name: Sync Invoice Data

on:
  schedule:
    - cron: '0 2 * * *' # Daily at 2 AM UTC
  workflow_dispatch: # Allow manual trigger

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        run: npm install playwright @supabase/supabase-js

      - name: Install Playwright browsers
        run: npx playwright install chromium

      - name: Sync invoices
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.NEXT_PUBLIC_SUPABASE_URL }}
          SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
          INVOICE_EMAIL: ${{ secrets.INVOICE_EMAIL }}
          INVOICE_PASSWORD: ${{ secrets.INVOICE_PASSWORD }}
        run: node scripts/scrape-invoices.mjs
```

### Option C: Vercel Cron (Serverless)

Create `app/api/cron/sync-invoices/route.ts`:

```typescript
import { NextRequest, NextResponse } from 'next/server'
import { exec } from 'child_process'
import { promisify } from 'util'

const execAsync = promisify(exec)

export async function GET(request: NextRequest) {
  // Verify cron secret
  const authHeader = request.headers.get('authorization')
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    const { stdout, stderr } = await execAsync('node scripts/scrape-invoices.mjs')

    return NextResponse.json({
      success: true,
      output: stdout,
      errors: stderr,
    })
  } catch (error) {
    return NextResponse.json(
      {
        success: false,
        error: error.message,
      },
      { status: 500 }
    )
  }
}
```

Add to `vercel.json`:

```json
{
  "crons": [
    {
      "path": "/api/cron/sync-invoices",
      "schedule": "0 2 * * *"
    }
  ]
}
```

---

## Analytics & Reporting

### Refresh Analytics View

```bash
# Manually refresh the materialized view
node -e "
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
supabase.rpc('exec', { sql: 'REFRESH MATERIALIZED VIEW invoice_analytics' })
  .then(() => console.log('Analytics refreshed'))
"
```

### Example Queries

```sql
-- Total outstanding amount per client
SELECT
  client_name,
  SUM(amount) as outstanding_amount
FROM invoices
WHERE status IN ('pending', 'overdue')
GROUP BY client_name
ORDER BY outstanding_amount DESC;

-- Overdue invoices
SELECT
  invoice_id,
  client_name,
  amount,
  due_date,
  CURRENT_DATE - due_date as days_overdue
FROM invoices
WHERE status = 'overdue'
ORDER BY days_overdue DESC;

-- Payment performance by client
SELECT * FROM invoice_analytics
WHERE total_invoices > 0
ORDER BY avg_payment_days ASC;

-- Monthly revenue trend
SELECT
  DATE_TRUNC('month', payment_date) as month,
  COUNT(*) as invoices_paid,
  SUM(amount) as revenue
FROM invoices
WHERE status = 'paid'
  AND payment_date IS NOT NULL
GROUP BY DATE_TRUNC('month', payment_date)
ORDER BY month DESC;
```

### Add to Analytics Dashboard

Integrate invoice data into your existing analytics dashboard by creating a new component:

```typescript
// components/InvoiceAnalytics.tsx
import { useEffect, useState } from 'react'

export function InvoiceAnalytics() {
  const [data, setData] = useState(null)

  useEffect(() => {
    fetch('/api/analytics/invoices')
      .then(res => res.json())
      .then(setData)
  }, [])

  return (
    <div className="space-y-4">
      <h2>Invoice Analytics</h2>
      <div className="grid grid-cols-3 gap-4">
        <StatCard title="Total Outstanding" value={`$${data?.outstanding}`} />
        <StatCard title="Overdue" value={data?.overdue} />
        <StatCard title="Avg Payment Days" value={data?.avgDays} />
      </div>
    </div>
  )
}
```

---

## Next Steps

1. **Explore the invoice system** - Understand its structure and available data
2. **Choose integration method** - API (preferred) or scraping
3. **Set up database** - Run `setup-invoices-table.mjs`
4. **Test scraper** - Update selectors and run test
5. **Automate** - Set up cron job or GitHub Action
6. **Build analytics** - Add invoice metrics to dashboard

Need help with a specific step? Check the troubleshooting section or review the script comments for more details.
