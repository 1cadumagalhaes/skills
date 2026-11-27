# Social analytics eval fixture

This is a small eval fixture, not production code. It models a daily Airflow ingestion DAG and dbt BigQuery models for social post metrics. The ad-spend pipeline the eval asks for does not exist here on purpose: this fixture only provides the conventions to follow. Dates are parameterized so the same task graph can be used for daily runs and bounded backfills. The source API and cloud project are fictional.
