# Bugs and failure modes

Correctness first, because everything else is wasted on code that is wrong. These are the failures that survive tests: the paths nobody exercises until production.

## Inputs and boundaries

- `[check]` Empty vs missing vs null vs zero vs `""` — are they distinguished, or silently equivalent?
- `[check]` Off-by-one at the edges: inclusive/exclusive ranges, `<` vs `<=`, slicing a list of length 0 or 1.
- `[check]` Parsing without validation: `int(x)` on user input, JSON without a schema, a timestamp assumed to be a datetime.
- `[check]` Silent truncation or coercion: floats for money, ints for IDs wider than they look, timezone-naive datetimes.
- `[check]` Length/size limits: a payload, list or query result assumed small.

## Error paths

- `[check]` `except: pass`, bare `except Exception`, `catch {}` — what error is being swallowed, and who needed to know?
- `[check]` Errors converted into falsy returns (`return None`, `return []`) so callers cannot distinguish "none" from "failed".
- `[check]` Partial writes: half the records written, then an exception, with no transaction or compensation.
- `[check]` Cleanup not in `finally`/context manager — a file handle, lock, connection or temp file leaked on the error path.
- `[check]` Retries without idempotency: a payment, an insert, an email, sent twice because the caller retried a timeout.

## Concurrency and state

- `[check]` Shared mutable state without a lock; a global cache mutated by request handlers.
- `[check]` Check-then-act races: read a value, branch on it, write — between two threads or two processes.
- `[check]` Ordering assumptions: dict iteration, `set` order, filesystem listing, "the callback fires before the next line".
- `[check]` Async without cancellation: a task that outlives its request, a timeout that does not stop the work.
- `[check]` Re-entrancy: a function that calls back into itself through an event handler or a lazy property.

## Time, money, identity

- `[check]` Timezone: naive datetimes, "today" computed in local time on a server in UTC, DST boundaries.
- `[check]` Money in float; rounding at the wrong step; currency assumed.
- `[check]` IDs compared as strings vs ints; leading zeros; case sensitivity in an identity that is case-insensitive in reality.
- `[check]` Clock skew or `now()` called twice in one operation, so the before and after disagree.

## Resources

- `[check]` Unbounded growth: an in-memory dict/list keyed by user or request, never evicted.
- `[check]` Connection or session reuse across threads; a pool smaller than the concurrency.
- `[check]` Reading a whole file/table into memory when it streams fine.
- `[check]` Recursion depth on user-controlled input; unbounded retry/backoff loops.

## Reporting

For each finding: **what breaks**, **under what condition**, **what the user sees** (500? wrong number? silent data loss?), and **how you know** (a read of the code path, a test, a reproduction). "Might be a problem" is not a finding; either trace it end to end or drop it.
