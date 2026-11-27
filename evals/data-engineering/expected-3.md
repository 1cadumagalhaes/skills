# data-engineering / prompt-3

## Must decide
- Measure before changing: current bytes scanned from the dry run or `INFORMATION_SCHEMA.JOBS`, then the same measurement after.
- Cost work is partition pruning, column pruning, clustering, or a pre-aggregate. `LIMIT` is not a cost fix.
- Benchmarks are vetted before they are reported, so chain the leaf `~/.agents/skills/benchmark-check/SKILL.md`.

## Must show
- chained: `references/bigquery.md` for the rewrite and `~/.agents/skills/benchmark-check/SKILL.md` for the numbers.
- The `bq query --dry_run` command to run before and after, on the same date range, and the R$/TB arithmetic applied to the given baseline (3.1 TB per run, 2 runs a day) rather than a made-up after-number.
- The specific change named: partition predicate on the date column, explicit column list, clustering key, or pre-aggregated table.
- The remaining scan floor stated honestly, or the reason it cannot go lower without changing grain.

## Miss if
- Reports a post-change byte count it never measured.
- Reports should be cheaper with no bytes number and no measurement command.
- Compares against a different query or date range, making the baselines non-comparable.
- Treats `SELECT *` plus `LIMIT 500` as the cost problem: the scan happens before the limit, and only a scan reduction changes the bill.
- Keeps `SELECT *`, or drops the partition filter to make the SQL look simpler.
