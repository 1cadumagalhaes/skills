---
name: data-engineering
description: Building or fixing a data pipeline — Airflow DAGs, BigQuery and Postgres SQL, API ingestion, dbt models and data-quality checks. Use when writing or reviewing a DAG, when a query costs too much or scans too much, when deciding how to load or extract incrementally, when a backfill must be safe to re-run, or when defining freshness and tests for a dataset.
---

# Data engineering

Pipelines fail in four predictable ways: they are not idempotent, they scan too much, they trust the source, and nobody notices until a report is wrong. This skill is organised around those.

| you are | read |
|---|---|
| writing or reviewing an Airflow DAG | `references/airflow.md` |
| writing BigQuery SQL, or a query is slow/expensive | `references/bigquery.md` |
| extracting from or loading into Postgres | `references/postgres.md` |
| modelling with dbt, or defining data-quality checks | `references/dbt-and-quality.md` |
| pulling from an API or a website | `references/ingestion.md` |

Adjacent: app schema and transactions → `backend`; architecture at scale → `~/.agents/skills/dsa-system-design/references/system-design-patterns.md`; extraction mechanics and anti-bot → `webscraping-expert`.

## Non-negotiables

1. **Every task and every load is idempotent.** Re-running a window produces the same table, not a duplicate. If it cannot be re-run, it cannot be backfilled, and a backfill is how you fix a wrong number.
2. **Incremental means a watermark, never `OFFSET`.** `updated_at`/monotonic id, stored per source, advanced only after the write commits.
3. **Cost is bytes scanned.** A query without a partition filter on a partitioned table is a budget incident, not a style issue.
4. **Raw is immutable.** Land the payload as received, transform downstream. If the transform is wrong, replay from raw instead of re-fetching the world.
5. **A pipeline without a test is a rumour.** Freshness, volume, uniqueness, referential integrity — at least the ones that would have caught the last incident.
6. **Backfills run with the same code and the same tests as the daily run.** A separate backfill script is a second implementation that will drift.

## Layers

    raw/bronze    as received, append-only, partitioned by load date
    staging       typed, deduped, one row per entity per source
    marts         business entities, tested, documented, what BI reads

Never let a consumer read raw. Never fix a mart by editing staging by hand.

## Sources consulted

Airflow 3.4 Best Practices · BigQuery "Introduction to optimizing query performance" · Airflow Google provider (BigQuery operators) · Mozilla `bigquery-etl` recommended practices · dbt best practices, CDC guide and `freshness` reference · PostgreSQL 18 docs (COPY, MERGE, VACUUM, isolation).
