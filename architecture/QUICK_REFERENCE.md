# Segment Compliance System - Quick Reference

**Last Updated:** December 3, 2025

---

## Daily Operations

### Refresh Compliance Dashboard

```bash
node scripts/apply-latest-segment-only.mjs
```

**When:** After events are updated, weekly maintenance

---

## Common Tasks

### 1. Excel File Updated → Database

**Activities Sheet Changed:**

```bash
node scripts/parse-tier-requirements.mjs
node scripts/apply-latest-segment-only.mjs
```

**Segment Changes Updated:**

```bash
node scripts/update-segment-dates-to-september.mjs
node scripts/apply-latest-segment-only.mjs
```

### 2. Quick Verification

**Check MinDef:**

```bash
node -e "
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });
const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
(async () => {
  const { data } = await supabase.from('event_compliance_summary').select('segment, total_event_types_count, overall_compliance_score').eq('client_name', 'Ministry of Defence, Singapore').eq('year', 2025).single();
  console.log(\`MinDef: \${data.segment} tier, \${data.total_event_types_count} events, \${data.overall_compliance_score}% compliant\`);
})();
"
```

**Expected:** `MinDef: Leverage tier, 9 events, 56% compliant`

### 3. Verify Data Integrity

**One row per client:**

```bash
node -e "
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });
const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
(async () => {
  const { data } = await supabase.from('event_compliance_summary').select('client_name, year').eq('year', 2025);
  const counts = {};
  data.forEach(r => counts[r.client_name] = (counts[r.client_name] || 0) + 1);
  const multiples = Object.entries(counts).filter(([_, c]) => c > 1);
  console.log(multiples.length === 0 ? '✅ All clients have 1 row' : \`❌ \${multiples.length} clients have multiple rows\`);
})();
"
```

---

## Key Facts

### Excel File Location

```
/Users/jimmy.leimonitis/Library/CloudStorage/OneDrive-AlteraDigitalHealth/
APAC Clients - Client Success/Client Segmentation/
APAC Client Segmentation Activity Register 2025.xlsx
```

### Important Dates

- **All 2025 segment changes:** September 1, 2025
- **Normal deadline:** December 31, 2025
- **Segment change deadline:** June 20, 2026

### Tier Names (Database)

- Maintain
- Leverage
- Nurture
- Collaboration
- Sleeping Giant _(singular)_
- Giant _(singular)_

### MinDef Example

**Name in DB:** `Ministry of Defence, Singapore`
**Names in Excel:** `MINDEF-NCS`, `NCS/MinDef Singapore`
**Segment:** Maintain (Jan-Aug) → Leverage (Sept-Dec)
**Events:** 9 (Leverage tier requirements)

---

## Troubleshooting

| Issue                   | Command                                              | Expected Result                 |
| ----------------------- | ---------------------------------------------------- | ------------------------------- |
| Compliance outdated     | `node scripts/apply-latest-segment-only.mjs`         | `✅ View refreshed`             |
| Wrong event count       | Check latest segment in DB                           | Should match Excel client sheet |
| Purple star wrong month | `node scripts/update-segment-dates-to-september.mjs` | All changes → Sept 1            |
| Multiple rows           | Re-apply compliance view                             | One row per client              |

---

## File Structure

```
docs/
├── SEGMENT_COMPLIANCE_SYSTEM.md    # Full documentation
├── QUICK_REFERENCE.md              # This file
└── migrations/
    ├── 20251202_tier_event_requirements.sql
    └── 20251203_compliance_view_latest_segment_only.sql

scripts/
├── parse-tier-requirements.mjs              # Excel → tier_event_requirements
├── update-segment-dates-to-september.mjs    # Set all changes to Sept 1
└── apply-latest-segment-only.mjs            # Refresh compliance view

src/
├── hooks/
│   ├── useSegmentChange.ts          # Purple star badge logic
│   └── useEventCompliance.ts        # Read compliance data
└── app/(dashboard)/clients/[clientId]/components/v2/
    └── RightColumn.tsx              # Monthly overview UI
```

---

## Emergency Reset

If everything is broken:

```bash
# 1. Re-parse tier requirements
node scripts/parse-tier-requirements.mjs

# 2. Fix segment change dates
node scripts/update-segment-dates-to-september.mjs

# 3. Rebuild compliance view
node scripts/apply-latest-segment-only.mjs

# 4. Verify
node -e "
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });
const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE_KEY);
(async () => {
  const { count } = await supabase.from('event_compliance_summary').select('*', { count: 'exact' }).eq('year', 2025);
  console.log(\`Total clients in 2025: \${count}\`);
})();
"
```

---

**For detailed information, see `docs/SEGMENT_COMPLIANCE_SYSTEM.md`**
