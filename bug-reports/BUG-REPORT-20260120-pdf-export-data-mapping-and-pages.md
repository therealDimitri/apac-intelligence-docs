# Bug Report: PDF Export Data Mapping and Missing Pages

**Date**: 2026-01-20
**Status**: Fixed
**Severity**: High
**Component**: PDF Export (`/api/planning/export`)

## Problem Description

The PDF export functionality was not producing reports that matched the design specification in `ACCOUNT_PLAN_PDF_REPORT_DESIGN.md`. Two major issues were identified:

### Issue 1: Data Mapping Mismatch
The PDF generator was looking for data fields using incorrect property names that didn't match the database schema:
- Code expected `portfolio` but DB stores `portfolio_data`
- Code expected `actions` but DB stores `actions_data`
- Code expected `stakeholders` but DB stores `stakeholders_data`
- Code expected `portfolio_data.clients` array but DB stores `portfolio_data` directly as an array

### Issue 2: Conditional Page Generation
Pages were only generated if their corresponding data existed. This resulted in:
- Only 6 pages generated instead of 10+
- Missing pages: Financial Plan, Gap Analysis, MEDDPICC Assessment, Risk Assessment, StoryBrand Messaging, Action Plan

### Issue 3: Character Encoding
Unicode symbols (★, ▲, ○) in the stakeholder type column were rendering as garbled characters like `%Ë Neutral` due to jsPDF font limitations.

## Root Cause

1. **Data mapping**: The code was written before the database schema was finalised, resulting in mismatched field names
2. **Page generation**: Early return/skip logic prevented pages from rendering when data was empty
3. **Encoding**: jsPDF's default font doesn't support all Unicode characters

## Solution Implemented

### Files Modified:
- `src/app/api/planning/export/route.ts` (lines ~2040-2210)
- `src/lib/pdf/account-plan-pdf.ts`

### Changes:

1. **Fixed data mapping in `generateEnhancedPDF`**:
```typescript
// FIX: Handle all possible data locations from strategic_plans table
const rawPlan = plan as any
const portfolioClients = (
  Array.isArray(rawPlan.portfolio_data)
    ? rawPlan.portfolio_data
    : rawPlan.portfolio_data?.clients || rawPlan.portfolio || []
) as any[]
const allActions = (rawPlan.actions_data || rawPlan.actions || rawPlan.action_plan_data?.actions || []) as any[]
const allStakeholders = (rawPlan.stakeholders_data || rawPlan.stakeholders || []) as any[]
const methodology = rawPlan.methodology_data || rawPlan.value_data
```

2. **Always generate all pages**:
```typescript
async generate(): Promise<Buffer> {
  this.generateCoverPage()
  // Page 2: Executive Summary - ALWAYS generate
  this.doc.addPage()
  this.pageNumber++
  this.generateExecutiveSummary()
  // ... continues for all 10 pages unconditionally
}
```

3. **Added placeholder for missing data**:
```typescript
private drawNoDataMessage(message: string): void {
  const { margin, contentWidth } = AlteraLayout
  this.doc.setFillColor(...hexToRgb(AlteraBrand.neutral.light))
  this.doc.roundedRect(margin.left, this.yPos, contentWidth, 30, 2, 2, 'F')
  this.doc.setFontSize(10)
  this.doc.setTextColor(...hexToRgb(AlteraBrand.neutral.dark))
  this.doc.text('No data available', margin.left + contentWidth / 2, this.yPos + 12, { align: 'center' })
  this.doc.text(message, margin.left + contentWidth / 2, this.yPos + 22, { align: 'center' })
  this.yPos += 40
}
```

4. **Fixed character encoding**:
```typescript
// Before
s.isChampion ? '★ Champion' : s.isBlocker ? '▲ Blocker' : '○ Neutral'

// After
s.isChampion ? '[Champion]' : s.isBlocker ? '[Blocker]' : 'Neutral'
```

## Testing

1. Ran `npm run build` - passed with no TypeScript errors
2. Exported PDF via browser - confirmed 10 pages now generate
3. Verified placeholder messages appear for empty sections
4. Verified stakeholder type column displays correctly without encoding issues

## Commit

```
fix(pdf): Fix PDF export data mapping and generate all pages

- Fix data mapping in generateEnhancedPDF to handle DB field names
- Always generate all 10 pages regardless of data availability
- Add "No data available" placeholder messages for empty sections
- Fix character encoding issue in stakeholder type column

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

## Notes

The values showing as $0 for ARR and N/A for Health/NPS are data entry issues in the database, not code issues. The data mapping fix ensures that when this data is populated in the `strategic_plans` table, it will be correctly displayed in the PDF.
