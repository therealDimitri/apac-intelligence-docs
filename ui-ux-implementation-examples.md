# CSI Dashboard - Implementation Examples

**Practical code examples for each UI/UX recommendation**

---

## Example 1: Redesigned Ratio Card Component

### Complete Component (Recommended Implementation)

```tsx
import { memo, useMemo, useState } from 'react'
import { Info, TrendingUp, TrendingDown, CheckCircle2, AlertTriangle } from 'lucide-react'
import { Sparklines, SparklinesLine, SparklinesReferenceLine } from 'react-sparklines'
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip'
import { cn } from '@/lib/utils'
import type { RatioAnalysis, CSIRatioName } from '@/types/csi-insights'

interface RatioCardProps {
  ratio: CSIRatioName
  analysis: RatioAnalysis
  focusYear: number
  onClick?: () => void
}

/**
 * Redesigned Ratio Card following industry best practices
 * - Stripe: Primary metric dominance, progressive disclosure
 * - Linear: Clear typography hierarchy, status badges
 * - Datadog: Sparkline with target threshold
 * - Mixpanel: Semantic colour system
 */
export const RatioCard = memo(function RatioCard({
  ratio,
  analysis,
  focusYear,
  onClick
}: RatioCardProps) {
  const config = RATIO_CONFIG[ratio]
  const [isHovered, setIsHovered] = useState(false)

  // Memoized calculations
  const sparklineData = useMemo(
    () => analysis.rollingAverages.slice(-12).map(r => r.value),
    [analysis.rollingAverages]
  )

  const forecastAtTarget = useMemo(
    () => ratio === 'ga'
      ? analysis.mlPrediction.yearAverage <= analysis.target
      : analysis.mlPrediction.yearAverage >= analysis.target,
    [ratio, analysis.mlPrediction.yearAverage, analysis.target]
  )

  const trendPercentage = useMemo(() => {
    const change = analysis.mlPrediction.yearAverage - analysis.forecastData.currentMonthValue
    return ((change / analysis.forecastData.currentMonthValue) * 100).toFixed(1)
  }, [analysis.mlPrediction.yearAverage, analysis.forecastData.currentMonthValue])

  // Determine status with warning threshold (90-99% of target)
  const percentageOfTarget = (analysis.mlPrediction.yearAverage / analysis.target) * 100
  const isAtRisk = !forecastAtTarget && percentageOfTarget >= 90 && percentageOfTarget < 100

  const status = forecastAtTarget ? 'success' : isAtRisk ? 'warning' : 'error'
  const statusText = forecastAtTarget ? 'On track' : isAtRisk ? 'Watch' : 'Below target'

  // Sparkline range for hover tooltip
  const sparklineMin = Math.min(...sparklineData).toFixed(2)
  const sparklineMax = Math.max(...sparklineData).toFixed(2)

  return (
    <article
      className={cn(
        "bg-white dark:bg-gray-800 rounded-xl p-5 border border-gray-200 dark:border-gray-700",
        "transition-all duration-200 ease-out",
        "hover:shadow-lg hover:-translate-y-1 hover:border-gray-300 dark:hover:border-gray-600",
        "focus:outline-none focus:ring-2 focus:ring-purple-500 focus:ring-offset-2",
        "cursor-pointer"
      )}
      tabIndex={0}
      role="button"
      aria-label={`${config.name} ratio: ${analysis.actualData.latestValue.toFixed(2)}, ${statusText}, ${analysis.trend.direction} trend`}
      onClick={onClick}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault()
          onClick?.()
        }
      }}
    >
      {/* Header: Ratio name + Info tooltip */}
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-xs font-semibold text-gray-600 dark:text-gray-300 uppercase tracking-wide">
          {config.shortName} Ratio
        </h3>

        <TooltipProvider>
          <Tooltip delayDuration={300}>
            <TooltipTrigger asChild>
              <button
                className="text-gray-400 hover:text-gray-600 dark:hover:text-gray-300 transition-colors"
                aria-label={`Formula information for ${config.name}`}
                onClick={(e) => e.stopPropagation()}
              >
                <Info className="w-4 h-4" />
              </button>
            </TooltipTrigger>
            <TooltipContent side="top" className="max-w-xs">
              <div className="space-y-1.5">
                <p className="text-xs font-semibold text-white">{config.name}</p>
                <p className="text-xs text-gray-300 font-mono">{config.definition}</p>
                <p className="text-xs text-gray-400 pt-1 border-t border-gray-700">
                  Target: {ratio === 'ga' ? `≤${analysis.target}%` : `≥${analysis.target}`}
                </p>
              </div>
            </TooltipContent>
          </Tooltip>
        </TooltipProvider>
      </div>

      {/* Primary Value - 40px bold */}
      <div className="mb-3">
        <div className="flex items-baseline gap-1">
          <span className="text-4xl font-bold text-gray-900 dark:text-white tabular-nums">
            {analysis.actualData.latestValue.toFixed(2)}
          </span>
          {ratio === 'ga' && (
            <span className="text-lg text-gray-400 dark:text-gray-500">%</span>
          )}
        </div>
      </div>

      {/* Status Badge + Trend Indicator */}
      <div className="flex items-center gap-2 mb-4">
        {/* Status badge */}
        <div className={cn(
          "flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium",
          status === 'success' && "bg-green-50 text-green-700 dark:bg-green-900/20 dark:text-green-400",
          status === 'warning' && "bg-amber-50 text-amber-700 dark:bg-amber-900/20 dark:text-amber-400",
          status === 'error' && "bg-red-50 text-red-700 dark:bg-red-900/20 dark:text-red-400"
        )}>
          <div className={cn(
            "w-2 h-2 rounded-full",
            status === 'success' && "bg-green-500",
            status === 'warning' && "bg-amber-500",
            status === 'error' && "bg-red-500"
          )} />
          <span>{statusText}</span>
        </div>

        {/* Trend indicator */}
        {analysis.trend.direction !== 'stable' && (
          <div className="flex items-center gap-0.5 text-xs text-gray-600 dark:text-gray-400">
            {analysis.trend.direction === 'improving' ? (
              <TrendingUp className="w-3.5 h-3.5 text-green-600 dark:text-green-400" />
            ) : (
              <TrendingDown className="w-3.5 h-3.5 text-red-600 dark:text-red-400" />
            )}
            <span className="font-medium">
              {Math.abs(parseFloat(trendPercentage))}%
            </span>
          </div>
        )}
      </div>

      {/* Sparkline with target threshold line */}
      <div className="relative mb-3">
        <div className="h-10 relative group">
          <Sparklines data={sparklineData} width={200} height={40} margin={5}>
            {/* Main trend line - always neutral grey */}
            <SparklinesLine
              color="#9CA3AF"
              style={{ strokeWidth: 2, fill: 'none' }}
            />
            {/* Target threshold line - dashed */}
            <SparklinesReferenceLine
              type="custom"
              value={analysis.target}
              style={{
                stroke: '#D1D5DB',
                strokeDasharray: '4 4',
                strokeWidth: 1
              }}
            />
          </Sparklines>

          {/* Hover tooltip showing range */}
          {isHovered && (
            <div className="absolute -top-10 left-1/2 -translate-x-1/2 z-10 pointer-events-none">
              <div className="bg-gray-900 text-white text-xs px-2.5 py-1.5 rounded shadow-lg whitespace-nowrap">
                Range: {sparklineMin} - {sparklineMax}
                <div className="absolute top-full left-1/2 -translate-x-1/2 -mt-px">
                  <div className="w-0 h-0 border-l-4 border-r-4 border-t-4 border-transparent border-t-gray-900" />
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Target line label */}
        <div className="flex items-center justify-end gap-1 mt-1">
          <div className="h-px w-3 border-t border-dashed border-gray-300" />
          <span className="text-[10px] text-gray-400">
            Target: {analysis.target}{ratio === 'ga' ? '%' : ''}
          </span>
        </div>
      </div>

      {/* Compact Plan → Forecast comparison */}
      <div className="pt-3 border-t border-gray-100 dark:border-gray-700">
        <div className="flex items-center justify-between text-xs">
          <div className="flex items-center gap-2 text-gray-600 dark:text-gray-400">
            <span className="text-gray-500 dark:text-gray-500">
              Plan: {analysis.forecastData.currentMonthValue.toFixed(2)}
            </span>
            <span className="text-gray-300 dark:text-gray-600">→</span>
            <span className="font-medium text-gray-900 dark:text-white">
              Forecast: {analysis.mlPrediction.yearAverage.toFixed(2)}
            </span>
          </div>
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger asChild>
                <span className="text-gray-400 dark:text-gray-500 text-[10px] cursor-help">
                  {analysis.mlPrediction.confidence}% conf.
                </span>
              </TooltipTrigger>
              <TooltipContent side="top">
                <p className="text-xs">
                  Machine learning forecast confidence based on {analysis.rollingAverages.length} months of historical data
                </p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        </div>

        {/* Period metadata */}
        <div className="text-[10px] text-gray-400 dark:text-gray-500 mt-1.5">
          Latest: {analysis.actualData.latestPeriod}
        </div>
      </div>
    </article>
  )
})

RatioCard.displayName = 'RatioCard'
```

---

## Example 2: Skeleton Loading State

```tsx
/**
 * Content-aware skeleton that matches final card layout
 * Following Figma pattern for skeleton screens
 */
export function RatioCardSkeleton() {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-xl p-5 border border-gray-200 dark:border-gray-700 animate-pulse">
      {/* Header */}
      <div className="flex items-center justify-between mb-4">
        <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-20" />
        <div className="h-4 w-4 bg-gray-200 dark:bg-gray-700 rounded-full" />
      </div>

      {/* Primary value */}
      <div className="h-10 bg-gray-200 dark:bg-gray-700 rounded w-24 mb-3" />

      {/* Status badge */}
      <div className="flex items-center gap-2 mb-4">
        <div className="h-6 bg-gray-100 dark:bg-gray-700 rounded-full w-24" />
        <div className="h-4 bg-gray-100 dark:bg-gray-700 rounded w-12" />
      </div>

      {/* Sparkline */}
      <div className="h-10 bg-gray-100 dark:bg-gray-700 rounded mb-3" />

      {/* Comparison section */}
      <div className="pt-3 border-t border-gray-100 dark:border-gray-700">
        <div className="h-3 bg-gray-100 dark:bg-gray-700 rounded w-full mb-2" />
        <div className="h-2 bg-gray-100 dark:bg-gray-700 rounded w-32" />
      </div>
    </div>
  )
}
```

---

## Example 3: Animated Value Component

```tsx
import { useEffect, useRef } from 'react'

interface AnimatedValueProps {
  value: number
  duration?: number
  className?: string
  decimals?: number
}

/**
 * Animated number counter following Mixpanel pattern
 * Creates sense of data "coming alive" on load
 */
export function AnimatedValue({
  value,
  duration = 1000,
  className,
  decimals = 2
}: AnimatedValueProps) {
  const elementRef = useRef<HTMLSpanElement>(null)
  const frameRef = useRef<number>()
  const startTimeRef = useRef<number>()

  useEffect(() => {
    const element = elementRef.current
    if (!element) return

    const startValue = 0
    const endValue = value

    const animate = (currentTime: number) => {
      if (!startTimeRef.current) {
        startTimeRef.current = currentTime
      }

      const elapsed = currentTime - startTimeRef.current
      const progress = Math.min(elapsed / duration, 1)

      // Easing function (ease-out)
      const easeOut = 1 - Math.pow(1 - progress, 3)
      const currentValue = startValue + (endValue - startValue) * easeOut

      element.textContent = currentValue.toFixed(decimals)

      if (progress < 1) {
        frameRef.current = requestAnimationFrame(animate)
      }
    }

    frameRef.current = requestAnimationFrame(animate)

    return () => {
      if (frameRef.current) {
        cancelAnimationFrame(frameRef.current)
      }
    }
  }, [value, duration, decimals])

  return (
    <span ref={elementRef} className={className}>
      {value.toFixed(decimals)}
    </span>
  )
}

// Usage in RatioCard:
<AnimatedValue
  value={analysis.actualData.latestValue}
  className="text-4xl font-bold text-gray-900 dark:text-white tabular-nums"
/>
```

---

## Example 4: Status Badge Component

```tsx
import { CheckCircle2, AlertTriangle, AlertCircle } from 'lucide-react'
import { cn } from '@/lib/utils'

type Status = 'success' | 'warning' | 'error'

interface StatusBadgeProps {
  status: Status
  text: string
  className?: string
}

/**
 * Reusable status badge following Linear pattern
 * Single source of truth for status communication
 */
export function StatusBadge({ status, text, className }: StatusBadgeProps) {
  const icons = {
    success: CheckCircle2,
    warning: AlertTriangle,
    error: AlertCircle
  }

  const Icon = icons[status]

  return (
    <div className={cn(
      "inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-medium",
      status === 'success' && "bg-green-50 text-green-700 dark:bg-green-900/20 dark:text-green-400",
      status === 'warning' && "bg-amber-50 text-amber-700 dark:bg-amber-900/20 dark:text-amber-400",
      status === 'error' && "bg-red-50 text-red-700 dark:bg-red-900/20 dark:text-red-400",
      className
    )}>
      <div className={cn(
        "w-2 h-2 rounded-full",
        status === 'success' && "bg-green-500",
        status === 'warning' && "bg-amber-500",
        status === 'error' && "bg-red-500"
      )} />
      <span>{text}</span>
    </div>
  )
}
```

---

## Example 5: Enhanced Sparkline Component

```tsx
import { useMemo } from 'react'
import { Sparklines, SparklinesLine, SparklinesReferenceLine } from 'react-sparklines'

interface EnhancedSparklineProps {
  data: number[]
  target: number
  width?: number
  height?: number
  showRange?: boolean
}

/**
 * Sparkline with target threshold following Datadog pattern
 * Always neutral grey to avoid status confusion
 */
export function EnhancedSparkline({
  data,
  target,
  width = 200,
  height = 40,
  showRange = true
}: EnhancedSparklineProps) {
  const range = useMemo(() => ({
    min: Math.min(...data).toFixed(2),
    max: Math.max(...data).toFixed(2),
    avg: (data.reduce((sum, val) => sum + val, 0) / data.length).toFixed(2)
  }), [data])

  return (
    <div className="space-y-1">
      <div className="h-10 relative">
        <Sparklines data={data} width={width} height={height} margin={5}>
          {/* Main line - neutral grey */}
          <SparklinesLine
            color="#9CA3AF"
            style={{ strokeWidth: 2, fill: 'none' }}
          />
          {/* Target threshold - dashed line */}
          <SparklinesReferenceLine
            type="custom"
            value={target}
            style={{
              stroke: '#D1D5DB',
              strokeDasharray: '4 4',
              strokeWidth: 1
            }}
          />
        </Sparklines>
      </div>

      {showRange && (
        <div className="flex items-center justify-between text-[10px] text-gray-400">
          <span>Min: {range.min}</span>
          <span>Avg: {range.avg}</span>
          <span>Max: {range.max}</span>
        </div>
      )}
    </div>
  )
}
```

---

## Example 6: Responsive Grid Container

```tsx
import { cn } from '@/lib/utils'
import { ReactNode } from 'react'

interface RatioCardGridProps {
  children: ReactNode
  className?: string
}

/**
 * Responsive grid following Notion pattern
 * Ensures cards never shrink below 280px
 */
export function RatioCardGrid({ children, className }: RatioCardGridProps) {
  return (
    <div className={cn(
      "grid gap-6",
      // Mobile: 1 column
      "grid-cols-1",
      // Tablet: 2 columns (640px+)
      "sm:grid-cols-2",
      // Desktop: 3 columns (1024px+)
      "lg:grid-cols-3",
      // Large: 4 columns (1280px+)
      "xl:grid-cols-4",
      // XL: 6 columns (1536px+)
      "2xl:grid-cols-6",
      // Ensure minimum card width
      "[&>*]:min-w-[280px]",
      className
    )}>
      {children}
    </div>
  )
}

// Alternative: CSS Grid Auto-Fit (Figma pattern)
export function FluidRatioCardGrid({ children, className }: RatioCardGridProps) {
  return (
    <div
      className={cn("grid gap-6", className)}
      style={{
        gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))'
      }}
    >
      {children}
    </div>
  )
}
```

---

## Example 7: ARIA-Enhanced Card

```tsx
/**
 * Fully accessible ratio card with ARIA attributes
 * Ensures screen reader compatibility
 */
export function AccessibleRatioCard({ ratio, analysis }: RatioCardProps) {
  const config = RATIO_CONFIG[ratio]
  const statusText = forecastAtTarget ? 'On track' : 'Below target'

  return (
    <article
      className="bg-white rounded-xl p-5 border"
      tabIndex={0}
      role="button"
      aria-label={`${config.name} ratio card`}
      aria-describedby={`${ratio}-description`}
    >
      {/* Screen reader only description */}
      <div id={`${ratio}-description`} className="sr-only">
        {config.name} ratio is {analysis.actualData.latestValue.toFixed(2)},
        with a {analysis.trend.direction} trend.
        Status: {statusText}.
        Target is {analysis.target}.
        Forecast predicts {analysis.mlPrediction.yearAverage.toFixed(2)} with {analysis.mlPrediction.confidence}% confidence.
      </div>

      {/* Visible content */}
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-xs font-semibold uppercase">
          {config.shortName} Ratio
        </h3>
        <button
          aria-label={`View formula for ${config.name}`}
          className="text-gray-400 hover:text-gray-600"
        >
          <Info className="w-4 h-4" aria-hidden="true" />
        </button>
      </div>

      <div className="mb-3">
        <span className="text-4xl font-bold" aria-label={`Current value: ${analysis.actualData.latestValue.toFixed(2)}`}>
          {analysis.actualData.latestValue.toFixed(2)}
        </span>
      </div>

      {/* Sparkline with ARIA role */}
      <div
        role="img"
        aria-label={`Trend chart showing ${analysis.trend.direction} pattern over 12 months, ranging from ${Math.min(...sparklineData).toFixed(2)} to ${Math.max(...sparklineData).toFixed(2)}`}
      >
        <Sparklines data={sparklineData}>
          <SparklinesLine color="#9CA3AF" />
        </Sparklines>
      </div>
    </article>
  )
}
```

---

## Example 8: Card Detail Modal

```tsx
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { ResponsiveContainer, LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ReferenceLine } from 'recharts'

interface CardDetailModalProps {
  ratio: CSIRatioName
  analysis: RatioAnalysis
  historicalData: HistoricalDataPoint[]
  isOpen: boolean
  onClose: () => void
}

/**
 * Expanded card view with full historical chart
 * Following Stripe pattern for drill-down details
 */
export function CardDetailModal({
  ratio,
  analysis,
  historicalData,
  isOpen,
  onClose
}: CardDetailModalProps) {
  const config = RATIO_CONFIG[ratio]

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle>{config.name} Ratio Details</DialogTitle>
          <DialogDescription>
            {config.definition}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6 mt-4">
          {/* Summary stats */}
          <div className="grid grid-cols-4 gap-4">
            <div className="bg-gray-50 rounded-lg p-4">
              <div className="text-xs text-gray-500 mb-1">Current</div>
              <div className="text-2xl font-bold">{analysis.actualData.latestValue.toFixed(2)}</div>
            </div>
            <div className="bg-gray-50 rounded-lg p-4">
              <div className="text-xs text-gray-500 mb-1">Target</div>
              <div className="text-2xl font-bold">{analysis.target}</div>
            </div>
            <div className="bg-gray-50 rounded-lg p-4">
              <div className="text-xs text-gray-500 mb-1">Forecast</div>
              <div className="text-2xl font-bold">{analysis.mlPrediction.yearAverage.toFixed(2)}</div>
            </div>
            <div className="bg-gray-50 rounded-lg p-4">
              <div className="text-xs text-gray-500 mb-1">Trend</div>
              <div className="text-2xl font-bold capitalize">{analysis.trend.direction}</div>
            </div>
          </div>

          {/* Full historical chart */}
          <div className="h-96">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={historicalData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" />
                <XAxis
                  dataKey="monthName"
                  tick={{ fontSize: 12 }}
                  stroke="#6B7280"
                />
                <YAxis
                  tick={{ fontSize: 12 }}
                  stroke="#6B7280"
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1F2937',
                    border: 'none',
                    borderRadius: '8px',
                    color: 'white'
                  }}
                />
                <Legend />
                <ReferenceLine
                  y={analysis.target}
                  stroke="#9CA3AF"
                  strokeDasharray="4 4"
                  label={{
                    value: `Target: ${analysis.target}`,
                    position: 'right',
                    fill: '#6B7280',
                    fontSize: 12
                  }}
                />
                <Line
                  type="monotone"
                  dataKey={`ratios.${ratio}`}
                  stroke="#9CA3AF"
                  strokeWidth={2}
                  dot={{ fill: '#9CA3AF', r: 4 }}
                  activeDot={{ r: 6 }}
                  name={config.shortName}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          {/* Formula breakdown */}
          <div className="bg-purple-50 dark:bg-purple-900/20 rounded-lg p-4">
            <h4 className="text-sm font-semibold text-purple-900 dark:text-purple-300 mb-2">
              Formula Breakdown
            </h4>
            <p className="text-sm text-purple-800 dark:text-purple-400 font-mono">
              {config.definition}
            </p>
            <p className="text-xs text-purple-600 dark:text-purple-500 mt-2">
              This ratio measures efficiency by comparing revenue to operational expenses.
              {ratio === 'ga' ? ' Lower values indicate better cost management.' : ' Higher values indicate better efficiency.'}
            </p>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  )
}
```

---

## Example 9: Storybook Stories

```tsx
import type { Meta, StoryObj } from '@storybook/react'
import { RatioCard } from './RatioCard'
import type { RatioAnalysis } from '@/types/csi-insights'

const meta: Meta<typeof RatioCard> = {
  title: 'CSI/RatioCard',
  component: RatioCard,
  parameters: {
    layout: 'padded',
    backgrounds: {
      default: 'light',
      values: [
        { name: 'light', value: '#F3F4F6' },
        { name: 'dark', value: '#1F2937' }
      ]
    }
  },
  tags: ['autodocs'],
  argTypes: {
    ratio: {
      control: 'select',
      options: ['ps', 'sales', 'salesApac', 'maintenance', 'rd', 'ga']
    }
  }
}

export default meta
type Story = StoryObj<typeof RatioCard>

// Mock data
const mockAnalysisOnTrack: RatioAnalysis = {
  actualData: {
    latestValue: 2.34,
    latestPeriod: 'Dec 2025'
  },
  forecastData: {
    currentMonthValue: 2.10,
    currentMonthPeriod: 'Jan 2026'
  },
  mlPrediction: {
    yearAverage: 2.34,
    confidence: 85
  },
  target: 2.0,
  trend: {
    direction: 'improving'
  },
  rollingAverages: Array.from({ length: 12 }, (_, i) => ({
    value: 2.0 + (i * 0.03),
    period: `Month ${i + 1}`
  }))
}

const mockAnalysisBelowTarget: RatioAnalysis = {
  ...mockAnalysisOnTrack,
  actualData: {
    latestValue: 1.75,
    latestPeriod: 'Dec 2025'
  },
  mlPrediction: {
    yearAverage: 1.85,
    confidence: 78
  },
  trend: {
    direction: 'declining'
  }
}

// Stories
export const OnTrack: Story = {
  args: {
    ratio: 'ps',
    analysis: mockAnalysisOnTrack,
    focusYear: 2026
  }
}

export const BelowTarget: Story = {
  args: {
    ratio: 'ps',
    analysis: mockAnalysisBelowTarget,
    focusYear: 2026
  }
}

export const AtRisk: Story = {
  args: {
    ratio: 'sales',
    analysis: {
      ...mockAnalysisOnTrack,
      mlPrediction: {
        yearAverage: 1.95, // 97.5% of target (2.0)
        confidence: 82
      }
    },
    focusYear: 2026
  }
}

export const Loading: Story = {
  render: () => <RatioCardSkeleton />
}

export const DarkMode: Story = {
  args: OnTrack.args,
  parameters: {
    backgrounds: { default: 'dark' }
  },
  decorators: [
    (Story) => (
      <div className="dark">
        <Story />
      </div>
    )
  ]
}

export const AllRatios: Story = {
  render: () => (
    <div className="grid grid-cols-3 gap-6">
      {(['ps', 'sales', 'salesApac', 'maintenance', 'rd', 'ga'] as const).map(ratio => (
        <RatioCard
          key={ratio}
          ratio={ratio}
          analysis={mockAnalysisOnTrack}
          focusYear={2026}
        />
      ))}
    </div>
  )
}
```

---

## Example 10: Accessibility Testing Component

```tsx
import { render, screen } from '@testing-library/react'
import { axe, toHaveNoViolations } from 'jest-axe'
import userEvent from '@testing-library/user-event'
import { RatioCard } from './RatioCard'

expect.extend(toHaveNoViolations)

describe('RatioCard Accessibility', () => {
  const mockProps = {
    ratio: 'ps' as const,
    analysis: {
      actualData: { latestValue: 2.34, latestPeriod: 'Dec 2025' },
      forecastData: { currentMonthValue: 2.10, currentMonthPeriod: 'Jan 2026' },
      mlPrediction: { yearAverage: 2.34, confidence: 85 },
      target: 2.0,
      trend: { direction: 'improving' as const },
      rollingAverages: []
    },
    focusYear: 2026
  }

  it('should have no accessibility violations', async () => {
    const { container } = render(<RatioCard {...mockProps} />)
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })

  it('should be keyboard navigable', async () => {
    const user = userEvent.setup()
    const onClick = jest.fn()
    render(<RatioCard {...mockProps} onClick={onClick} />)

    const card = screen.getByRole('button', { name: /PS ratio/i })

    // Tab to focus
    await user.tab()
    expect(card).toHaveFocus()

    // Enter to activate
    await user.keyboard('{Enter}')
    expect(onClick).toHaveBeenCalledTimes(1)

    // Space to activate
    await user.keyboard(' ')
    expect(onClick).toHaveBeenCalledTimes(2)
  })

  it('should announce meaningful information to screen readers', () => {
    render(<RatioCard {...mockProps} />)

    const card = screen.getByRole('button')
    expect(card).toHaveAccessibleName(/Professional Services ratio: 2\.34, On track, improving trend/i)
  })

  it('should have sufficient colour contrast', () => {
    const { container } = render(<RatioCard {...mockProps} />)

    // Check primary value (should be black on white)
    const primaryValue = container.querySelector('.text-4xl')
    expect(primaryValue).toHaveClass('text-gray-900')

    // Check status badge (should meet 4.5:1 ratio)
    const statusBadge = screen.getByText(/on track/i)
    expect(statusBadge).toHaveClass('text-green-700')
  })

  it('should not rely on colour alone for status', () => {
    render(<RatioCard {...mockProps} />)

    // Status should have both colour AND text
    const statusBadge = screen.getByText(/on track/i)
    expect(statusBadge).toBeInTheDocument()

    // And a visual indicator (dot)
    const dotElement = statusBadge.previousElementSibling
    expect(dotElement).toHaveClass('rounded-full', 'bg-green-500')
  })
})
```

---

## Usage Example: Complete Implementation

```tsx
// app/(dashboard)/financials/page.tsx

import { CSIOverviewPanel } from '@/components/csi/CSIOverviewPanel'
import { RatioCardGrid } from '@/components/csi/RatioCardGrid'
import { RatioCard } from '@/components/csi/RatioCard'
import { RatioCardSkeleton } from '@/components/csi/RatioCardSkeleton'
import { Suspense } from 'react'

export default async function FinancialsPage() {
  // Fetch data
  const statistics = await fetchCSIStatistics()
  const historicalData = await fetchHistoricalData()

  const ratioOrder: CSIRatioName[] = ['ps', 'sales', 'salesApac', 'maintenance', 'rd', 'ga']

  return (
    <div className="container mx-auto px-4 py-8 space-y-8">
      {/* Page header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
          Financial Performance
        </h1>
        <p className="text-gray-600 dark:text-gray-400 mt-2">
          CSI Operating Ratios for {statistics.focusYear}
        </p>
      </div>

      {/* Calendar year context */}
      <div className="bg-purple-50 dark:bg-purple-900/20 border border-purple-200 dark:border-purple-800 rounded-lg p-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-3">
            <span className="text-2xl font-bold text-purple-600 dark:text-purple-400">
              {statistics.focusYear}
            </span>
            <span className="text-sm text-purple-700 dark:text-purple-300">
              BURC Calendar Year — All metrics measured against {statistics.focusYear} targets
            </span>
          </div>
          <span className="text-xs text-purple-500">
            Data: 2023-{statistics.focusYear - 1}
          </span>
        </div>
      </div>

      {/* Ratio cards grid */}
      <Suspense fallback={
        <RatioCardGrid>
          {ratioOrder.map(ratio => (
            <RatioCardSkeleton key={ratio} />
          ))}
        </RatioCardGrid>
      }>
        <RatioCardGrid>
          {ratioOrder.map(ratio => (
            <RatioCard
              key={ratio}
              ratio={ratio}
              analysis={statistics.ratios[ratio]}
              focusYear={statistics.focusYear}
            />
          ))}
        </RatioCardGrid>
      </Suspense>

      {/* Timeline chart */}
      {historicalData.length > 0 && (
        <div className="bg-white dark:bg-gray-800 rounded-xl p-6 border border-gray-200 dark:border-gray-700">
          <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
            Ratio Timeline
          </h2>
          <CSITimelineChart data={historicalData} />
        </div>
      )}
    </div>
  )
}
```

---

**Last Updated:** 6 January 2026
**Status:** Ready for implementation
**Related Docs:**
- Full analysis: `/docs/ui-ux-analysis-csi-dashboard.md`
- Quick reference: `/docs/ui-ux-quick-reference.md`
