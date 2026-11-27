# backend / prompt-1

## Must decide
- Order: API contract, then storage invariant, then the transactional boundary, then async delivery, then operational guards.
- Idempotency is mandatory: `Idempotency-Key` plus a natural key, enforced by a unique constraint or dedupe table, not a handler `if exists`.
- The migration ships across deploys: expand, backfill, switch, contract. No destructive single deploy.
- Database write plus message publish is an outbox, not a dual write; the worker must survive the same message twice.
- Tenant scope lives in the query (`WHERE tenant_id = $1`), never only in the route guard.

## Must show
- RFC 9457 problem+json on every failure path, no stack traces, vendor strings, or cross-tenant detail.
- Explicit timeout on the publish call and a stated pool size; health/readiness behavior named.
- chained: `references/api-design.md`, `references/data-modelling.md`, `references/transactions-and-consistency.md`, `references/async-and-jobs.md`.
- A test that POSTs twice with the same key and asserts one row and one outbox message.

## Miss if
- `INSERT` then `publish()` in the same handler with no outbox and no dedupe.
- One migration that adds a NOT NULL column and backfills inside the deploy.
- Tenant filter only in middleware, or a 500 that carries the raw exception.
