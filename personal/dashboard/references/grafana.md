# Grafana (native dashboards)

In Grafana you do not lay out pixels — you choose a **panel type, a query, a unit, a threshold and a variable**. The craft moves from CSS to configuration, so the failure modes are different. Everything in `metrics-and-filters.md` still applies; this file is what changes.

## Strategy first

- **USE** (utilization, saturation, errors) for resources — CPU, memory, disk, network. Reports *causes*.
- **RED** (rate, errors, duration) for services. Reports *symptoms*; alert on these.
- **Four Golden Signals** when you can only afford four numbers: latency, traffic, errors, saturation.
- One question per panel. If the title needs an "and", split it.
- Name dashboards by owner and subject; tag them; put `TEST`/`TMP` in experiments and delete them afterwards.

## Panel choice (question → panel)

| question | panel |
|---|---|
| how does it move over time | **Time series** (lines; bars only for discrete buckets) |
| one number, with a state | **Stat** with thresholds — not a gauge |
| distribution of values | **Histogram**; over time, **Heatmap** |
| compare categories | **Bar gauge** (horizontal) or **Table** |
| top N of many | **Table** sorted, or Bar gauge with a row limit |
| state changes over time | **State timeline** / **Status history** |
| where it's happening | **Geomap** |
| explain, link, annotate | **Text** panel + dashboard links |

Gauge/speedometer panels are the Grafana equivalent of our "gauge" defect: they encode one number in a large area, need a fake range, and read slower than a bold figure. Use a Stat unless the metric genuinely has a bounded physical range (a disk at 0–100 % counts).

## Units, decimals, missing

- Set the unit **per panel**, explicitly: `percentunit` for 0–1 ratios, `percent` for 0–100, `currencyUSD` for money, `s`/`ms` for duration, `bytes`, `reqps`. Leaving `short` on money is how a dashboard reports `5k` dollars.
- Set decimals to what the decision needs (0 for money in cards, 1–2 for percentages), and keep it consistent across panels showing the same quantity.
- Choose the **no-data** behaviour deliberately: `—` (or "no data"), never a zero-looking line. In Time series, "No value: connected" draws a straight line through a gap — usually a lie.
- Same unit and same scale across panels side by side, or the reader compares apples to fonts.

## Axes and thresholds

- Bars start at zero. Time series for latency/cost may not, but then set `min`/`max` explicitly so two panels compare honestly.
- Log scale only for orders of magnitude, and label it in the title.
- Thresholds encode *direction*: for lower-is-better (latency, error rate, cost) invert the colour steps. Two neutral steps plus one alert step beat a rainbow.
- Never let colour carry the meaning alone — set the stat's value text and add the word (`ok` / `slow` / `failing`).

## Variables (the part that most often lies)

- **`All` is ambiguous.** With "Include All", the variable expands to `$__all` (PromQL: `=~".*"`; SQL: an `IN (...)` list that may exclude `NULL`). Decide and document whether `All` means *all values* or *all including unknown* — the two give different totals.
- **Multi-value** needs the right expansion: `=~"$var"` in PromQL, `IN (${var:sqlstring})` in SQL. A bare `$var` with three selections silently uses only one.
- **High-cardinality variables are a performance bug**: `All` over 500 nodes fans out the query. Constrain the variable query (`label_values(...)`, a `WHERE` filter), and default to a small selection instead of `All`.
- **Data source as a variable** (and cluster/environment) so one dashboard serves dev and prod instead of one dashboard per environment.
- Viewers change variables, never panels. If answering a recurring question requires editing, the dashboard is missing a variable.

## Time

- Dashboard time range **and** refresh are part of the spec. 5 s refresh on a monthly metric burns the datasource for nothing.
- Bind queries to the picker: `$__timeFilter(ts)` for SQL datasources, `$__timeFrom`/`$__timeTo` for literal bounds. A query with a hardcoded window ignores the time picker — the classic "why doesn't the range change anything".
- Prometheus rates: use `$__rate_interval`, not a hardcoded `[5m]`. Hardcoded windows go empty at long ranges and unreadably noisy at short ones.
- Bucketing: `$__interval` / `$__interval_ms` with a **min interval** set, so a 30-day range does not scan per-second data.
- Timezone is a dashboard setting (UTC vs browser). Pick one for shared dashboards; mixed teams read different hours.
- The in-progress bucket always droops — annotate or exclude the last interval when the number matters.

## Tables and transformations

- Sort by the metric, not alphabetically. Right-align numbers; explicit column widths; the unit in the header.
- `Organize fields` to hide noise — never hide the identity column; a table of numbers with no keys is a puzzle.
- `Join by field` can **duplicate rows** (fan-out) exactly like a SQL join. Verify row counts after any join.
- `Reduce` for totals per series; prefer datasource-side aggregation when the raw series is large.
- Cell types: `auto` for text, `gauge`/`sparkline` only when the trend is the point.

## Reproducibility (non-negotiable for you)

- Dashboards live **as code**: Jsonnet/grafonnet or grafanalib, or the Terraform provider. Browser-clicked dashboards cannot be reviewed, diffed or restored.
- Version-control the generated JSON; provision to a test instance first, promote only what proved useful.
- No browser editing on production dashboards. Variable changes are the allowed interaction.
- Alerts belong to the dashboards, not to memory: an alert should link to the dashboard that explains it.

## Anti-patterns

- a wall of Stat panels with no hierarchy (that is a spreadsheet with shadows)
- auto-refresh faster than the data's actual freshness
- hardcoded `rate(x[5m])` and hardcoded time filters
- `All` on a high-cardinality variable
- one dashboard per environment, per node, or per customer
- legends with 20 unsorted series and `Value` off
- "no data" drawn as zero
- no annotations for deploys, incidents or config changes — then nothing explains a step change
- panels that answer a question nobody asks at 3 a.m.
