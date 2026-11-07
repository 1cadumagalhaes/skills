---
name: dashboard
description: >
  Build, spec or critique an analytics dashboard — KPI tiles, charts, tables, filters and the
  numbers behind them. Use when someone asks for a dashboard, scorecard, monitoring view,
  report page or a native Grafana dashboard, when choosing which metrics and dimensions belong on
  it, when defining filters and date ranges, when a chart is misleading or a number does not
  reconcile, or when reviewing an existing dashboard for honesty and readability. Routes the spec
  to dashboard-spec, the metric rigor to its own reference, and the drawing (or Grafana panel
  configuration) to dashboard-design and references/grafana.md.
---

# Dashboard

A dashboard is an argument made of numbers. Four separate jobs, in order:

| phase | what it answers | where |
|---|---|---|
| **spec** | who reads this, what decision it serves, which questions in priority order | `dashboard-spec` skill |
| **metrics & filters** | is each number defined, complete and comparable | `references/metrics-and-filters.md` (always, for any number shown) |
| **drawing & critique** | which mark for which question, axes, colour, layout | `dashboard-design` skill → `perception.md`, `components.md`, `layout.md`, `qa.md` |
| **native Grafana** | panel type, units, thresholds, variables, time picker, dashboards-as-code | `references/grafana.md` |

Surrounding UI (spacing, focus, contrast, tables, forms) follows `ui-craft` — its `[req]` rules win over any taste rule below. A repo's `DESIGN.md` (see `design-contract`) wins over `dashboard-design`'s house style; the user's stated taste wins over both.

## Non-negotiables

1. **No number without a definition.** Every metric on the page has a card in the spec: name, plain-English definition, formula, grain, additivity class, source table, owner. If it cannot be defined, it does not ship.
2. **Every headline answers "compared to what?"** with exactly one baseline, named on the page: previous period (same elapsed time), target, or historical range. A bare number is decoration.
3. **Nothing derived from rows that do not mean what the label says.** Check join fan-out before trusting a sum (a two-row-per-entity join doubles every total).
4. **Missing is not zero.** No data renders as `—`, never `0`, `$0` or `0%`.
5. **Filters are visible and honest.** The active range and every filter appear in the page text, not only behind a control. "All" must be defined: all values, or all *including unknown* — the two produce different numbers.
6. **The freshness is on the page**: last successful load and the data lag, or the reader assumes real time.
7. **One chart per question.** If a panel answers two questions, it is two panels or one is cut.

## Cut list — these are defects unless the brief demands them

- pie or donut with more than two slices, or any 3D chart
- dual y-axes with different units (use two stacked panels sharing an x-axis)
- a line chart whose y-axis does not start at zero when comparing magnitudes (bars always start at zero)
- gauges, dials and speedometers for a number that has no range
- more than ~6 KPI tiles on one screen; a wall of tiles is a spreadsheet with shadows
- sorting a categorical axis alphabetically when the value is the point
- cumulative and per-period series on the same axis
- green/red alone carrying good/bad, where the metric's direction is not obvious (`lower is better` must be labelled)
- a delta shown as a percentage from a base under ~5 (say "was 1", not "−80 %")

## Process

1. **Spec** (`dashboard-spec`): audience, the decision, questions in priority order, one chart per question, refresh cadence, and what is deliberately left off. Vanity metrics get cut in the spec, not in review.
2. **Define** each metric and filter with `references/metrics-and-filters.md`. Write the metric cards into the spec document, not into chat.
3. **Draw** with `dashboard-design`: `perception.md` for the encoding ladder, `components.md` for tiles/tables/lists, `layout.md` for the grid, `tokens.md` for colour and type. **If the target is native Grafana**, the drawing phase is configuration instead — read `references/grafana.md` first; `components.md` and `tokens.md` do not apply, and panel choice, units, thresholds, variables and the time picker carry the craft.
4. **Build** per `frontend-workflow`; the shell, controls, tables and states follow `ui-craft`.
5. **QA**: `dashboard-design/references/qa.md` plus this file's report.

## Report

When done, state in ≤6 lines: the questions the dashboard answers, the metrics with their grain and additivity class, the filters and their defaults, what was left off and why, the freshness/lag, and any number that could not be reconciled.
