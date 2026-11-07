# BigQuery

The bill is bytes scanned, the speed is bytes scanned, and the failure mode is a query that silently reads ten years of history. Everything here follows from that.

## Partitioning and clustering

- `[req]` Fact tables are partitioned (`PARTITION BY DATE(ts)` or `_PARTITIONDATE`), and the table sets `require_partition_filter = TRUE` so a missing filter fails instead of scanning everything.
- `[conv]` Cluster on the columns most queries filter or group by, in order of use. Clustering helps most when the leading column is filtered by equality/`IN`.
- `[conv]` Partition by date, not by `TIMESTAMP` with sub-day granularity you never filter on — millions of tiny partitions cost metadata and planning time.
- `[conv]` Partition pruning only works when the filter is on the partitioning column directly: `WHERE DATE(ts) = '2026-11-01'` prunes; `WHERE TIMESTAMP_TRUNC(ts, DAY) = ...` may not. Verify with bytes scanned, not hope.

## Cost control

- `[conv]` Check with a dry run before running something new: `bq query --dry_run` returns the bytes it would scan for free.
- `[conv]` Measure real cost from `INFORMATION_SCHEMA.JOBS` (`total_bytes_billed` per job) — that is the source of truth for what a dashboard or DAG costs per run.
- `[req]` Never `SELECT *` in a model that feeds a mart: columnar storage means unused columns are pure cost.
- `[conv]` `LIMIT` does not reduce bytes scanned (it reduces the result, after the scan). It saves nothing on cost.
- `[conv]` `ORDER BY` without `LIMIT` sorts the whole result for nothing. Window functions over an unpartitioned table are the expensive shape.
- `[conv]` Materialise the expensive intermediate once (a table, or a materialized view) rather than repeating it inside five dashboards.

## Deduplication and upserts

- `[conv]` Dedupe in the same query that produces the row, with `QUALIFY`:

      SELECT * FROM src
      QUALIFY ROW_NUMBER() OVER (PARTITION BY entity_id ORDER BY updated_at DESC, _loaded_at DESC) = 1

- `[conv]` `MERGE` for upserts, scoped to the touched partitions in both `USING` and `ON`. A `MERGE` without a partition constraint scans and rewrites both sides entirely.
- `[conv]` For append-only facts, prefer `WRITE_TRUNCATE` on a partition over `MERGE`: it is cheaper, idempotent, and leaves no half-merged state.
- `[conv]` Streaming inserts are not deduplicated reliably; the Storage Write API gives at-least-once with offsets. If duplicates matter, dedupe downstream on the natural key.

## Incremental patterns

- `[conv]` Re-process a window to catch late data: `WHERE DATE(ts) >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 DAY)`, then replace those partitions rather than appending.
- `[conv]` Never key an incremental model on `CURRENT_TIMESTAMP()` inside the query — the same run repeated produces different rows and breaks idempotency.
- `[conv]` Deletes need an explicit signal (a `deleted_at`, a CDC stream, or a full reconcile). A `WHERE updated_at > watermark` extract cannot see deletions, and the mart slowly accumulates ghosts.

## Types and structure

- `[conv]` `TIMESTAMP` for instants (UTC), `DATETIME` for wall-clock without a zone, `DATE` for days. Mixing them is how a report shifts by a day.
- `[conv]` Nested/repeated fields with `UNNEST` beat joining a normalised child table when the grain is the parent row: no fan-out, no dedupe needed. But `UNNEST` multiplies rows — `COUNT(*)` after an `UNNEST` counts unnested rows.
- `[conv]` Use `STRUCT` with names, not positional tuples; schema evolution on nested fields is unforgiving.
- `[conv]` Schema autodetect is for exploration. It infers types from a sample and gets them wrong in predictable ways (integers that should be text, mixed types becoming `STRING`) — declare the schema for anything scheduled.

## Loading

- `[conv]` Load from GCS with a load job, not row-by-row inserts: cheaper and atomic per job. `WRITE_APPEND` for raw landing, `WRITE_TRUNCATE` for partition rebuilds.
- `[conv]` A load job is the natural idempotency boundary: same files, same destination, `WRITE_TRUNCATE` per partition.

## Slots and contention

- `[conv]` On-demand pricing is per-query; reservations buy slots and change the failure mode from "expensive" to "queued". If queries queue, look at project-level slot usage, not at the SQL.
- `[conv]` Many small concurrent queries waste slots on planning; batch them.
