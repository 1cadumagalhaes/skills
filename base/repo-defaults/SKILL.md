---
name: repo-defaults
description: "Default repo conventions: reading order, minimal scope, verification bar, durable docs, and commits. Use when starting work in a repo or when no narrower skill fits."
cluster: base
tier: root
---

# Project baseline

Defaults for any repository before stack or domain skills apply. Project-level `AGENTS.md` and team skills always take precedence.

## Reading first

- Read repo `AGENTS.md`, `DESIGN.md`, `README`, `Makefile` or `justfile`, and existing tests before proposing changes.
- Query `graphify` (`graphify query "<question>"`) before grepping when `graphify-out/graph.json` exists.
- Read the repo database guide before touching any database. In Retize repos, read `~/Work/retize/AGENTS.md` first (ports are environment-sensitive; authenticate via `~/.pgpass` only, never set `PGPASSWORD`).
- Write durable outputs, test scratch, and reports inside the workspace rather than `/tmp`.

## Structure

- Keep each change to one logical unit: smallest complete patch that ships the value, no drive-by edits, leave unrelated files untouched.
- Match the repo's existing naming, formatting, and patterns; surface contradictions instead of blending styles silently.
- Put repeatable commands and checks in the repo (`Makefile` targets or scripts) rather than ad-hoc one-offs.

## Verification

- Done means the repo check command (`make check` or stack equivalent) is green, types and lint pass, and the behavior is demonstrated with command output, test counts, or a live check.
- Fail closed by default: when a check cannot run (missing credentials, offline environment, stopped VM), report it as unverified rather than inferring success. Report pre-existing failures separately with counts.

## Documentation and commits

- Record durable architectural or design decisions in repo docs (`DESIGN.md`, `docs/adr/`, or `docs/`) in the same change.
- Use Conventional Commits (`type(scope): subject`, imperative mood, no trailing period) and explain why in the body when the diff cannot show it.
- Never commit secrets or `.env*` files, and never stash or discard uncommitted user work without asking.
