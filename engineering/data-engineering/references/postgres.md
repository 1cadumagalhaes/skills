# Postgres in a pipeline

Postgres is an OLTP database that happens to be a convenient source and sink. Treat it as a transaction system you are a guest in, not as a warehouse.

Schema design, constraints and migrations live in `backend` → `data-modelling.md`. This file is about moving rows in and out safely.

## Incremental extraction

- `[req]` Never `OFFSET` paginate a live table: rows shift under you, so the extract skips and repeats. Use **keyset pagination** on a stable, indexed tuple:

      SELECT * FROM orders
      WHERE (updated_at, id) > ($1, $2)
      ORDER BY updated_at, id
      LIMIT 5000;

- `[req]` The watermark is stored per source and advanced **only after** the write downstream commits. Advancing it before the load loses rows silently.
- `[conv]` The watermark column needs an index, or every extract becomes a sequential scan that grows with the table.
- `[conv]` `updated_at` must be set by the database (`DEFAULT now()` / trigger), not by the application, or a buggy client writes rows that no watermark will ever see.
- `[conv]` Overlapping windows (re-read the last N minutes) are cheaper than debugging a missed row.

## When polling is not enough

- `[conv]` Polling by `updated_at` cannot see **deletes** or hard updates without a timestamp. If deletions matter, you need CDC: logical replication (`wal_level = logical`, a publication and slot) with Debezium or similar.
- `[conv]` CDC caveats that bite: replication slots retain WAL forever if the consumer dies (disk fills at 2 a.m.), `REPLICA IDENTITY` must be set for old-row data, and schema changes need coordination with the consumer.
- `[conv]` Read from a replica if available, but watch lag, and remember a long query on a replica still affects the primary through `hot_standby_feedback` (bloat).

## Bulk loading

- `[conv]` `COPY` is the fast path (one statement, no per-row overhead). Multi-row `INSERT` is acceptable in batches of a few hundred; row-at-a-time in a loop is not.
- `[conv]` Stage in `UNLOGGED` or `TEMP` tables, then merge into the target: `UPDATE ... FROM staging`, `INSERT ... SELECT ... WHERE NOT EXISTS`, or `MERGE` (PostgreSQL 15+).
- `[conv]` `INSERT ... ON CONFLICT (key) DO UPDATE` is the simplest idempotent upsert; beware that it rewrites the row (bloat) and fires no `DELETE`.
- `[conv]` Wrap a load in one transaction when the batch is a unit; commit per batch when it is not. Never leave a transaction open while calling an API.
- `[conv]` `VACUUM ANALYZE` after a large load, or the planner keeps using statistics for the empty table.

## Being a good guest

- `[req]` No heavy analytics on the production primary. Use a replica, an export to the warehouse, or a read pool. The same query that takes 40 s in BigQuery can hold locks and bloat a hot OLTP table.
- `[conv]` Set `statement_timeout` and `idle_in_transaction_session_timeout` for pipeline connections. An idle transaction blocks `VACUUM` and eventually the whole table's cleanup.
- `[conv]` Cap concurrency per source with an Airflow pool; ten parallel extracts of the same table is a self-inflicted outage.
- `[conv]` Check `pg_stat_activity` for long-running queries and `pg_stat_user_tables` for bloat when a pipeline gets slower each week.

## dbt on Postgres

- `[conv]` Incremental strategies are adapter-specific: `append` (immutable facts), `delete+insert` (mutable dimensions, needs a `unique_key`), `merge` (PostgreSQL 15+). Pick from whether rows get updated and deleted, not from habit.
- `[conv]` Without a `unique_key`, "incremental" is just `append`, and reruns duplicate.
- `[conv]` `delete+insert` on a large table rewrites whole partitions; scope the delete to the affected window when the model allows it.
