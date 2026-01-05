-- Seed Data for Regional Benchmarks Table
-- Created: 2026-01-05
-- Purpose: Populate regional_benchmarks with realistic demonstration data
-- Instructions: Run this AFTER executing 20260105_regional_benchmarks.sql

-- Clear existing data (if any)
DELETE FROM regional_benchmarks;

-- 2025-Q4 Data
-- APAC Region
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit) VALUES
('APAC', '2025-Q4', 'NRR', 108.5, 110.0, 107.2, '%'),
('APAC', '2025-Q4', 'GRR', 95.2, 96.0, 94.8, '%'),
('APAC', '2025-Q4', 'Rule of 40', 42.3, 45.0, 41.1, '%'),
('APAC', '2025-Q4', 'DSO', 52.0, 45.0, 54.5, 'days'),
('APAC', '2025-Q4', 'Churn Rate', 4.8, 4.0, 5.2, '%'),
('APAC', '2025-Q4', 'ARR Growth', 23.5, 25.0, 22.8, '%'),
('APAC', '2025-Q4', 'Customer Acquisition Cost', 12500.00, 11000.00, 13200.00, '$'),
('APAC', '2025-Q4', 'Lifetime Value', 145000.00, 150000.00, 142000.00, '$'),
('APAC', '2025-Q4', 'Revenue per Client', 285000.00, 300000.00, 278000.00, '$'),
('APAC', '2025-Q4', 'Gross Margin', 72.5, 75.0, 71.8, '%'),
('APAC', '2025-Q4', 'Operating Margin', 18.8, 20.0, 18.3, '%'),
('APAC', '2025-Q4', 'EBITDA Margin', 24.2, 25.0, 23.7, '%');

-- EMEA Region
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit) VALUES
('EMEA', '2025-Q4', 'NRR', 112.3, 110.0, 111.5, '%'),
('EMEA', '2025-Q4', 'GRR', 96.8, 96.0, 96.2, '%'),
('EMEA', '2025-Q4', 'Rule of 40', 47.8, 45.0, 46.9, '%'),
('EMEA', '2025-Q4', 'DSO', 38.5, 45.0, 39.2, 'days'),
('EMEA', '2025-Q4', 'Churn Rate', 3.2, 4.0, 3.8, '%'),
('EMEA', '2025-Q4', 'ARR Growth', 27.2, 25.0, 26.5, '%'),
('EMEA', '2025-Q4', 'Customer Acquisition Cost', 10800.00, 11000.00, 11200.00, '$'),
('EMEA', '2025-Q4', 'Lifetime Value', 162000.00, 150000.00, 158000.00, '$'),
('EMEA', '2025-Q4', 'Revenue per Client', 312000.00, 300000.00, 305000.00, '$'),
('EMEA', '2025-Q4', 'Gross Margin', 76.2, 75.0, 75.5, '%'),
('EMEA', '2025-Q4', 'Operating Margin', 20.6, 20.0, 20.4, '%'),
('EMEA', '2025-Q4', 'EBITDA Margin', 26.8, 25.0, 26.2, '%');

-- Americas Region
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit) VALUES
('Americas', '2025-Q4', 'NRR', 115.7, 110.0, 114.2, '%'),
('Americas', '2025-Q4', 'GRR', 97.5, 96.0, 97.1, '%'),
('Americas', '2025-Q4', 'Rule of 40', 52.1, 45.0, 50.8, '%'),
('Americas', '2025-Q4', 'DSO', 42.3, 45.0, 43.8, 'days'),
('Americas', '2025-Q4', 'Churn Rate', 2.5, 4.0, 2.9, '%'),
('Americas', '2025-Q4', 'ARR Growth', 31.5, 25.0, 30.2, '%'),
('Americas', '2025-Q4', 'Customer Acquisition Cost', 9500.00, 11000.00, 9800.00, '$'),
('Americas', '2025-Q4', 'Lifetime Value', 178000.00, 150000.00, 172000.00, '$'),
('Americas', '2025-Q4', 'Revenue per Client', 345000.00, 300000.00, 338000.00, '$'),
('Americas', '2025-Q4', 'Gross Margin', 78.9, 75.0, 78.2, '%'),
('Americas', '2025-Q4', 'Operating Margin', 20.6, 20.0, 20.6, '%'),
('Americas', '2025-Q4', 'EBITDA Margin', 27.5, 25.0, 27.1, '%');

-- Global Aggregate
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit) VALUES
('Global', '2025-Q4', 'NRR', 112.2, 110.0, 111.0, '%'),
('Global', '2025-Q4', 'GRR', 96.5, 96.0, 96.0, '%'),
('Global', '2025-Q4', 'Rule of 40', 47.4, 45.0, 46.3, '%'),
('Global', '2025-Q4', 'DSO', 44.3, 45.0, 45.8, 'days'),
('Global', '2025-Q4', 'Churn Rate', 3.5, 4.0, 4.0, '%'),
('Global', '2025-Q4', 'ARR Growth', 27.4, 25.0, 26.5, '%'),
('Global', '2025-Q4', 'Customer Acquisition Cost', 10933.00, 11000.00, 11400.00, '$'),
('Global', '2025-Q4', 'Lifetime Value', 161667.00, 150000.00, 157333.00, '$'),
('Global', '2025-Q4', 'Revenue per Client', 314000.00, 300000.00, 307000.00, '$'),
('Global', '2025-Q4', 'Gross Margin', 75.9, 75.0, 75.2, '%'),
('Global', '2025-Q4', 'Operating Margin', 20.0, 20.0, 19.8, '%'),
('Global', '2025-Q4', 'EBITDA Margin', 26.2, 25.0, 25.7, '%');

-- 2025-YTD Data
-- APAC Region
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit) VALUES
('APAC', '2025-YTD', 'NRR', 107.8, 110.0, 105.5, '%'),
('APAC', '2025-YTD', 'GRR', 94.9, 96.0, 94.2, '%'),
('APAC', '2025-YTD', 'Rule of 40', 41.5, 45.0, 39.8, '%'),
('APAC', '2025-YTD', 'DSO', 53.2, 45.0, 56.8, 'days'),
('APAC', '2025-YTD', 'Churn Rate', 5.1, 4.0, 5.8, '%'),
('APAC', '2025-YTD', 'ARR Growth', 22.9, 25.0, 21.2, '%'),
('APAC', '2025-YTD', 'Customer Acquisition Cost', 12800.00, 11000.00, 13800.00, '$'),
('APAC', '2025-YTD', 'Lifetime Value', 143500.00, 150000.00, 138000.00, '$'),
('APAC', '2025-YTD', 'Revenue per Client', 281000.00, 300000.00, 272000.00, '$');

-- EMEA Region
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit) VALUES
('EMEA', '2025-YTD', 'NRR', 111.5, 110.0, 109.8, '%'),
('EMEA', '2025-YTD', 'GRR', 96.5, 96.0, 95.9, '%'),
('EMEA', '2025-YTD', 'Rule of 40', 46.8, 45.0, 45.2, '%'),
('EMEA', '2025-YTD', 'DSO', 39.8, 45.0, 41.2, 'days'),
('EMEA', '2025-YTD', 'Churn Rate', 3.5, 4.0, 4.1, '%'),
('EMEA', '2025-YTD', 'ARR Growth', 26.5, 25.0, 25.2, '%'),
('EMEA', '2025-YTD', 'Customer Acquisition Cost', 11100.00, 11000.00, 11500.00, '$'),
('EMEA', '2025-YTD', 'Lifetime Value', 159000.00, 150000.00, 154000.00, '$'),
('EMEA', '2025-YTD', 'Revenue per Client', 308000.00, 300000.00, 298000.00, '$');

-- Americas Region
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit) VALUES
('Americas', '2025-YTD', 'NRR', 114.8, 110.0, 112.5, '%'),
('Americas', '2025-YTD', 'GRR', 97.2, 96.0, 96.8, '%'),
('Americas', '2025-YTD', 'Rule of 40', 51.2, 45.0, 49.5, '%'),
('Americas', '2025-YTD', 'DSO', 43.5, 45.0, 44.8, 'days'),
('Americas', '2025-YTD', 'Churn Rate', 2.8, 4.0, 3.2, '%'),
('Americas', '2025-YTD', 'ARR Growth', 30.5, 25.0, 29.2, '%'),
('Americas', '2025-YTD', 'Customer Acquisition Cost', 9800.00, 11000.00, 10200.00, '$'),
('Americas', '2025-YTD', 'Lifetime Value', 175000.00, 150000.00, 168000.00, '$'),
('Americas', '2025-YTD', 'Revenue per Client', 340000.00, 300000.00, 332000.00, '$');

-- Global Aggregate
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit) VALUES
('Global', '2025-YTD', 'NRR', 111.4, 110.0, 109.3, '%'),
('Global', '2025-YTD', 'GRR', 96.2, 96.0, 95.6, '%'),
('Global', '2025-YTD', 'Rule of 40', 46.5, 45.0, 44.8, '%'),
('Global', '2025-YTD', 'DSO', 45.5, 45.0, 47.6, 'days'),
('Global', '2025-YTD', 'Churn Rate', 3.8, 4.0, 4.4, '%'),
('Global', '2025-YTD', 'ARR Growth', 26.6, 25.0, 25.2, '%'),
('Global', '2025-YTD', 'Customer Acquisition Cost', 11233.00, 11000.00, 11833.00, '$'),
('Global', '2025-YTD', 'Lifetime Value', 159167.00, 150000.00, 153333.00, '$'),
('Global', '2025-YTD', 'Revenue per Client', 309667.00, 300000.00, 300667.00, '$');

-- 2025-FY (Full Year) Data
-- APAC Region
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit) VALUES
('APAC', '2025-FY', 'NRR', 107.8, 110.0, 104.2, '%'),
('APAC', '2025-FY', 'GRR', 94.9, 96.0, 93.8, '%'),
('APAC', '2025-FY', 'Rule of 40', 41.5, 45.0, 38.5, '%'),
('APAC', '2025-FY', 'DSO', 53.2, 45.0, 58.5, 'days'),
('APAC', '2025-FY', 'Churn Rate', 5.1, 4.0, 6.2, '%'),
('APAC', '2025-FY', 'ARR Growth', 22.9, 25.0, 19.8, '%');

-- EMEA Region
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit) VALUES
('EMEA', '2025-FY', 'NRR', 111.5, 110.0, 108.5, '%'),
('EMEA', '2025-FY', 'GRR', 96.5, 96.0, 95.2, '%'),
('EMEA', '2025-FY', 'Rule of 40', 46.8, 45.0, 43.8, '%'),
('EMEA', '2025-FY', 'DSO', 39.8, 45.0, 42.5, 'days'),
('EMEA', '2025-FY', 'Churn Rate', 3.5, 4.0, 4.8, '%'),
('EMEA', '2025-FY', 'ARR Growth', 26.5, 25.0, 23.5, '%');

-- Americas Region
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit) VALUES
('Americas', '2025-FY', 'NRR', 114.8, 110.0, 111.2, '%'),
('Americas', '2025-FY', 'GRR', 97.2, 96.0, 96.2, '%'),
('Americas', '2025-FY', 'Rule of 40', 51.2, 45.0, 48.2, '%'),
('Americas', '2025-FY', 'DSO', 43.5, 45.0, 45.8, 'days'),
('Americas', '2025-FY', 'Churn Rate', 2.8, 4.0, 3.8, '%'),
('Americas', '2025-FY', 'ARR Growth', 30.5, 25.0, 27.8, '%');

-- Global Aggregate
INSERT INTO regional_benchmarks (region, period, metric_name, metric_value, target_value, previous_value, unit) VALUES
('Global', '2025-FY', 'NRR', 111.4, 110.0, 108.0, '%'),
('Global', '2025-FY', 'GRR', 96.2, 96.0, 95.1, '%'),
('Global', '2025-FY', 'Rule of 40', 46.5, 45.0, 43.5, '%'),
('Global', '2025-FY', 'DSO', 45.5, 45.0, 48.9, 'days'),
('Global', '2025-FY', 'Churn Rate', 3.8, 4.0, 4.9, '%'),
('Global', '2025-FY', 'ARR Growth', 26.6, 25.0, 23.7, '%');

-- Verify data loaded correctly
SELECT
  region,
  period,
  COUNT(*) as metric_count
FROM regional_benchmarks
GROUP BY region, period
ORDER BY region, period;

-- Show sample data
SELECT * FROM regional_benchmarks
WHERE period = '2025-Q4'
ORDER BY region, metric_name
LIMIT 20;
