# Ingestion

Getting data in from APIs and the open web. The rule for all of it: **land raw first, transform after**. A bug in parsing then costs a re-run, not a re-fetch.

## Every source gets a cursor

- `[req]` A stored cursor per source (timestamp, sequence, page token, ETag). Advanced only after the landing write commits.
- `[req]` Resumable: a run that dies at page 400 restarts at page 400, not at page 1.
- `[conv]` The cursor is data, not a variable: a row in a control table with source, cursor value, updated_at, and the run id that set it.

## HTTP clients

- `[req]` Explicit timeouts (connect and read) on every request. `requests` defaults to no timeout, which is how a DAG hangs for six hours.
- `[conv]` Retries on 429/5xx with exponential backoff **and jitter**, honouring `Retry-After`. Retrying a 400 is a bug, not persistence.
- `[conv]` Paginate properly: follow the API's cursor or `Link: rel="next"`, not an assumed page count. Cap total pages and fail loudly when the cap is hit.
- `[conv]` Authenticate once, refresh on 401, cache the token; do not re-authenticate per request.
- `[conv]` Rate-limit yourself below the documented limit, per token and per host, and log the remaining quota if the API exposes it.

## Landing

- `[req]` Raw payloads are stored as received: JSON as JSON (or `STRING` in the warehouse), files as files, with `source`, `fetched_at`, `run_id`, and the request parameters. Never parse-and-discard.
- `[conv]` Partition the raw layer by fetch date; keep it long enough to replay a rebuild (30-90 days is common).
- `[conv]` Dedupe on a content hash (`sha256` of the payload) or the source's stable id when re-fetching the same window.
- `[conv]` Typed staging is derived from raw, as a view or an incremental model, never a hand-edited table.

## Schema drift

- `[req]` Assume the source changes. A new field is fine; a renamed or retyped field must fail a test, not silently become `NULL`.
- `[conv]` Cast explicitly in staging (`SAFE_CAST` in BigQuery, `::type` in Postgres) and count cast failures. A rising count is the early warning.
- `[conv]` Schema autodetect is exploration only (see `bigquery.md`): it infers from a sample and quietly gets types wrong.

## Files and bulk sources

- `[conv]` API → GCS → warehouse load job beats row-by-row inserts for anything above a few thousand rows.
- `[conv]` Keep the file, not just the table: the load job is replayable, the API may not be.
- `[conv]` Dedupe on `(source, filename, hash)` before loading; a re-download of the same CSV is the usual duplicate source.

## Web extraction

- `[conv]` For anything beyond a plain HTML fetch, follow the `webscraping` skill: intake, then the cheapest ladder (HTTP → fingerprint impersonation → browser injection → headless), not a browser by default.
- `[conv]` Prefer a documented API or a structured payload on the page (JSON-LD, `__NEXT_DATA__`, embedded JSON) over parsing rendered markup; the markup is the least stable surface.
- `[conv]` Store the raw HTML/JSON alongside the extracted rows, keyed by URL + hash, so extraction can be re-run without re-crawling.
- `[conv]` Extraction logic lives in a normal module with tests over saved fixtures, not inline in the DAG. Fixtures are the only way to test a parser after the site changes.

## Observability

- `[req]` Per run: rows fetched, rows landed, cursor before/after, duration, HTTP status counts.
- `[conv]` Alert on **no new data** as loudly as on failure. A source that returns 200 with an empty list is the quietest outage there is.
- `[conv]` One log line per source per run with the cursor and the row count; that line is what you will grep at 2 a.m.
- `[conv]` Keep the response status and a redacted body snippet for failures, but never log tokens, cookies or personal data.
