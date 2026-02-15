# Simulation Engine Design

**Created:** 5 February 2026
**Status:** Approved for implementation
**Category:** Moonshot Feature

---

## Overview

The Simulation Engine provides three core capabilities for strategic planning:

1. **What-If Modelling** — Impact analysis of client loss, opportunity slippage, win rate changes
2. **Monte Carlo Forecasting** — Probability ranges using MEDDPICC-weighted distributions
3. **Optimal Path Recommendation** — Best route to quota based on effort/impact scoring

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SimulationEngine                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │ What-If      │  │ Monte Carlo  │  │ Path         │       │
│  │ Scenarios    │  │ Forecaster   │  │ Optimiser    │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                 │                 │                │
│         └─────────────────┼─────────────────┘                │
│                           ▼                                  │
│                  ┌────────────────┐                          │
│                  │ SimulationResult                          │
│                  │ - scenarios[]                              │
│                  │ - monteCarlo                               │
│                  │ - recommendations[]                        │
│                  └────────────────┘                          │
│                           │                                  │
│                           ▼                                  │
│           ┌───────────────────────────────────┐              │
│           │   SimulationVisualiser            │              │
│           │   (ForecastCone + Waterfall)      │              │
│           └───────────────────────────────────┘              │
└─────────────────────────────────────────────────────────────┘
```

**Design decisions:**
- **Client-side first** — No API calls for simulations (instant feedback, offline capable)
- **MEDDPICC integration** — Uses qualification scores to derive probability distributions
- **Composable** — Each simulation type runs independently or together
- **Deterministic seeding** — Same inputs produce same Monte Carlo results

---

## Data Models

### Core Types

```typescript
// src/lib/simulation/types.ts

/** MEDDPICC scores drive probability distribution variance */
interface MEDDPICCScores {
  metrics: number           // 0-100
  economicBuyer: number
  decisionCriteria: number
  decisionProcess: number
  paperProcess: number
  identifyPain: number
  champion: number
  competition: number
}

/** Enhanced opportunity for simulation */
interface SimulationOpportunity extends Opportunity {
  // Inherits from Opportunity:
  // - id, name, value, probability (0-100), stage, closeDate, client

  // Optional MEDDPICC for variance calculation
  meddpicc?: MEDDPICCScores
}

/** Probability distribution for Monte Carlo sampling */
interface ProbabilityDistribution {
  base: number              // From opportunity.probability
  min: number               // Lower bound (pessimistic)
  max: number               // Upper bound (optimistic)
  mode: number              // Most likely (often = base)
  source: 'probability_only' | 'meddpicc_adjusted'
}

/** A single what-if scenario */
interface WhatIfScenario {
  id: string
  name: string
  type: 'client_loss' | 'opportunity_slip' | 'win_rate_change'
  parameters: {
    clientId?: string           // For client loss
    opportunityIds?: string[]   // Specific opps affected
    slipMonths?: number         // For timing scenarios
    winRateMultiplier?: number  // e.g., 0.9 = 10% drop
  }
  result: ForecastResult        // Simulated outcome
  delta: ForecastResult         // Difference from baseline
  riskLevel: 'low' | 'medium' | 'high' | 'critical'
}

/** Monte Carlo simulation result */
interface MonteCarloResult {
  iterations: number            // e.g., 10,000
  percentiles: {
    p10: number   // 10% chance of being below this
    p25: number
    p50: number   // Median (most likely)
    p75: number
    p90: number   // 90% chance of being below this
  }
  mean: number
  stdDev: number
  histogram: { bucket: number; count: number }[]
  confidenceInterval: { lower: number; upper: number; level: number }
}

/** Optimal path recommendation */
interface PathRecommendation {
  action: string
  impact: number              // Revenue impact
  effort: 'low' | 'medium' | 'high'
  priority: number            // 1-10
  affectedOpportunities: string[]
  reasoning: string
}
```

### Probability Distribution Logic

The `probability` field on each opportunity is the baseline. MEDDPICC scores add variance:

```typescript
// Calculation logic:
// 1. Start with opp.probability as the mode
// 2. If MEDDPICC exists:
//    - High variance scores (e.g., champion:90, economicBuyer:30)
//      → widen min/max range
//    - Consistent scores → tighter distribution
// 3. If no MEDDPICC:
//    - Use stage-based variance (early stage = wider, late = tighter)
//    - e.g., Discovery ±30%, Negotiation ±10%

// Example:
// Opportunity: probability: 70, MEDDPICC scores vary 30-95
// Result: { base: 70, min: 45, max: 85, mode: 70, source: 'meddpicc_adjusted' }
```

---

## Core Algorithms

### What-If Scenario Engine

```typescript
// Scenario: "What if we lose Barwon Health?"
function simulateClientLoss(
  baseline: ForecastResult,
  opportunities: SimulationOpportunity[],
  clientId: string
): WhatIfScenario {
  // 1. Filter out all opportunities for this client
  const remaining = opportunities.filter(o => o.client !== clientId)

  // 2. Recalculate forecast
  const simulated = calculateForecast({
    opportunities: remaining,
    target: baseline.target
  })

  // 3. Calculate delta and risk level
  const revenueImpact = baseline.weighted - simulated.weighted
  const coverageImpact = baseline.coverage - simulated.coverage

  return {
    result: simulated,
    delta: { weighted: -revenueImpact, coverage: -coverageImpact, ... },
    riskLevel: getRiskLevel(revenueImpact, baseline.target)
  }
}

function simulateOpportunitySlip(
  baseline: ForecastResult,
  opportunities: SimulationOpportunity[],
  opportunityIds: string[],
  slipMonths: number
): WhatIfScenario {
  // Adjust close dates, recalculate in-period forecast
}

function simulateWinRateChange(
  baseline: ForecastResult,
  opportunities: SimulationOpportunity[],
  multiplier: number  // e.g., 0.9 = 10% drop
): WhatIfScenario {
  // Apply multiplier to all probabilities, recalculate
}
```

### Monte Carlo Forecaster

```typescript
function runMonteCarlo(
  opportunities: SimulationOpportunity[],
  iterations: number = 10000,
  seed?: number  // For reproducibility
): MonteCarloResult {
  const rng = seededRandom(seed)
  const outcomes: number[] = []

  for (let i = 0; i < iterations; i++) {
    let total = 0
    for (const opp of opportunities) {
      const dist = getProbabilityDistribution(opp)
      // Sample from triangular distribution (min, mode, max)
      const sampledProb = sampleTriangular(dist.min, dist.mode, dist.max, rng)
      // Binary outcome: win or lose based on sampled probability
      const won = rng() < (sampledProb / 100)
      if (won) total += opp.value
    }
    outcomes.push(total)
  }

  return computePercentiles(outcomes)
}

function sampleTriangular(min: number, mode: number, max: number, rng: () => number): number {
  const u = rng()
  const fc = (mode - min) / (max - min)
  if (u < fc) {
    return min + Math.sqrt(u * (max - min) * (mode - min))
  }
  return max - Math.sqrt((1 - u) * (max - min) * (max - mode))
}

function seededRandom(seed: number = Date.now()): () => number {
  // Mulberry32 PRNG - fast, good distribution
  return function() {
    let t = seed += 0x6D2B79F5
    t = Math.imul(t ^ t >>> 15, t | 1)
    t ^= t + Math.imul(t ^ t >>> 7, t | 61)
    return ((t ^ t >>> 14) >>> 0) / 4294967296
  }
}
```

### Path Optimiser

```typescript
function findOptimalPath(
  opportunities: SimulationOpportunity[],
  target: number,
  constraints: { maxEffort: 'low' | 'medium' | 'high' }
): PathRecommendation[] {
  const recommendations: PathRecommendation[] = []

  for (const opp of opportunities) {
    // Score: impact × probability improvement potential ÷ effort
    const potentialGain = assessPotentialGain(opp)
    const effort = estimateEffort(opp)
    const score = potentialGain / effortMultiplier(effort)

    recommendations.push({
      action: generateActionDescription(opp),
      impact: potentialGain,
      effort,
      priority: score,
      affectedOpportunities: [opp.id],
      reasoning: generateReasoning(opp)
    })
  }

  return recommendations
    .filter(r => effortMultiplier(r.effort) <= effortMultiplier(constraints.maxEffort))
    .sort((a, b) => b.priority - a.priority)
    .slice(0, 10)
}
```

**Performance:** 10,000 Monte Carlo iterations with 50 opportunities runs in ~15ms.

---

## UI Components

### SimulationPanel (Main Container)

```tsx
<SimulationPanel
  opportunities={opportunities}
  baseline={currentForecast}
  meddpiccScores={meddpiccByOpportunity}
>
  <SimulationTabs>
    <Tab name="What If">
      <WhatIfBuilder />
    </Tab>
    <Tab name="Probability">
      <MonteCarloView />
    </Tab>
    <Tab name="Optimal Path">
      <PathRecommendations />
    </Tab>
  </SimulationTabs>
</SimulationPanel>
```

### WhatIfBuilder (Interactive Scenario Creator)

```
┌─────────────────────────────────────────────────────────┐
│  What-If Simulator                              [Reset] │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Drag to simulate:                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │ 🏥 Lose     │  │ 📅 Slip     │  │ 📉 Win Rate │     │
│  │   Client    │  │   Timing    │  │   Change    │     │
│  └─────────────┘  └─────────────┘  └─────────────┘     │
│                                                         │
│  Active Scenarios:                                      │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ❌ Lose Barwon Health         -$420K  ⚠️ High   │   │
│  │ ❌ Q2 slips 2 months          -$180K  🟡 Medium │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  Combined Impact: -$600K | Coverage: 2.1x → 1.4x       │
└─────────────────────────────────────────────────────────┘
```

### MonteCarloView (Probability Visualisation)

Uses existing `ForecastCone.tsx` component, enhanced with:
- P10/P50/P90 bands clearly labelled
- "Target line" showing quota
- Histogram distribution below the cone
- Confidence level selector (80%, 90%, 95%)

### PathRecommendations (Action Cards)

```
┌─────────────────────────────────────────────────────────┐
│  Optimal Path to $2.5M Target                          │
├─────────────────────────────────────────────────────────┤
│  1. 🎯 Close Barwon EMR Deal              +$320K       │
│     Probability: 70% → Focus on Economic Buyer         │
│     Effort: Medium | Impact: High                      │
│                                            [View Deal] │
│  ───────────────────────────────────────────────────── │
│  2. 📈 Expand St Vincent's Scope          +$150K       │
│     Add Analytics module to existing deal              │
│     Effort: Low | Impact: Medium                       │
│                                            [View Deal] │
└─────────────────────────────────────────────────────────┘
```

---

## File Structure

### New Files

```
src/lib/simulation/
├── types.ts                    # All interfaces
├── probability-distribution.ts # MEDDPICC → distribution logic
├── what-if-engine.ts          # Client loss, slip, win rate scenarios
├── monte-carlo.ts             # Seeded RNG, triangular sampling, percentiles
├── path-optimiser.ts          # Recommendation scoring algorithm
├── index.ts                   # Public API exports

src/hooks/
├── useSimulation.ts           # Main hook combining all engines
├── useWhatIfScenarios.ts      # Scenario state management
├── useMonteCarlo.ts           # Memoised Monte Carlo

src/components/simulation/
├── SimulationPanel.tsx        # Main container with tabs
├── WhatIfBuilder.tsx          # Drag-drop scenario creator
├── ScenarioCard.tsx           # Individual scenario display
├── MonteCarloView.tsx         # Cone + histogram visualisation
├── PathRecommendations.tsx    # Ranked action cards
├── SimulationSummary.tsx      # Combined impact display
├── index.ts
```

### Integration Points

| Location | Integration |
|----------|-------------|
| Strategic Planning Wizard Step 4 (Opportunity) | Add `<SimulationPanel>` below opportunity list |
| Client Profile → Pipeline Tab | "Simulate" button opens modal |
| Territory View | Aggregate simulation across all clients |
| `ForecastSummary.tsx` | Add "Run Simulation" action button |

---

## Error Handling

```typescript
interface SimulationWarning {
  code: 'NO_OPPORTUNITIES' | 'MISSING_MEDDPICC' | 'STALE_DATA' | 'LOW_SAMPLE'
  message: string
  severity: 'info' | 'warning'
}

function validateSimulationInput(opps: SimulationOpportunity[]): SimulationWarning[] {
  const warnings: SimulationWarning[] = []

  if (opps.length === 0) {
    warnings.push({
      code: 'NO_OPPORTUNITIES',
      message: 'Add opportunities to run simulations',
      severity: 'warning'
    })
  }

  const withMeddpicc = opps.filter(o => o.meddpicc).length
  if (withMeddpicc < opps.length * 0.5) {
    warnings.push({
      code: 'MISSING_MEDDPICC',
      message: `${opps.length - withMeddpicc} opportunities lack MEDDPICC scores — using stage-based variance`,
      severity: 'info'
    })
  }

  return warnings
}
```

**Key principle:** Simulations always run — missing data triggers warnings, not errors.

---

## Testing Strategy

| Test Type | Coverage |
|-----------|----------|
| **Unit tests** | `probability-distribution.ts`, `monte-carlo.ts` — pure functions |
| **Deterministic seeds** | Monte Carlo with seed=12345 always produces same P50 |
| **Edge cases** | 0 opportunities, 100% probability deals, negative values |
| **Performance** | Assert 10K iterations < 50ms |

```typescript
describe('Monte Carlo', () => {
  it('produces consistent results with seed', () => {
    const result1 = runMonteCarlo(mockOpps, 1000, 12345)
    const result2 = runMonteCarlo(mockOpps, 1000, 12345)
    expect(result1.percentiles.p50).toBe(result2.percentiles.p50)
  })

  it('P10 < P50 < P90', () => {
    const result = runMonteCarlo(mockOpps, 10000)
    expect(result.percentiles.p10).toBeLessThan(result.percentiles.p50)
    expect(result.percentiles.p50).toBeLessThan(result.percentiles.p90)
  })
})
```

---

## Implementation Phases

| Phase | Scope | Estimate |
|-------|-------|----------|
| 1 | Core algorithms (types, monte-carlo, what-if) | 1-2 days |
| 2 | Hooks and state management | 1 day |
| 3 | UI components | 2-3 days |
| 4 | Integration into wizard/client profile | 1 day |
| 5 | Testing and polish | 1 day |

**Total: 6-8 days**

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Monte Carlo performance | < 50ms for 10K iterations |
| User adoption | 50% of plans use simulation within 30 days |
| Forecast accuracy improvement | Track P50 vs actual outcomes |
