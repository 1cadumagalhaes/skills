---
name: frontend-dashboard
description: "Spec, build, or critique analytics dashboards and Grafana panels: audience, decision, defined metrics, honest filters, and visual encoding. Use when designing or reviewing dashboards."
cluster: frontend
tier: root
---

# Dashboard

| When | Read |
|---|---|
| Choosing chart forms, layout, and visual encoding | `~/.agents/skills/frontend-dashboard-charts/SKILL.md` |
| Applying interface accessibility and CSS rules | `~/.agents/skills/frontend-rules/SKILL.md` |
| Preparing a dashboard specification | `references/dashboard-spec/` |

A dashboard is an argument made of numbers. Start from the audience and decision before opening any table or charting tool.

| Phase | Purpose | Reference |
|---|---|---|
| Spec gate | Audience, one decision, prioritized questions, cut list | Inline below; template in `references/dashboard-spec/` |
| Metrics and filters | Metric cards, grain, additivity, filter behavior | `references/metrics-and-filters.md` |
| Drawing and QA | Mark chooser, axes, color scales, grid layout, screenshot QA | `~/.agents/skills/frontend-dashboard-charts/SKILL.md` |
| Native Grafana | Panel types, units, thresholds, variables, dashboards-as-code | `references/grafana.md` |

For custom web app dashboards, follow `frontend-build` and `frontend-rules` (`[req]` rules always win). A repo `DESIGN.md` (`frontend-design-doc`) overrides generic style defaults.

## Spec gate before drawing

1. **Pin audience and decision in one sentence:** who opens this, what decision they make, and how often. Derive with `[assumption]` tags in headless runs; if neither can be derived, stop and ask once.
2. **List at most seven questions in priority order**, each paired with the action triggered when the number goes bad. Question 1 sits top-left and must be answerable without clicking.
3. **Assign one chart per question.** Time trend uses line chart; category comparison uses sorted bar chart from zero; single current value vs target uses number tile with comparison; distribution uses histogram or box plot; two-measure relationship uses scatter plot; exact lookup uses table.
4. **Cap global filters at four with explicit defaults.** Exclude any filter that fans out a metric (`category` on order-level revenue) and document why.
5. **Match refresh cadence to decision cadence** and display freshness ("data as of" timestamp) on the page.
6. **Write a cut list** using the vanity test ("if this doubled tomorrow, what changes?"). Cut cumulative all-time totals, unlinked traffic counts, and uninfluenceable numbers.

## Non-negotiables

1. **No number ships without a written definition.** Record name, plain-English definition, formula, grain, additivity class, source table, and owner in the spec. Flag missing ones `undefined` rather than guessing.
2. **Every headline number names one comparison baseline** on the page (previous elapsed period, target, or historical range).
3. **Verify join grain before summing.** Never aggregate across a one-to-many fan-out join.
4. **Missing is not zero.** Render absent data as `-` or explicit empty state, never `0`, `$0`, or `0%`.
5. **Show active filters and define "All"** directly in visible page text (whether "All" includes unknown/null values).
6. **Display last successful load and data lag** on the page so stale data never reads as real time.
7. **Keep one question per panel.** Split multi-question charts or cut the secondary metric.

## Defect cut list

Fix or reject dashboards containing:

- Pie or donut charts with more than two slices, or any 3D chart
- Dual y-axes with different units (stack two panels sharing an x-axis instead)
- Truncated y-axes on bar charts or non-zero-baseline magnitude comparisons
- Gauges or speedometers for unbounded metrics
- More than six KPI tiles on one screen
- Alphabetically sorted categorical bars when ranking by value is the point
- Cumulative and per-period series on the same axis
- Green/red color alone without direction labels (`lower is better`)
- Percentage deltas from a base under 5 (write `was 1`, not `-80%`)

## Process and completion bar

1. Confirm the spec gate and write metric cards (`references/metrics-and-filters.md`).
2. For native Grafana, read `references/grafana.md` and configure panels, variables, units, and dashboards-as-code. For custom UI, read `~/.agents/skills/frontend-dashboard-charts/SKILL.md` (`perception.md`, `components.md`, `layout.md`, `qa.md`) and build via `frontend-build`.
3. Inspect screenshots via `frontend-verify` (or rendered Grafana panels).
4. Close with a concise summary (6 lines max): questions answered, metrics with grain and additivity, filters and defaults, cut list with reasons, freshness SLA, and any unreconciled numbers.
