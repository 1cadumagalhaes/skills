# backend / prompt-2

## Must decide
- Refuse the single-deploy destructive migration even with the deadline: expand, backfill, switch, contract, across deploys.
- The backfill is a separate bounded job (batched, resumable, idempotent), not part of the DDL transaction.
- Narrow instead of lecturing: state what can ship tonight (nullable column, dual write, backfill job) and what waits.

## Must show
- The four-step plan with which deploy each step lands in, and read/write behavior during the gap.
- The lock/rewrite risk named (`ALTER ... SET NOT NULL` rewrites or locks depending on version) and the safer form (validated NOT NULL constraint or index).
- The invariant still enforced in the database at the end, plus the rollback path for the new column.
- Evidence old code works against the new schema: current test suite run against the migrated database.

## Miss if
- Agrees because the deadline is real, or runs DDL plus backfill in one transaction.
- Backfills with one unbounded `UPDATE` and no batching or resume.
- Leaves the invariant only in application code.
