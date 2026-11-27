# python / prompt-3

## Must decide
- Standalone script: PEP 723 inline metadata, dependencies declared in the script, executed with `uv run script.py`. No project, no manual venv, no `pip install`.
- A write of 400k rows still needs batching, a dry run, and idempotency; the data rules travel with the script.
- Dependency edits go through `uv add --script script.py <pkg>`, never a hand-edited header or a side `requirements.txt`.

## Must show
- The `# /// script` block with `[project].dependencies` and `requires-python`, and `uv run script.py` as the run command.
- `uv run script.py --dry-run` first, with the row count it reports, before the real run.
- Batched writes with a bounded size, a resume cursor, and the dedupe key that makes a rerun safe.
- chained: `~/.agents/skills/data-engineering/references/bigquery.md` for the load rules.

## Miss if
- `pip install`, `python3 -m venv`, or a `requirements.txt` for a single script.
- Pushes 400k rows in one job with no batch, dry run, or idempotency key.
- Drops the data-engineering rules because the file is not a project.
