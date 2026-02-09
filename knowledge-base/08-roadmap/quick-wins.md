# Quick Wins

Tasks that deliver visible improvement with minimal effort. Each should take < 1 day. **12/12 complete.**

## Data Quality Quick Wins

### ~~1. Validate BURC Cell References~~ ✅ DONE
Raw `sheet[col+row]?.v` replaced with `getCellValue()` + `readMonthlyRow()` helpers. Pre-flight `validateCellRefs()` added for CSI ratios.

### ~~2. Document Excel Cell Mapping~~ ✅ DONE
`docs/burc-cell-mapping.md` enhanced with per-row detail for all 5 sheets.

### ~~3. Add Fiscal Year Parameter~~ ✅ DONE
Hardcoded `2026` replaced with dynamic `FISCAL_YEAR` in 4 scripts + 1 API route. `ACTIVITY_REGISTER_CURRENT`/`PREVIOUS` dynamic constants added.

## UI Quick Wins

### ~~4. Hide Dev Pages~~ ✅ DONE
All three pages already have `if (process.env.NODE_ENV === 'production') notFound()`:
- `/test-ai/page.tsx` (line 65)
- `/test-charts/page.tsx` (line 224)
- `/chasen-icons/page.tsx` (line 397)

### ~~5. Create PageShell Component~~ ✅ DONE
`src/components/layout/PageShell.tsx` (79 lines). Adopted by settings (9 pages), financials, team-performance, pipeline, NPS, and segmentation.

### ~~6. Wire useLeadingIndicators~~ ✅ DONE
Wired in 3 places: client detail page (`RightColumn.tsx:383`), `LeadingIndicatorsCard.tsx:130`, `LeadingIndicatorAlerts.tsx:316`.

## Automation Quick Wins

### ~~7. Schedule Activity Register Sync~~ ✅ DONE
`setup-activity-sync.sh` created for launchd service management. `sync-excel-activities.mjs` updated to use `ACTIVITY_REGISTER_CURRENT`.

### ~~8. Add Staleness Check to Dashboard~~ ✅ DONE
`StalenessBar.tsx` exists with 2h/25h/25h thresholds. Sync completion toast added via sessionStorage tracking.

### ~~9. Seed Goal Hierarchy~~ ✅ DONE
`seed-goal-hierarchy.mjs` seeds 9 team goals + 12 projects with real APAC client names. 3 pillars + 9 BU goals already existed.

## Data Integrity Quick Wins

### ~~10. Centralise Remaining Client Name Mappings~~ ✅ DONE
`lib/client-names.mjs` shared module created. `seed-client-name-aliases.mjs` upserts 32 aliases. Both sync scripts import from shared module.

### ~~11. Add Sync Completion Notification~~ ✅ DONE
`StalenessBar.tsx` detects recent sync completions from `sync_history` and shows sonner toast.

### ~~12. Fix Empty Admin Routes~~ ✅ DONE
All 10 admin routes verified fully functional.

## Priority Order

Start with the ones that protect data accuracy:
1. Validate BURC cell references (#1)
2. Document Excel cell mapping (#2)
3. Centralise client name mappings (#10)
4. Hide dev pages (#4)
5. Create PageShell (#5)
6. Wire useLeadingIndicators (#6)
7. Schedule Activity Register sync (#7)
8. Add staleness banner (#8)
9. Seed goal hierarchy (#9)
10. Add fiscal year parameter (#3)
11. Add sync notification (#11)
12. Fix admin routes (#12)
