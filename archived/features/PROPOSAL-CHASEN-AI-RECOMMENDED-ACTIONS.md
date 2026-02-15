# Proposal: ChaSen AI-Powered Recommended Actions

**Date:** 2025-12-03
**Priority:** High
**Effort:** Medium (2-3 days)
**Impact:** High - Contextual, intelligent recommendations vs. rule-based logic

---

## Current State vs. Proposed State

### Current: Rule-Based Recommendations

```typescript
// Hard-coded thresholds
if (client.health_score < 50) → Show "Critical health - Escalate"
if (client.nps_score < -50) → Show "Critical NPS - Schedule session"
if (daysSinceLastMeeting >= 90) → Show "No contact - Schedule check-in"
```

**Limitations**:

- ❌ No contextual awareness (doesn't consider WHY health is low)
- ❌ Generic actions (same recommendation for all clients at same threshold)
- ❌ No cross-client insights (can't identify patterns across portfolio)
- ❌ No prioritization based on business impact
- ❌ Static thresholds (doesn't adapt based on segment, history, trends)

### Proposed: ChaSen AI-Powered Recommendations

```typescript
// AI analyzes ALL client data + portfolio patterns
const recommendations = await generateAIRecommendations(client, portfolioContext)
```

**Benefits**:

- ✅ **Contextual**: Analyzes WHY metrics are low (NPS themes, meeting notes, action trends)
- ✅ **Personalized**: Different actions for healthcare vs. government vs. enterprise clients
- ✅ **Cross-Portfolio**: Identifies patterns (e.g., "3 clients in healthcare segment trending down")
- ✅ **Impact-Driven**: Prioritizes by revenue risk, churn probability, expansion opportunity
- ✅ **Adaptive**: Learns from successful interventions, adjusts thresholds by segment

---

## Architecture Proposal

### 1. New API Endpoint: `/api/chasen/recommend-actions`

**Purpose**: Generate AI-powered action recommendations for a specific client

**Input**:

```typescript
POST /api/chasen/recommend-actions

{
  clientName: "Albury Wodonga Health",
  includePortfolioContext: true,  // Compare to similar clients
  limit: 5,                        // Top N recommendations
  refreshCache: false              // Use cached recommendations if < 1 hour old
}
```

**Output**:

```typescript
{
  recommendations: [
    {
      id: "rec_001",
      severity: "critical" | "warning" | "info",
      category: "engagement" | "satisfaction" | "compliance" | "financial" | "initiative",
      title: "Schedule urgent feedback session",
      description: "NPS dropped 45 points in Q4. Analysis of feedback shows 3 detractors citing 'lack of communication'. Schedule 1:1s with key stakeholders.",
      reasoning: "ChaSen analyzed 12 NPS responses and identified communication as primary concern. Similar pattern observed in 2 other healthcare clients.",
      impactScore: 0.89,            // 0-1 scale: revenue risk, churn probability
      confidenceScore: 0.92,        // AI confidence in recommendation
      estimatedEffort: "2 hours",
      expectedOutcome: "Improve NPS by 15-20 points within 30 days",
      actions: [
        {
          type: "schedule_meeting",
          label: "Schedule feedback session",
          deepLink: "/meetings/calendar?action=schedule&client=Albury+Wodonga+Health"
        },
        {
          type: "create_action",
          label: "Create follow-up action",
          deepLink: "/actions?action=create&client=Albury+Wodonga+Health"
        }
      ],
      generatedAt: "2025-12-03T10:30:00Z",
      expiresAt: "2025-12-03T11:30:00Z"  // Cache for 1 hour
    },
    // ... more recommendations
  ],
  metadata: {
    clientContext: {
      segment: "Enterprise",
      healthScore: 67,
      npsScore: -8,
      revenueAtRisk: 450000,
      daysToRenewal: 127
    },
    portfolioInsights: {
      similarClients: 4,
      successfulInterventions: 2,
      averageImprovementTime: "45 days"
    },
    generationTime: "1.2s",
    cacheHit: false
  }
}
```

---

### 2. ChaSen Analysis Process

#### Step 1: Data Gathering (Client Context)

```typescript
const clientContext = {
  // Demographics
  name: client.name,
  segment: client.segment,
  industry: client.industry,
  revenue: client.annual_revenue,

  // Health Metrics
  healthScore: client.health_score,
  healthTrend: calculateHealthTrend(client, last90Days),
  npsScore: client.nps_score,
  npsTrend: calculateNPSTrend(client, last90Days),

  // Engagement
  lastMeetingDate: client.last_meeting_date,
  meetingFrequency: calculateMeetingFrequency(client, last90Days),
  openActions: getOpenActions(client),
  overdueActions: getOverdueActions(client),

  // Compliance
  eventCompliance: getEventCompliance(client, currentYear),
  complianceTrend: getComplianceTrend(client, last3Months),
  atRiskEvents: getAtRiskEvents(client),

  // Financial
  agingCompliance: getAgingCompliance(client),
  daysToRenewal: calculateDaysToRenewal(client),
  revenueAtRisk: calculateRevenueAtRisk(client),

  // Initiatives
  portfolioProgress: getPortfolioInitiatives(client),
  blockedInitiatives: getBlockedInitiatives(client),

  // Qualitative
  recentNPSThemes: getNPSThemes(client, last90Days),
  meetingNotes: getRecentMeetingNotes(client, last3Meetings),
  actionPatterns: analyzeActionPatterns(client),
}
```

#### Step 2: Portfolio Context (Optional but Powerful)

```typescript
const portfolioContext = {
  // Segment Benchmarks
  segmentAverage: {
    healthScore: getSegmentAverage(client.segment, 'health_score'),
    npsScore: getSegmentAverage(client.segment, 'nps_score'),
    engagementFrequency: getSegmentAverage(client.segment, 'meeting_frequency'),
  },

  // Similar Client Patterns
  similarClients: findSimilarClients(client, {
    criteria: ['segment', 'revenue', 'health_score_range'],
    limit: 5,
  }),

  // Success Stories
  successfulInterventions: getSuccessfulInterventions({
    segment: client.segment,
    similarIssues: clientContext.atRiskEvents,
    timeframe: 'last_6_months',
  }),

  // Portfolio-Wide Trends
  emergingRisks: identifyEmergingRisks(currentYear),
  topPerformers: getTopPerformers(client.segment),
}
```

#### Step 3: ChaSen Prompt Engineering

```typescript
const prompt = `You are ChaSen, an AI customer success intelligence assistant.

Analyze the following client and generate 3-5 prioritized action recommendations.

CLIENT CONTEXT:
${JSON.stringify(clientContext, null, 2)}

PORTFOLIO CONTEXT:
${JSON.stringify(portfolioContext, null, 2)}

INSTRUCTIONS:
1. Identify the top 3-5 actions that will have the highest impact on:
   - Preventing churn (if health/NPS declining)
   - Expanding revenue (if health/NPS strong)
   - Improving efficiency (if compliance/engagement gaps)

2. For each recommendation:
   - Explain WHY this action is recommended (root cause analysis)
   - Provide CONTEXT from client data (NPS themes, meeting notes, trends)
   - Suggest SPECIFIC next steps (not generic advice)
   - Estimate business IMPACT (revenue protection, NPS improvement, time saved)
   - Reference similar SUCCESS STORIES from portfolio context

3. Prioritize by:
   - Severity (critical > warning > info)
   - Impact Score (revenue at risk, churn probability, expansion opportunity)
   - Urgency (days to renewal, trend velocity)

4. Be specific and actionable. Instead of "Improve NPS", say:
   "Schedule 1:1 feedback sessions with 3 detractors (Dr. Smith, Nurse Manager Jones, IT Director Lee)
   who cited 'lack of communication' in recent surveys. Address specific concerns about product roadmap
   visibility and technical support response times."

OUTPUT FORMAT:
Return a JSON array of recommendations matching the RecommendationResponse schema.`
```

#### Step 4: AI Generation + Post-Processing

```typescript
const aiResponse = await callChaSenAPI(prompt)

// Post-process to ensure:
// 1. Valid JSON structure
// 2. All required fields present
// 3. Impact/confidence scores normalized (0-1)
// 4. Deep links correctly formatted
// 5. Cache metadata added

const recommendations = postProcessRecommendations(aiResponse, clientContext)

// Cache for 1 hour
await cacheRecommendations(client.name, recommendations, { ttl: 3600 })

return recommendations
```

---

## Integration with Existing Recommended Actions Card

### Hybrid Approach (Recommended for Phase 1)

**Combine rule-based + AI-powered recommendations**:

```typescript
// In RightColumn.tsx

const { recommendations: aiRecommendations, loading: aiLoading } = useChaSenRecommendations(
  client.name
)

// Build action items
const actionItems: ActionItem[] = []

// 1. CRITICAL RULE-BASED (Fast, Always Available)
if (client.health_score < 50) {
  actionItems.push({
    /* critical health */
  })
}

// 2. AI-POWERED RECOMMENDATIONS (Contextual, High-Value)
if (aiRecommendations && !aiLoading) {
  aiRecommendations.forEach(rec => {
    actionItems.push({
      icon: getIconForCategory(rec.category),
      text: rec.title,
      severity: rec.severity,
      color: getSeverityColor(rec.severity),
      bgColor: getSeverityBgColor(rec.severity),
      borderColor: getSeverityBorderColor(rec.severity),
      onClick: () => showRecommendationDetail(rec),
      meta: {
        description: rec.description,
        reasoning: rec.reasoning,
        impactScore: rec.impactScore,
        actions: rec.actions,
      },
    })
  })
}

// 3. FALLBACK RULE-BASED (If AI slow/failed)
if (!aiRecommendations && !aiLoading) {
  // Use existing 14 rule-based recommendations
}

// Sort by severity + impact score
actionItems.sort((a, b) => {
  if (a.severity !== b.severity) {
    return severityOrder[a.severity] - severityOrder[b.severity]
  }
  return (b.meta?.impactScore || 0) - (a.meta?.impactScore || 0)
})

// Limit to top 5
const topActions = actionItems.slice(0, 5)
```

---

## UI Enhancements

### 1. AI Badge

```tsx
<div className="flex items-center gap-2">
  <Sparkles className="h-4 w-4 text-purple-600" />
  <h4 className="text-sm font-semibold text-gray-900">Recommended Actions</h4>
  {aiRecommendations && (
    <span className="px-2 py-0.5 bg-purple-100 text-purple-700 text-xs font-medium rounded-full">
      AI-Powered
    </span>
  )}
</div>
```

### 2. Expandable Recommendation Details

```tsx
<button
  onClick={() => setExpandedRec(rec.id)}
  className="w-full px-3 py-2.5 flex items-start gap-3 rounded-lg border transition-all"
>
  <Icon className={`h-4 w-4 ${item.color} flex-shrink-0 mt-0.5`} />
  <div className="flex-1 text-left">
    <span className={`text-xs font-medium ${item.color}`}>{rec.title}</span>
    {expandedRec === rec.id && (
      <div className="mt-2 space-y-2">
        <p className="text-xs text-gray-600">{rec.description}</p>
        <div className="text-xs text-gray-500 italic">
          <strong>Why:</strong> {rec.reasoning}
        </div>
        <div className="flex items-center gap-2 text-xs">
          <span className="text-gray-600">Impact:</span>
          <div className="flex-1 bg-gray-200 rounded-full h-1.5">
            <div
              className="bg-purple-600 h-1.5 rounded-full"
              style={{ width: `${rec.impactScore * 100}%` }}
            />
          </div>
          <span className="text-gray-600">{Math.round(rec.impactScore * 100)}%</span>
        </div>
        <div className="flex gap-2 mt-2">
          {rec.actions.map(action => (
            <Link
              key={action.type}
              href={action.deepLink}
              className="px-2 py-1 bg-purple-600 text-white text-xs rounded hover:bg-purple-700"
            >
              {action.label}
            </Link>
          ))}
        </div>
      </div>
    )}
  </div>
  <ChevronDown
    className={`h-3 w-3 text-gray-400 transition-transform ${
      expandedRec === rec.id ? 'rotate-180' : ''
    }`}
  />
</button>
```

---

## Implementation Plan

### Phase 1: Foundation (Week 1)

- [ ] Create `/api/chasen/recommend-actions` endpoint
- [ ] Implement data gathering functions (client + portfolio context)
- [ ] Design ChaSen prompt template for recommendations
- [ ] Test AI output quality with 5-10 sample clients
- [ ] Implement caching layer (1-hour TTL)

### Phase 2: Integration (Week 2)

- [ ] Create `useChaSenRecommendations()` hook
- [ ] Integrate with existing Recommended Actions card (hybrid approach)
- [ ] Add AI badge and expandable details UI
- [ ] Implement error handling & fallbacks
- [ ] Add loading states & skeleton UI

### Phase 3: Refinement (Week 3)

- [ ] A/B test AI vs. rule-based recommendations
- [ ] Collect CSE feedback on recommendation quality
- [ ] Fine-tune prompts based on feedback
- [ ] Add "Dismiss" and "Snooze" functionality
- [ ] Track recommendation completion rates

### Phase 4: Scale (Week 4)

- [ ] Portfolio-wide recommendations API
- [ ] Manager dashboard showing all CSE recommendations
- [ ] Recommendation effectiveness tracking
- [ ] Success story database (feed back into prompts)
- [ ] Automated weekly "Top 10 Actions" report per CSE

---

## Success Metrics

### Quality Metrics

- **Recommendation Accuracy**: CSEs rate recommendations as "relevant" (target: >80%)
- **Action Completion Rate**: % of AI recommendations that get acted upon (target: >60%)
- **Client Outcome Correlation**: Health score improvement after AI-recommended actions (target: +10 pts avg)

### Performance Metrics

- **API Response Time**: < 2 seconds for recommendation generation
- **Cache Hit Rate**: > 70% (reduces API calls, costs)
- **Cost per Recommendation**: Track Claude API token usage

### Business Impact Metrics

- **Churn Prevention**: Clients where AI flagged critical risk and CSE intervened
- **Revenue Protection**: $ value of at-risk revenue where actions prevented churn
- **Time Savings**: Hours saved vs. manual portfolio review
- **NPS Recovery**: Avg NPS improvement after satisfaction-focused recommendations

---

## Estimated Costs

### Development

- **API Endpoint**: 4 hours
- **Data Gathering Logic**: 6 hours
- **Prompt Engineering**: 4 hours
- **Hook & Integration**: 4 hours
- **UI Enhancements**: 4 hours
- **Testing & Refinement**: 6 hours
  **Total**: ~28 hours (3.5 days)

### Operational (Monthly)

- **Claude API Costs**: ~$50-150/month (assuming 200 clients, 5 recommendations each, refreshed daily)
- **Caching**: Minimal (Redis/Vercel KV)

---

## Risk Mitigation

### Risk 1: AI Hallucinations

**Mitigation**:

- Always combine with rule-based critical checks
- Confidence score threshold (only show if >0.7)
- CSE can flag "unhelpful" recommendations → improve prompts

### Risk 2: API Latency

**Mitigation**:

- 1-hour cache (recommendations don't change frequently)
- Background refresh (generate new recs every hour, serve from cache)
- Skeleton UI with "Generating recommendations..." message

### Risk 3: Cost Escalation

**Mitigation**:

- Cache aggressively
- Rate limiting per client (max 1 refresh/hour)
- Monitor token usage, alert if >$200/month

---

## Future Enhancements (Phase 2)

### 1. Portfolio-Wide Insights

"You have 3 healthcare clients trending down. Common theme: Product roadmap uncertainty. Schedule portfolio-wide webinar."

### 2. Proactive Alerts

"ChaSen predicts 68% churn risk for Albury Wodonga Health based on declining engagement + low NPS. Escalate now."

### 3. Success Story Database

Track when CSEs complete AI recommendations → measure outcomes → feed back into prompts
"Similar action taken for Royal Melbourne Hospital resulted in +25 NPS improvement in 30 days."

### 4. Natural Language Interface

CSE: "What should I focus on this week?"
ChaSen: "Top 3 priorities: 1) Schedule feedback session with Western Health (NPS -45)..."

---

## Recommendation

**Approve for Phase 1 implementation** with hybrid rule-based + AI approach.

This provides:

- ✅ Immediate value (contextual, high-quality recommendations)
- ✅ Low risk (rule-based fallback always available)
- ✅ Measurable impact (track completion rates, client outcomes)
- ✅ Scalable foundation (can expand to portfolio-wide, proactive alerts)

---

**Next Steps**:

1. Approve proposal → Begin Phase 1 development
2. Select 5-10 pilot clients for testing
3. Design success metrics dashboard
4. Schedule weekly check-ins to review recommendation quality

**Questions? Feedback?**

---

**Created By**: Claude Code
**Date**: 2025-12-03
**Status**: Awaiting Approval
