# CSE Email Communications System

## Overview

A structured weekly email communication system designed to coach, guide, and acknowledge CSE performance across their full portfolio - including AR health, client engagement, NPS, and strategic initiatives.

---

## Weekly Email Cadence

### Monday: "Week Ahead Focus" Email

**Send time:** 7:00 AM local time
**Purpose:** Set priorities and focus areas for the week

### Wednesday: "Mid-Week Check-In" Email

**Send time:** 12:00 PM local time
**Purpose:** Progress update, course corrections, and encouragement

### Friday: "Week in Review" Email

**Send time:** 3:00 PM local time
**Purpose:** Celebrate wins, acknowledge effort, provide coaching insights

---

## Email Content Breakdown

### 1. Monday - "Week Ahead Focus"

**Subject line:** `🎯 [Name], Your Week Ahead: [X] Priority Actions`

#### Sections:

**A. Portfolio Health Snapshot**

- Total clients in portfolio
- Overall health score (aggregated)
- Clients requiring attention (red/amber status)

**B. AR Focus Areas**
| Priority | Client | Issue | Suggested Action |
|----------|--------|-------|------------------|
| 🔴 Critical | Client A | $45K at 95 days | Schedule call today |
| 🟡 High | Client B | $28K at 62 days | Send payment reminder |
| 🟢 Monitor | Client C | Payment plan active | Follow up Thursday |

**C. Client Engagement Priorities**

- Clients with no contact in 30+ days
- Upcoming contract renewals (next 90 days)
- Recent NPS detractors needing follow-up
- Scheduled meetings this week

**D. Strategic Initiatives**

- Active initiatives requiring updates
- Deadlines approaching this week
- Cross-functional dependencies

**E. Quick Wins Available**

- Easy actions that will improve metrics
- Low-effort, high-impact opportunities

**F. Personal Development Tip**

- Weekly rotating tips on AR management, client communication, etc.

---

### 2. Wednesday - "Mid-Week Check-In"

**Subject line:** `📊 Mid-Week Update: [X] of [Y] Actions Completed`

#### Sections:

**A. Progress Dashboard**

```
Monday Priorities Progress:
✅ Completed: 3
🔄 In Progress: 2
⏳ Not Started: 1
```

**B. What's Changed Since Monday**

- AR amounts collected this week
- Client status changes
- New issues that emerged
- Meetings completed

**C. Recommendation Status**
| Monday Recommendation | Status | Outcome |
|----------------------|--------|---------|
| Call Client A about $45K | ✅ Done | Payment plan agreed |
| Send reminder to Client B | 🔄 Pending | - |
| Review Client C contract | ⏳ Not started | - |

**D. Course Corrections**

- Adjusted priorities based on new information
- Items that can wait until next week
- Items that need escalation

**E. Team Comparison (Optional - for managers)**

- How this CSE compares to team average
- Best practices from high performers

**F. Encouragement Note**

- Personalised acknowledgment of effort
- Recognition of specific actions taken

---

### 3. Friday - "Week in Review"

**Subject line:** `🏆 Week in Review: [Headline Achievement]`

#### Sections:

**A. Wins & Accomplishments**

```
This Week's Highlights:
💰 AR Collected: $127,500
📞 Client Contacts: 12
📈 Health Scores Improved: 3 clients
⭐ NPS Responses: 2 promoters
```

**B. Goal Progress**
| Metric | Goal | Actual | Status |
|--------|------|--------|--------|
| AR Under 60 Days | 90% | 87% | 🟡 Close |
| Client Contacts | 10 | 12 | ✅ Exceeded |
| Meeting Notes | 100% | 100% | ✅ Met |

**C. Recommendations Actioned**

- Summary of Monday recommendations and outcomes
- Impact of actions taken
- Lessons learned

**D. Recognition & Kudos**

- Specific callouts for excellent work
- Client feedback received
- Team contributions acknowledged

**E. Coaching Corner**

- One skill/behaviour to focus on
- Resource or tip for improvement
- Success story from another CSE (anonymised)

**F. Next Week Preview**

- Major items coming up
- Key dates to remember
- Preparation suggestions

---

## Audience Segments & Customisation

### Individual CSEs

- Personalised to their portfolio
- Focus on actionable items
- Encouraging tone

### CSE Team Leads

- Aggregated team view
- Individual CSE highlights
- Escalations needing attention

### Regional Managers

- Regional summary
- Cross-CSE comparisons
- Strategic alignment updates

### Executive Leadership (Weekly/Monthly)

- High-level KPIs only
- Trend analysis
- Risk summary

---

## Data Sources Integration

| Data Point           | Source                      | Refresh Frequency |
| -------------------- | --------------------------- | ----------------- |
| AR Aging             | Invoice Tracker API         | Daily             |
| Client Health Scores | APAC Intelligence DB        | Real-time         |
| Meeting History      | Unified Meetings table      | Real-time         |
| NPS Scores           | NPS Responses table         | Daily             |
| Action Items         | Actions table               | Real-time         |
| Initiatives          | Portfolio Initiatives table | Real-time         |

---

## Technical Implementation

### Email Delivery

- **Provider:** SendGrid, Resend, or AWS SES
- **Scheduling:** Cron jobs or serverless functions
- **Templating:** React Email or MJML for responsive design

### Personalisation Engine

```typescript
interface CSEEmailContext {
  cseName: string
  portfolioClients: Client[]
  arMetrics: ARMetrics
  weeklyActions: Action[]
  completedActions: Action[]
  npsResponses: NPSResponse[]
  upcomingMeetings: Meeting[]
  healthScoreChanges: HealthChange[]
}
```

### Recommendation Engine

- Rule-based prioritisation
- AI-powered suggestions (via ChaSen/MatchaAI)
- Historical pattern recognition

---

## Sample Email Templates

### Monday Email Preview

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Sarah, Your Week Ahead: 4 Priority Actions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Good morning Sarah!

Here's what needs your focus this week:

📊 PORTFOLIO SNAPSHOT
━━━━━━━━━━━━━━━━━━━━
• Total Clients: 18
• Health Score: 7.2/10 (↑ 0.3 from last week)
• AR Outstanding: $342,500
• At-Risk (90+ days): $45,200

🔴 PRIORITY ACTIONS
━━━━━━━━━━━━━━━━━━━━

1. URGENT: Grampians Health - $45,200 at 95 days
   → Schedule call today to discuss payment plan
   → Contact: John Smith (CFO) - john@grampians.health

2. HIGH: Peninsula Health - Contract renewal in 28 days
   → Prepare renewal proposal
   → Review usage metrics for upsell opportunity

3. MEDIUM: Alfred Health - NPS detractor (score: 6)
   → Follow up on support ticket #4521
   → Sentiment has been declining - check in call needed

4. MONITOR: Austin Health - Payment plan active
   → Next payment due Thursday
   → Send friendly reminder Wednesday

💡 QUICK WIN
━━━━━━━━━━━━
Monash Health has been quiet but healthy. A quick
check-in call could generate a referral opportunity.

📅 YOUR WEEK
━━━━━━━━━━━━
• Tuesday 10am: QBR with Eastern Health
• Thursday 2pm: Onboarding call - New client

Have a great week!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Friday Email Preview

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🏆 Week in Review: $67,500 Collected!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Great work this week, Sarah!

🎉 YOUR WINS
━━━━━━━━━━━━
✅ Collected $67,500 in AR (32% above target!)
✅ Grampians Health agreed to payment plan
✅ Peninsula Health renewal confirmed (+15% uplift)
✅ 14 client touchpoints (vs 10 goal)

📈 METRICS MOVEMENT
━━━━━━━━━━━━━━━━━━━━
• AR Under 60 Days: 87% → 91% ✅
• Client Health Avg: 7.2 → 7.5 ↑
• At-Risk Amount: $45,200 → $12,800 ↓

📋 RECOMMENDATIONS ACTIONED
━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Grampians call - Payment plan $15K/month
✅ Peninsula renewal - Signed!
✅ Alfred Health follow-up - Issue resolved
⏳ Austin reminder - Sent, awaiting payment

🌟 RECOGNITION
━━━━━━━━━━━━━━
"Sarah's proactive approach with Grampians
turned a potential write-off into a structured
recovery. Great example of persistence paying off!"
- Team Lead feedback

💭 COACHING CORNER
━━━━━━━━━━━━━━━━━━
This week you excelled at AR recovery. Next week,
consider applying the same proactive approach to
your NPS detractors - early intervention prevents
churn.

📅 NEXT WEEK PREVIEW
━━━━━━━━━━━━━━━━━━━━
• 2 contracts up for renewal
• Austin Health payment due Monday
• QBR preparation needed for Monash

Enjoy your weekend! 🎉
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Implementation Phases

### Phase 1: Foundation (2-3 weeks)

- [ ] Email service integration (SendGrid/Resend)
- [ ] Basic template system
- [ ] Manual data aggregation
- [ ] Monday email only

### Phase 2: Automation (2-3 weeks)

- [ ] Automated data collection
- [ ] Wednesday and Friday emails
- [ ] Action tracking integration
- [ ] Basic personalisation

### Phase 3: Intelligence (3-4 weeks)

- [ ] AI-powered recommendations
- [ ] Predictive insights
- [ ] Automated coaching suggestions
- [ ] Team comparisons

### Phase 4: Optimisation (Ongoing)

- [ ] A/B testing subject lines
- [ ] Engagement analytics
- [ ] Feedback loop integration
- [ ] Content refinement

---

## Success Metrics

| Metric                 | Target               | Measurement     |
| ---------------------- | -------------------- | --------------- |
| Email Open Rate        | >70%                 | Email analytics |
| Action Completion Rate | >80%                 | System tracking |
| CSE Satisfaction       | >4.5/5               | Survey          |
| AR Improvement         | 10% reduction in 90+ | Dashboard       |
| Client Health          | 5% improvement       | Health scores   |

---

## Configuration Options

### User Preferences

- Preferred email time
- Summary detail level (brief/detailed)
- Notification channels (email/Slack/Teams)
- Opt-out of specific sections

### Manager Controls

- Enable/disable team comparisons
- Set custom goals per CSE
- Add manual kudos/coaching
- Override AI recommendations

---

## Next Steps

1. **Review and approve** email cadence and content structure
2. **Select email provider** (recommendation: Resend for developer experience)
3. **Design email templates** with brand styling
4. **Build data aggregation** APIs
5. **Implement recommendation engine**
6. **Pilot with 2-3 CSEs** before full rollout

---

_Document created: 2025-12-21_
_Status: Recommendation - Awaiting approval_
