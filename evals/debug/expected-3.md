# debug / prompt-3

## Must decide
- Performance regression: Phase 1 is a timed run of the one model (`uv run dbt run --select <model>` repeated), not a theory session.
- Supposedly means the diff is evidence: `git diff` since the last green run, and the compiled SQL under `target/compiled/`, not the model file.
- Warehouse slowness is measured with `EXPLAIN (ANALYZE, BUFFERS)` (Postgres/AlloyDB) or bytes-scanned/slot-time (BigQuery), then vetted before reporting.

## Must show
- The timing baseline: three runs before, the median, and the same after the fix.
- The compiled SQL difference that explains 40s to 9min: lost partition filter, join fan-out, missing index/cluster, or a new full refresh.
- The regression guard: a test or DQ/duration check that fails when scan or runtime crosses a threshold.
- chained: `~/.agents/skills/data-engineering/references/bigquery.md` (or `postgres.md`) and `~/.agents/skills/benchmark-check/SKILL.md`.

## Miss if
- Recommends add an index or optimize the SQL with no plan or measurement.
- Compares a cold run against a warm cache, or a different date range.
- Fixes it without leaving a check that catches the next 13x regression.
