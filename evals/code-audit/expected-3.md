# code-audit / prompt-3

## Must decide
- A diff review is the leaf `~/.agents/skills/code-review/SKILL.md` (Standards + Spec since a fixed point), not the six-dimension audit.
- The fixed point is explicit: `git merge-base origin/main HEAD`; only changed files and their direct callers are in scope.
- Standards means the repo documented rules (`AGENTS.md`, lint config), not personal preference.

## Must show
- chained: `~/.agents/skills/code-review/SKILL.md`, with the merge-base SHA named in the report.
- Two reports side by side: standards findings and spec/issue coverage, each with `file:line`.
- The repo check run on the branch (`make check` or equivalent) with exit status, not assumed green.
- Retry-specific questions asked of the diff: idempotency on replay, bounded retries with backoff, no retry on non-retryable 4xx.

## Miss if
- Runs the six-dimension audit on the branch.
- Reviews with no fixed point, or includes untouched files as findings.
- Reports style nits while missing an uncapped retry loop or duplicated writes.
