# repo-defaults / prompt-1

## Must decide
- Read before editing: repo `AGENTS.md`, `DESIGN.md`, `README`, `Makefile`, existing tests, and `~/Work/retize/AGENTS.md` (Retize rules, `~/.pgpass` only, never `PGPASSWORD`).
- One logical unit: tests for `sources/` plus the `make check` wiring, no drive-by edits elsewhere.
- `graphify query` only if `graphify-out/graph.json` exists; otherwise say so and grep.

## Must show
- artifact: `tests/test_sources_*.py` inside the repo, matching the existing test layout and fixtures.
- `Makefile`: the `check` target now includes the new tests (not a new ad-hoc script).
- command: `make check` run to completion, exit 0, test count reported.
- commit shape `test(sources): ...` or `build(make): ...` in Conventional Commits form, only if a commit was asked for.

## Miss if
- Tests written in `/tmp`, or the change touches unrelated files.
- Claims tests added with no `make check` output or count.
- Hides a failure instead of reporting it separately with counts.
