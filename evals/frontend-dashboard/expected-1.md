# frontend-dashboard / prompt-1

## Must decide
- Spec gate before any chart: one sentence pinning audience and the decision it drives (who opens it, what they decide, how often), then at most seven prioritized questions, each with the action a bad number triggers.
- One chart per question using the stated mapping: line for trend, sorted bar from zero for comparison, number tile vs target for a current value, scatter for two-measure relationship, table for lookup.
- At most four global filters with explicit defaults, All defined in visible text, and no filter that fans out the metric (category on order-level revenue).

## Must show
- Metric cards for MRR/churn/spend/CAC: name, definition, formula, grain, additivity class, source table, owner; anything undefined flagged `undefined`, never guessed.
- One comparison baseline per headline number; missing data rendered `-`, never `0`.
- Freshness displayed (data as of ...), with refresh cadence matched to the weekly decision.
- A cut list from the vanity test, with reasons per metric.
- chained: `references/metrics-and-filters.md`, then `~/.agents/skills/frontend-dashboard-charts/SKILL.md` for drawing and `~/.agents/skills/frontend-verify/SKILL.md` for screenshots.

## Miss if
- Draws charts before the spec and definitions exist, or invents a metric definition.
- More than six KPI tiles, a pie with more than two slices, dual y-axes, or a truncated bar baseline.
- Cumulative and per-period series on one axis, or a percent delta from a base under 5.
