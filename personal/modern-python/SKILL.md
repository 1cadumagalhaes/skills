---
name: modern-python
description: My modern Python tooling workflow — uv for everything, Ruff, ty, typed code, Makefile commands. Use when creating, scaffolding or changing any Python project, adding dependencies, or setting up lint/types/tests.
---

# Modern Python

All Python work goes through **uv**. No `pip install`, no manual `requirements.txt`, no hand-managed venvs, no `python -m venv`.

## Immutable rules

- Dependencies change **only via the uv CLI** (`uv add`, `uv remove`) — never edit `pyproject.toml` dependencies by hand, never run pip.
- Everything runs through `uv run` (it locks and syncs before executing, guaranteeing a consistent environment).
- `uv.lock` and `.python-version` are committed. `pyproject.toml` is never the source of exact versions.
- Typing is mandatory: `ty check` passes with zero errors before anything is considered done.

## Project layout (uv default)

```text
pyproject.toml
.python-version      # uv python pin
uv.lock
src/<package>/       # src layout, no implicit sys.path
tests/
Makefile
```

## Commands

| Task | Command |
| --- | --- |
| New project | `uv init <name> && cd <name>` |
| Python version | `uv python pin 3.14` |
| Add/remove dependency | `uv add <pkg>` / `uv remove <pkg>` |
| Add dev dependency | `uv add --dev <pkg>` |
| Run anything | `uv run <cmd>` (e.g. `uv run pytest`) |
| Sync env | `uv sync` (exact sync; removes extraneous packages) |
| Single-file script | PEP 723 inline metadata + `uv run script.py` (`uv add --script <pkg>`) |
| Lint | `uv run ruff check .` |
| Format | `uv run ruff format .` |
| Type check | `uv run ty check` |
| Test | `uv run pytest -q` |

Upgrade discipline: `uv lock --upgrade-package <pkg>` (surgical) or `uv lock --upgrade` (all, separately reviewed). Never edit `uv.lock` manually; `uv lock --check` proves the lock matches `pyproject.toml`.

## Typing — ty

- Config lives in `pyproject.toml` (`[tool.ty]`) or a `ty.toml`; run `ty check` from project root.
- Target version comes from `project.requires-python` automatically.
- Suppress only with `ty: ignore` comments, always with a reason on the same line.
- Unexplained rule? `ty explain rule <rule>` before suppressing anything.
- Do not add mypy/pyright config; ty is the checker.

## Style — Ruff

- Ruff is both linter and formatter (`ruff check`, `ruff format`); no Black/isort/flake8.
- Config in `pyproject.toml` under `[tool.ruff]` (`lint.select`, `line-length`).
- A file passes = `ruff check` clean and `ruff format` idempotent.

## Tests — pytest

- Tests live in `tests/`, named `test_<module>.py`, run via `uv run pytest`.
- New behavior ships with a test; bugfix must fail before the fix (add a regression test first when reproducing a bug).
- Fixtures over setup/teardown; parametrize over copy-paste loops; no network in unit tests.

## Makefile — the stable front door

Every project exposes the same targets; agents and humans use only these:

```makefile
.PHONY: setup lint fmt typecheck test check
setup:        ## create env, install locked deps
	uv sync
lint:         ## ruff check
	uv run ruff check .
fmt:          ## ruff format + fix lint
	uv run ruff format . && uv run ruff check --fix .
typecheck:    ## ty
	uv run ty check
test:         ## pytest
	uv run pytest -q
check: lint typecheck test
```

"Done" for a change in this repo = `make check` green.

## References

- uv project guide — https://docs.astral.sh/uv/guides/projects/ (init/add/lock/sync/run; lockfile semantics, universal lock)
- uv CLI — https://docs.astral.sh/uv/reference/cli/ (`uv format`, `uv check`, `uv audit`, `--locked`/`--frozen`)
- ty CLI — https://docs.astral.sh/ty/reference/cli/ (check, explain, baselines, exit codes)
- ty config — https://docs.astral.sh/ty/reference/configuration/
- Ruff settings — https://docs.astral.sh/ruff/configuration/
- pytest — https://docs.pytest.org/