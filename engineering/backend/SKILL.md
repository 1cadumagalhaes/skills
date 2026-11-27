---
name: backend
description: "Backend design and changes: API contracts, schema migrations, transactions, queues/jobs, and service resilience (timeouts, pools, health, tenancy). Use when adding endpoints, tables, or async jobs."
cluster: engineering
tier: root
---

# Backend

| When | Read |
|---|---|
| Designing module boundaries | `~/.agents/skills/module-design/SKILL.md` |
| Defining domain invariants | `~/.agents/skills/domain-modeling/SKILL.md` |
| Choosing distributed architecture | `~/.agents/skills/system-design/SKILL.md` |
| Reviewing a backend diff | `~/.agents/skills/code-review/SKILL.md` |

Rules for the five places backends fail or lose data. Principles apply equally across FastAPI, Go, and Rust services.

| Area | Question | File |
|---|---|---|
| API contract | Can a client retry safely, and does it get one error shape? | `references/api-design.md` |
| Data and migrations | Is the invariant in the database, and can this ship without downtime? | `references/data-modelling.md` |
| Transactions | Where is the boundary, and which isolation anomaly am I buying? | `references/transactions-and-consistency.md` |
| Async and jobs | What happens when this message arrives twice? | `references/async-and-jobs.md` |
| Service contract | What happens when a dependency is slow, absent, or deploying? | `references/service-contract.md` |

For auditing existing backend code, use `code-audit`. For large-scale architecture patterns (sharding, consensus, storage engines), read `~/.agents/skills/system-design/SKILL.md`.

## Non-negotiables

1. **Every write with a side effect needs idempotency.** Use a natural key, client `Idempotency-Key`, or dedupe table.
2. **Ship schema changes across deploys.** Expand, backfill, switch, then contract. Avoid destructive single-deploy migrations.
3. **Scope tenant filters inside the query.** Never rely on handler-level checks alone.
4. **Set explicit timeouts on every outbound call.** Unbounded calls leak workers and connections.
5. **Use an outbox instead of dual writes.** Writing to the database and publishing a message are separate failure domains.
6. **Redact errors at the boundary.** Return structured problem details without stack traces, raw vendor strings, or cross-tenant leaks.

## Order of work

Define the API contract first, then storage invariants, then transactional write boundaries, then async delivery and retries, and finally operational guards (timeouts, health checks, deploy behavior).

## Sources

RFC 9457 (Problem Details), RFC 9745 (Deprecation header), RFC 9110 (HTTP semantics), PostgreSQL 18 §13.2 (isolation levels), HikariCP pool sizing, `draft-ietf-httpapi-idempotency-key-header`.
