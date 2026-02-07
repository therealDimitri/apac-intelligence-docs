## Project: apac-intelligence-docs

This is a documentation-only repository. No npm, no build, no tests, no deployment.
Skip all quality standards related to `npm test`, `npm run build`, and Netlify verification.
The autonomous workflow for this repo is: Edit → Commit → Push → Document.

## Knowledge Base

`knowledge-base/` contains the master plan for the APAC Intelligence platform — 8 sections, 21 files. This is the primary context source for Claude Code sessions.

- **Master index**: `knowledge-base/README.md` — section overview, architecture diagram, tech stack
- **Maintaining**: When features are added/changed in v2, update the relevant knowledge base section
- **Adding files**: Follow existing naming conventions (`kebab-case.md`), update the section table in README.md
- **Feature status**: `05-feature-inventory/phase-audit.md` tracks LIVE/WIRED/scaffolded counts — update after shipping features
- **Database changes**: After migrations, update `06-database/tables.md` and `06-database/migrations.md`
- **Quick wins**: Cross off completed items in `08-roadmap/quick-wins.md`

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
- **NPS display format**: Always show as score between -100 and +100 (e.g., "NPS: +45" or "NPS: -12"), NEVER as individual response score (0-10). Individual scores are just "score" not "NPS".
- **Always verify NPS with SQL** — don't calculate manually from score lists (error-prone). Use:
  ```sql
  SELECT period, ROUND(((COUNT(*) FILTER (WHERE score >= 9))::numeric -
    (COUNT(*) FILTER (WHERE score <= 6))::numeric) / COUNT(*)::numeric * 100) as nps
  FROM nps_responses WHERE client_name ILIKE '%Client%' GROUP BY period
  ```

## Supabase Column Reference (support_case_details)

- Client column: `client_name`
- State column: `state` (values: Closed, Canceled, Resolved, In Progress, On Hold, New)
- Resolution time: `resolution_duration_seconds` (BIGINT, in seconds — divide by 3600 for hours)
- Open cases filter: `state=not.in.(Closed,Canceled,Resolved)`

## Supabase Column Reference (support_sla_metrics)

- Open cases: `backlog` (not `open_cases`)
- SLA compliance: `resolution_sla_percent` (not `sla_compliance_percent`)
- CSAT score: `satisfaction_score` (scale 0-5, not `csat_score`)
- Aging buckets: `aging_0_7d`, `aging_8_30d`, `aging_31_60d`, `aging_61_90d`, `aging_90d_plus`
- Support health score: **calculated**, not stored - use formula: `(SLA% × 0.4) + (CSAT% × 0.3) + (backlog_factor × 0.3)`

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
- Client name matching: Uses `client_name_aliases` table for cross-table joins (commit 51d517a, 2026-01-29)
- **Fixed (2026-01-29):** Support metric sample size increased from n=4 to n=11 by using `client_name_aliases` for client name normalization. Root cause was exact string matching between tables with different naming conventions (e.g., "Barwon Health Australia" vs "Barwon Health", "GHA" vs "Gippsland Health Alliance (GHA)")

## Statistical Review Checklist

When reviewing CSI model validation results, check for these caveats:
- Power analysis: What's the minimum detectable effect? (n=13 → d ≥ 1.15 only)
- CI crossing zero: Bootstrap CIs with small n may span zero despite strong point estimates
- Perfect AUC (1.000): Suggests overfitting or methodological circularity — validate on held-out data
- Sensitivity vs specificity trade-off: 66.7% sensitivity = 1 in 3 at-risk clients missed
- Exploratory thresholds: Optimal cutoffs derived from same data as validation are provisional

## PDF Export

- Preferred method: Open in Typora, then File → Export → PDF
- Open in Typora: `open -a Typora <file.md>`
- Trigger export via AppleScript: `osascript -e 'tell application "Typora" to activate' -e 'delay 0.5' -e 'tell application "System Events" to keystroke "e" using {command down, shift down}'`
- No pdflatex installed — avoid pandoc `--pdf-engine=pdflatex`

## Git Workflow with Remote Changes

- When push fails due to remote changes: `git stash && git pull --rebase && git push && git stash pop`
- Ignore .DS_Store files in commits - they're local macOS metadata
