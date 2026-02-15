# PDF Formatting Recommendations: World-Class Document Design Standards

**Date**: 2026-01-29
**Type**: Design Recommendations
**Status**: Proposed
**Component**: PDF Export (`/api/planning/export`, `jsPDF/autoTable`)

---

## Executive Summary

This document provides specific, actionable recommendations for resolving PDF formatting issues based on design patterns from industry leaders: Stripe (data-dense documentation), Apple (typography and whitespace), Linear (information density), Notion (table styling), and Figma (technical documentation).

### Issues Addressed

1. Wide tables (14+ columns) with overlapping/garbled headers
2. T/F values in cramped columns causing visual clutter
3. Dash-separated bullet points rendering as continuous paragraph text
4. Client names wrapping awkwardly mid-word

---

## 1. Wide Table Handling

### The Problem

Tables with 14+ columns (e.g., MEDDPICC scorecards with M, E, D1, D2, P, I, C1, C2, plus metadata) exceed A4 portrait width (210mm - 28mm margins = 182mm usable). At 9pt font with minimal padding, each column needs approximately 15-20mm minimum, meaning 14 columns require ~280mm - exceeding available space by 50%.

### Industry Approaches

**Stripe's Approach (API Documentation)**
- Uses landscape orientation for data-heavy tables
- Implements horizontal scrolling in digital contexts
- Splits conceptually related columns into grouped sub-tables
- Maximum 6-7 columns per table in print documentation

**Apple's Approach (Human Interface Guidelines PDFs)**
- Strict 5-column maximum for print
- Uses progressive disclosure: summary table links to detail pages
- Rotates tables to landscape only for financial/comparison matrices

**Linear's Approach (Changelogs & Release Notes)**
- Transposes wide tables: rows become columns when data is per-entity
- Uses card-based layouts for 1:1 data (entity details)
- Reserves tables for truly tabular comparisons only

### Recommended Solutions

#### Priority 1: Transpose Wide Tables (Recommended)

For MEDDPICC scorecards and similar single-entity data, transpose the layout:

```
BEFORE (14 columns, cramped):
| Metric | M | E | D1 | D2 | P | I | C1 | C2 | Score | Champion | Blocker | Next Step | Owner |

AFTER (2 columns, scannable):
+------------------+------------------+
| MEDDPICC Element | Score            |
+------------------+------------------+
| Metrics (M)      | 4/5 ████░        |
| Economic Buyer   | 3/5 ███░░        |
| Decision Criteria| 5/5 █████        |
| Decision Process | 2/5 ██░░░        |
| Paper Process    | 4/5 ████░        |
| Identified Pain  | 5/5 █████        |
| Champion         | 4/5 ████░        |
| Competition      | 3/5 ███░░        |
+------------------+------------------+
| TOTAL SCORE      | 30/40 (75%)      |
+------------------+------------------+
```

**Implementation in jsPDF:**

```typescript
// account-plan-pdf.ts - MEDDPICC Scorecard
private generateMEDDPICCScorecard(): void {
  const elements = [
    { key: 'M', label: 'Metrics', score: this.data.meddpicc?.m || 0 },
    { key: 'E', label: 'Economic Buyer', score: this.data.meddpicc?.e || 0 },
    { key: 'D1', label: 'Decision Criteria', score: this.data.meddpicc?.d1 || 0 },
    { key: 'D2', label: 'Decision Process', score: this.data.meddpicc?.d2 || 0 },
    { key: 'P', label: 'Paper Process', score: this.data.meddpicc?.p || 0 },
    { key: 'I', label: 'Identified Pain', score: this.data.meddpicc?.i || 0 },
    { key: 'C1', label: 'Champion', score: this.data.meddpicc?.c1 || 0 },
    { key: 'C2', label: 'Competition', score: this.data.meddpicc?.c2 || 0 },
  ]

  const tableData = elements.map(el => [
    `${el.key} - ${el.label}`,
    this.renderScoreBar(el.score, 5),  // Visual bar + number
  ])

  autoTable(this.doc, {
    startY: this.yPos,
    head: [['Element', 'Score']],
    body: tableData,
    columnStyles: {
      0: { cellWidth: 80 },
      1: { cellWidth: 100 },
    },
    styles: {
      fontSize: 10,
      cellPadding: { top: 4, bottom: 4, left: 6, right: 6 },
    },
  })
}

private renderScoreBar(score: number, max: number): string {
  const filled = '█'.repeat(score)
  const empty = '░'.repeat(max - score)
  return `${score}/${max}  ${filled}${empty}`
}
```

#### Priority 2: Landscape Orientation for Comparison Tables

When tables genuinely require 7+ columns (e.g., multi-client comparisons), switch to landscape:

```typescript
// Before adding wide table
if (columns.length > 6) {
  this.doc.addPage('a4', 'landscape')
  this.isLandscape = true
  this.pageWidth = 297  // A4 landscape width
  this.contentWidth = 297 - (14 * 2)  // margins
}
```

**jsPDF Landscape Configuration:**

```typescript
private switchToLandscape(): void {
  this.doc.addPage('a4', 'landscape')
  this.pageNumber++
  // Update layout constants for landscape
  this.currentLayout = {
    pageWidth: 297,
    pageHeight: 210,
    margin: { top: 14, bottom: 14, left: 14, right: 14 },
    contentWidth: 269,
    contentHeight: 182,
  }
  this.yPos = this.currentLayout.margin.top
}
```

#### Priority 3: Column Abbreviations with Legend

For tables that must remain in portrait, use standardised abbreviations:

| Full Header | Abbreviation | Width Saved |
|-------------|--------------|-------------|
| Metrics | M | 75% |
| Economic Buyer | EB | 85% |
| Decision Criteria | DC | 80% |
| Champion | Ch | 70% |
| Identified Pain | IP | 80% |
| Competition | Co | 80% |

**Implementation:**

```typescript
const COLUMN_ABBREVIATIONS: Record<string, string> = {
  'Metrics': 'M',
  'Economic Buyer': 'EB',
  'Decision Criteria': 'DC',
  'Decision Process': 'DP',
  'Paper Process': 'PP',
  'Identified Pain': 'IP',
  'Champion': 'Ch',
  'Competition': 'Co',
}

// Add legend below table
private addAbbreviationLegend(abbreviations: string[]): void {
  this.doc.setFontSize(7)
  this.doc.setTextColor(120, 120, 120)
  const legendText = abbreviations
    .map(abbr => `${abbr} = ${Object.entries(COLUMN_ABBREVIATIONS).find(([_, v]) => v === abbr)?.[0]}`)
    .join(' | ')
  this.doc.text(legendText, this.margin.left, this.yPos + 4)
  this.yPos += 8
}
```

---

## 2. Typography Improvements

### The Problem

Current implementation uses jsPDF defaults which lack the refined typography of professional documents. Line height is too tight, making dense data hard to scan.

### Industry Standards

**Stripe Typography (stripe.com/docs)**
- Body: 16px/24px (1.5 line-height)
- Table cells: 14px/20px (1.43 line-height)
- Captions: 12px/16px (1.33 line-height)

**Apple Typography (HIG PDFs)**
- Minimum line-height: 1.4 for body text
- Table headers: SF Pro Bold, +1px tracking
- Cell padding: 12px vertical minimum

**Notion Typography**
- Body: 16px/1.5
- Table: 14px/1.4
- Headers: 700 weight, 0.5px letter-spacing

### Recommended Typography Scale for PDF

```typescript
// altera-branding.ts - Typography Scale
export const AlteraTypography = {
  // Document title (cover page)
  h1: { size: 28, lineHeight: 1.2, weight: 'bold', letterSpacing: -0.5 },

  // Section headers
  h2: { size: 18, lineHeight: 1.3, weight: 'semibold', letterSpacing: 0 },

  // Subsection headers
  h3: { size: 14, lineHeight: 1.4, weight: 'medium', letterSpacing: 0.25 },

  // Body text
  body: { size: 10, lineHeight: 1.5, weight: 'regular', letterSpacing: 0 },

  // Table headers
  tableHeader: { size: 9, lineHeight: 1.3, weight: 'semibold', letterSpacing: 0.5 },

  // Table cells
  tableCell: { size: 9, lineHeight: 1.4, weight: 'regular', letterSpacing: 0 },

  // Captions and footnotes
  caption: { size: 8, lineHeight: 1.3, weight: 'regular', letterSpacing: 0.25 },
}

// Helper function
export function applyTypography(doc: jsPDF, style: keyof typeof AlteraTypography): void {
  const config = AlteraTypography[style]
  doc.setFontSize(config.size)
  // Note: jsPDF doesn't support letter-spacing natively
  // Font weight requires loading font variants
}
```

### Line Height Implementation

jsPDF's `autoTable` doesn't directly support line-height, but we can simulate it with cell padding:

```typescript
// Effective line-height through padding
const LINE_HEIGHT_RATIO = 1.4
const BASE_FONT_SIZE = 9

autoTable(this.doc, {
  styles: {
    fontSize: BASE_FONT_SIZE,
    cellPadding: {
      top: BASE_FONT_SIZE * (LINE_HEIGHT_RATIO - 1) / 2,    // ~1.8pt
      bottom: BASE_FONT_SIZE * (LINE_HEIGHT_RATIO - 1) / 2, // ~1.8pt
      left: 4,
      right: 4,
    },
    lineHeight: LINE_HEIGHT_RATIO,  // autoTable supports this
  },
})
```

---

## 3. List Formatting

### The Problem

Markdown bullet points like `- Item one - Item two - Item three` render as continuous text: "- Item one - Item two - Item three" instead of a properly formatted list.

### Industry Approaches

**Stripe Documentation**
- Clear visual bullets (small filled circles)
- 24px left indent
- 8px vertical spacing between items
- Nested lists use hollow circles, then dashes

**Linear Changelogs**
- Uses checkmarks or category icons instead of generic bullets
- 16px spacing between items
- Grey bullet, dark text for contrast

**Notion Exports**
- Consistent 6px bullet size
- 28px indent from margin
- 1.5x line-height within items
- 0.5x line-height between items

### Recommended Implementation

```typescript
// Helper function to parse and render bullet lists
private renderBulletList(text: string, startY: number): number {
  const BULLET_INDENT = 14          // mm from left margin
  const BULLET_SIZE = 1.5           // mm diameter
  const ITEM_SPACING = 6            // mm between items
  const LINE_HEIGHT = 4.5           // mm per line of text
  const MAX_LINE_WIDTH = 160        // mm before wrapping

  let yPos = startY

  // Parse dash-separated items
  const items = text.split(/\s*[-•]\s+/).filter(item => item.trim())

  for (const item of items) {
    // Draw bullet
    this.doc.setFillColor(...hexToRgb(AlteraBrand.neutral.medium))
    this.doc.circle(
      this.margin.left + BULLET_SIZE,
      yPos + 1.5,  // Vertically centre with text
      BULLET_SIZE / 2,
      'F'
    )

    // Wrap text if needed
    const textLines = this.doc.splitTextToSize(item.trim(), MAX_LINE_WIDTH)

    this.doc.setFontSize(10)
    this.doc.setTextColor(40, 40, 40)
    textLines.forEach((line: string, lineIndex: number) => {
      this.doc.text(line, this.margin.left + BULLET_INDENT, yPos + (lineIndex * LINE_HEIGHT))
    })

    yPos += (textLines.length * LINE_HEIGHT) + ITEM_SPACING
  }

  return yPos
}

// Usage in content generation
private generateRiskAssessment(): void {
  // ...
  const mitigationSteps = risk.mitigation || '- No mitigation defined'
  this.yPos = this.renderBulletList(mitigationSteps, this.yPos)
}
```

### Visual Comparison

```
BEFORE:
Mitigation steps - Review contract terms - Schedule QBR -
Escalate to executive sponsor - Document concerns

AFTER:
Mitigation steps:
  • Review contract terms
  • Schedule QBR
  • Escalate to executive sponsor
  • Document concerns
```

---

## 4. Data Density: T/F Alternatives

### The Problem

Boolean columns showing "T" or "F" (or "True"/"False") create visual clutter and waste space in tables with many binary fields.

### Industry Approaches

**Stripe Dashboard**
- Uses icons: checkmark (green) for true, X (red) for false, dash (grey) for null
- Never uses text for booleans in tables

**Linear Issue Tracker**
- Status dots: green filled = complete, grey hollow = incomplete
- Hover reveals text tooltip

**Notion Tables**
- Checkbox cells: filled checkbox = true, empty = false
- Takes only 20px column width

**Apple System Preferences**
- Checkmarks only (no explicit "false" indicator)
- Absence = false

### Recommended Visual Indicators

Since jsPDF has limited Unicode support, use simple ASCII-compatible symbols:

```typescript
// Boolean rendering options (ordered by recommendation)
const BOOLEAN_FORMATS = {
  // Option 1: Checkmark only (cleanest)
  checkOnly: {
    true: '[x]',
    false: '[ ]',
    null: '[-]',
  },

  // Option 2: Filled/empty circles (if unicode works)
  circles: {
    true: '●',   // \u25CF
    false: '○',  // \u25CB
    null: '◌',   // \u25CC
  },

  // Option 3: Y/N (more explicit)
  yesNo: {
    true: 'Y',
    false: 'N',
    null: '-',
  },
}

// Column width comparison
const COLUMN_WIDTHS = {
  'True/False': 35,  // mm
  '[x]/[ ]': 12,     // mm - 66% space savings
  'Y/N': 10,         // mm - 71% space savings
}
```

### Implementation with Colour Coding

```typescript
private formatBoolean(value: boolean | null, format: 'check' | 'color' = 'check'): { text: string; color: [number, number, number] } {
  if (value === true) {
    return format === 'check'
      ? { text: '[x]', color: [34, 139, 34] }   // Forest green
      : { text: 'Y', color: [34, 139, 34] }
  }
  if (value === false) {
    return format === 'check'
      ? { text: '[ ]', color: [180, 180, 180] } // Grey
      : { text: 'N', color: [180, 180, 180] }
  }
  return { text: '-', color: [180, 180, 180] }   // Grey for null
}

// In autoTable cell styling
autoTable(this.doc, {
  didParseCell: (data) => {
    // If this is a boolean column
    if (BOOLEAN_COLUMNS.includes(data.column.index)) {
      const formatted = this.formatBoolean(data.cell.raw as boolean)
      data.cell.text = [formatted.text]
      data.cell.styles.textColor = formatted.color
      data.cell.styles.halign = 'center'
    }
  },
})
```

### Visual Density Improvement

```
BEFORE (14 columns):
| Client | Champion | Blocker | Executive | Budget | Timeline | Pain | ... |
| ACME   | True     | False   | True      | True   | False    | True | ... |

AFTER (same data, 40% narrower):
| Client | Ch | Bl | Ex | Bu | Tl | Pa | ... |
| ACME   | Y  | -  | Y  | Y  | -  | Y  | ... |

Or with visual indicators:
| Client | Ch  | Bl  | Ex  | Bu  | Tl  | Pa  | ... |
| ACME   | [x] | [ ] | [x] | [x] | [ ] | [x] | ... |
```

---

## 5. Cell Padding and Table Styling

### The Problem

Default jsPDF-autoTable styling creates tables that feel cramped and lack the polished appearance of enterprise documentation.

### Industry Standards

**Stripe Tables**
- Horizontal padding: 16px
- Vertical padding: 12px (cells), 16px (headers)
- Header background: subtle grey (#F7F7F7)
- Row borders: 1px #EBEBEB (horizontal only)
- No vertical cell borders

**Apple Tables (HIG)**
- Generous whitespace (20px+ padding)
- Alternating row colours (very subtle)
- Bold headers, normal weight data
- Left-align text, right-align numbers

**Linear Tables**
- Minimal borders (bottom only)
- Hover states for interactivity (N/A for PDF)
- Icon + text in cells where relevant

**Notion Tables**
- Full borders but light (#E0E0E0)
- Header row has stronger bottom border
- Equal padding all around (12px)

### Recommended Table Configuration

```typescript
// altera-branding.ts - Table Styles
export const AlteraTableStyles = {
  // Primary table style (most tables)
  default: {
    theme: 'plain' as const,
    styles: {
      fontSize: 9,
      cellPadding: { top: 4, bottom: 4, left: 6, right: 6 },
      lineColor: [220, 220, 220] as [number, number, number],
      lineWidth: 0.1,
      textColor: [40, 40, 40] as [number, number, number],
      font: 'Montserrat',
    },
    headStyles: {
      fillColor: [247, 247, 250] as [number, number, number],  // Very light grey-purple
      textColor: [57, 51, 145] as [number, number, number],    // Altera purple
      fontStyle: 'bold' as const,
      fontSize: 9,
      cellPadding: { top: 5, bottom: 5, left: 6, right: 6 },
      halign: 'left' as const,
    },
    bodyStyles: {
      halign: 'left' as const,
    },
    alternateRowStyles: {
      fillColor: [252, 252, 254] as [number, number, number],  // Very subtle alternate
    },
    columnStyles: {
      // Numbers right-aligned
      numeric: { halign: 'right' as const },
      // Centre for status/boolean
      status: { halign: 'center' as const },
    },
  },

  // Compact style (for dense data like MEDDPICC)
  compact: {
    styles: {
      fontSize: 8,
      cellPadding: { top: 2, bottom: 2, left: 4, right: 4 },
    },
  },

  // Risk/alert style (red header)
  risk: {
    headStyles: {
      fillColor: [239, 68, 68] as [number, number, number],  // Red
      textColor: [255, 255, 255] as [number, number, number],
    },
  },

  // Success style (green header)
  success: {
    headStyles: {
      fillColor: [34, 139, 34] as [number, number, number],
      textColor: [255, 255, 255] as [number, number, number],
    },
  },
}
```

### Improved Border Strategy

Remove vertical borders for cleaner appearance (Stripe pattern):

```typescript
autoTable(this.doc, {
  startY: this.yPos,
  head: [headers],
  body: data,
  ...AlteraTableStyles.default,
  // Override to remove vertical lines
  tableLineColor: [220, 220, 220],
  tableLineWidth: 0,
  didDrawCell: (data) => {
    // Draw only bottom border for each cell
    if (data.section === 'body' || data.section === 'head') {
      this.doc.setDrawColor(220, 220, 220)
      this.doc.setLineWidth(0.1)
      this.doc.line(
        data.cell.x,
        data.cell.y + data.cell.height,
        data.cell.x + data.cell.width,
        data.cell.y + data.cell.height
      )
    }
  },
})
```

---

## 6. Client Name Wrapping

### The Problem

Long client names like "Melbourne Health and Aged Care Services" break mid-word when columns are narrow, producing:

```
| Melbourne He- |
| alth and Ag-  |
| ed Care Se... |
```

### Industry Solutions

**Stripe**
- Uses CSS `word-break: break-word` (not mid-word)
- Truncates with ellipsis after 2 lines
- Tooltip reveals full name

**Apple**
- Abbreviates known entities (Apple Inc. -> Apple)
- Uses fixed-width columns that accommodate longest expected value

**Linear**
- Truncates with ellipsis
- Full name in expandable row

### Recommended Approach

```typescript
private formatClientName(name: string, maxWidth: number): string {
  // 1. Check if it fits
  const textWidth = this.doc.getTextWidth(name)
  if (textWidth <= maxWidth) {
    return name
  }

  // 2. Try abbreviating common suffixes
  const ABBREVIATIONS: Record<string, string> = {
    ' Health Service': ' HS',
    ' Health Services': ' HS',
    ' and Aged Care': ' & AC',
    ' Metropolitan': ' Metro',
    ' Regional': ' Reg',
    ' Hospital': ' Hosp',
    ' Services': ' Svcs',
    ' Department': ' Dept',
    ' Corporation': ' Corp',
    ' Incorporated': ' Inc',
    ' Limited': ' Ltd',
    ' Australia': ' AU',
    ' New Zealand': ' NZ',
  }

  let abbreviated = name
  for (const [full, abbr] of Object.entries(ABBREVIATIONS)) {
    if (abbreviated.includes(full)) {
      abbreviated = abbreviated.replace(full, abbr)
      if (this.doc.getTextWidth(abbreviated) <= maxWidth) {
        return abbreviated
      }
    }
  }

  // 3. Truncate at word boundary with ellipsis
  const words = abbreviated.split(' ')
  let truncated = ''
  for (const word of words) {
    const test = truncated ? `${truncated} ${word}` : word
    if (this.doc.getTextWidth(test + '...') > maxWidth) {
      return truncated ? `${truncated}...` : `${word.substring(0, 10)}...`
    }
    truncated = test
  }

  return truncated
}
```

### Column Width Strategy

Define minimum widths that accommodate typical values:

```typescript
const COLUMN_MIN_WIDTHS = {
  clientName: 45,      // Fits "Melbourne Metro HS"
  personName: 35,      // Fits "Dr. Sarah Chen-Williams"
  currency: 25,        // Fits "$12,345,678"
  percentage: 15,      // Fits "100%"
  date: 22,            // Fits "29/01/2026"
  boolean: 10,         // Fits "[x]"
  score: 12,           // Fits "5/5"
  status: 20,          // Fits "In Progress"
}
```

---

## 7. Responsive Column Strategy

### Dynamic Column Allocation

When table content varies, calculate column widths based on actual content:

```typescript
private calculateColumnWidths(headers: string[], data: string[][]): number[] {
  const PADDING = 4  // mm padding each side
  const MIN_WIDTH = 15
  const MAX_WIDTH = 60

  const widths: number[] = []

  for (let col = 0; col < headers.length; col++) {
    // Find longest value in column (including header)
    let maxLength = this.doc.getTextWidth(headers[col])

    for (const row of data) {
      const cellWidth = this.doc.getTextWidth(row[col] || '')
      maxLength = Math.max(maxLength, cellWidth)
    }

    // Add padding and clamp to min/max
    const width = Math.min(MAX_WIDTH, Math.max(MIN_WIDTH, maxLength + PADDING * 2))
    widths.push(width)
  }

  // Check total width - if exceeds page, proportionally reduce
  const totalWidth = widths.reduce((a, b) => a + b, 0)
  const availableWidth = this.contentWidth

  if (totalWidth > availableWidth) {
    const ratio = availableWidth / totalWidth
    return widths.map(w => Math.max(MIN_WIDTH, w * ratio))
  }

  return widths
}
```

---

## 8. Implementation Priority Matrix

| Recommendation | Effort | Impact | Priority |
|----------------|--------|--------|----------|
| Transpose wide tables (MEDDPICC) | Medium | High | P1 |
| List formatting (bullet parsing) | Low | High | P1 |
| Boolean visual indicators (Y/N) | Low | Medium | P1 |
| Cell padding increase | Low | Medium | P2 |
| Client name abbreviations | Medium | Medium | P2 |
| Landscape for 7+ columns | Low | Medium | P2 |
| Typography scale | Medium | Medium | P2 |
| Remove vertical borders | Low | Low | P3 |
| Dynamic column widths | High | Medium | P3 |
| Column abbreviation legends | Low | Low | P3 |

---

## 9. Complete Code Example

Below is a refactored version of a typical table generation function incorporating all recommendations:

```typescript
// account-plan-pdf.ts - Example: Stakeholder Directory

private generateStakeholderDirectory(): void {
  this.addSectionHeader('Stakeholder Directory')

  const stakeholders = this.data.stakeholders || []

  if (stakeholders.length === 0) {
    this.drawNoDataMessage('Add stakeholders in the Account Planning section')
    return
  }

  // Define columns with smart widths
  const columns = [
    { header: 'Name', key: 'name', width: 40, align: 'left' },
    { header: 'Role', key: 'role', width: 35, align: 'left' },
    { header: 'Influence', key: 'influence', width: 20, align: 'center' },
    { header: 'Champion', key: 'isChampion', width: 15, align: 'center', type: 'boolean' },
    { header: 'Blocker', key: 'isBlocker', width: 15, align: 'center', type: 'boolean' },
    { header: 'Last Contact', key: 'lastContact', width: 22, align: 'left' },
  ]

  const headers = columns.map(c => c.header)
  const columnStyles: Record<number, { cellWidth: number; halign: 'left' | 'center' | 'right' }> = {}

  columns.forEach((col, idx) => {
    columnStyles[idx] = {
      cellWidth: col.width,
      halign: col.align as 'left' | 'center' | 'right',
    }
  })

  const body = stakeholders.map(s => [
    this.formatClientName(s.name || '', 35),
    formatSnakeCaseToTitleCase(s.role || ''),
    s.influence ? `${s.influence}/10` : '-',
    this.formatBoolean(s.isChampion).text,
    this.formatBoolean(s.isBlocker).text,
    s.lastContact ? new Date(s.lastContact).toLocaleDateString('en-AU') : '-',
  ])

  autoTable(this.doc, {
    startY: this.yPos,
    head: [headers],
    body: body,
    ...AlteraTableStyles.default,
    columnStyles: columnStyles,
    didParseCell: (data) => {
      // Colour boolean cells
      const colIndex = data.column.index
      if (columns[colIndex]?.type === 'boolean') {
        const value = stakeholders[data.row.index]?.[columns[colIndex].key as keyof typeof stakeholders[0]]
        const formatted = this.formatBoolean(value as boolean | null)
        data.cell.styles.textColor = formatted.color
      }
    },
  })

  this.yPos = (this.doc as any).lastAutoTable.finalY + 10
}
```

---

## 10. Testing Checklist

Before deploying changes:

- [ ] Generate PDF with 14-column table - verify no overlapping
- [ ] Generate PDF with 20+ stakeholders - verify pagination works
- [ ] Check client names 40+ characters - verify clean wrapping/abbreviation
- [ ] Check boolean columns - verify visual indicators render correctly
- [ ] Check bullet lists - verify proper line breaks and spacing
- [ ] Check landscape tables - verify header/footer still appear
- [ ] Check empty states - verify placeholder messages appear
- [ ] Print test - verify legibility at 100% scale
- [ ] Compare to Stripe API docs PDF - assess professional appearance parity

---

## References

- [Stripe API Documentation Style](https://stripe.com/docs)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Linear Changelog](https://linear.app/changelog)
- [Notion Template Gallery](https://www.notion.so/templates)
- [jsPDF-AutoTable Documentation](https://github.com/simonbengtsson/jsPDF-AutoTable)
- [Butterick's Practical Typography](https://practicaltypography.com/)

---

## Document History

| Date | Author | Changes |
|------|--------|---------|
| 2026-01-29 | Claude Opus 4.5 | Initial recommendations document |

