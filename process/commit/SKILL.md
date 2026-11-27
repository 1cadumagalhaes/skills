---
name: commit
description: Split work into small verifiable commits with conventional subjects, an issue key in the subject and a body that explains why. Use when staging, splitting, or writing commit messages.
cluster: process
tier: root
disable-model-invocation: true
---

# Commits

A commit is a reviewable unit with one reason to change. `repo-defaults` sets the floor, meaning conventional subjects and no secrets. This skill is the craft on top of that floor.

| When | Read |
|---|---|
| Deciding what ships in which PR | `~/.agents/skills/pr/SKILL.md` |
| A bug fix that needs its failing repro first | `~/.agents/skills/debug/SKILL.md` |

## Size: one reason to change

- The unit is a reason, not a file count. A 6-file rename and a 20-line behavior change are two commits even when they touch the same file.
- Every commit builds and passes its own checks. If a split cannot satisfy that, the split is wrong, not the rule: `git bisect` has to land on a commit that tells the truth.
- If the subject would need "and", split it.
- Small enough to review in a minute, large enough to be worth writing a message about. Micro is not trivial.

## Splitting a diff

- **Mechanical before behavioral.** Rename, move, or reformat first with a `refactor:` subject and no behavior change, then the behavior in its own commit. A reviewer should never have to diff a rename against a logic change.
- **Schema ships in steps.** Expand, backfill, contract are three commits in that order, each deployable.
- **A test belongs with the fix it proves**, unless the failing test has to land first to show the bug: then the repro commit goes before the fix, never after it.
- **Generated files and lockfile churn** travel with the change that caused them, alone when the diff is large.

## Stage deliberately

- `git add -p` for anything non-trivial, then `git diff --cached` before every commit. `git add -A` only in a tree that holds nothing else you did not intend.
- Never stage a secret, an `.env*` file, or an unrelated file. If a secret is already tracked, removing it and adding it to `.gitignore` is its own commit, and it goes first.
- A formatting-only pass stays out of a behavior commit, even when the formatter ran on its own.

## Message

- **Subject:** `type(scope): imperative summary`, 72 characters at most, no trailing period, and an issue key when the repo uses one, as in `feat(api): retry a 503 twice CLUBE-123`.
- **Body:** the why and the tradeoff. The what is in the diff, so do not narrate it. Wrap at 72, one blank line after the subject.
- **Reference or close:** `Refs #12` for partial work, `Closes #12` only in the commit that finishes the issue.
- **Types:** feat, fix, refactor, perf, test, docs, build, ci, chore.

## History hygiene

- Amend or `--fixup` only commits not yet pushed on your own branch. Never rewrite a shared branch without being asked.
- Order the commits so a reviewer reads them as a story: prerequisite first, behavior second, cleanup last.
- A pre-commit hook failure is information about your diff, not an obstacle. Fix the cause and never pass `--no-verify` unless the user says so.

## Before pushing

- `git log --oneline @{u}..` reads as intended, every subject honest about its type.
- `git diff @{u}` shows only the lines you meant to change.
- The repo check is green on the last commit, not only in your working tree.
