# Airflow

Airflow is an orchestrator, not a compute engine: its job is to decide *what runs when* and to make failure visible. Heavy transformation belongs in the warehouse.

## The DAG file

- `[req]` **No top-level code that touches the network, the database or a file.** The scheduler re-parses DAG files continuously; an API call at import time is an outage that grows with DAG count. Everything dynamic goes inside a task or a `@task`.
- `[conv]` One DAG file per pipeline, with `start_date` fixed in the past and never `datetime.now()`. A moving start date rewrites history on every parse.
- `[conv]` `catchup=False` unless you genuinely want history re-run, and `max_active_runs` bounded.
- `[conv]` `schedule` explicit (`"0 3 * * *"`, `timedelta`, or a dataset/asset); `None` for manually triggered DAGs, not the old `@daily` default surprises.

## Idempotency and the logical date

- `[req]` A task's output is a function of its **data interval** (`logical_date` / `data_interval_start..end`), not of `datetime.now()`. Everything that writes must key on the interval it was given, so a retry or a backfill overwrites the same partition instead of appending a second copy.
- `[req]` Writes are partition-replace (`WRITE_TRUNCATE` on the target partition, `DELETE`+`INSERT` in the same transaction, or `MERGE` on the natural key), never blind insert.
- `[conv]` Backfill uses the same DAG and the same tests: `airflow dags backfill -s ... -e ...`. A separate backfill script is a second implementation that drifts.
- `[conv]` Late-arriving data gets a re-processing window (re-run the last N days), not a hope.

## Retries and failure

- `[conv]` Retries are for transient faults: `retries=2–3`, `retry_delay` with exponential backoff, and `retry_exponential_backoff=True`. Retrying a deterministic data error burns the window.
- `[conv]` Fail loudly with a message that names the source, the interval and the check that failed. A task that logs a warning and returns success is worse than a crash.
- `[conv]` One notification per failed DAG run (`on_failure_callback` or `default_args`), never one per retry. Alert on *absence* of success too, because a DAG that never runs looks identical to one that succeeds.
- `[conv]` Distinguish "pipeline broken" from "no new data". Both render as an empty table.

## Operators and waiting

- `[conv]` Prefer operators that push work to the target system: `BigQueryInsertJobOperator`, `SQLExecuteQueryOperator`, dbt operators. A Python task that pulls 10 M rows to transform them is a memory incident.
- `[conv]` Sensors: `mode="reschedule"` or the deferrable variant, always with `timeout` and `poke_interval`. A default-mode sensor holds a worker slot for hours.
- `[conv]` Deferrable operators free the worker while waiting on a cloud API; use them for anything slow (BigQuery jobs, GCS, S3).
- `[conv]` No `time.sleep` in a task. Sleeping is what the scheduler is for.

## Data passing

- `[req]` XCom is for **pointers and small metadata** (a path, a row count, a job id), not for dataframes. XCom is stored in the metadata database and is not a transport.
- `[conv]` Pass a GCS path or a table name between tasks; the data stays where it belongs.

## Concurrency and isolation

- `[conv]` Pools sized to what the *source* can take, not to what Airflow can schedule. One pool per fragile upstream.
- `[conv]` `max_active_tasks` per DAG bounded, so a backfill does not saturate the warehouse.
- `[conv]` Dynamic task mapping for fan-out over a known list (files, tenants), with the list computed inside a task.

## Testing

- `[conv]` `airflow dags list-import-errors` and a DAG-parse test in CI. That catches the top-level-code class of bug before deploy.
- `[conv]` `dag.test()` or a task-level test against a dev connection for the pieces with logic.
- `[conv]` Unit-test the callables (SQL builders, parsers) as plain functions; the DAG is wiring and needs no test of its own.

## Performance of the scheduler

- `[conv]` Fewer, larger DAGs parse faster than hundreds of tiny ones; avoid `schedule_interval` per-minute unless the work truly is per-minute.
- `[conv]` Keep the metadata DB healthy: a slow scheduler is often a bloated `task_instance`/`xcom` table, and purging is a maintenance task, not an afterthought.
