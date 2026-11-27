from datetime import date, timedelta


def date_window(logical_date: date, dag_run_conf: dict | None = None) -> tuple[date, date]:
    """Return a half-open [start, end) window, honoring an explicit backfill range."""
    conf = dag_run_conf or {}
    start = date.fromisoformat(conf["start_date"]) if conf.get("start_date") else logical_date
    end = date.fromisoformat(conf["end_date"]) if conf.get("end_date") else start + timedelta(days=1)
    if end <= start or (end - start).days > 90:
        raise ValueError("window must be positive and at most 90 days")
    return start, end
