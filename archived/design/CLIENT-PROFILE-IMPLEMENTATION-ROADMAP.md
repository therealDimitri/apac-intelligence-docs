# Client Profile Redesign - Implementation Roadmap

> **Purpose**: Step-by-step implementation guide with specific code changes
> **Created**: 4 January 2026
> **Estimated Effort**: 6 phases across development sprints

---

## Overview

This roadmap breaks down the Client Profile redesign into 6 phases, ordered by impact and dependency. Each phase includes specific files to modify, code snippets, and acceptance criteria.

---

## Phase 1: Design Tokens & Foundation

**Priority**: Critical (Required for all other phases)
**Effort**: 1-2 days

### 1.1 Create Design Tokens File

**File**: `src/lib/design-tokens.ts`

```typescript
// Design tokens for Client Profile redesign
export const tokens = {
  colors: {
    brand: {
      purple50: '#F5F3FF',
      purple100: '#EDE9FE',
      purple500: '#8B5CF6',
      purple600: '#7C3AED',
      purple700: '#6D28D9',
    },
    semantic: {
      success50: '#ECFDF5',
      success500: '#10B981',
      success600: '#059669',
      warning50: '#FFFBEB',
      warning500: '#F59E0B',
      warning600: '#D97706',
      danger50: '#FEF2F2',
      danger500: '#EF4444',
      danger600: '#DC2626',
    },
    neutral: {
      50: '#F9FAFB',
      100: '#F3F4F6',
      200: '#E5E7EB',
      300: '#D1D5DB',
      400: '#9CA3AF',
      500: '#6B7280',
      600: '#4B5563',
      700: '#374151',
      800: '#1F2937',
      900: '#111827',
    },
  },
  typography: {
    display: { size: '36px', weight: 700, lineHeight: '40px', letterSpacing: '-0.02em' },
    h1: { size: '28px', weight: 700, lineHeight: '34px', letterSpacing: '-0.02em' },
    h2: { size: '20px', weight: 600, lineHeight: '28px', letterSpacing: '-0.01em' },
    h3: { size: '16px', weight: 600, lineHeight: '24px', letterSpacing: '0' },
    body: { size: '15px', weight: 400, lineHeight: '24px', letterSpacing: '0' },
    bodySm: { size: '14px', weight: 400, lineHeight: '20px', letterSpacing: '0' },
    caption: { size: '12px', weight: 500, lineHeight: '16px', letterSpacing: '0.02em' },
    metricLg: { size: '48px', weight: 700, lineHeight: '52px', letterSpacing: '-0.02em' },
    metricMd: { size: '32px', weight: 700, lineHeight: '36px', letterSpacing: '-0.02em' },
    metricSm: { size: '24px', weight: 600, lineHeight: '28px', letterSpacing: '-0.01em' },
  },
  spacing: {
    1: '4px',
    2: '8px',
    3: '12px',
    4: '16px',
    5: '20px',
    6: '24px',
    8: '32px',
    10: '40px',
    12: '48px',
    16: '64px',
  },
  radius: {
    sm: '4px',
    md: '8px',
    lg: '12px',
    xl: '16px',
    '2xl': '24px',
    full: '9999px',
  },
  shadows: {
    xs: '0 1px 2px rgba(0,0,0,0.05)',
    sm: '0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06)',
    md: '0 4px 6px -1px rgba(0,0,0,0.1), 0 2px 4px -1px rgba(0,0,0,0.06)',
    lg: '0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05)',
    xl: '0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04)',
    hover: '0 8px 16px -4px rgba(124,58,237,0.15)',
    glowSuccess: '0 0 20px rgba(16,185,129,0.3)',
    glowWarning: '0 0 20px rgba(245,158,11,0.3)',
    glowDanger: '0 0 20px rgba(239,68,68,0.3)',
  },
  animation: {
    fast: '100ms',
    normal: '200ms',
    slow: '300ms',
    slower: '500ms',
    easeOut: 'cubic-bezier(0, 0, 0.2, 1)',
    easeInOut: 'cubic-bezier(0.4, 0, 0.2, 1)',
    spring: 'cubic-bezier(0.175, 0.885, 0.32, 1.275)',
  },
} as const

// Health status helpers
export function getHealthColor(score: number) {
  if (score >= 70) return { bg: tokens.colors.semantic.success50, text: tokens.colors.semantic.success600, glow: tokens.shadows.glowSuccess }
  if (score >= 50) return { bg: tokens.colors.semantic.warning50, text: tokens.colors.semantic.warning600, glow: tokens.shadows.glowWarning }
  return { bg: tokens.colors.semantic.danger50, text: tokens.colors.semantic.danger600, glow: tokens.shadows.glowDanger }
}

export function getHealthGradient(score: number) {
  if (score >= 70) return 'linear-gradient(135deg, #10B981, #059669)'
  if (score >= 50) return 'linear-gradient(135deg, #F59E0B, #D97706)'
  return 'linear-gradient(135deg, #EF4444, #DC2626)'
}
```

### 1.2 Add Tailwind Config Extensions

**File**: `tailwind.config.ts` (extend existing)

```typescript
// Add to theme.extend
extend: {
  colors: {
    brand: {
      purple: {
        50: '#F5F3FF',
        100: '#EDE9FE',
        500: '#8B5CF6',
        600: '#7C3AED',
        700: '#6D28D9',
      },
    },
  },
  boxShadow: {
    'hover': '0 8px 16px -4px rgba(124,58,237,0.15)',
    'glow-success': '0 0 20px rgba(16,185,129,0.3)',
    'glow-warning': '0 0 20px rgba(245,158,11,0.3)',
    'glow-danger': '0 0 20px rgba(239,68,68,0.3)',
  },
  animation: {
    'gauge-fill': 'gauge-fill 1s cubic-bezier(0, 0, 0.2, 1) forwards',
    'skeleton-pulse': 'skeleton-pulse 1.5s ease-in-out infinite',
    'fade-up': 'fade-up 0.3s ease-out forwards',
  },
  keyframes: {
    'gauge-fill': {
      'from': { strokeDashoffset: '440' },
      'to': { strokeDashoffset: 'var(--gauge-offset)' },
    },
    'skeleton-pulse': {
      '0%, 100%': { opacity: '0.5' },
      '50%': { opacity: '1' },
    },
    'fade-up': {
      'from': { opacity: '0', transform: 'translateY(20px)' },
      'to': { opacity: '1', transform: 'translateY(0)' },
    },
  },
}
```

### Acceptance Criteria
- [ ] Design tokens file created and exported
- [ ] Tailwind config extended with new values
- [ ] Build succeeds without errors
- [ ] Existing styles remain unchanged

---

## Phase 2: Health Score Radial Gauge

**Priority**: High (Hero component, high visual impact)
**Effort**: 2-3 days
**Dependencies**: Phase 1

### 2.1 Create HealthGauge Component

**File**: `src/components/charts/HealthGauge.tsx`

```typescript
'use client'

import React, { useEffect, useState } from 'react'
import { getHealthColor, getHealthGradient } from '@/lib/design-tokens'
import { TrendingUp, TrendingDown, Minus } from 'lucide-react'

interface HealthGaugeProps {
  score: number
  maxScore?: number
  trend?: number // positive = improving, negative = declining
  size?: 'sm' | 'md' | 'lg'
  showTrend?: boolean
  animated?: boolean
  className?: string
}

const sizeConfig = {
  sm: { diameter: 100, stroke: 8, fontSize: 24, subFontSize: 10 },
  md: { diameter: 140, stroke: 12, fontSize: 48, subFontSize: 14 },
  lg: { diameter: 180, stroke: 16, fontSize: 56, subFontSize: 16 },
}

export default function HealthGauge({
  score,
  maxScore = 100,
  trend,
  size = 'md',
  showTrend = true,
  animated = true,
  className = '',
}: HealthGaugeProps) {
  const [animatedScore, setAnimatedScore] = useState(animated ? 0 : score)
  const config = sizeConfig[size]
  const { text: textColor, glow } = getHealthColor(score)
  const gradient = getHealthGradient(score)

  // SVG calculations
  const radius = (config.diameter - config.stroke) / 2
  const circumference = 2 * Math.PI * radius
  const progress = (animatedScore / maxScore) * 100
  const offset = circumference - (progress / 100) * circumference

  // Animate on mount
  useEffect(() => {
    if (!animated) return

    const duration = 1000
    const startTime = Date.now()

    const animate = () => {
      const elapsed = Date.now() - startTime
      const progress = Math.min(elapsed / duration, 1)
      // Ease out cubic
      const eased = 1 - Math.pow(1 - progress, 3)
      setAnimatedScore(Math.round(score * eased))

      if (progress < 1) {
        requestAnimationFrame(animate)
      }
    }

    requestAnimationFrame(animate)
  }, [score, animated])

  // Generate unique gradient ID
  const gradientId = `health-gradient-${Math.random().toString(36).substr(2, 9)}`

  return (
    <div className={`flex flex-col items-center ${className}`}>
      {/* SVG Gauge */}
      <div
        className="relative"
        style={{
          width: config.diameter,
          height: config.diameter,
          filter: `drop-shadow(${glow})`,
        }}
      >
        <svg
          width={config.diameter}
          height={config.diameter}
          viewBox={`0 0 ${config.diameter} ${config.diameter}`}
          className="transform -rotate-90"
        >
          {/* Gradient definition */}
          <defs>
            <linearGradient id={gradientId} x1="0%" y1="0%" x2="100%" y2="100%">
              {score >= 70 ? (
                <>
                  <stop offset="0%" stopColor="#10B981" />
                  <stop offset="100%" stopColor="#059669" />
                </>
              ) : score >= 50 ? (
                <>
                  <stop offset="0%" stopColor="#F59E0B" />
                  <stop offset="100%" stopColor="#D97706" />
                </>
              ) : (
                <>
                  <stop offset="0%" stopColor="#EF4444" />
                  <stop offset="100%" stopColor="#DC2626" />
                </>
              )}
            </linearGradient>
          </defs>

          {/* Background track */}
          <circle
            cx={config.diameter / 2}
            cy={config.diameter / 2}
            r={radius}
            fill="none"
            stroke="#E5E7EB"
            strokeWidth={config.stroke}
            strokeLinecap="round"
          />

          {/* Progress arc */}
          <circle
            cx={config.diameter / 2}
            cy={config.diameter / 2}
            r={radius}
            fill="none"
            stroke={`url(#${gradientId})`}
            strokeWidth={config.stroke}
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={offset}
            className={animated ? 'transition-all duration-1000 ease-out' : ''}
          />
        </svg>

        {/* Centre content */}
        <div className="absolute inset-0 flex flex-col items-center justify-center">
          <span
            className="font-bold"
            style={{
              fontSize: config.fontSize,
              color: textColor,
              lineHeight: 1,
            }}
          >
            {animatedScore}
          </span>
          <span
            className="text-gray-400"
            style={{ fontSize: config.subFontSize }}
          >
            /{maxScore}
          </span>
        </div>
      </div>

      {/* Trend indicator */}
      {showTrend && trend !== undefined && (
        <div className={`flex items-center gap-1 mt-2 text-sm font-medium ${
          trend > 0 ? 'text-green-600' : trend < 0 ? 'text-red-600' : 'text-gray-500'
        }`}>
          {trend > 0 ? (
            <TrendingUp className="h-4 w-4" />
          ) : trend < 0 ? (
            <TrendingDown className="h-4 w-4" />
          ) : (
            <Minus className="h-4 w-4" />
          )}
          <span>
            {trend > 0 ? '+' : ''}{trend} vs 30d
          </span>
        </div>
      )}
    </div>
  )
}
```

### 2.2 Integrate into LeftColumn

**File**: `src/app/(dashboard)/clients/[clientId]/components/v2/LeftColumn.tsx`

**Changes Required:**
1. Import the new HealthGauge component
2. Replace the existing health score display with the radial gauge
3. Add trend calculation from health history

```typescript
// Add import
import HealthGauge from '@/components/charts/HealthGauge'

// In the component, replace the health score section with:
<div className="flex justify-center py-4">
  <HealthGauge
    score={calculatedHealthScore ?? client.health_score ?? 0}
    trend={historicalTrend}
    size="lg"
    animated={true}
  />
</div>
```

### Acceptance Criteria
- [ ] HealthGauge component renders correctly
- [ ] Animation plays on initial load
- [ ] Colour changes based on score (green/amber/red)
- [ ] Glow effect visible around gauge
- [ ] Trend indicator shows correct direction
- [ ] Respects prefers-reduced-motion

---

## Phase 3: NPS Donut Chart

**Priority**: High (Key metric visualisation)
**Effort**: 2 days
**Dependencies**: Phase 1

### 3.1 Create NPSDonut Component

**File**: `src/components/charts/NPSDonut.tsx`

```typescript
'use client'

import React, { useState } from 'react'
import { tokens } from '@/lib/design-tokens'

interface NPSDonutProps {
  promoters: number
  passives: number
  detractors: number
  size?: 'sm' | 'md' | 'lg'
  showLegend?: boolean
  className?: string
}

const sizeConfig = {
  sm: { diameter: 80, stroke: 12, innerRadius: 28 },
  md: { diameter: 100, stroke: 16, innerRadius: 34 },
  lg: { diameter: 120, stroke: 20, innerRadius: 40 },
}

export default function NPSDonut({
  promoters,
  passives,
  detractors,
  size = 'md',
  showLegend = true,
  className = '',
}: NPSDonutProps) {
  const [hoveredSegment, setHoveredSegment] = useState<string | null>(null)
  const config = sizeConfig[size]

  const total = promoters + passives + detractors
  const npsScore = total > 0
    ? Math.round(((promoters - detractors) / total) * 100)
    : 0

  // Calculate percentages
  const promoterPct = total > 0 ? (promoters / total) * 100 : 0
  const passivePct = total > 0 ? (passives / total) * 100 : 0
  const detractorPct = total > 0 ? (detractors / total) * 100 : 0

  // SVG calculations
  const radius = (config.diameter - config.stroke) / 2
  const circumference = 2 * Math.PI * radius

  // Calculate dash arrays for each segment
  const promoterDash = (promoterPct / 100) * circumference
  const passiveDash = (passivePct / 100) * circumference
  const detractorDash = (detractorPct / 100) * circumference

  // Calculate offsets (segments start where previous ends)
  const promoterOffset = 0
  const passiveOffset = -promoterDash
  const detractorOffset = -(promoterDash + passiveDash)

  const segments = [
    {
      key: 'promoters',
      value: promoters,
      pct: promoterPct,
      color: '#10B981',
      dash: promoterDash,
      offset: promoterOffset,
      label: 'Promoters',
    },
    {
      key: 'passives',
      value: passives,
      pct: passivePct,
      color: '#9CA3AF',
      dash: passiveDash,
      offset: passiveOffset,
      label: 'Passives',
    },
    {
      key: 'detractors',
      value: detractors,
      pct: detractorPct,
      color: '#EF4444',
      dash: detractorDash,
      offset: detractorOffset,
      label: 'Detractors',
    },
  ]

  return (
    <div className={`flex flex-col ${className}`}>
      <div className="flex items-center gap-6">
        {/* Donut chart */}
        <div
          className="relative flex-shrink-0"
          style={{ width: config.diameter, height: config.diameter }}
        >
          <svg
            width={config.diameter}
            height={config.diameter}
            viewBox={`0 0 ${config.diameter} ${config.diameter}`}
            className="transform -rotate-90"
          >
            {/* Background circle */}
            <circle
              cx={config.diameter / 2}
              cy={config.diameter / 2}
              r={radius}
              fill="none"
              stroke="#F3F4F6"
              strokeWidth={config.stroke}
            />

            {/* Segments */}
            {segments.map((segment, index) => (
              <circle
                key={segment.key}
                cx={config.diameter / 2}
                cy={config.diameter / 2}
                r={radius}
                fill="none"
                stroke={segment.color}
                strokeWidth={config.stroke}
                strokeDasharray={`${segment.dash} ${circumference}`}
                strokeDashoffset={segment.offset}
                className={`transition-all duration-200 ${
                  hoveredSegment === segment.key ? 'opacity-100' :
                  hoveredSegment ? 'opacity-50' : 'opacity-100'
                }`}
                style={{
                  transform: hoveredSegment === segment.key
                    ? 'scale(1.05)'
                    : 'scale(1)',
                  transformOrigin: 'center',
                }}
                onMouseEnter={() => setHoveredSegment(segment.key)}
                onMouseLeave={() => setHoveredSegment(null)}
              />
            ))}
          </svg>

          {/* Centre label */}
          <div className="absolute inset-0 flex items-center justify-center">
            <span className="text-xs font-medium text-gray-400">NPS</span>
          </div>
        </div>

        {/* Score and status */}
        <div className="flex flex-col">
          <span className={`text-3xl font-bold ${
            npsScore > 0 ? 'text-green-600' :
            npsScore < 0 ? 'text-red-600' :
            'text-gray-600'
          }`}>
            {npsScore > 0 ? '+' : ''}{npsScore}
          </span>
          <span className={`text-sm font-medium ${
            npsScore >= 50 ? 'text-green-600' :
            npsScore >= 0 ? 'text-yellow-600' :
            'text-red-600'
          }`}>
            {npsScore >= 50 ? 'Excellent' :
             npsScore >= 0 ? 'Good' :
             'Needs Work'}
          </span>
        </div>
      </div>

      {/* Legend */}
      {showLegend && (
        <div className="flex flex-col gap-1.5 mt-4">
          {segments.map(segment => (
            <div
              key={segment.key}
              className={`flex items-center justify-between text-sm transition-opacity ${
                hoveredSegment && hoveredSegment !== segment.key
                  ? 'opacity-50'
                  : 'opacity-100'
              }`}
              onMouseEnter={() => setHoveredSegment(segment.key)}
              onMouseLeave={() => setHoveredSegment(null)}
            >
              <div className="flex items-center gap-2">
                <div
                  className="w-3 h-3 rounded-full"
                  style={{ backgroundColor: segment.color }}
                />
                <span className="text-gray-600">{segment.label}</span>
              </div>
              <div className="flex items-center gap-2">
                <span className="font-medium text-gray-900">{segment.value}</span>
                <span className="text-gray-400">({Math.round(segment.pct)}%)</span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
```

### 3.2 Create NPS Card Wrapper

**File**: `src/components/cards/NPSScoreCard.tsx`

```typescript
'use client'

import React from 'react'
import NPSDonut from '@/components/charts/NPSDonut'
import { TrendingUp, TrendingDown, Minus, ChevronRight } from 'lucide-react'

interface NPSScoreCardProps {
  promoters: number
  passives: number
  detractors: number
  trend?: number
  quarter?: string
  onClick?: () => void
  className?: string
}

export default function NPSScoreCard({
  promoters,
  passives,
  detractors,
  trend,
  quarter,
  onClick,
  className = '',
}: NPSScoreCardProps) {
  return (
    <div
      className={`bg-white rounded-xl border border-gray-200 p-5 ${
        onClick ? 'cursor-pointer hover:shadow-hover hover:-translate-y-0.5 transition-all' : ''
      } ${className}`}
      onClick={onClick}
    >
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div>
          <span className="text-xs font-medium text-gray-500 uppercase tracking-wide">
            NPS Score
          </span>
          {quarter && (
            <span className="text-xs text-gray-400 ml-2">• {quarter}</span>
          )}
        </div>
        {trend !== undefined && (
          <div className={`flex items-center gap-1 text-xs font-medium ${
            trend > 0 ? 'text-green-600' : trend < 0 ? 'text-red-600' : 'text-gray-500'
          }`}>
            {trend > 0 ? <TrendingUp className="h-3 w-3" /> :
             trend < 0 ? <TrendingDown className="h-3 w-3" /> :
             <Minus className="h-3 w-3" />}
            <span>{trend > 0 ? '+' : ''}{trend}</span>
          </div>
        )}
      </div>

      {/* Donut chart */}
      <NPSDonut
        promoters={promoters}
        passives={passives}
        detractors={detractors}
        size="md"
        showLegend={true}
      />

      {/* View details link */}
      {onClick && (
        <button className="flex items-center gap-1 text-sm font-medium text-purple-600 hover:text-purple-700 mt-4">
          View details
          <ChevronRight className="h-4 w-4" />
        </button>
      )}
    </div>
  )
}
```

### Acceptance Criteria
- [ ] Donut chart renders with three segments
- [ ] Segments are proportionally sized
- [ ] Hover state highlights individual segment
- [ ] Legend shows counts and percentages
- [ ] NPS score displays with correct colour
- [ ] Card has hover elevation effect

---

## Phase 4: Financial Health Stacked Bar

**Priority**: Medium (Important data visualisation)
**Effort**: 2 days
**Dependencies**: Phase 1

### 4.1 Create StackedAgingBar Component

**File**: `src/components/charts/StackedAgingBar.tsx`

```typescript
'use client'

import React, { useState } from 'react'
import { CheckCircle2, XCircle } from 'lucide-react'

interface AgingBuckets {
  current: number
  days1to30: number
  days31to60: number
  days61to90: number
  days91to120: number
  days121to180: number
  days181to270: number
  days271to365: number
  daysOver365: number
}

interface StackedAgingBarProps {
  buckets: AgingBuckets
  totalOutstanding: number
  percentUnder60Days: number
  percentUnder90Days: number
  currency?: string
  className?: string
}

const bucketConfig = [
  { key: 'current', label: 'Current', color: '#10B981' },
  { key: 'days1to30', label: '1-30 days', color: '#34D399' },
  { key: 'days31to60', label: '31-60 days', color: '#FBBF24' },
  { key: 'days61to90', label: '61-90 days', color: '#F59E0B' },
  { key: 'days91to120', label: '91-120 days', color: '#F97316' },
  { key: 'days121to180', label: '121-180 days', color: '#EF4444' },
  { key: 'days181to270', label: '181-270 days', color: '#DC2626' },
  { key: 'days271to365', label: '271-365 days', color: '#B91C1C' },
  { key: 'daysOver365', label: '365+ days', color: '#7F1D1D' },
] as const

export default function StackedAgingBar({
  buckets,
  totalOutstanding,
  percentUnder60Days,
  percentUnder90Days,
  currency = '$',
  className = '',
}: StackedAgingBarProps) {
  const [hoveredBucket, setHoveredBucket] = useState<string | null>(null)

  // Calculate total for percentages
  const total = Object.values(buckets).reduce((sum, val) => sum + Math.abs(val), 0)

  // Build segments with percentages
  const segments = bucketConfig
    .map(config => ({
      ...config,
      value: Math.abs(buckets[config.key as keyof AgingBuckets]),
      percentage: total > 0
        ? (Math.abs(buckets[config.key as keyof AgingBuckets]) / total) * 100
        : 0,
    }))
    .filter(seg => seg.percentage > 0) // Only show non-zero segments

  const formatCurrency = (value: number) => {
    return `${currency}${Math.abs(value).toLocaleString('en-AU', {
      minimumFractionDigits: 0,
      maximumFractionDigits: 0,
    })}`
  }

  const meetsGoals = percentUnder60Days >= 90 && percentUnder90Days >= 100

  return (
    <div className={className}>
      {/* Total outstanding */}
      <div className="flex items-baseline justify-between mb-3">
        <span className="text-xl font-bold text-gray-900">
          {formatCurrency(totalOutstanding)}
        </span>
        <span className="text-sm text-gray-500">Outstanding</span>
      </div>

      {/* Stacked bar */}
      <div className="relative">
        <div className="flex h-6 rounded-md overflow-hidden bg-gray-100">
          {segments.map((segment, index) => (
            <div
              key={segment.key}
              className="relative transition-all duration-200"
              style={{
                width: `${segment.percentage}%`,
                backgroundColor: segment.color,
                opacity: hoveredBucket && hoveredBucket !== segment.key ? 0.5 : 1,
              }}
              onMouseEnter={() => setHoveredBucket(segment.key)}
              onMouseLeave={() => setHoveredBucket(null)}
            >
              {/* Tooltip on hover */}
              {hoveredBucket === segment.key && (
                <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 px-3 py-2 bg-gray-900 text-white text-xs rounded-lg whitespace-nowrap z-10">
                  <div className="font-medium">{segment.label}</div>
                  <div>{formatCurrency(segment.value)} ({Math.round(segment.percentage)}%)</div>
                  <div className="absolute top-full left-1/2 -translate-x-1/2 border-4 border-transparent border-t-gray-900" />
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Legend labels for major buckets */}
        <div className="flex justify-between mt-1 text-xs text-gray-500">
          <span>Current</span>
          <span>60d</span>
          <span>90d</span>
          <span>365d+</span>
        </div>
      </div>

      {/* Compliance badges */}
      <div className="flex gap-3 mt-4">
        <div className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium ${
          percentUnder60Days >= 90
            ? 'bg-green-50 text-green-700 border border-green-200'
            : 'bg-amber-50 text-amber-700 border border-amber-200'
        }`}>
          {percentUnder60Days >= 90 ? (
            <CheckCircle2 className="h-4 w-4" />
          ) : (
            <XCircle className="h-4 w-4" />
          )}
          <span>{Math.round(percentUnder60Days)}% &lt;60d</span>
        </div>

        <div className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-sm font-medium ${
          percentUnder90Days >= 100
            ? 'bg-green-50 text-green-700 border border-green-200'
            : 'bg-amber-50 text-amber-700 border border-amber-200'
        }`}>
          {percentUnder90Days >= 100 ? (
            <CheckCircle2 className="h-4 w-4" />
          ) : (
            <XCircle className="h-4 w-4" />
          )}
          <span>{Math.round(percentUnder90Days)}% &lt;90d</span>
        </div>
      </div>

      {/* Overall status */}
      <div className={`mt-3 text-sm font-medium ${
        meetsGoals ? 'text-green-600' : 'text-amber-600'
      }`}>
        {meetsGoals ? '✓ Meets compliance goals' : '⚠ Below target'}
      </div>
    </div>
  )
}
```

### Acceptance Criteria
- [ ] Stacked bar renders with proportional segments
- [ ] Hover shows tooltip with bucket details
- [ ] Compliance badges show correct status
- [ ] Currency formatting uses Australian locale
- [ ] Empty buckets are hidden

---

## Phase 5: Timeline Card Redesign

**Priority**: Medium (Core interaction component)
**Effort**: 3-4 days
**Dependencies**: Phase 1

### 5.1 Create Modern Timeline Card

**File**: `src/components/timeline/TimelineCard.tsx`

```typescript
'use client'

import React, { useState } from 'react'
import {
  CheckCircle2, Calendar, MessageSquare, Mail, FileText,
  MoreHorizontal, Edit3, Trash2, Copy, ExternalLink,
  Users, Clock, Video
} from 'lucide-react'
import { EnhancedSelect } from '@/components/ui/enhanced'

type ItemType = 'action' | 'meeting' | 'note' | 'email'
type ActionStatus = 'open' | 'in-progress' | 'completed' | 'cancelled'
type MeetingStatus = 'scheduled' | 'completed' | 'cancelled'

interface TimelineCardProps {
  id: string
  type: ItemType
  title: string
  description?: string
  timestamp: Date
  status?: ActionStatus | MeetingStatus
  priority?: 'critical' | 'high' | 'medium' | 'low'
  owner?: string
  attendees?: string[]
  hasRecording?: boolean
  onStatusChange?: (id: string, status: string) => void
  onEdit?: (id: string) => void
  onDelete?: (id: string) => void
  onCopy?: (id: string) => void
  onClick?: (id: string) => void
  className?: string
}

const typeConfig = {
  action: { icon: CheckCircle2, color: '#7C3AED', bgColor: '#F5F3FF', label: 'Action' },
  meeting: { icon: Calendar, color: '#3B82F6', bgColor: '#EFF6FF', label: 'Meeting' },
  note: { icon: MessageSquare, color: '#10B981', bgColor: '#ECFDF5', label: 'Note' },
  email: { icon: Mail, color: '#6366F1', bgColor: '#EEF2FF', label: 'Email' },
}

const priorityConfig = {
  critical: { color: 'text-red-600', bg: 'bg-red-50', border: 'border-red-200' },
  high: { color: 'text-red-600', bg: 'bg-red-50', border: 'border-red-200' },
  medium: { color: 'text-yellow-600', bg: 'bg-yellow-50', border: 'border-yellow-200' },
  low: { color: 'text-green-600', bg: 'bg-green-50', border: 'border-green-200' },
}

export default function TimelineCard({
  id,
  type,
  title,
  description,
  timestamp,
  status,
  priority,
  owner,
  attendees,
  hasRecording,
  onStatusChange,
  onEdit,
  onDelete,
  onCopy,
  onClick,
  className = '',
}: TimelineCardProps) {
  const [isHovered, setIsHovered] = useState(false)
  const [showMenu, setShowMenu] = useState(false)

  const config = typeConfig[type]
  const Icon = config.icon

  const formatTime = (date: Date) => {
    return date.toLocaleTimeString('en-AU', { hour: '2-digit', minute: '2-digit' })
  }

  const formatDate = (date: Date) => {
    return date.toLocaleDateString('en-AU', { day: 'numeric', month: 'short' })
  }

  return (
    <div
      className={`
        bg-white rounded-xl border border-gray-200
        transition-all duration-200 ease-out
        ${isHovered ? 'shadow-hover -translate-y-0.5' : 'shadow-sm'}
        ${onClick ? 'cursor-pointer' : ''}
        ${className}
      `}
      style={{ borderLeftWidth: '4px', borderLeftColor: config.color }}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => { setIsHovered(false); setShowMenu(false) }}
      onClick={() => onClick?.(id)}
    >
      <div className="p-4">
        {/* Header row */}
        <div className="flex items-start gap-3 mb-3">
          {/* Type icon */}
          <div
            className="h-9 w-9 rounded-lg flex items-center justify-center flex-shrink-0"
            style={{ backgroundColor: config.bgColor }}
          >
            <Icon className="h-4 w-4" style={{ color: config.color }} />
          </div>

          {/* Content */}
          <div className="flex-1 min-w-0">
            <div className="flex items-start justify-between gap-3">
              <h4 className="text-sm font-semibold text-gray-900 line-clamp-2">
                {title}
              </h4>

              {/* Menu button */}
              <button
                onClick={(e) => { e.stopPropagation(); setShowMenu(!showMenu) }}
                className={`p-1 rounded hover:bg-gray-100 transition-opacity ${
                  isHovered ? 'opacity-100' : 'opacity-0'
                }`}
              >
                <MoreHorizontal className="h-4 w-4 text-gray-500" />
              </button>
            </div>

            {/* Metadata */}
            <div className="flex items-center gap-3 mt-1 text-xs text-gray-500">
              {owner && (
                <div className="flex items-center gap-1">
                  <Users className="h-3 w-3" />
                  <span>{owner}</span>
                </div>
              )}
              {type === 'meeting' && (
                <div className="flex items-center gap-1">
                  <Clock className="h-3 w-3" />
                  <span>{formatTime(timestamp)}</span>
                </div>
              )}
              <span>•</span>
              <span>{formatDate(timestamp)}</span>
            </div>
          </div>
        </div>

        {/* Description */}
        {description && (
          <p className="text-sm text-gray-600 line-clamp-2 mb-3">
            {description}
          </p>
        )}

        {/* Attendees */}
        {attendees && attendees.length > 0 && (
          <div className="flex flex-wrap gap-1.5 mb-3">
            {attendees.slice(0, 3).map((attendee, idx) => (
              <span
                key={idx}
                className="px-2 py-0.5 bg-gray-100 rounded text-xs text-gray-700"
              >
                {attendee}
              </span>
            ))}
            {attendees.length > 3 && (
              <span className="text-xs text-gray-500">
                +{attendees.length - 3} more
              </span>
            )}
          </div>
        )}

        {/* Action bar */}
        <div className="flex items-center justify-between pt-3 border-t border-gray-100">
          <div className="flex items-center gap-2">
            {/* Status dropdown */}
            {status && onStatusChange && (
              <EnhancedSelect
                value={status}
                onValueChange={(value) => onStatusChange(id, value)}
                options={
                  type === 'action'
                    ? [
                        { value: 'open', label: 'Not Started' },
                        { value: 'in-progress', label: 'In Progress' },
                        { value: 'completed', label: 'Completed' },
                        { value: 'cancelled', label: 'Cancelled' },
                      ]
                    : [
                        { value: 'scheduled', label: 'Scheduled' },
                        { value: 'completed', label: 'Completed' },
                        { value: 'cancelled', label: 'Cancelled' },
                      ]
                }
                triggerClassName="text-xs"
              />
            )}

            {/* Priority badge */}
            {priority && (
              <span className={`px-2.5 py-1 rounded-lg text-xs font-medium border ${
                priorityConfig[priority].color
              } ${priorityConfig[priority].bg} ${priorityConfig[priority].border}`}>
                {priority}
              </span>
            )}

            {/* Recording indicator */}
            {hasRecording && (
              <span className="flex items-center gap-1 px-2.5 py-1 bg-purple-50 text-purple-600 rounded-lg text-xs font-medium">
                <Video className="h-3 w-3" />
                Recording
              </span>
            )}
          </div>

          {/* Quick actions */}
          <div className={`flex items-center gap-1 transition-opacity ${
            isHovered ? 'opacity-100' : 'opacity-0'
          }`}>
            {onEdit && (
              <button
                onClick={(e) => { e.stopPropagation(); onEdit(id) }}
                className="p-1.5 hover:bg-gray-100 rounded transition"
                title="Edit"
              >
                <Edit3 className="h-3.5 w-3.5 text-gray-600" />
              </button>
            )}
            {onDelete && (
              <button
                onClick={(e) => { e.stopPropagation(); onDelete(id) }}
                className="p-1.5 hover:bg-red-50 rounded transition"
                title="Delete"
              >
                <Trash2 className="h-3.5 w-3.5 text-red-600" />
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Dropdown menu */}
      {showMenu && (
        <div className="absolute right-4 top-12 w-48 bg-white rounded-lg shadow-lg border border-gray-200 py-1 z-50">
          {onEdit && (
            <button
              onClick={(e) => { e.stopPropagation(); onEdit(id); setShowMenu(false) }}
              className="w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 flex items-center gap-2"
            >
              <Edit3 className="h-4 w-4" />
              Edit
            </button>
          )}
          {onCopy && (
            <button
              onClick={(e) => { e.stopPropagation(); onCopy(id); setShowMenu(false) }}
              className="w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 flex items-center gap-2"
            >
              <Copy className="h-4 w-4" />
              Copy details
            </button>
          )}
          {type === 'meeting' && (
            <button
              onClick={(e) => { e.stopPropagation(); setShowMenu(false) }}
              className="w-full px-4 py-2 text-left text-sm text-gray-700 hover:bg-gray-50 flex items-center gap-2"
            >
              <ExternalLink className="h-4 w-4" />
              Open in Outlook
            </button>
          )}
          <div className="border-t border-gray-100 my-1" />
          {onDelete && (
            <button
              onClick={(e) => { e.stopPropagation(); onDelete(id); setShowMenu(false) }}
              className="w-full px-4 py-2 text-left text-sm text-red-600 hover:bg-red-50 flex items-center gap-2"
            >
              <Trash2 className="h-4 w-4" />
              Delete
            </button>
          )}
        </div>
      )}
    </div>
  )
}
```

### Acceptance Criteria
- [ ] Card renders with left colour border based on type
- [ ] Hover state shows elevation and quick actions
- [ ] Status dropdown is inline-editable
- [ ] Priority badges have correct colours
- [ ] Menu dropdown works correctly
- [ ] Click event propagates to parent

---

## Phase 6: AI Insight Cards

**Priority**: Medium (Enhances user guidance)
**Effort**: 1-2 days
**Dependencies**: Phase 1

### 6.1 Create AIInsightCard Component

**File**: `src/components/cards/AIInsightCard.tsx`

```typescript
'use client'

import React, { useState } from 'react'
import { AlertTriangle, Lightbulb, Sparkles, X, Plus } from 'lucide-react'

type InsightType = 'risk' | 'opportunity' | 'prediction'

interface AIInsightCardProps {
  type: InsightType
  title: string
  description: string
  confidence: number // 0-100
  onCreateAction?: () => void
  onDismiss?: () => void
  className?: string
}

const typeConfig = {
  risk: {
    icon: AlertTriangle,
    gradient: 'from-amber-50 to-white',
    borderColor: 'border-amber-200',
    iconColor: 'text-amber-600',
    titleColor: 'text-amber-700',
    barColor: 'bg-amber-500',
  },
  opportunity: {
    icon: Lightbulb,
    gradient: 'from-blue-50 to-white',
    borderColor: 'border-blue-200',
    iconColor: 'text-blue-600',
    titleColor: 'text-blue-700',
    barColor: 'bg-blue-500',
  },
  prediction: {
    icon: Sparkles,
    gradient: 'from-purple-50 to-white',
    borderColor: 'border-purple-200',
    iconColor: 'text-purple-600',
    titleColor: 'text-purple-700',
    barColor: 'bg-purple-500',
  },
}

export default function AIInsightCard({
  type,
  title,
  description,
  confidence,
  onCreateAction,
  onDismiss,
  className = '',
}: AIInsightCardProps) {
  const [isDismissing, setIsDismissing] = useState(false)
  const config = typeConfig[type]
  const Icon = config.icon

  const handleDismiss = () => {
    setIsDismissing(true)
    setTimeout(() => onDismiss?.(), 300)
  }

  return (
    <div
      className={`
        rounded-xl border p-4
        bg-gradient-to-br ${config.gradient} ${config.borderColor}
        transition-all duration-300
        ${isDismissing ? 'opacity-0 scale-95' : 'opacity-100 scale-100'}
        ${className}
      `}
    >
      {/* Header */}
      <div className="flex items-start gap-3 mb-3">
        <Icon className={`h-5 w-5 ${config.iconColor} flex-shrink-0 mt-0.5`} />
        <div className="flex-1">
          <h4 className={`text-sm font-semibold ${config.titleColor}`}>
            {title}
          </h4>
        </div>
        {onDismiss && (
          <button
            onClick={handleDismiss}
            className="p-1 hover:bg-white/50 rounded transition"
          >
            <X className="h-4 w-4 text-gray-400" />
          </button>
        )}
      </div>

      {/* Description */}
      <p className="text-sm text-gray-700 mb-4">
        {description}
      </p>

      {/* Confidence bar */}
      <div className="mb-4">
        <div className="flex items-center justify-between mb-1">
          <span className="text-xs font-medium text-gray-500">Confidence</span>
          <span className="text-xs font-medium text-gray-700">{confidence}%</span>
        </div>
        <div className="h-1.5 bg-gray-200 rounded-full overflow-hidden">
          <div
            className={`h-full ${config.barColor} rounded-full transition-all duration-500`}
            style={{ width: `${confidence}%` }}
          />
        </div>
      </div>

      {/* Actions */}
      <div className="flex items-center gap-2">
        {onCreateAction && (
          <button
            onClick={onCreateAction}
            className="flex items-center gap-1.5 px-3 py-1.5 bg-gray-900 text-white text-sm font-medium rounded-lg hover:bg-gray-800 transition"
          >
            <Plus className="h-4 w-4" />
            Create Action
          </button>
        )}
        {onDismiss && (
          <button
            onClick={handleDismiss}
            className="px-3 py-1.5 text-sm font-medium text-gray-600 hover:bg-white/50 rounded-lg transition"
          >
            Dismiss
          </button>
        )}
      </div>
    </div>
  )
}
```

### Acceptance Criteria
- [ ] Card renders with correct gradient based on type
- [ ] Confidence bar fills to correct percentage
- [ ] Dismiss animation plays smoothly
- [ ] Create Action button triggers callback
- [ ] Icons match insight type

---

## Summary & Timeline

| Phase | Component | Files | Estimated Effort |
|-------|-----------|-------|------------------|
| 1 | Design Tokens | 2 | 1-2 days |
| 2 | Health Gauge | 2 | 2-3 days |
| 3 | NPS Donut | 2 | 2 days |
| 4 | Financial Bar | 1 | 2 days |
| 5 | Timeline Cards | 1 | 3-4 days |
| 6 | AI Insight Cards | 1 | 1-2 days |

**Total Estimated Effort**: 11-15 days

### Dependencies Graph

```
Phase 1 (Tokens)
    ├── Phase 2 (Health Gauge)
    ├── Phase 3 (NPS Donut)
    ├── Phase 4 (Financial Bar)
    ├── Phase 5 (Timeline Cards)
    └── Phase 6 (AI Insight Cards)
```

All phases depend on Phase 1 (Design Tokens), but Phases 2-6 can be developed in parallel after Phase 1 is complete.

---

## Testing Checklist

### Visual Testing
- [ ] Components render correctly in Chrome, Firefox, Safari
- [ ] Animations are smooth (60fps)
- [ ] Hover states work on desktop
- [ ] Touch interactions work on mobile/tablet
- [ ] Dark mode compatibility (if applicable)

### Accessibility Testing
- [ ] Screen reader announces all interactive elements
- [ ] Keyboard navigation works for all components
- [ ] Focus indicators are visible
- [ ] Colour contrast meets WCAG 2.1 AA
- [ ] Reduced motion is respected

### Performance Testing
- [ ] Initial paint under 1.5 seconds
- [ ] No layout shift during animation
- [ ] Memory usage stable during interactions
- [ ] Bundle size increase acceptable

---

*Document Version: 1.0*
*Last Updated: 4 January 2026*
