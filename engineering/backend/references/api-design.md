# API contract

A client must be able to answer three questions from the docs alone: *may I retry this?*, *what does failure look like?*, *how do I know it took effect?*

## Resources and verbs

- `[req]` Verbs are HTTP semantics (RFC 9110): GET safe and cacheable, PUT idempotent replace, PATCH partial but not idempotent unless designed so, DELETE idempotent, POST neither safe nor idempotent.
- `[conv]` Resources are nouns, plural, stable: `/invoices/{id}`. Actions that are not CRUD become a sub-resource (`/invoices/{id}/void`) rather than a verb in the path.
- `[conv]` Filters, sort and pagination are query parameters with an explicit allowlist. Never interpolate a client-sent field name into SQL.
- `[req]` Request size and array length have limits, enforced server-side, and the error says which limit.

## Status codes that carry meaning

| situation | code |
|---|---|
| created | `201` + `Location` |
| accepted, async work started | `202` + status resource |
| no content | `204` |
| malformed request (unparseable, wrong types) | `400` |
| parses but violates business rules | `422` |
| not found **and** not visible to this caller | `404` for both, never `403` (a 403 leaks existence) |
| not allowed to act on something you can see | `403` |
| state conflict (already paid, version mismatch) | `409` |
| precondition failed (ETag/If-Match) | `412` |
| rate limited | `429` + `Retry-After` |
| server fault, retry with backoff allowed | `5xx` + `Retry-After` when known |

Never `200 OK` with `{"success": false}`. That makes every client parse two error channels.

## One error shape

Use RFC 9457 (`application/problem+json`) and use it everywhere, including validation errors:

    { "type": "https://errors.example.com/insufficient-funds",
      "title": "Insufficient funds",
      "status": 422,
      "detail": "Balance 12.00 is below the charge of 20.00",
      "instance": "/invoices/abc/charge",
      "errors": [{"field": "amount", "code": "gt_budget"}] }

`type` is a stable URI clients can branch on; `detail` is for humans and may change. No stack traces, no SQL, no upstream vendor strings. Log those and return a correlation id.

## Idempotency

- `[req]` Any endpoint that creates money-moving or otherwise irreversible effects accepts an **`Idempotency-Key`** header (currently `draft-ietf-httpapi-idempotency-key-header`). Store `key + endpoint + account` with a hash of the request body and the response; replay the stored response on a repeat, and return `409` if the same key arrives with a different body.
- `[conv]` Give keys a TTL (24 h is common) and document it. A key stored forever is a table nobody cleans.
- `[conv]` `PUT` and `DELETE` should be idempotent by construction (replace/removal), so they need no key. If your `PUT` appends, it is a `POST` wearing a disguise.
- `[conv]` Server-side dedupe on the natural key (a unique constraint on `(account_id, external_id)`) beats a client honour system.

## Concurrency control

- `[conv]` Optimistic by default: return `ETag`, honour `If-Match`, answer `412` on mismatch. Cheaper than locking and it fails loudly.
- `[conv]` Expose the version in the body as well as the ETag when the client is a UI that must show a conflict.

## Pagination

- `[conv]` **Cursor** for anything that changes or is large; `offset` only for small, static, human-browsable lists. Offset pagination skips and repeats rows when items are inserted above the cursor.
- `[conv]` The cursor is opaque (an encoded key, not an offset the client can compute), stable under ties (order by a unique tiebreaker), and carries the filter it was created with. Otherwise the result set silently changes meaning.
- `[conv]` No total counts by default; they cost a second query and go stale. Offer them behind a flag.

## Long-running work

- `[conv]` `202 Accepted` + a status resource (`/jobs/{id}`) with a state machine, not a request that blocks for 40 s.
- `[req]` Never claim success for partial completion. If 3 of 5 rows were written, the response says so and names which.

## Versioning and deprecation

- `[conv]` Additive first: new fields are optional, new endpoints are new paths. Renaming or removing is a breaking change.
- `[conv]` Deprecate with RFC 9745: `Deprecation: @1735689600` plus `Link: <https://.../>; rel="deprecation"`, and tell clients the timeline. A `Sunset` header plus a changelog entry beats a surprise 404.
- `[conv]` Version in the path (`/v2`) or a dated media type. Pick one per product and never both.
