# Data modelling and migrations

The database is the last line of defence for an invariant. Anything only the application enforces is enforced until someone runs a script.

## Tables

- `[conv]` Primary key: surrogate (`bigint`/UUIDv7) unless the natural key is genuinely immutable and short. UUIDv4 as a clustered PK fragments inserts; UUIDv7 or `bigserial` does not.
- `[req]` `NOT NULL` by default. A nullable column is a decision. Write down which value means "unknown" and how queries treat it.
- `[req]` Invariants live in constraints, not only in handlers: `UNIQUE`, `CHECK`, `FOREIGN KEY` with an explicit `ON DELETE` policy (`RESTRICT` unless cascade is genuinely what you mean).
- `[conv]` Enumerations: `CHECK (status IN (...))` or a lookup table. Never a bare integer whose meaning lives in a constant file.
- `[req]` Timestamps are `timestamptz`, stored in UTC, named `created_at` / `updated_at` / `deleted_at`. A naive `timestamp` is a bug waiting for a DST boundary.
- `[conv]` Soft delete is a policy, not a column: a partial unique index (`WHERE deleted_at IS NULL`), a purge window, and every query filtered, or use real deletes.
- `[conv]` Money is an integer in minor units or `numeric`, never `float`. Currency is a column, not an assumption.
- `[req]` Every tenant-scoped table carries `tenant_id` (or equivalent), indexed, and appearing **first** in composite indexes where most queries filter by it.

## Indexes

- `[conv]` One index per real query pattern, not per column. Composite order follows the query: equality columns first, then range, then order-by.
- `[conv]` Partial indexes (`WHERE status = 'pending'`) are the cheapest index for a hot small subset.
- `[conv]` Every index costs write throughput and disk. Before adding one: `EXPLAIN (ANALYZE, BUFFERS)` the actual query on realistic data.
- `[conv]` Foreign keys need an index on the referencing side, or every parent delete and join scans.

## Migrations without downtime

The pattern is **expand → backfill → switch → contract**, one step per deploy:

1. **Expand**: add the new column nullable (or a new table), with no reader depending on it yet. Deploy code that writes both.
2. **Backfill**: batched, rate-limited, resumable, idempotent, never a single `UPDATE` over millions of rows inside a deploy.
3. **Switch**: deploy code that reads the new shape. Keep writing both until nothing reads the old one.
4. **Contract**: drop the old column/table in a later deploy, after the last reader is gone.

Rules that prevent 2 a.m. incidents:

- `[req]` No long `ACCESS EXCLUSIVE` lock on a hot table. In PostgreSQL set a short `lock_timeout` and retry, or use concurrent index creation (`CREATE INDEX CONCURRENTLY`, which cannot run inside a transaction).
- `[req]` A column rename is expand+contract, never `ALTER TABLE ... RENAME` in the same deploy that changes the code.
- `[conv]` Adding a `NOT NULL` column with a default: on modern PostgreSQL a constant default is metadata-only, but a volatile default is a full rewrite. Check before shipping.
- `[conv]` Backfills are idempotent (`WHERE new_col IS NULL`) so a retry is safe, and they have a progress query.
- `[conv]` Down-migrations for destructive steps do not exist in practice: dropping a column drops the data. Make the rollback a code rollback, not a schema rollback.
- `[conv]` Migrations run **before** the code that needs them, in a separate step, and the deploy waits for them to finish.

## Data model smells worth naming in review

- a unique rule enforced by a `SELECT` before `INSERT` (race; use a constraint)
- `status` plus `status_updated_at` plus `status_reason` on four tables (a state machine wanting to be one)
- the same enum value duplicated in code, migration and dashboard
- a `json`/`jsonb` column absorbing fields that are queried (promote them)
- cross-table invariants maintained by triggers nobody can find
