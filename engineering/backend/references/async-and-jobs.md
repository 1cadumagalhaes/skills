# Async and jobs

The queue delivers a message more than once, in any order, sometimes late, sometimes never. Design for that sentence.

## Delivery semantics

- **At-most-once**: fire and forget; loss is possible. Only for telemetry.
- **At-least-once**: the real default for every broker that acks. Duplicates are guaranteed over time.
- **Exactly-once**: only *inside* one system that supports it (a transaction with the enqueue, or Kafka transactions). Across a network it is a marketing term.

Therefore: `[req]` every consumer must be idempotent, and that is not "it usually doesn't happen twice".

## Idempotent consumers

- `[req]` Dedupe on a **business key** (payment id, order id), not the broker's message id. A republish gets a new id and the effect re-applies.
- `[conv]` Implement as an effect table with a unique constraint, or an upsert keyed on the business identity. "Check if it exists, then insert" is a race.
- `[conv]` Record the outcome, not just the attempt, so a duplicate can replay the original response instead of recomputing.

## Retries

- `[conv]` Exponential backoff with **jitter**, a cap, and a max attempt count. Fixed-interval retries synchronise a fleet into a thundering herd.
- `[req]` Classify the failure: transient (timeout, 5xx, deadlock) retries; permanent (validation, 4xx, malformed) goes straight to the dead-letter queue. Retrying a poison message burns the queue.
- `[conv]` DLQ with a **replay path and a reason per message**; a DLQ nobody reads is where data goes to die quietly.
- `[conv]` Alert on DLQ depth and on age of the oldest message, not only on error rate.

## Broker mechanics that cause duplicates

- `[req]` Visibility/ack timeout must exceed the worst realistic processing time, or the message is redelivered while the first attempt still runs. Long jobs heartbeat or ack in stages.
- `[conv]` Ack after the effect is durable, not before.
- `[conv]` Prefetch/consumer concurrency sized to the downstream, not to the broker.
- `[conv]` Ordering guarantees are per partition/key only. If order matters, key by the entity (tenant, order) and accept that global order does not exist.

## Scheduling

- `[conv]` Distinguish scheduled work (cron, at a time) from queued work (as soon as possible). Different failure modes: cron overlaps, queues pile up.
- `[req]` A scheduled job must be a **singleton** in a multi-instance deployment. Use a lock, a leader election, or a "claim the row" pattern. Otherwise N instances run it N times.
- `[conv]` Timezones: schedule in UTC, and decide explicitly whether "daily" means 24 h or midnight local.
- `[conv]` Missed runs: catch-up policy (run once for the latest, or backfill every skipped window) written down, not discovered.

## Backpressure

- `[req]` A consumer that cannot keep up must slow the producer (paused queue, 429 upstream, bounded in-flight), not grow memory until OOM.
- `[conv]` Rate-limit toward the downstream dependency per tenant, not globally, so one tenant cannot starve the rest.
- `[conv]` Dead-letter to disk/table when the broker's retention would drop the message.

## Observability

- `[conv]` Four numbers per queue: depth, age of oldest message, processing latency (p50/p95), DLQ count.
- `[conv]` A message carries a correlation id and the originating request id; logs and traces join on them.
- `[conv]` A job that silently does nothing is worse than one that fails: emit a processed/skipped counter with a reason.
