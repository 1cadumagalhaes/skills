from datetime import date
from pathlib import Path
import sys

from airflow.models import DagBag

DAGS_PATH = Path(__file__).resolve().parents[1] / "dags"
sys.path.insert(0, str(DAGS_PATH))
from common.utils import date_window


def test_dag_loads_without_import_errors():
    bag = DagBag(dag_folder=str(DAGS_PATH), include_examples=False)
    assert "social_posts_daily" in bag.dags
    assert not bag.import_errors
    assert set(bag.dags["social_posts_daily"].task_ids) == {"load_api_window", "dbt_mart_build"}


def test_backfill_window_is_bounded_and_half_open():
    assert date_window(date(2026, 11, 27), {"start_date": "2026-11-24", "end_date": "2026-11-27"}) == (date(2026, 11, 24), date(2026, 11, 27))
