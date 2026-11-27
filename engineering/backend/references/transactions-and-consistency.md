# Transactions and consistency

Two questions decide everything here: **where does the boundary go**, and **which anomaly am I willing to live with**.

## The boundary

- `[conv]` One transaction per business action, opened in the service layer, not per repository call. A transaction that wraps each `insert` separately is not a transaction.
- `[req]` No network calls inside a transaction — an HTTP call or a queue publish holds locks for as long as the remote is slow.
- `[conv]` Keep it short: the transaction is the unit of atomicity, not the unit of work. Compute first, then write.
- `[conv]` Reads that feed a decision the write depends on belong inside the same transaction (or the decision belongs in the write, as a conditional `UPDATE ... WHERE`).

## Isolation levels (PostgreSQL 18, §13.2)

| level | dirty read | non-repeatable read | phantom read | serialization anomaly |
|---|---|---|---|---|
| Read uncommitted | not possible in PG (behaves as Read Committed) | possible | possible | possible |
| **Read committed** (default) | not possible | possible | possible | possible |
| Repeatable read (snapshot isolation) | not possible | not possible | **not possible in PG** | **possible** |
| Serializable (SSI) | not possible | not possible | not possible | not possible |

Practical consequences:

- `[conv]` Read Committed is fine for independent statements; it is **not** enough for read-modify-write across two statements.
- `[req]` Repeatable Read does not save you from **write skew** — two transactions each read a set, each writes a disjoint row, both commit, and the invariant breaks (the classic "two doctors both go off call"). Only Serializable (SSI) prevents it.
- `[conv]` Serializable costs retries: handle `40001` (`serialization_failure`) with a bounded retry loop. Code that cannot tolerate a retry cannot use Serializable.

## Read-modify-write

- `[conv]` Prefer a single conditional statement: `UPDATE accounts SET balance = balance - 100 WHERE id = $1 AND balance >= 100` — the check and the write are one operation.
- `[conv]` Otherwise lock what you read: `SELECT ... FOR UPDATE` (pessimistic), or carry a `version` column and `WHERE version = $n` (optimistic) — and treat "0 rows updated" as the conflict.
- `[conv]` Advisory locks (`pg_advisory_xact_lock`) for invariants that span rows or tables; they are released at commit and cost nothing if unused.

## Two writes are never one

- `[req]` **Never** `INSERT` then publish/invalidate/call — the second can fail and the first stays. Use the **transactional outbox**: write the row and an `outbox` record in the same transaction, and a relay publishes from the outbox (at-least-once downstream).
- `[conv]` The consumer side of that is dedupe, not hope: see `async-and-jobs.md`.
- `[conv]` Across services, use a saga with explicit compensations. Distributed transactions across an HTTP boundary are a fiction; do not design one.

## Effective once

- `[conv]` Exactly-once delivery does not exist end to end. Effective-once does: idempotency key on the request, unique constraint on the effect, and a consumer that upserts rather than appends.
- `[conv]` The dedupe key must be the business key (payment id), not the message id, or a redelivery with a new id re-applies the effect.

## Audit trail

- `[conv]` If someone will ask "who changed this and when", the answer belongs in the write path (an append-only history table, or an outbox consumer), not in a log line that rotates in 14 days.
