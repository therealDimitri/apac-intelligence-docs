# 2026 CS Operating Rhythm - Pitch Presentation Guide

**Purpose:** Design specification for building the presentation in [Pitch](https://pitch.com)

---

## Why Pitch?

Pitch is ideal for this presentation because:
- **Real-time collaboration** — Multiple team members can edit simultaneously
- **Smart templates** — Modern, consistent design system built-in
- **Animations** — Smooth, professional transitions without code
- **Analytics** — Track who views and engages with the deck
- **Embed support** — Embed Loom, Figma, and live data
- **Export options** — PDF, video recording, shareable links

---

## Pitch Template Recommendation

Use: **"Company Overview"** or **"Quarterly Update"** template as base

Then customise with these brand settings:

### Brand Kit Setup

```
Primary Colors:
├── Background:     #0a0a0a (Dark)
├── Surface:        #18181b (Cards)
├── Border:         #27272a (Dividers)
├── Text Primary:   #fafafa (White)
└── Text Muted:     #a1a1aa (Gray)

Accent Colors (Category-coded):
├── NPS:            #f59e0b (Amber)
├── Planning:       #3b82f6 (Blue)
├── Audit:          #8b5cf6 (Violet)
├── MarCom:         #ec4899 (Pink)
└── Segmentation:   #10b981 (Green)

Typography:
├── Headings:       Inter Bold
├── Body:           Inter Regular
└── Data/Code:      JetBrains Mono
```

---

## Slide-by-Slide Design Spec

### Slide 1: Title

**Layout:** Centered title, dark gradient background

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                                                                 │
│                                                                 │
│                    2026 Operating Rhythm                        │
│                    ━━━━━━━━━━━━━━━━━━━━━                        │
│                                                                 │
│                    APAC Client Success                          │
│                                                                 │
│                                                                 │
│                                                                 │
│            Charting the Course, Delivering Together             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pitch features to use:**
- Gradient text on main title (Blue → Violet → Pink)
- Subtle particle animation in background
- Fade-in animation on tagline

---

### Slide 2: Strategic Context (Bento Grid)

**Layout:** 3-column bento grid with key metrics

```
┌─────────────────────────────────────────────────────────────────┐
│                     Strategic Context                           │
│                                                                 │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │
│  │  📉 ATTRITION   │ │  📈 PIPELINE    │ │  ⚠️ CONC.       │   │
│  │                 │ │                 │ │                 │   │
│  │    $2.72M       │ │    $8.36M       │ │      80%        │   │
│  │                 │ │                 │ │                 │   │
│  │  FY25-28        │ │  CSE Weighted   │ │  4 clients =    │   │
│  │  Confirmed      │ │  Opportunities  │ │  Maintenance    │   │
│  └─────────────────┘ └─────────────────┘ └─────────────────┘   │
│                                                                 │
│  At 35% conversion, pipeline barely covers attrition.           │
│  Execution is critical.                                         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pitch features to use:**
- Smart Layout → "Stats" block
- Coloured borders on cards (Amber, Blue, neutral)
- Animate cards sequentially

---

### Slide 3: Annual Orbit View

**Layout:** Circular/radial diagram showing the year

```
┌─────────────────────────────────────────────────────────────────┐
│                      Annual Orbit                               │
│                                                                 │
│                         JAN                                     │
│                      ╭───────╮                                  │
│                   ╱  🔵       ╲                                 │
│               DEC│   Compass   │FEB                             │
│                  │             │                                │
│                  │    2026     │                                │
│              NOV │             │ MAR                            │
│                  │             │                                │
│                   ╲  🟡      ╱                                  │
│               OCT  ╲ Q4 NPS╱  APR                              │
│                      ╰───╯                                      │
│                   🟡          🟡                                 │
│                  Q4 NPS      Q2 NPS                             │
│                                                                 │
│           SEP                       MAY                         │
│                    AUG    JUL   JUN                             │
│                         🟣                                       │
│                       MarCom                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pitch features to use:**
- Smart Layout → "Process" or custom shape arrangement
- Animate each event appearing around the circle
- Use Pitch's shape tools for orbit rings
- Clickable hotspots linking to detail slides

**How to build in Pitch:**
1. Insert → Shape → Circle (3 concentric rings, stroke only)
2. Add text box in center: "2026"
3. Position colored circles at 12, 3, 6, 9 o'clock positions
4. Add labels for months around perimeter
5. Group all elements
6. Set animation: "Pop" for each event circle, sequenced

---

### Slide 4: Q1 Timeline

**Layout:** Horizontal timeline with event cards below

```
┌─────────────────────────────────────────────────────────────────┐
│               Q1: Foundation (Jan - Mar)                        │
│                                                                 │
│   JAN ────────●────────●─────────────────────────────────────   │
│               │        │                                        │
│           Sales    Compass                                      │
│          Workshop   21-23                                       │
│            12                                                   │
│                                                                 │
│   FEB ───────────────────────────────────────────────────────   │
│                                                                 │
│   MAR ───────●────────────────────────────────────────●──────   │
│              │                                        │         │
│         Q1 Plan                                   NPS List      │
│         Update                                      Prep        │
│           2-6                                        25         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pitch features to use:**
- Smart Layout → "Timeline" template
- Custom icons for each event type
- Hover states to reveal event details

---

### Slide 5: APAC Compass Deep Dive

**Layout:** Full event card with all details

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│   🔵 PLANNING                                                   │
│                                                                 │
│   APAC Compass                                                  │
│   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                         │
│   21-23 January 2026 • 3 Days                                   │
│                                                                 │
│   ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                      │
│   │ EVP │ │ VP  │ │ AVP │ │CSEs │ │CAMs │                      │
│   └─────┘ └─────┘ └─────┘ └─────┘ └─────┘                      │
│                                                                 │
│   ─────────────────────────────────────────────────────────     │
│   DELIVERABLES                                                  │
│                                                                 │
│   → Annual account plans per client                             │
│   → Pipeline opportunities with probability                     │
│   → Stakeholder strategy & relationship maps                    │
│   → Risk register with mitigations                              │
│   → Satisfaction Action Plans (at-risk clients)                 │
│                                                                 │
│   ─────────────────────────────────────────────────────────     │
│   TOOLS: Planning Hub • Satisfaction Template • Activity Reg    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pitch features to use:**
- Card component with shadow
- Pill/badge components for participants
- List with custom icons (→)
- Link buttons to tools

---

### Slide 6: Q2 - Execute & Measure

**Layout:** Bento grid emphasizing NPS survey

```
┌─────────────────────────────────────────────────────────────────┐
│               Q2: Execute & Measure (Apr - Jun)                 │
│                                                                 │
│   ┌─────────────────────────────────────┐ ┌─────────────────┐   │
│   │  🟡 NPS Q2 SURVEY                   │ │  CS & MarCom    │   │
│   │                                     │ │  Audit          │   │
│   │  April 8-22                         │ │  Apr 13-17      │   │
│   │  2-week survey window               │ │                 │   │
│   │                                     │ │  Q1 learnings   │   │
│   │  Apr 13: Non-responder #1           │ │  review         │   │
│   │  Apr 20: Non-responder #2           │ └─────────────────┘   │
│   │                                     │                       │
│   └─────────────────────────────────────┘ ┌─────────────────┐   │
│                                           │  Segmentation   │   │
│   ┌─────────────────────────────────────┐ │  Review         │   │
│   │  NPS Analysis & Client Letters      │ │  May 18-Jun 12  │   │
│   │  Apr 27 - May 30                    │ │                 │   │
│   │  Workshop → BU → EVP → Send         │ │  Refresh model  │   │
│   └─────────────────────────────────────┘ └─────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pitch features to use:**
- Flexible grid layout
- Large featured card for NPS (spans 2 columns)
- Amber border on NPS cards
- Sequential animation

---

### Slide 7: Q3 - Optimise & Plan Ahead

**Layout:** 3 cards + 1 highlight card

```
┌─────────────────────────────────────────────────────────────────┐
│             Q3: Optimise & Plan Ahead (Jul - Sep)               │
│                                                                 │
│   ┌───────────────┐ ┌───────────────┐ ┌───────────────┐        │
│   │  NPS Init.    │ │  CS & MarCom  │ │  2027 MarCom  │        │
│   │  Update       │ │  Audit        │ │  Kickoff      │        │
│   │  Jul 2        │ │  Jul 13-17    │ │  Jul 20       │        │
│   └───────────────┘ └───────────────┘ └───────────────┘        │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │  ⚠️  CRITICAL DEADLINE                                  │   │
│   │                                                         │   │
│   │  September 30: NPS Q4 Recipient List                    │   │
│   │  Validate contacts • Flag unsubscribed • Upload         │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pitch features to use:**
- Alert/callout component for deadline
- Icon highlight (⚠️)
- Amber background on deadline card

---

### Slide 8: Q4 - Close & Prepare

**Layout:** Similar to Q2 with NPS focus

```
┌─────────────────────────────────────────────────────────────────┐
│               Q4: Close & Prepare (Oct - Dec)                   │
│                                                                 │
│   ┌─────────────────────────────────────┐ ┌─────────────────┐   │
│   │  🟡 NPS Q4 SURVEY                   │ │  Q4 Account     │   │
│   │                                     │ │  Plan Update    │   │
│   │  October 7-21                       │ │  Oct 8          │   │
│   │  Final survey of the year           │ │                 │   │
│   └─────────────────────────────────────┘ │  Year-end prep  │   │
│                                           └─────────────────┘   │
│   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │
│   │  NPS Analysis   │ │  Client Letters │ │  Year-End       │   │
│   │  Oct 26-30      │ │  Nov 23-25      │ │  NPS Review     │   │
│   │  Workshop       │ │  EVP approved   │ │  Dec 16         │   │
│   └─────────────────┘ └─────────────────┘ └─────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

### Slide 9: Segmentation Engagement

**Layout:** Table with color-coded segments

```
┌─────────────────────────────────────────────────────────────────┐
│                  Segmentation Engagement                        │
│           Year-round activities by segment                      │
│                                                                 │
│   ┌──────────────┬────────┬────────┬────────┬────────┬───────┐  │
│   │ Activity     │Maintain│Leverage│Nurture │Collab. │ Giant │  │
│   │              │  🔴    │  🟡    │  🟠    │  🟢    │  🔵   │  │
│   ├──────────────┼────────┼────────┼────────┼────────┼───────┤  │
│   │ Partnership  │ Monthly│Quarterl│ Monthly│Quarterl│Quarterl│  │
│   │ Service Rev  │ Monthly│Quarterl│ Monthly│Quarterl│Quarterl│  │
│   │ Health Check │Quarterl│Bi-ann. │Quarterl│Bi-ann. │Bi-ann. │  │
│   │ QBR          │Quarterl│Quarterl│Quarterl│Quarterl│Quarterl│  │
│   │ Exec Engage  │As need │Bi-ann. │Quarterl│Bi-ann. │Quarterl│  │
│   └──────────────┴────────┴────────┴────────┴────────┴───────┘  │
│                                                                 │
│   Clients in Maintain, Nurture, and Sleeping Giant require      │
│   active Satisfaction Action Plans.                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pitch features to use:**
- Table component with alternating rows
- Colored header cells for each segment
- Footer note in muted text

---

### Slide 10: Tools & Resources

**Layout:** 3-card grid with icons

```
┌─────────────────────────────────────────────────────────────────┐
│                    Tools & Resources                            │
│                                                                 │
│   ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐   │
│   │                 │ │                 │ │                 │   │
│   │       📊        │ │       📋        │ │       📧        │   │
│   │                 │ │                 │ │                 │   │
│   │   DASHBOARD     │ │   TEMPLATES     │ │      NPS        │   │
│   │                 │ │                 │ │                 │   │
│   │ APAC Intelligence│ │ Satisfaction   │ │ HubSpot Surveys │   │
│   │                 │ │ Action Plans    │ │                 │   │
│   │ apac-cs-        │ │ OneDrive >      │ │ Automated       │   │
│   │ dashboards.com  │ │ Segmentation    │ │ deployment      │   │
│   │                 │ │                 │ │                 │   │
│   │   [Open →]      │ │   [Open →]      │ │   [Open →]      │   │
│   └─────────────────┘ └─────────────────┘ └─────────────────┘   │
│                                                                 │
│   Dashboard modules: Command Centre • Client Profiles •         │
│   Planning Hub • Briefing Room • NPS Analytics                  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pitch features to use:**
- Card with icon, title, description
- Link buttons embedded in cards
- Icon library (Pitch has built-in icons)

---

### Slide 11: Key Takeaways

**Layout:** Checklist-style summary

```
┌─────────────────────────────────────────────────────────────────┐
│                      Key Takeaways                              │
│                                                                 │
│                                                                 │
│        🔵  38 scheduled events across the year                  │
│                                                                 │
│        🟡  2 NPS surveys with 4-week analysis cycles            │
│                                                                 │
│        🟣  4 quarterly audits for continuous improvement        │
│                                                                 │
│        🟢  Segmentation-driven engagement cadence               │
│                                                                 │
│        🟣  Plan ahead – 2027 MarCom starts in July              │
│                                                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pitch features to use:**
- "Build" animation (each point appears sequentially)
- Colored bullet icons matching category
- Large text for readability

---

### Slide 12: Questions / End

**Layout:** Centered, minimal

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                                                                 │
│                                                                 │
│                        Questions?                               │
│                                                                 │
│                                                                 │
│                                                                 │
│          docs/2026-CS-OPERATING-RHYTHM.md                       │
│                                                                 │
│                                                                 │
│                                                                 │
│                  APAC Client Success • 2026                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**Pitch features to use:**
- Large centered heading
- Code/monospace styling for file path
- Subtle footer with team attribution

---

## Animation Recommendations

| Slide | Animation | Timing |
|-------|-----------|--------|
| Title | Fade in title, then tagline | 0.5s, 0.3s delay |
| Metrics | Cards pop in left-to-right | 0.3s each, 0.2s stagger |
| Orbit | Events appear clockwise | 0.4s each, 0.3s stagger |
| Timeline | Points draw in sequence | 0.2s each |
| Event cards | Slide up from bottom | 0.4s |
| Tables | Rows fade in top-to-bottom | 0.15s stagger |
| Takeaways | Build one by one | On click |

---

## Pitch-Specific Tips

1. **Use Pitch's Smart Templates**
   - Start with "Company Update" template
   - Swap colours to match brand kit

2. **Embed Live Content**
   - Embed a Loom video walkthrough
   - Link to live APAC Intelligence dashboard

3. **Enable Presenter Notes**
   - Add speaking notes per slide
   - Include timing suggestions

4. **Share Settings**
   - Enable "Allow viewers to copy"
   - Track analytics to see engagement

5. **Export Options**
   - PDF for offline sharing
   - Video recording for async viewing
   - Public link for stakeholders

---

## Quick Start in Pitch

1. Go to [pitch.com](https://pitch.com) and create new presentation
2. Choose "Company Update" template
3. Open Brand Kit (sidebar) → Set colours from spec above
4. Replace template slides with content from this guide
5. Add animations using the Animation panel (right sidebar)
6. Share via link or export to PDF

---

*Design specification for Pitch presentation build.*
