# repo-defaults / prompt-3

## Must decide
- A branch diff review is not a baseline pass: hand off to the leaf `~/.agents/skills/code-review/SKILL.md` (review since a fixed point).
- Fix the point first: `git merge-base origin/main HEAD`, then review only the changed files and their direct callers.
- The baseline still applies before judging: `AGENTS.md`, `Makefile`, `DESIGN.md` define the repo standards.

## Must show
- chained: `~/.agents/skills/code-review/SKILL.md`, with the merge-base SHA named in the report.
- Two axes side by side: repo standards and the spec/issue the branch claims to implement.
- `make check` (or the repo check command) exit status on the branch, not on `main`.
- Findings with `file:line`; a clean baseline does not replace the review.

## Miss if
- Runs a six-dimension audit or a rewrite critique on the diff.
- Reviews with no fixed point, or flags files the branch never touched.
- Reports findings without the repo check status, or does not run the check at all.
