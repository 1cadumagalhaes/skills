from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator

from common.utils import date_window

PROJECT = "demo-social-analytics"
DATASET = "raw"
SOURCE_TABLE = "social_posts"

POST_FIELDS = ("post_id", "account_id", "published_at", "impressions", "likes", "shares")


def fetch_posts(start: str, end: str) -> list[dict]:
    import requests

    response = requests.get(
        "https://api.example-social.test/v2/posts",
        params={"since": start, "until": end, "fields": ",".join(POST_FIELDS)},
        timeout=30,
    )
    response.raise_for_status()
    return response.json()["data"]


def load_window(logical_date=None, dag_run=None, **_context):
    from google.cloud import bigquery

    params = (dag_run.conf or {}) if dag_run else {}
    start, end = date_window(
        logical_date=logical_date,
        start_date=params.get("start_date"),
        end_date=params.get("end_date"),
    )
    rows = fetch_posts(start.isoformat(), end.isoformat())
    if not rows:
        return 0

    client = bigquery.Client(project=PROJECT)
    errors = client.insert_rows_json(
        f"{PROJECT}.{DATASET}.{SOURCE_TABLE}",
        rows,
        row_ids=[f"{row['post_id']}:{row['published_at'][:10]}" for row in rows],
    )
    if errors:
        raise RuntimeError(f"insert failed: {errors[:3]}")
    return len(rows)


with DAG(
    dag_id="social_posts_daily",
    start_date=datetime(2026, 1, 1),
    schedule="0 5 * * *",
    catchup=False,
    max_active_runs=1,
    params={"start_date": None, "end_date": None},
    default_args={"retries": 3, "retry_delay": timedelta(minutes=5)},
    tags=["analytics", "social"],
) as dag:
    load_posts = PythonOperator(task_id="load_posts", python_callable=load_window)

    build_mart = BashOperator(
        task_id="dbt_mart_build",
        bash_command="cd /opt/airflow/dbt && uv run dbt build --select social_posts_daily",
    )

    load_posts >> build_mart
