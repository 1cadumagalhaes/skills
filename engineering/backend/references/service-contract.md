# Service contract

What the service promises when things go wrong. This is the difference between a service that degrades and one that takes the platform with it.

## Timeouts

- `[req]` Every outbound call — HTTP, database, queue, cache — has an explicit timeout, connect **and** read. Default timeouts are usually infinite or 30+ seconds; both are wrong here.
- `[conv]` A timeout shorter than your caller's timeout. Otherwise you finish the work nobody is waiting for, and it gets retried anyway.
- `[conv]` Set the whole request budget at the edge and pass a deadline down, rather than multiplying per-hop timeouts.

## Retries and circuit breaking

- `[conv]` Retry only idempotent operations, with backoff + jitter, a cap, and a retry budget (a percentage of calls, not unlimited).
- `[conv]` A circuit breaker stops hammering a dead dependency; a half-open state probes with one request.
- `[conv]` Load shedding beats collapse: when saturated, reject early with `429`/`503` and a `Retry-After` rather than queueing until every thread waits.
- `[conv]` Retries at two layers multiply: 3 client retries × 3 gateway retries × 3 service retries = 27 calls to a failing dependency.

## Connection pools

- `[conv]` Start from the HikariCP sizing heuristic: `connections = (cores * 2) + effective_spindle_count`, then measure. It is a starting point, not a law.
- `[req]` Sum of all instance pools < the database's `max_connections`, with headroom for admin and migrations. The classic outage is a deploy that doubles the instance count.
- `[conv]` Watch pool wait time, not pool usage. A pool that is 100 % busy but never waits is fine; one that waits 300 ms is too small.
- `[conv]` Never hold a connection across a network call (see the transaction rules).

## Graceful shutdown

- `[req]` On `SIGTERM`: stop accepting new work, fail readiness, finish in-flight requests within a grace period, stop pulling from queues, close pools, exit. Kubernetes sends `SIGKILL` after `terminationGracePeriodSeconds` — stay under it.
- `[conv]` Long jobs checkpoint or re-queue themselves rather than dying mid-write.

## Health and readiness

- `[conv]` **Liveness** answers "is this process wedged, restart me" — no dependency checks, or a slow database restarts the whole fleet.
- `[conv]` **Readiness** answers "should traffic come here" — fails when a *required* dependency is down, stays up when an optional one is.
- `[conv]` Health endpoints do not write, do not require auth, and do not leak versions or config.

## Identity, tenancy, authz

- `[req]` Tenant/owner scope comes from the authenticated principal, never from a client-supplied field. A `tenant_id` in the request body is a vulnerability with a schema.
- `[req]` Every query on tenant data is scoped, in the same statement that fetches it (or enforce it in the database with row-level security). Do not "fetch then check".
- `[conv]` Authorisation next to the data it protects, not only at the route: the route does not know that this invoice belongs to another org.
- `[conv]` Distinguish `401` (who are you) from `403` (you may not), and return `404` when revealing existence is itself a leak.

## Observability

- `[conv]` One structured log line per request: method, path template, status, duration, principal id, request id, tenant. No PII, no bodies, no tokens.
- `[conv]` Metrics that answer the three questions: rate, errors, duration — per endpoint and per dependency.
- `[conv]` Propagate `traceparent` (W3C) so a user-visible failure can be followed across services; correlate async work with the same id.
- `[conv]` Log the *resolved* configuration once at startup, secrets redacted (`code-audit` → `configuration.md`).

## Deploy contract

- `[conv]` Migrations run as a separate step, before the new code, and the deploy waits for them (`backend` → `data-modelling.md`).
- `[conv]` Feature-flag anything that cannot be rolled back by redeploying the previous image.
- `[conv]` Draining, rolling, and rollback are tested at least once — an untested rollback is a rumour.
