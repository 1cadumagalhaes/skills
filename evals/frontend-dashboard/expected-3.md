# frontend-dashboard / prompt-3

## Must decide
- Native Grafana path: read `references/grafana.md` and pick panel types from the question mapping (time series, stat vs target, barchart, table), with units and thresholds set per panel.
- Dashboards-as-code: JSON exporter or provisioning YAML committed to the repo and reviewed like code, not click-ops in the UI.
- Variables replace the global filters: at most four, explicit defaults, All semantics defined (`includeAll` plus `allValue`), and a datasource variable only if environments differ.

## Must show
- The dashboard artifact in the repo (provisioning YAML or exported JSON) alongside the filled spec gate.
- Per panel: query bounded by time range or variable, unit, threshold, and the single question it answers.
- Freshness or lag displayed (stat panel or annotation), and a legend naming the comparison baseline.
- QA screenshots of the rendered panels, following `~/.agents/skills/frontend-verify/SKILL.md` practice.
- chained: `references/grafana.md`, `references/metrics-and-filters.md`, `~/.agents/skills/frontend-dashboard-charts/SKILL.md`.

## Miss if
- Produces a click-through UI recipe with no committed dashboard artifact.
- Panels with default units, no thresholds, or no time filter on the query.
- More than four variables, or All left undefined in visible text.
