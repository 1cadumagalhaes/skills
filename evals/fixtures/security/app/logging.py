import json
import logging
from typing import Any

_sink = logging.getLogger("member-api")


def log_event(event: str, fields: dict[str, Any]) -> None:
    """Current fixture logger serializes supplied fields without redaction."""
    _sink.info(json.dumps({"event": event, **fields}, default=str))
