# debug / prompt-1

## Must decide
- Redact first: no tokens, passwords, or DSNs in commands or artifacts; credentials come from env or `~/.pgpass`.
- Phase 1 before theories: a red-capable, deterministic, fast loop asserting the doubled total for a multi-contract client, e.g. `uv run pytest tests/test_invoice.py -k multi_contract` with a two-contract fixture. Not a `print` in the handler.
- No Phase 2 until the loop ran once, is red, and asserts the reported symptom.

## Must show
- The named command and its redacted red output, plus why it is tight (seconds, pinned fixture).
- Minimization to load-bearing elements: two contracts vs one, shared invoice vs none.
- 3-5 ranked falsifiable hypotheses (`If <X>, then changing <Y> changes the output to <Z>`), then one probe at a time tagged `[DEBUG-xxxx]`.
- Regression test at the real seam, smallest root-cause fix, original loop green, `make check` counts.
- Cleanup: `grep -rn '\[DEBUG-'` returns nothing, no scratch files in `/tmp`.

## Miss if
- Opens with a theory or a fix before any red loop exists.
- Writes a test that mocks away the join or aggregation where the bug lives.
- Leaves debug markers or files behind, or reports done without re-running the un-minimized loop.
