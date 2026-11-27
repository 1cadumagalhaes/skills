---
name: python
description: "Python tooling workflow: uv for deps and execution, Ruff for lint/format, ty for typing, pytest, and standard Makefile targets. Use when creating or changing any Python project."
cluster: engineering
tier: root
---

# Modern Python

| When | Read |
|---|---|
| Setting module boundaries or public interfaces | `~/.agents/skills/module-design/SKILL.md` |
| Auditing existing Python code | `~/.agents/skills/code-audit/SKILL.md` |

Run all Python commands and dependency changes through `uv`. Never install via `pip`, edit dependency lists manually instead of using `uv`, or create manual virtualenvs.

## Immutable rules

- Manage dependencies only via `uv add`, `uv add --dev`, and `uv remove`.
- Execute tools and scripts via `uv run <cmd>` so locked environments stay synced.
- Commit `uv.lock` and `.python-version`.
- Fix all `ty check` errors before reporting work done.
- In FastAPI endpoints, import status constants (`from fastapi import status`) instead of bare HTTP numeric codes.

## Default project layout

```text
pyproject.toml
.python-version      # uv python pin
uv.lock
src/<package>/       # src layout
tests/
Makefile
```

## Core commands

| Task | Command |
|---|---|
| New project | `uv init <name> && cd <name>` |
| Pin Python | `uv python pin 3.14` |
| Add / remove dependency | `uv add <pkg>` / `uv remove <pkg>` |
| Add dev dependency | `uv add --dev <pkg>` |
| Run command | `uv run <cmd>` |
| Sync environment | `uv sync` |
| Standalone script | PEP 723 metadata + `uv run script.py` (`uv add --script <pkg>`) |
| Lint | `uv run ruff check .` |
| Format | `uv run ruff format .` |
| Type check | `uv run ty check` |
| Test | `uv run pytest -q` |

Upgrade dependencies via `uv lock --upgrade-package <pkg>` or `uv lock --upgrade` (reviewed separately), and verify consistency with `uv lock --check`.

## Typing with ty

- Configure `[tool.ty]` in `pyproject.toml` or `ty.toml` and run `uv run ty check` from project root.
- Let `project.requires-python` set the target Python version.
- Explain unexpected rules with `ty explain rule <rule>` before adding `# ty: ignore` with an inline reason.
- Keep mypy and pyright configs out of projects standardized on `ty`.

## Lint and format with Ruff

- Configure `[tool.ruff]` in `pyproject.toml` and use Ruff for both linting and formatting instead of Black, isort, or flake8.
- Pass criteria: `uv run ruff check .` clean and `uv run ruff format --check .` clean.

## Tests with pytest

- Keep tests under `tests/test_<module>.py` and run via `uv run pytest`.
- Add failing regression tests before fixing bugs and pair new behavior with tests.
- Prefer fixtures over setup/teardown boilerplate, parametrize repetitive cases, and isolate unit tests from live network calls.

## Standard Makefile

Expose these targets so humans and agents share one entry point:

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

Done in a Python repo means `make check` exits zero with reported test counts.

## References

- uv projects and CLI: https://docs.astral.sh/uv/guides/projects/
- ty CLI and configuration: https://docs.astral.sh/ty/reference/cli/
- Ruff configuration: https://docs.astral.sh/ruff/configuration/
- pytest documentation: https://docs.pytest.org/
