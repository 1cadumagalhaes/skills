# python / prompt-1

## Must decide
- Everything through `uv`: `uv init`, `uv python pin 3.14`, `uv add fastapi httpx`, `uv add --dev pytest ruff ty`. No `pip`, no hand-edited dependency lists, no manual virtualenv.
- src layout (`src/<package>/`, `tests/`), with `uv.lock` and `.python-version` committed.
- Makefile exposes `setup lint fmt typecheck test check`, with `check: lint typecheck test`.

## Must show
- `make check` green with the pytest count in the report; `uv run ruff check .`, `uv run ruff format --check .`, `uv run ty check` all clean.
- FastAPI handlers importing `from fastapi import status` and using `status.HTTP_201_CREATED`, never bare `201`.
- One endpoint test through `httpx` ASGI transport with no live network.
- No mypy or pyright config in the tree; ty is the checker.

## Miss if
- `pip install`, `python -m pytest`, or editing `[project].dependencies` by hand.
- A manual `.venv` or `requirements.txt`, or `uv.lock` left uncommitted.
- `make check` skipped, or ty errors suppressed instead of fixed.
