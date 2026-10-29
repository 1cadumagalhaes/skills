---
name: project-baseline
description: My default project conventions — how I read, structure, verify, document and commit in any repo. Use as the base layer when starting work in a project or when no more specific skill applies.
---

# Project baseline

Defaults for any project (before more specific skills like `modern-python`, `frontend-workflow`, `design-contract`, or the `retize-*` set apply).

## Reading first

- `AGENTS.md` (repo), `DESIGN.md`, `README`, existing tests and Makefile/justfile: conventions beat my defaults. Prebuilt knowledge graph? `graphify query` before grepping (`graphify` skill).
- When touching a DB, read the repo's own DB doc first (in Retize repos: `~/Work/retize/AGENTS.md` — ports are environment-sensitive, never set `PGPASSWORD`, `~/.pgpass` only).
- Large outputs get filtered before reaching context (`rtk` where available); artifacts go to files, not chat.

## Structure

- One change = one logical unit: smallest complete change that ships value, no drive-by's, unrelated files untouched.
- Follow the repo's existing naming and layout; consistency outranks taste.
- Scripts and repeated processes live in the repo (Makefile/skills), not in my head or /tmp.

## Verification

- "Done" = the repo's check command green (Makefile target otherwise), typed/linted per the repo's stack, and the behavior demonstrated (command output, test, or URL) — not assumed.
- Fail-closed by default: verification gates and calibration never assume success; when a check cannot run (no creds, no env), report it as unverified instead of inferring.

## Documentation & memory

- Durable decisions go to the repo's docs (`DESIGN.md`, `docs/`, `retize-docs` for team standards) — not to chat.
- Cross-session facts land in OptMem-Split: project store by default, `--global` only for what stays true in any repo.

## Commits

- Conventional Commit style: `type(scope): subject` (`feat`, `fix`, `chore`, `docs`, `refactor`, `test`), subject in imperative, no period, scope = module/app when the repo organizes by it.
- Commit messages carry the why in the body when the diff cannot say it.
- Never commit: secrets, `.env*`, secrets-adjacent files, half-states that break others' builds. Uncommitted user work is never overwritten or stashed away without asking.