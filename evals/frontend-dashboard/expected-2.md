# frontend-dashboard / prompt-2

## Must decide
- Narrow against the defect cut list: 11 metrics on one screen fails the vanity test and the six-tile ceiling; a donut with more than two plan slices is out; spend against CAC on a dual axis with different units is out, so two panels sharing an x-axis.
- Triage into at most seven questions first; anything that answers no question is cut with the reason recorded.
- If plan mix is genuinely wanted, a sorted bar from zero replaces the donut.

## Must show
- The triage table: 11 metrics in, N questions out, each cut with its vanity-test reason.
- The replacement encodings named concretely: how many tiles survive, donut to sorted bar, dual axis to stacked panels.
- Metric definitions with grain and additivity for whatever survives, before any panel is built.
- chained: `references/metrics-and-filters.md` and the cut list in the skill body.

## Miss if
- Builds the 11-metric screen as asked to avoid friction.
- Keeps the donut or the dual axis with only a color or label tweak.
- Cuts metrics without recording why, or builds panels with no definitions.
