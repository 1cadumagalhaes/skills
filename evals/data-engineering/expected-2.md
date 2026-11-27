# data-engineering / prompt-2

## Must decide
- Refuse the copy: backfills run through the same DAG, code, and tests as the daily run.
- Parameterize the window (`--conf '{"start":...,"end":...}'` or DAG params), keep the task graph identical, and clear the affected task instances instead of scripting the load.
- Idempotency is what makes the rerun safe: prove a second run of the same window adds zero rows.

## Must show
- The concrete invocation: `airflow dags test <dag> <logical-date>` for one window, then clear/backfill for the range, with the dates named.
- The dedupe/MERGE key that makes the rerun a no-op, plus before/after row counts on the second run.
- DQ checks for the recovered window (freshness, volume) passing before the mart refresh.
- chained: `references/airflow.md` (idempotent task design) and `references/dbt-and-quality.md` (checks).

## Miss if
- Writes or endorses the one-off script with hardcoded dates.
- Runs the range backfill without first proving reproducibility on one window.
- Refreshes the mart before recovered partitions pass their checks.
