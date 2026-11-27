# Metrics and filters

The part no chart library will tell you: whether the number is *defined*, *complete* and *comparable*. Read this before putting any figure on a dashboard.

## 1. The metric card

Every metric on the page needs this, written into the spec document, not into chat:

| field | example |
|---|---|
| name | Active sponsors (7-day) |
| plain definition | distinct sponsor entities with ≥1 published asset in the trailing 7 days |
| formula | `count(distinct sponsor_id)` over `assets` where `published_at >= now() - 7d` |
| grain | daily snapshot, computed per day, displayed as a 30-day line |
| additivity | **non-additive** (distinct count) |
| source | `bq://retize.dbt.fct_assets` filtered `status = 'published'` |
| population | excludes internal accounts and test events |
| owner | who answers when the number looks wrong |
| caveats | 3 % of sponsors have null `sponsor_id` (see §5) |

## 2. Additivity classes

The class decides what you may do in SQL and in the chart.

**Additive**: revenue, orders, sessions, events.
Safe to sum over time and over entities. Charts can stack and aggregate freely.

**Semi-additive**: balances and snapshots, such as inventory, MRR, open tickets and wallet balance.
Sum across entities *at a point in time*, **never across time**. A month's revenue is a sum; a month's MRR is the *last* value in the month (or an average), never the sum of daily values. Getting this wrong is the most common way a dashboard overstates by 30×.

**Non-additive**: ratios, rates, averages, distinct counts, percentiles.

- Never sum a ratio. Recompute it from numerator and denominator at the target grain.
- An average of averages must be weighted by its denominator. If you cannot weight it, do not average it.
- Percentiles (p50/p95) **cannot be averaged across windows**. Recompute from the distribution, or aggregate a sketch (t-digest / `HLL_COUNT` / `APPROX_QUANTILES`). A mean of daily p95s is not the p95 of the month.
- Distinct counts cannot be added across overlapping sets. DAU summed over 30 days ≠ MAU. Use a sketch union (`HLL_COUNT.MERGE`, `APPROX_COUNT_DISTINCT`) or recompute over the full window.
- Indices and scores inherit the worst of both.

## 3. Population and denominators

- **State the population** on the page: all accounts / active / paying / one segment. "Conversion rate" means nothing without it.
- **A rate needs its denominator named**: per user, per session, per order. Most "the dashboard is wrong" reports are two different denominators sharing a label.
- **Exclude deliberately**: internal/test accounts, known bots, cancelled-before-start rows. Say so in the metric card. An unexplained exclusion is indistinguishable from a bug.
- **Retention needs cohorts**, not periods: group by first-seen month and count returns, otherwise the aggregate hides churn behind growth.
- **Deduplicate before counting entities.** One entity appearing twice (a fan-out join, a replayed event) doubles a "users" tile without changing revenue.

## 4. Time

- Store UTC, display local, and say which. DST days are 23 or 25 hours. A "daily average" across a DST boundary is wrong by ~4 %.
- **Week start**: ISO (Monday) or US (Sunday). Pick one, state it, keep it consistent across every panel.
- **Grain**: hour / day / week / month. Never mix grains on one axis. To smooth daily noise into a weekly line, use a rolling 7-day mean labelled as such, not a mix of bar widths.
- **Partial current period**: either compare *same elapsed time* (month-to-date vs previous month-to-date), drop the incomplete bucket, or draw it dashed. Comparing a partial month to a full month produces a fake collapse every month.
- **Rolling vs calendar**: "last 30 days" and "this month" are different windows; a filter labelled with one and computed as the other is a silent lie.
- **Cumulative vs per-period** never share an axis.

## 5. Dimensions

- **Cardinality budget**: a dashboard panel shows roughly ≤ 10 categories. Beyond that, top-N plus an explicit `Other (n=…)` bucket, never a 60-slice rainbow where the last 40 are unreadable.
- **Unknown is a category.** Null/unknown must appear as its own bucket or be excluded *and stated*. Silently dropping nulls is usually where the missing revenue went.
- **Slowly changing attributes**: "region as of the event" and "region as of today" give different totals after a reorg. Name which one you used.
- **Fan-out is the classic trap.** Joining a fact to a dimension that is not unique on the join key multiplies rows and inflates every sum. Pre-aggregate or dedupe; verify with a row-count check against the un-joined fact.
- **Grain alignment**: do not filter an event-level fact by a dimension that only exists at order level without re-aggregating first.
- **Mixed-grain joins** (daily fact × hourly dimension) either duplicate or lose rows. Align on the coarser grain explicitly.

## 6. Filters

- **Defaults are a statement.** "Last 30 days, all channels, all sponsors" is what the dashboard *is*. Document it, and show it in the page text, not only inside a control.
- **"All" is ambiguous.** All values, or all *including unknown*? Two different numbers under one label. Define it once, apply it everywhere.
- **Filter state in the URL** so a view is shareable and reproducible. A dashboard you cannot link to is a screenshot.
- **Changing the range must move the baseline.** If the comparison period does not follow the filter, every delta on the page is comparing the wrong things.
- **Empty results explain themselves**: which filter excluded everything, and one click to reset. A blank panel reads as a broken pipeline.
- **Cascading filters** need a fixed order and a visible one (country → city), or the user cannot predict what a click will do.
- **Cross-filter vs global filter** are different tools; do not let a click on a chart silently change a global range.
- **SQL trap**: `channel != 'paid'` silently drops rows where `channel IS NULL`. Write `channel IS DISTINCT FROM 'paid'` or add the null branch deliberately.
- **Saved views** for recurring questions beat re-clicking filters every morning.

## 7. Freshness

- Show **last successful load** and the **lag** ("data through 14:00, 8 min lag"). Without it every reader assumes real time.
- Distinguish **"no new data"** from **"pipeline late"**; both render as a flat line at the right edge.
- **Backfills change history.** Say the re-processing window (e.g. "last 7 days may be revised") so a number moving is explainable.
- **Partial-day handling** belongs next to freshness, not in a footnote.

## 8. Reconciliation

- Every page total must reconcile to one named source-of-truth query. Keep the query next to the metric card.
- Check **row counts** before trusting sums: one join, one fan-out, one duplicated event.
- Round **once, at render**. Rounding in the pipeline compounds and contradicts other panels.
- Units and currency explicit in the label, not in a legend.
- Missing renders as `—`. Never `0`, `$0`, `0 %`, `NaN`, or an empty cell that looks like zero.
- Small bases: a delta from a base under ~5 reads "was 1", never "−80 %".
- The five SQL errors behind most "the numbers changed" tickets: `NOT IN` with a nullable column, integer division truncating cents, `COUNT(*)` where `COUNT(entity)` was meant, `WHERE` vs `HAVING` on aggregates, and `DATE(ts)` vs `TIMESTAMP(ts)` timezone shifts.
