# dbt and data quality

dbt's value is not SQL templating: it is that the DAG, the tests and the documentation are the same artefact. If the tests are not part of the build, you have a folder of queries.

## Layering

- `[conv]` `staging/` — one model per source table, renamed and typed, nothing joined. `intermediate/` — joins and business logic. `marts/` — entities a consumer can name (`fct_orders`, `dim_sponsors`).
- `[conv]` Staging models select explicit columns and cast types; no business logic, no filters that hide data.
- `[conv]` One model, one grain, stated in the model's description. If you cannot say the grain in one sentence, the model is two models.
- `[conv]` Marts are what BI and the API read. Nothing outside the project reads staging.

## Incremental models

- `[req]` `is_incremental()` guards the filter; without it the first run and the incremental run diverge.
- `[req]` A `unique_key` for anything mutable. Without one, `incremental` is `append`, and a rerun duplicates.
- `[conv]` Strategy follows the data, and the adapter's support: `append` for immutable events, `delete+insert` for rows that change, `merge` where the warehouse supports it (BigQuery, PostgreSQL 15+). `backend`-style thinking, not habit.
- `[conv]` Include a late-arriving window (`>= max(loaded_at) - interval '3 days'`) rather than assuming the last incremental run saw everything.
- `[conv]` Know what `--full-refresh` costs before you need it; if it is an hour, the model is also an hour of CI.

## Snapshots vs incremental

Straight from dbt's CDC guidance:

- **Incremental** keeps *current values* — cheaper, one row per entity.
- **Snapshot** keeps *history* — SCD2 with `dbt_valid_from` / `dbt_valid_to`, one row per version.
- Use both when consumers need current state and an audit trail; use snapshots only when someone will actually ask "what was true in March".
- `[conv]` Snapshot strategy: `timestamp` when the source has a reliable `updated_at`, `check` when it does not (compares listed columns each run — costlier, and it must run every period or you lose versions).

## Tests that earn their keep

- `[req]` On every key: `unique` and `not_null`. These two catch most pipeline breakage.
- `[conv]` `relationships` for foreign keys into marts; `accepted_values` only for genuinely closed sets (a status enum, not a country list that changes).
- `[conv]` Singular tests for business rules that would have caught the last incident: totals reconcile, no future-dated rows, a partition is non-empty, a rate falls in 0–1.
- `[conv]` `store_failures: true` on the tests you expect to fail someday, so the offending rows are inspectable instead of just a count.
- `[conv]` `dbt build` runs tests with models in DAG order — that is the default command, not `dbt run` followed by `dbt test` later.

## Freshness as a contract

- `[conv]` Declare `freshness` (`warn_after`, `error_after`) on sources and, in dbt 2.0+, on models; check with `dbt freshness` (`dbt source freshness` is the legacy command, still supported).
- `[conv]` Freshness belongs in the DAG, not in a wiki: a source that silently stops updating is the most common real incident, and it never throws an error.
- `[conv]` Distinguish stale (no new rows) from broken (job failed). They need different alerts.

## Quality beyond uniqueness

- `[conv]` **Volume**: row counts within an expected band (a 90 % drop is usually an upstream change, not a good day).
- `[conv]` **Distribution drift**: a category that disappears, a null rate that jumps, a mean that doubles.
- `[conv]` **Referential integrity**: every fact row resolves to a dimension, or the orphans are counted and explained.
- `[conv]` **Reconciliation**: the mart total equals the source total for the same window — the check that catches fan-out and double counting.

## CI and cost

- `[conv]` Slim CI: `dbt build --select state:modified+` against the production manifest (`--defer --state prod-manifest/`), so a PR tests only what it changed and its children.
- `[conv]` Every model that runs in CI costs warehouse money. Partition filters and incremental windows are the levers; a full-refresh PR is a budget decision.
- `[conv]` Contracts / `constraints` where the warehouse enforces them, when a model is consumed by something with its own schema expectations.
