# code-audit / prompt-1

## Must decide
- Scope line first, four one-liners: what the package owns and does not, callers and the invariant they rely on, the hot path, whether state is held or computed.
- 700 lines is over the 500-line inline budget, so dispatch a read-only delegate (`role: "review"`, closed file list, different model family, the subagent first line) and verify its findings before reporting.
- Only verifiable defects, ranked by impact x likelihood, each with the smallest fix. No rewrite proposal, no style report.

## Must show
- Findings in the required shape: `[blocker|major|minor] path/file.py:214 - <what fails>, triggers when <condition>.` plus `Fix: <minimal change>.`
- Coverage in dimension order (correctness, data structures/perf, decomposition, system design, anti-patterns, explicit config), with perf claims marked measured or unmeasured.
- The closing two lines: what was left unassessed, and the single highest impact-to-effort fix.
- chained: `references/bugs-and-failure-modes.md` and `references/data-structures-and-performance.md` for findings that need the checklist.

## Miss if
- Proposes restructuring or rewriting the package instead of ranked minimal fixes.
- Findings without `file:line` or without a trigger condition.
- Audits files outside `src/ingest/`, or accepts the delegate list without re-checking the top findings.
