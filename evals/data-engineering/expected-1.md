# data-engineering / prompt-1

## Must decide
- Idempotency first: rerunning any window produces the same rows, via MERGE on a natural key or partition overwrite. Never a bare append.
- Ingest with `dlt` against a persisted watermark (`updated_at` or cursor), advanced only after the target write commits; no `OFFSET` paging.
- Bronze is immutable and partitioned by load date; staging dedupes; the mart reads staging, never raw.
- Backfill runs the same DAG and the same tests, parameterized by window.

## Must show
- A partition filter on every scan and `bq query --dry_run` bytes reported before the query ships.
- DQ checks: freshness, volume, uniqueness, referential integrity, each naming the incident it would have caught.
- chained: `references/airflow.md`, `references/ingestion.md`, `references/bigquery.md`, `references/dbt-and-quality.md`.
- Commands and outputs: `airflow dags test <dag> <date>`, `uv run dbt build --select ...`, dry-run bytes.

## Miss if
- Append-only load with no dedupe, or a second hand-written backfill script.
- `SELECT *` across the table with no partition predicate, or no bytes-scanned number.
- Mart built from raw, or no DQ checks shipped with the DAG.
