---
name: backend
description: Designing or changing a backend — API contracts, data modelling and migrations, transaction boundaries, queues and jobs, and the service's operational contract (timeouts, pools, health, tenancy). Use when adding an endpoint, table or queue, when a write must be exactly-once-ish, or when deciding where a transaction, lock or idempotency key belongs. Language-agnostic.
---

# Backend

Rules for the five places backends break, in the order they cost money. Nothing here is language-specific: the same mistakes are made in FastAPI, Go and Rails.

| area | the question | file |
|---|---|---|
| API contract | can a client retry this safely, and does it get one error shape? | `references/api-design.md` |
| Data + migrations | is the invariant in the database, and can this ship without downtime? | `references/data-modelling.md` |
| Transactions | where is the boundary, and which anomaly am I buying? | `references/transactions-and-consistency.md` |
| Async | what happens when this message is delivered twice? | `references/async-and-jobs.md` |
| Operations | what happens when a dependency is slow, absent, or I am deploying? | `references/service-contract.md` |

Auditing a backend that already exists: `code-quality`. Architecture-level judgement at scale (sharding, consensus, storage engines): `~/.agents/skills/dsa-system-design/references/system-design-patterns.md`.

## Non-negotiables

1. **Every write with a side effect needs an idempotency story** — a natural key, a client `Idempotency-Key`, or a dedupe table. "The client won't retry" is not one.
2. **No destructive schema change in one deploy.** Expand, backfill, switch, contract — in that order, across deploys.
3. **Tenant scope is in the query, not in the caller's good intentions.** A filter the handler can forget will be forgotten.
4. **Every outbound call has a timeout.** A call without one is a thread you will never get back.
5. **Never write to the database and publish a message as if they were one operation.** They are not; use an outbox.
6. **Nothing in the API returns a stack trace, a vendor error string, or another tenant's existence.**

## Order of work

Contract first (what a client can rely on), then storage (what the data guarantees), then the write path (boundaries and locks), then the asynchronous path (retries and duplicates), then operations (timeouts, health, deploy). Designing the queue before the contract is how you get an API nobody can retry.

## Sources

RFC 9457 (Problem Details, obsoletes 7807) · RFC 9745 (Deprecation header) · RFC 9110 (HTTP semantics) · PostgreSQL 18 §13.2 (isolation levels and the anomaly table) · HikariCP pool sizing · `draft-ietf-httpapi-idempotency-key-header` (Internet-Draft, not yet an RFC).
