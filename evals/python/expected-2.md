# python / prompt-2

## Must decide
- Do not blanket-ignore: run `uv run ty explain rule <rule>` for that diagnostic first, then either fix the type or narrow the suppression to the rule.
- If suppression is right, it is `# ty: ignore[<rule>]` with an inline reason on that line only, never file-wide and never an ignore-everything setting.
- Keep mypy and pyright out of the project; ty is the checker, and adding a second checker is not the escape hatch.

## Must show
- The rule explained (name and what it protects) before any suppression appears.
- The exact edit: one line, rule-scoped, with the reason, or the small type fix that removes the diagnostic.
- `uv run ty check` re-run clean after the change, with `uv run pytest -q` still green.
- If the diagnostic marks a real bug (Optional not handled, None in a hot path), the bug is fixed, not suppressed.

## Miss if
- Writes the bare `# type: ignore` and calls it done.
- Adds per-module or global ty ignores broad enough to hide the class of error.
- Suppresses without re-running ty, or introduces mypy to double check.
