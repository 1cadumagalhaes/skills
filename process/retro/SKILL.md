---
name: retro
description: Run a session retrospective and fix repeated agent mistakes in repo architecture, types, checks, or skills.
cluster: process
tier: root
disable-model-invocation: true
derived_from: {repo: mattpocock/skills, commit: abeeaf95660b, license: MIT}
---

# Retrospective and mistake-proofing

| When | Read |
|---|---|
| Editing agent-facing guidance | `~/.agents/skills/agent-docs/SKILL.md` |
| Removing vague or padded prose | `~/.agents/skills/unslop/SKILL.md` |

Turn repeated agent mistakes and friction into durable fixes in the repository or agent tooling. Fix classes of mistakes at the highest enforceable level, never with prose alone when code or tooling can block the error.

When editing any skill or `AGENTS.md`, read `agent-docs` and finish with `~/.agents/skills/unslop/SKILL.md`.

## Phase 1: Gather primary evidence

Inspect the evidence sources relevant to the request:

1. Current conversation transcript or specific session logs (`~/.pi/agent/sessions/`, `~/.local/share/opencode/opencode.db` read-only, or project OptMem logs). In T3 Code, `t3_thread_read` and `t3_thread_search` reach past and parallel threads directly, and `task_status` shows what a delegated run produced, so read those before mining raw transcript files. Outside T3 Code, those transcript paths are the only source: read them directly.
2. Recent commits, reverts, PR review findings, and workaround comments in the target repo.
3. Repo steering files (`AGENTS.md`, `CODING_STANDARDS.md`, `DESIGN.md`, `Makefile`, CI workflows).

Group observed friction into concrete mistake classes. Count a pattern as a recurring class once it has happened at least twice or caused significant rework.

## Phase 2: Fix at the highest level that works

For each mistake class, pick the highest level in this order that prevents recurrence:

1. **Architecture.** Give each piece of state one owner and each task one supported path. Hide internals behind module boundaries, replace hand-synced lists with one generator or script, and delete legacy paths an agent would imitate.
2. **Types.** Encode invariants in the type system (`ty`, TypeScript strict types, Rust enums/newtypes) so invalid states fail typechecking.
3. **Deterministic check.** Add a Ruff rule, custom lint, pre-commit check, `Makefile` target, or CI test whose failure message names the exact replacement file, symbol, or command. Read existing repo check scripts before inventing a new one. Missing pre-commit or CI checks in an active repo count as a finding.
4. **Behavior test.** Add or repair a test that fails when the broken behavior returns and stays green across internal refactors.
5. **Docs and skills last.** Reserve `AGENTS.md`, `CODING_STANDARDS.md`, and skills for genuine judgment calls, navigation pointers, or tool economy. Always obey the rule table below: keep `AGENTS.md` thin with pointers, route review standards to review time rather than bloating implementation context, and delete no-op lines.

## Phase 3: Prove the enforcement

Before reporting done:

- Apply the highest-impact fixes (or propose them cleanly if asked for review only).
- **Prove every new deterministic check catches the real mistake.** Test it against the past failure state or a minimal broken snippet and show the failing output, then run it clean on the fixed state.
- Report the evidence per class: mistake class and counts, level chosen, why a higher level could not hold it, command and output proving the new check works, and any remaining judgment-only items.

Synthesized from `mattpocock/skills` `retro` (MIT, Matt Pocock) and `backnotprop/pstack` `correct` (MIT, Lauren Tan).
