# Feature: PowerPoint Templates Library

**Date:** 16 December 2024
**Commit:** `f01eef6`
**Status:** Implemented

## Overview

Added a comprehensive library of 15 professional PowerPoint templates with Altera Digital Health branding. Templates are downloadable directly from the Guides & Resources page.

## Features Implemented

### 1. PowerPoint Template Generator Script

**File:** `scripts/generate-ppt-templates.py`

A Python script using the `python-pptx` library to generate branded PowerPoint templates with:

- Altera brand colours (Primary Purple #7C3AED)
- Consistent slide layouts across all templates
- Professional typography and spacing
- Widescreen format (13.33" x 7.5")

**Slide Types:**

- Title slides with branded header bar
- Section divider slides
- Content slides with bullet points
- Two-column comparison slides
- Metrics/KPI slides
- Table slides
- Action items slides
- Closing slides with next steps

### 2. Template Categories

All templates saved to `public/templates/presentations/`:

#### Customer Meeting Templates

| Template                  | Filename                                  | Purpose                                                                 |
| ------------------------- | ----------------------------------------- | ----------------------------------------------------------------------- |
| QBR Presentation          | `QBR-Presentation-Template.pptx`          | Quarterly Business Reviews with health scorecard, metrics, ROI analysis |
| Executive Business Review | `Executive-Business-Review-Template.pptx` | Strategic alignment, business outcomes, benchmarking                    |
| Check-in Meeting Agenda   | `Check-in-Meeting-Agenda-Template.pptx`   | Regular client check-ins with wins, usage, support items                |

#### Renewal Templates

| Template                | Filename                                | Purpose                                                     |
| ----------------------- | --------------------------------------- | ----------------------------------------------------------- |
| Renewal Proposal        | `Renewal-Proposal-Template.pptx`        | Executive summary, value retrospective, ROI analysis        |
| Renewal Risk Assessment | `Renewal-Risk-Assessment-Template.pptx` | Health indicators, stakeholder mapping, mitigation strategy |
| Multi-Year Commitment   | `Multi-Year-Commitment-Template.pptx`   | TCO analysis, discount structure, commitment benefits       |

#### Expansion Templates

| Template                | Filename                                | Purpose                                                 |
| ----------------------- | --------------------------------------- | ------------------------------------------------------- |
| Upsell Discovery        | `Upsell-Discovery-Template.pptx`        | Usage analysis, unutilised features, ROI projection     |
| Cross-Sell Opportunity  | `Cross-Sell-Opportunity-Template.pptx`  | Solution footprint, adjacent products, bundling options |
| Expansion Business Case | `Expansion-Business-Case-Template.pptx` | Current state, benefits breakdown, payback period       |

#### Risk Mitigation Templates

| Template                      | Filename                                      | Purpose                                                       |
| ----------------------------- | --------------------------------------------- | ------------------------------------------------------------- |
| At-Risk Recovery Plan         | `At-Risk-Recovery-Plan-Template.pptx`         | Situation assessment, root cause analysis, 30/60/90 day plan  |
| Attrition Prevention Playbook | `Attrition-Prevention-Playbook-Template.pptx` | Warning indicators, intervention tactics, escalation protocol |

#### Sales Process Templates

| Template           | Filename                           | Purpose                                                   |
| ------------------ | ---------------------------------- | --------------------------------------------------------- |
| Discovery Call     | `Discovery-Call-Template.pptx`     | Business objectives, challenges, stakeholders, timeline   |
| Demo Customisation | `Demo-Customization-Template.pptx` | Audience profile, pain points, features to highlight      |
| Proposal           | `Proposal-Template.pptx`           | Executive summary, solution overview, implementation plan |
| Negotiation Prep   | `Negotiation-Prep-Template.pptx`   | Walk-away price, concession strategy, close plan          |

### 3. Guides Page Integration

**File:** `src/app/(dashboard)/guides/page.tsx`

Added download buttons to all 15 template cards in the Templates Library section:

- Colour-coded buttons matching each card's theme
- Direct download via `<a href="..." download>` pattern
- Lucide `Download` icon added to imports
- Buttons styled with hover states and transitions

## Brand Colours Used

| Colour                  | Hex       | Usage                    |
| ----------------------- | --------- | ------------------------ |
| Altera Purple (Primary) | `#7C3AED` | Headers, primary accents |
| Altera Purple Dark      | `#5B21B6` | Dark mode, emphasis      |
| Altera Blue             | `#3B82F6` | Secondary accents        |
| Altera Green            | `#22C55E` | Success states           |
| Altera Orange           | `#F97316` | Warning states           |
| Altera Red              | `#EF4444` | Critical/risk states     |

## Technical Implementation

### Dependencies

- `python-pptx` - Python library for creating PowerPoint files
- Lucide React icons (Download icon added)

### File Structure

```
public/
  templates/
    presentations/
      At-Risk-Recovery-Plan-Template.pptx
      Attrition-Prevention-Playbook-Template.pptx
      Check-in-Meeting-Agenda-Template.pptx
      Cross-Sell-Opportunity-Template.pptx
      Demo-Customization-Template.pptx
      Discovery-Call-Template.pptx
      Executive-Business-Review-Template.pptx
      Expansion-Business-Case-Template.pptx
      Multi-Year-Commitment-Template.pptx
      Negotiation-Prep-Template.pptx
      Proposal-Template.pptx
      QBR-Presentation-Template.pptx
      Renewal-Proposal-Template.pptx
      Renewal-Risk-Assessment-Template.pptx
      Upsell-Discovery-Template.pptx

scripts/
  generate-ppt-templates.py
```

## Usage

### Downloading Templates

1. Navigate to **Guides & Resources** in the dashboard
2. Go to the **Workflows & Templates** tab
3. Expand the **Templates Library** section
4. Click the **Download Template** button on any template card

### Regenerating Templates

To regenerate all templates (e.g., after brand updates):

```bash
python3 scripts/generate-ppt-templates.py
```

### Customising Templates

1. Open any downloaded template in PowerPoint
2. Replace placeholder text with client-specific information
3. Add client logo to title slide
4. Update metrics and data as needed

## Future Enhancements

- [ ] Add client logo placeholder positions
- [ ] Create template variants for different client tiers
- [ ] Add speaker notes to each slide
- [ ] Integrate with ChaSen AI for auto-population
- [ ] Add template preview thumbnails to Guides page

## Related Files

- `src/app/(dashboard)/guides/page.tsx` - Guides & Resources page
- `scripts/generate-ppt-templates.py` - Template generator script
- `public/templates/presentations/` - Generated template files
