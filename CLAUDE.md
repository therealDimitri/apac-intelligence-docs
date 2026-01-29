## Project: apac-intelligence-docs

This is a documentation-only repository. No npm, no build, no tests, no deployment.
Skip all quality standards related to `npm test`, `npm run build`, and Netlify verification.
The autonomous workflow for this repo is: Edit → Commit → Push → Document.

## Docs Folder Conventions

- Naming: `TYPE-YYYYMMDD-description.md` (e.g. `DATA-IMPORT-20260128-servicenow-case-stats.md`)
- Types used: `DATA-IMPORT`, `PROCESS`, plus `plans/` subdirectory for design documents
- Always create process docs after completing non-trivial workflows

## Supabase Column Reference (nps_responses)

- Period column: `period` (not `survey_period` or `nps_period`)
- Period format: `Q4 25` (not `Q4 2025`)
- Contact column: `contact_name` (not `respondent_name`)
- Score column: `score` (integer 0-10)
- Feedback column: `feedback` (verbatim text, nullable)
- Client column: `client_name`
- NPS calculation: (promoters - detractors) / total × 100. Promoters = 9-10, Detractors = 0-6.

## Supabase Column Reference (support_case_details)

- Client column: `client_name`
- State column: `state` (values: Closed, Canceled, Resolved, In Progress, On Hold, New)
- Resolution time: `resolution_duration_seconds` (BIGINT, in seconds — divide by 3600 for hours)
- Open cases filter: `state=not.in.(Closed,Canceled,Resolved)`

## Data Integrity Audits

- When changing any number in a document, grep for ALL references before editing
- One value change can cascade to 7+ locations and require recalculating derived metrics
- Always use `replace_all` cautiously — verify the string won't match unintended locations
- After fixing NPS values, recalculate: NPS deltas, threshold averages, Spearman notes, accuracy counts
- When adding automated analysis sections, reconcile figures with earlier manual sections (sample sizes, correlations may differ due to data source coverage)

## CSI Statistical Analysis Pipeline

- Location: `apac-intelligence-v2/scripts/csi_statistical_analysis.py`
- Dependencies: `scripts/requirements-stats.txt` (pandas, numpy, scipy, statsmodels, scikit-learn, seaborn, matplotlib, supabase)
- Run: `python scripts/csi_statistical_analysis.py --period "Q4 25" --output-dir ./docs/plans/csi_statistics`
- Outputs: JSON (machine-readable), Markdown (human-readable), plots/ (correlation heatmap, ROC curves, threshold sensitivity)
- Note: Supabase `support_case_details` has fewer clients with `resolution_duration_seconds` than Excel imports — expect n=4 vs n=11 for support metrics
