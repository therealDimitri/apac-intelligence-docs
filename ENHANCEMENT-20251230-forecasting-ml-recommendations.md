# Enhancement: Forecasting & ML Model Improvements

**Date:** 30 December 2025
**Type:** Technical Review & Recommendations
**Status:** Analysis Complete

---

## Executive Summary

This document provides a comprehensive review of all forecasting, prediction, and ML functions across the APAC Intelligence dashboard. It identifies critical issues, explains why R-squared values are low for CSI ratios, and recommends cutting-edge improvements based on best practices from leading data analytics companies (Uber, Stripe, Netflix).

---

## 1. Critical Bugs Found

### 1.1 Variance Calculation Bug (CRITICAL)

**File:** `src/lib/emails/trend-analysis.ts:119`

```typescript
// CURRENT (BUG):
const variance = changes.reduce((acc, change) => acc + Math.pow(change - avgChange, 0), 0) / changes.length

// CORRECT:
const variance = changes.reduce((acc, change) => acc + Math.pow(change - avgChange, 2), 0) / changes.length
```

**Impact:** `Math.pow(x, 0)` always returns 1, making variance calculation completely wrong. This breaks:
- Volatility detection in email reports
- Direction classification (volatile vs stable)
- Trend confidence assessments

**Priority:** P0 - Fix immediately

---

## 2. Why CSI R-squared Values Are Low

### 2.1 Root Causes Identified

Based on analysis of `src/lib/csi-analytics.ts` and industry research:

| Cause | Explanation | Solution |
|-------|-------------|----------|
| **Low signal-to-noise ratio** | Financial/operational ratios are inherently noisy with many external factors | Use ensemble methods, add exogenous variables |
| **Non-stationarity** | Ratios change behaviour over time (structural breaks) | Apply differencing, use adaptive models |
| **Limited data points** | Only 48 months of historical data | Use Bayesian approaches, transfer learning |
| **Simple linear model** | Linear regression assumes constant linear relationship | Upgrade to Prophet, ARIMA, or hybrid models |
| **No feature engineering** | Using raw ratios without derived features | Add lag features, rolling statistics, momentum |

### 2.2 Expected R-squared for Financial Data

According to [research on financial time series](https://jfin-swufe.springeropen.com/articles/10.1186/s40854-024-00617-3):

> "Financial time series forecasting presents a notoriously formidable challenge. Such series are characterised by low signal-to-noise ratios, non-stationarity, nonlinearity and frequent structural breaks."

**Key insight:** R-squared is **not the right metric** for time series forecasting. Industry best practice recommends:
- **MAE** (Mean Absolute Error) for interpretability
- **RMSE** (Root Mean Square Error) for penalising large errors
- **MAPE** (Mean Absolute Percentage Error) for business context
- **Out-of-sample validation** rather than in-sample R²

---

## 3. Current Implementation Analysis

### 3.1 Models Currently Used

| Component | Model | Limitations |
|-----------|-------|-------------|
| CSI Trend Analysis | Linear Regression | Cannot capture nonlinear patterns, seasonality |
| Forecasting | Simple Linear Extrapolation | No uncertainty quantification, breaks on regime changes |
| Anomaly Detection | Z-score | Assumes normal distribution, misses subtle anomalies |
| Seasonality | Monthly Averaging | Requires 24+ months, no statistical significance test |
| Compliance Predictions | Rate-based Linear Projection | Ignores historical completion patterns |
| Health Predictions | LLM-based (Claude) | Good for insights, but no quantitative confidence |

### 3.2 Strengths of Current Implementation

- Clean, well-documented code
- Good use of simple-statistics and regression libraries
- Appropriate confidence level classifications
- Proper handling of edge cases (insufficient data)
- Seasonal decomposition attempt

### 3.3 Gaps Identified

1. **No cross-validation** - Models aren't validated on held-out data
2. **No prediction intervals** - Point forecasts without uncertainty
3. **No model selection** - Always uses linear regression
4. **No feature engineering** - Missing lag features, momentum indicators
5. **No ensemble methods** - Single model approach
6. **Wrong evaluation metric** - Over-reliance on R-squared

---

## 4. Recommended Improvements

### 4.1 Quick Wins (1-2 weeks)

#### 4.1.1 Fix Variance Bug
```typescript
// src/lib/emails/trend-analysis.ts:119
const variance = changes.reduce((acc, change) =>
  acc + Math.pow(change - avgChange, 2), 0) / changes.length
```

#### 4.1.2 Add Prediction Intervals
Based on [Uber's forecasting best practices](https://eng.uber.com/forecasting-introduction/):

> "Prediction intervals are just as important as the point forecast itself and should always be included in forecasts."

```typescript
interface ForecastWithInterval {
  point: number
  lower95: number
  upper95: number
  lower80: number
  upper80: number
}

function calculatePredictionInterval(
  prediction: number,
  residualStdDev: number,
  horizon: number
): ForecastWithInterval {
  // Wider intervals for further horizons
  const multiplier = 1 + (horizon * 0.1)
  return {
    point: prediction,
    lower95: prediction - 1.96 * residualStdDev * multiplier,
    upper95: prediction + 1.96 * residualStdDev * multiplier,
    lower80: prediction - 1.28 * residualStdDev * multiplier,
    upper80: prediction + 1.28 * residualStdDev * multiplier,
  }
}
```

#### 4.1.3 Replace R-squared with MAE/RMSE

```typescript
function calculateForecastAccuracy(actuals: number[], predictions: number[]) {
  const errors = actuals.map((a, i) => a - predictions[i])

  const mae = ss.mean(errors.map(Math.abs))
  const rmse = Math.sqrt(ss.mean(errors.map(e => e * e)))
  const mape = ss.mean(errors.map((e, i) =>
    Math.abs(e / actuals[i]) * 100
  ))

  return { mae, rmse, mape }
}
```

#### 4.1.4 Add Lag Features for Better Predictions

```typescript
function createLagFeatures(data: number[], lags: number[] = [1, 3, 6, 12]) {
  return data.map((value, index) => ({
    value,
    ...Object.fromEntries(
      lags.map(lag => [`lag_${lag}`, index >= lag ? data[index - lag] : null])
    ),
    momentum_3m: index >= 3 ? value - data[index - 3] : null,
    momentum_12m: index >= 12 ? value - data[index - 12] : null,
    rolling_avg_3m: index >= 2 ? ss.mean(data.slice(index - 2, index + 1)) : null,
    rolling_std_3m: index >= 2 ? ss.standardDeviation(data.slice(index - 2, index + 1)) : null,
  }))
}
```

### 4.2 Medium-Term Improvements (1-2 months)

#### 4.2.1 Implement Prophet for Time Series

[Prophet](https://facebook.github.io/prophet/) is Meta's additive forecasting model, ideal for business metrics:

```typescript
// Using prophet-ts (TypeScript wrapper)
import { Prophet } from 'prophet-ts'

async function forecastWithProphet(
  data: { ds: Date; y: number }[],
  periodsAhead: number
) {
  const model = new Prophet({
    yearly_seasonality: true,
    weekly_seasonality: false, // Monthly data
    daily_seasonality: false,
    changepoint_prior_scale: 0.05, // Conservative trend changes
  })

  await model.fit(data)
  const future = model.make_future_dataframe({ periods: periodsAhead })
  const forecast = await model.predict(future)

  return forecast.map(row => ({
    date: row.ds,
    prediction: row.yhat,
    lower: row.yhat_lower,
    upper: row.yhat_upper,
  }))
}
```

**Benefits:**
- Handles seasonality automatically
- Provides uncertainty intervals
- Robust to missing data
- Interpretable components (trend, seasonality)

#### 4.2.2 Implement Cross-Validation

```typescript
function timeSeriesCrossValidation(
  data: number[],
  modelFn: (train: number[]) => (x: number) => number,
  initialWindow: number = 24,
  horizon: number = 6,
  step: number = 3
) {
  const results: { predicted: number; actual: number; fold: number }[] = []

  for (let i = initialWindow; i <= data.length - horizon; i += step) {
    const train = data.slice(0, i)
    const test = data.slice(i, i + horizon)
    const model = modelFn(train)

    test.forEach((actual, j) => {
      results.push({
        predicted: model(i + j),
        actual,
        fold: Math.floor((i - initialWindow) / step),
      })
    })
  }

  return {
    results,
    mae: ss.mean(results.map(r => Math.abs(r.predicted - r.actual))),
    rmse: Math.sqrt(ss.mean(results.map(r => Math.pow(r.predicted - r.actual, 2)))),
  }
}
```

#### 4.2.3 Implement Ensemble Forecasting

Following [research showing model combinations improve accuracy](https://arxiv.org/html/2507.07296v1):

```typescript
interface EnsembleForecast {
  linear: number
  movingAverage: number
  exponentialSmoothing: number
  ensemble: number // Weighted average
  weights: { linear: number; ma: number; exp: number }
}

function ensembleForecast(data: number[]): EnsembleForecast {
  const linearPred = linearRegressionForecast(data)
  const maPred = movingAverageForecast(data, 3)
  const expPred = exponentialSmoothingForecast(data, 0.3)

  // Adaptive weights based on recent performance
  const weights = calculateAdaptiveWeights(data, [linearPred, maPred, expPred])

  return {
    linear: linearPred,
    movingAverage: maPred,
    exponentialSmoothing: expPred,
    ensemble: weights.linear * linearPred + weights.ma * maPred + weights.exp * expPred,
    weights,
  }
}
```

#### 4.2.4 Improve Anomaly Detection with Isolation Forest

Replace Z-score with Isolation Forest for better anomaly detection:

```typescript
// Using isolation-forest npm package
import IsolationForest from 'isolation-forest'

function detectAnomaliesML(data: number[]): AnomalyResult[] {
  // Create features from raw data
  const features = data.map((value, i) => [
    value,
    i > 0 ? value - data[i - 1] : 0, // Change
    i > 2 ? ss.mean(data.slice(i - 2, i + 1)) : value, // MA3
  ])

  const forest = new IsolationForest({
    numberOfTrees: 100,
    sampleSize: Math.min(256, data.length),
  })

  forest.fit(features)
  const scores = forest.scores()

  return data
    .map((value, i) => ({ index: i, value, score: scores[i] }))
    .filter(item => item.score > 0.6) // Anomaly threshold
    .map(item => ({
      period: `Period ${item.index}`,
      value: item.value,
      zScore: item.score * 3, // Approximate conversion
      type: item.value > ss.mean(data) ? 'spike' : 'drop',
      severity: item.score > 0.8 ? 'critical' : item.score > 0.7 ? 'warning' : 'info',
    }))
}
```

### 4.3 Long-Term Improvements (3-6 months)

#### 4.3.1 Implement LSTM for Complex Patterns

Based on [research comparing forecasting models](https://neptune.ai/blog/arima-vs-prophet-vs-lstm):

> "LSTM achieved the highest accuracy for complex, long-term patterns... with an average of 87.445% reduction in error rates compared to Rolling ARIMA."

```typescript
// Using TensorFlow.js
import * as tf from '@tensorflow/tfjs-node'

async function createLSTMModel(sequenceLength: number, features: number) {
  const model = tf.sequential({
    layers: [
      tf.layers.lstm({
        units: 64,
        returnSequences: true,
        inputShape: [sequenceLength, features],
      }),
      tf.layers.dropout({ rate: 0.2 }),
      tf.layers.lstm({ units: 32, returnSequences: false }),
      tf.layers.dropout({ rate: 0.2 }),
      tf.layers.dense({ units: 16, activation: 'relu' }),
      tf.layers.dense({ units: 1 }),
    ],
  })

  model.compile({
    optimizer: tf.train.adam(0.001),
    loss: 'meanSquaredError',
    metrics: ['mae'],
  })

  return model
}
```

#### 4.3.2 Implement Transformer-Based Forecasting

According to [comparative research](https://www.researchgate.net/publication/398447751):

> "The Transformer model delivered the best forecasting results, recording an RMSE of 0.042 and a Forecast Accuracy of 97.8%."

Consider using [Chronos](https://github.com/amazon-science/chronos-forecasting) or [TimeGPT](https://nixtla.github.io/nixtla/) for state-of-the-art results.

#### 4.3.3 Implement Uber-Style Financial Forecasting

Based on [Uber's engineering blog](https://eng.uber.com/transforming-financial-forecasting-machine-learning/):

1. **Hierarchical forecasting** - Aggregate and disaggregate predictions
2. **External regressors** - Include market indicators, macroeconomic data
3. **Scenario modelling** - Multiple what-if scenarios with probabilities
4. **Continuous refinement** - Feedback loops comparing forecasts to actuals

---

## 5. Recommended Architecture

### 5.1 Forecasting Service Design

```
┌─────────────────────────────────────────────────────────────────┐
│                     Forecasting Service                          │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Prophet    │  │    ARIMA     │  │   LSTM       │          │
│  │   (Seasonal) │  │  (Short-term)│  │  (Complex)   │          │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘          │
│         │                  │                  │                  │
│         └─────────────┬────┴─────────────────┘                  │
│                       ▼                                          │
│              ┌─────────────────┐                                 │
│              │ Model Selector  │ ← Cross-validation scores       │
│              │ (Auto ML)       │                                 │
│              └────────┬────────┘                                 │
│                       ▼                                          │
│              ┌─────────────────┐                                 │
│              │ Ensemble Combiner│ ← Adaptive weights             │
│              └────────┬────────┘                                 │
│                       ▼                                          │
│              ┌─────────────────┐                                 │
│              │ Prediction      │ → Point + Intervals             │
│              │ Intervals       │                                 │
│              └─────────────────┘                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 5.2 Recommended Libraries

| Purpose | Library | Notes |
|---------|---------|-------|
| Statistical Models | simple-statistics | Already using ✓ |
| Linear Regression | regression | Already using ✓ |
| Prophet | prophet-ts | TypeScript wrapper for Prophet |
| ARIMA | arima | Pure JavaScript ARIMA |
| Deep Learning | @tensorflow/tfjs-node | LSTM, Transformer models |
| Anomaly Detection | isolation-forest | Better than Z-score |
| Feature Engineering | danfojs | DataFrame operations |
| Cross-Validation | ml-cross-validation | Time series CV |

---

## 6. Implementation Priority

### Phase 1: Critical Fixes (This Week)
- [ ] Fix variance calculation bug in trend-analysis.ts
- [ ] Add MAE/RMSE metrics alongside R-squared
- [ ] Add prediction intervals to all forecasts

### Phase 2: Quick Improvements (Next 2 Weeks)
- [ ] Add lag features and momentum indicators
- [ ] Implement time series cross-validation
- [ ] Add exponential smoothing as alternative model

### Phase 3: Model Upgrades (Month 1-2)
- [ ] Integrate Prophet for seasonal forecasting
- [ ] Implement ensemble forecasting
- [ ] Replace Z-score anomaly detection with Isolation Forest

### Phase 4: Advanced ML (Month 3-6)
- [ ] Build LSTM models for complex patterns
- [ ] Explore Transformer-based forecasting
- [ ] Implement Uber-style hierarchical forecasting

---

## 7. Success Metrics

| Metric | Current | Target | Measurement |
|--------|---------|--------|-------------|
| Forecast MAE | Unknown | <10% | Cross-validation |
| Prediction interval coverage | 0% | 95% | Actual values within intervals |
| Anomaly detection precision | ~60% | >85% | Manual validation |
| Model confidence reliability | Low | High | Calibration plots |
| Processing time | Fast | <2s | API response time |

---

## 8. Sources

- [ARIMA vs Prophet vs LSTM for Time Series Prediction](https://neptune.ai/blog/arima-vs-prophet-vs-lstm)
- [Uber: Transforming Financial Forecasting with ML](https://eng.uber.com/transforming-financial-forecasting-machine-learning/)
- [Uber: Forecasting Introduction](https://eng.uber.com/forecasting-introduction/)
- [Feature Selection for Financial Time Series](https://jfin-swufe.springeropen.com/articles/10.1186/s40854-024-00617-3)
- [Time Series Foundation Models for Financial Forecasting](https://arxiv.org/html/2507.07296v1)
- [Forecasting: Principles and Practice](https://otexts.com/fpp3/)
- [Comparative Study: ARIMA, LSTM, Transformers](https://www.researchgate.net/publication/398447751)

---

## Appendix: Code Snippets Ready for Implementation

### A1. Fixed Variance Calculation

```typescript
// src/lib/emails/trend-analysis.ts
const variance = changes.reduce((acc, change) =>
  acc + Math.pow(change - avgChange, 2), 0) / changes.length
```

### A2. Comprehensive Forecast Metrics

```typescript
export interface ForecastMetrics {
  // Traditional
  r2: number

  // Recommended
  mae: number
  rmse: number
  mape: number

  // Advanced
  smape: number // Symmetric MAPE
  mase: number  // Mean Absolute Scaled Error

  // Calibration
  coverage80: number // % of actuals within 80% interval
  coverage95: number // % of actuals within 95% interval
}
```

### A3. Adaptive Model Selection

```typescript
function selectBestModel(
  data: number[],
  models: ModelFunction[],
  validationRatio: number = 0.2
): { bestModel: ModelFunction; scores: number[] } {
  const splitPoint = Math.floor(data.length * (1 - validationRatio))
  const train = data.slice(0, splitPoint)
  const test = data.slice(splitPoint)

  const scores = models.map(model => {
    const predictions = model.fit(train).predict(test.length)
    return calculateRMSE(test, predictions)
  })

  const bestIndex = scores.indexOf(Math.min(...scores))
  return { bestModel: models[bestIndex], scores }
}
```
