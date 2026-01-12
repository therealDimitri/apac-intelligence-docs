# Bug Fixes: Prioritisation Matrix Alignment & ChaSen Risk Analysis

**Date:** 12 January 2026
**Status:** Resolved
**Type:** Bug Fix + Enhancement
**Severity:** Medium

## Summary

Fixed two related issues:
1. **Account Prioritisation Matrix**: Quadrant names conflicted with Altera segment definitions
2. **ChaSen Risk Analysis**: Poor formatting when expanded, and recommending already-implemented programs (like Voice of Customer)

## Issue 1: Prioritisation Matrix Segment Conflict

### Root Cause
The Account Prioritisation Matrix used quadrant names that conflicted with official Altera segment definitions:
- **Matrix "Maintain"** (High ARR, Low Fit) vs **Altera "Maintain"** (Low spend, Low satisfaction) - opposite meanings
- Users expected clicking quadrant legends to show focus strategies, but no click handler existed

### Solution

#### 1. Renamed Quadrants to Align with Segment Objectives
| Position | Old Name | New Name | Altera Segments |
|----------|----------|----------|-----------------|
| Top-Left (High ARR, Low Fit) | Maintain | **Nurture** | Nurture, Sleeping Giant |
| Top-Right (High ARR, High Fit) | Protect & Grow | Protect & Grow | Giant, Collaboration |
| Bottom-Left (Low ARR, Low Fit) | Evaluate | **Support** | Maintain |
| Bottom-Right (Low ARR, High Fit) | Develop | Develop | Leverage |

#### 2. Added Clickable Focus Strategy Popovers
Each quadrant header is now a clickable button that toggles a focus strategy popover showing:
- **Objective**: e.g., "Increase Satisfaction", "Reference", "Increase Spend"
- **Description**: Strategy explanation aligned with Altera methodology
- **Related Segments**: Badges showing which Altera segments map to this quadrant

### Code Changes

```typescript
// Added state for focus strategy popover
const [activeFocusStrategy, setActiveFocusStrategy] = useState<
  'protect-grow' | 'nurture' | 'leverage' | 'maintain' | null
>(null)

// Focus strategy definitions aligned with Altera segments
const FOCUS_STRATEGIES = {
  'protect-grow': {
    title: 'Protect & Grow',
    segments: ['Giant', 'Collaboration'],
    objective: 'Reference',
    description: 'High-value, satisfied clients. Leverage as reference customers...'
  },
  nurture: {
    segments: ['Nurture', 'Sleeping Giant'],
    objective: 'Increase Satisfaction',
    description: 'High-revenue clients at risk...'
  },
  // ...
}
```

## Issue 2: ChaSen Risk Analysis Formatting & Context

### Root Cause
1. **Poor Formatting**: Risk analysis displayed as a wall of text without visual hierarchy
2. **Missing Context**: AI recommended implementing "Voice of Customer programs" which already exist (NPS, Segmentation Events, etc.)

### Solution

#### 1. Updated AI Prompt with Altera Program Context
Added explicit context about existing Altera programs to prevent redundant recommendations:

```typescript
**CRITICAL CONTEXT - Existing Altera Programs (DO NOT recommend implementing these):**
- NPS Survey Program: Already implemented - quarterly surveys with automated theme extraction
- Client Segmentation: Active program tracking Giant, Collaboration, Leverage, Maintain, Nurture, and Sleeping Giant segments
- Segmentation Events: Compliance tracking for QBRs, EBRs, Renewals, and Success Plans per segment
- Health Score Monitoring: Real-time dashboard tracking client health metrics
- Strategic Planning Hub: Territory and Account planning tools
- MEDDPICC Scoring: Opportunity qualification framework

**IMPORTANT:** When making recommendations, reference using these EXISTING programs rather than suggesting to "implement" or "develop" new ones.
```

#### 2. Improved UI Formatting
Updated AIInsightsPanel CSS for better visual hierarchy:
- **Headers (h2)**: Bottom border, proper spacing, icon alignment
- **Subheaders (h3)**: Purple background pill styling
- **Lists (ul)**: Left border accent with proper spacing
- **Numbered lists (ol)**: Card-style items with background and border
- **Sections**: Clear visual separation between risk categories

### CSS Changes

```css
/* Inline panel styling */
[&>h2]:border-b [&>h2]:border-purple-200 [&>h2]:flex [&>h2]:items-center [&>h2]:gap-2
[&>h3]:bg-purple-50 [&>h3]:px-3 [&>h3]:py-1.5 [&>h3]:rounded-lg
[&>ul>li]:border-l-2 [&>ul>li]:border-purple-200 [&>ul>li]:ml-2
[&>ol>li]:bg-gray-50 [&>ol>li]:px-3 [&>ol>li]:py-2 [&>ol>li]:rounded-lg [&>ol>li]:border

/* Fullscreen modal styling */
[&>h2]:border-b-2 [&>h2]:border-purple-200
[&>h3]:bg-purple-50 [&>h3]:px-4 [&>h3]:py-2 [&>h3]:rounded-lg
```

#### 3. Improved Fallback Risk Analysis
Updated the fallback generator to:
- Group clients by risk severity (Critical, High, Moderate)
- Use markdown headers and sections for clear structure
- Reference existing Altera programs in recommendations

## Files Modified

1. **src/app/(dashboard)/planning/strategic/new/page.tsx**
   - Added `activeFocusStrategy` state and `FOCUS_STRATEGIES` config
   - Updated quadrant names (Maintain → Nurture, Evaluate → Support)
   - Added clickable headers with focus strategy popovers
   - Updated summary labels to match

2. **src/app/api/planning/strategic/new/ai/route.ts**
   - Added Altera program context to `buildAnalyzeRisksPrompt`
   - Added segment definitions for context
   - Improved `generateFallbackRiskAnalysis` with structured sections
   - Added NPS themes summary to risk analysis prompt

3. **src/components/planning/unified/AIInsightsPanel.tsx**
   - Enhanced inline panel CSS for better visual hierarchy
   - Enhanced fullscreen modal CSS for readability
   - Added section styling for headers, lists, and cards

## Testing Performed

- [x] Build passes with zero TypeScript errors
- [x] Quadrant headers are clickable and toggle focus strategy popovers
- [x] Focus strategy shows correct segment badges
- [x] Quadrant summary labels match new names (Nurture, Support)
- [x] ChaSen risk analysis prompt includes Altera program context
- [x] Fallback risk analysis has structured sections with visual hierarchy

## Visual Changes

### Before
- Wall of text without visual separation
- Quadrant names conflicted with segment terminology
- Recommendations suggested implementing existing programs

### After
- Clear section headers with purple styling
- Cards for recommended actions
- Left-border accent for bullet points
- Quadrant names align with Altera segmentation
- Recommendations reference using existing programs

## Commits

1. `fix: Align prioritisation matrix with Altera segments, add clickable focus strategies`
2. `fix: Improve ChaSen risk analysis UI and add Altera program context`
