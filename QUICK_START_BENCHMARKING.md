# Quick Start: Regional Benchmarking Dashboard

## 🚀 Get Started in 3 Steps

### Step 1: Create the Database Table (2 minutes)

1. **Open Supabase SQL Editor**
   - Go to: https://supabase.com/dashboard/project/usoyxsunetvxdjdglkmn/sql/new

2. **Copy the Migration SQL**
   - Open: `/docs/migrations/20260105_regional_benchmarks.sql`
   - Select all (Cmd+A / Ctrl+A)
   - Copy (Cmd+C / Ctrl+C)

3. **Execute in Supabase**
   - Paste into SQL Editor
   - Click "Run" button
   - Wait for success message ✓

### Step 2: Add Sample Data (1 minute)

1. **Stay in Supabase SQL Editor**

2. **Copy the Seed SQL**
   - Open: `/docs/migrations/20260105_regional_benchmarks_seed.sql`
   - Select all and copy

3. **Execute in Supabase**
   - Paste into SQL Editor
   - Click "Run" button
   - You should see ~100 rows inserted ✓

### Step 3: Access the Dashboard

1. **Open the Application**
   - Navigate to your APAC Intelligence Dashboard

2. **Click "Regional Benchmarking"**
   - Find it in the sidebar under Financials section

3. **Explore the Data**
   - View regional rankings
   - Compare metrics across regions
   - Analyse trends over time

## ✅ Verification

Run this query to verify everything is working:

```sql
SELECT
  region,
  period,
  COUNT(*) as metric_count
FROM regional_benchmarks
GROUP BY region, period
ORDER BY region, period;
```

**Expected Result:**
- You should see data for: APAC, EMEA, Americas, Global
- Multiple periods: 2025-Q4, 2025-YTD, 2025-FY
- Each region should have 6-12 metrics per period

## 🎯 Quick Tips

### Understanding the Metrics

- **Green Cards** = APAC is #1 in that metric (Excellent!)
- **Blue Cards** = APAC is #2 of 3 regions (Good)
- **Amber Cards** = APAC is #3 of 3 regions (Needs Improvement)

### Best Metrics for APAC

Look for these in your data:
- Trophy icons 🏆 = APAC is the best performer
- Up arrows ⬆️ = Improving over time
- Green variance = Above global average

### Areas to Focus On

- Red/amber status cards
- Metrics with negative variance from global
- Downward trend arrows ⬇️

## 📊 Sample Views

### Q4 2025 Snapshot
```
Region: All Regions
Period: Q4 2025
Mode: vs Other Regions
```
This shows current quarter performance across all regions.

### APAC Trend Analysis
```
Region: APAC
Period: 2025-YTD
Chart: Benchmark Trend Chart
Metric: NRR
```
This shows APAC's NRR performance over the year.

## 🆘 Troubleshooting

**Problem**: "Table not found" error
**Fix**: Go back to Step 1 and run the migration SQL

**Problem**: Dashboard shows "No data"
**Fix**: Go back to Step 2 and run the seed SQL

**Problem**: Charts not loading
**Fix**: Refresh the page, check browser console for errors

## 📚 More Information

- **Full Setup Guide**: `/docs/BENCHMARKING_SETUP.md`
- **Feature Documentation**: `/docs/features/REGIONAL_BENCHMARKING.md`
- **Database Schema**: `/docs/database-schema.md`

## 🎉 You're All Set!

The Regional Benchmarking Dashboard is now ready to use. Start exploring cross-region performance and identifying opportunities for improvement!

---

**Need Help?** Check the troubleshooting section above or review the full documentation.
