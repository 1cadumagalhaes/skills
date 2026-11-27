---
name: data-engineering
description: "Data pipelines and warehouses: Airflow DAGs, BigQuery and Postgres SQL, dlt/API ingestion, dbt models, and data-quality checks. Use when changing pipelines, optimizing costly queries, or adding tests."
cluster: engineering
tier: root
---

# Data engineering

| When | Read |
|---|---|
| Defining application or pipeline domain entities | `~/.agents/skills/domain-modeling/SKILL.md` |
| Choosing distributed data architecture | `~/.agents/skills/system-design/SKILL.md` |
| Scraping sites with anti-bot defenses | `~/.agents/skills/webscraping/SKILL.md` |

Pipelines fail in four recurring ways: non-idempotent loads, unbounded scans, blind trust in source payloads, and silent stale or wrong outputs.

| Task | Read |
|---|---|
| Writing or reviewing an Airflow DAG | `references/airflow.md` |
| Writing BigQuery SQL or cutting scan cost | `references/bigquery.md` |
| Extracting from or loading into Postgres / AlloyDB | `references/postgres.md` |
| Modeling with dbt or writing data-quality checks | `references/dbt-and-quality.md` |
| Ingesting with `dlt` or from an API | `references/ingestion.md` |

Adjacent guides: read `backend` for app schemas and transactions, `~/.agents/skills/system-design/SKILL.md` for distributed storage architecture, and `~/.agents/skills/webscraping/SKILL.md` for anti-bot scraping mechanics.

## Non-negotiables

1. **Make every task and load idempotent.** Re-running a window produces the exact same rows rather than duplicates, so backfills are safe.
2. **Drive incremental loads with a watermark, never `OFFSET`.** Persist `updated_at` or monotonic cursor per source and advance only after the target write commits.
3. **Control scan cost on partitioned tables.** Always enforce partition filters in BigQuery and inspect bytes scanned before running or shipping queries.
4. **Keep raw payloads immutable.** Land raw bronze data first and transform downstream so fixes replay locally without re-fetching upstream APIs.
5. **Ship data-quality checks with every pipeline.** Cover freshness, volume, uniqueness, and referential integrity, starting with checks that catch past incidents.
6. **Run backfills through the same code and tests as daily runs.** Separate backfill scripts drift from production logic.

## Layers

```text
raw/bronze   append-only as received, partitioned by load date
staging      typed, deduplicated, one row per entity per source
marts        tested, documented business entities consumed by BI
```

Keep consumers on marts rather than raw, and fix defects upstream instead of patching marts by hand.

## Sources

Airflow 3.4 Best Practices, BigQuery query optimization docs, Airflow Google provider BigQuery operators, Mozilla `bigquery-etl`, dbt best practices and freshness docs, PostgreSQL 18 docs (COPY, MERGE, VACUUM, isolation).
