---
name: pr
description: Author concise, evidence-backed PRs and stacked PRs following Cadu's GitHub workflow.
cluster: process
tier: root
disable-model-invocation: true
derived_from: {repo: mattpocock/skills, commit: abeeaf95660b, license: MIT}
---

# Pull requests

| When | Read |
|---|---|
| Reviewing a changed branch | `~/.agents/skills/code-review/SKILL.md` |
| Mapping likely impact before edits | `~/.agents/skills/blast-radius/SKILL.md` |

Create clean, verifiable PRs with compact visual summaries, measured before/after evidence, and explicit merge risk. Run all PR prose through `~/.agents/skills/unslop/SKILL.md`.

## GitHub and stack rules

- Title format: `type(scope): subject` in imperative mood.
- Pass `--base <intended trunk>` explicitly; never assume the repository default branch is the intended trunk.
- For stacked PRs, use GitHub-native stacks (`gh stack link`), never rebase PR branches unless explicitly asked, and verify stack order and each PR's base branch after linking.
- Open PRs ready for review unless the user asks for a draft.
- When reviewing a PR, present findings with reproduction evidence to the user for approval before posting comments or approvals to GitHub.

## Watching, reviewing and merging

In T3 Code, use the pull-request tools instead of `gh`: `link_pull_request` as soon as the PR exists (T3 tracks its status and settles the thread on merge), `pull_request_read` with `include: ["checks","threads","comments"]` to review, `pull_request_review` and `pull_request_respond` to comment and resolve, `pull_request_merge` with the head SHA you read.

To wait on CI, call `watch_pull_request` once and end the turn. It wakes the thread on failed checks, new comments or reviews, conflicts, and once on merge. Never sleep-loop, never `gh pr checks --watch`, never poll `task_status`. On a wake, read the cause with `ci_logs`, fix, push, and let the existing watch keep running. `ci_rerun` handles a flaky failure that is not yours.

Outside T3 Code, the fallback is `gh pr checks --watch` plus `gh pr view --comments`, run once and read, without a manual polling loop.

## PR body template

Keep the PR body to 40 lines at most. Drop any empty heading. Put long command logs, full test suites, and wide benchmark tables in a repo artifact or a linked PR comment rather than inline.

```markdown
## Summary

<smallest clear visual: pseudocode, call tree, shallow file tree, Mermaid diagram, or focused diff>

## What changed

- <concise bullet per logical change with file/module ownership>

## Evidence

- Before: <failing output, old metric, or baseline screenshot>
- After: <passing check command with counts, new metric, or after screenshot>
- Not verified / untouched: <explicit negative evidence, e.g. no DB writes, prod untouched>

## Merge danger

- Door: <one-way or two-way> (<why rollback is trivial or hard>)
- Blast radius: <affected callers, migrations, DAGs, wire contracts, or billing impact>
```

## Choosing the summary visual

Pick the smallest representation that makes the control flow, state transition, or structural boundary clear without overwhelming the reviewer:

- **Algorithm or state logic:** short pseudocode showing the decision branches.
- **Runtime control flow:** a shallow call tree or Mermaid sequence diagram.
- **File or module refactor:** a shallow file tree or `+`/`-` diff sketch.
- **UI component layout:** a minimal component tree naming state owners and modified leaves.

Done when the PR body fits within 40 lines, every claim cites observed command output or screenshots, merge danger explicitly classifies door reversibility and blast radius, and the prose passes `unslop`.

Synthesized from `mattpocock/skills` `pr` (MIT, Matt Pocock, crediting Dex Horthy's `show-me`) and `backnotprop/pstack` `worker.md` (MIT, Lauren Tan).
