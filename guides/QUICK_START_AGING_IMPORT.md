# Aging Accounts Import - Quick Start

⏱️ **5 minutes to get started**

## What You Need

- ✅ Your weekly aging accounts Excel file (`.xlsx`)
- ✅ Supabase credentials (already in `.env.local`)
- ✅ 5 minutes

---

## Setup (Do Once)

### 1. Apply Database Migration

```bash
node scripts/apply-migration-as-single-block.mjs docs/migrations/20251205_aging_accounts_database.sql
```

Expected output:

```
✅ Migration applied successfully
```

### 2. Import Your First File

```bash
node scripts/import-aging-accounts.mjs data/APAC_Intl_10Nov2025.xlsx
```

Expected output:

```
✅ Import complete!
   - Imported: 125 records
   - Week ending: 2025-11-10
```

### 3. Set Up GitHub Automation (Optional)

Add these secrets to GitHub:

- Go to Settings → Secrets → Actions
- Add `NEXT_PUBLIC_SUPABASE_URL`
- Add `SUPABASE_SERVICE_ROLE_KEY`

---

## Weekly Updates (Choose One)

### Option A: Drag & Drop (Easiest) ⭐

1. Save new Excel file to `data/` folder
2. Git commit and push:
   ```bash
   git add data/APAC_Intl_17Nov2025.xlsx
   git commit -m "Weekly aging update"
   git push
   ```
3. Done! GitHub Actions imports automatically.

### Option B: Run Script Manually

```bash
node scripts/import-aging-accounts.mjs data/APAC_Intl_17Nov2025.xlsx
```

### Option C: Fully Automated (Set & Forget)

Already set up! Just ensure latest file is in `data/` folder before Monday 9 AM.
The GitHub workflow runs automatically every Monday.

---

## Verify Import Worked

### Check GitHub Actions

- Go to Actions tab → Should see green checkmark

### Check Database

```bash
node -e "
const { createClient } = require('@supabase/supabase-js');
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);
supabase.from('aging_accounts')
  .select('cse_name, week_ending_date')
  .order('week_ending_date', { ascending: false })
  .limit(5)
  .then(({ data }) => console.log('Latest imports:', data));
"
```

---

## Troubleshooting

**"Pivot sheet not found"**
→ Check Excel file has sheet named "Pivot"

**"No data in database"**
→ Run import script with verbose output:

```bash
node scripts/import-aging-accounts.mjs data/APAC_Intl_10Nov2025.xlsx 2>&1 | tee import.log
```

**GitHub Actions fails**
→ Check Secrets are configured (Settings → Secrets → Actions)

---

## Next Steps

- 📖 Read full guide: [`docs/AGING_ACCOUNTS_IMPORT_GUIDE.md`](./AGING_ACCOUNTS_IMPORT_GUIDE.md)
- 🔧 Customize CSE/client name mappings in `scripts/import-aging-accounts.mjs`
- 📊 View compliance dashboard in app

---

**Questions?** See the [full documentation](./AGING_ACCOUNTS_IMPORT_GUIDE.md) or check troubleshooting section.
