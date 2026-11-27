---
name: code-audit
description: Audit existing code for bugs, data structure/perf flaws, decomposition, system design, anti-patterns, and explicit config. Use when reviewing a module or before extending code.
cluster: engineering
tier: root
---

# Code quality

| When | Read |
|---|---|
| Evaluating module boundaries and seams | `~/.agents/skills/module-design/SKILL.md` |
| Reviewing a branch or pull request diff | `~/.agents/skills/code-review/SKILL.md` |
| Mapping change impact before edits | `~/.agents/skills/blast-radius/SKILL.md` |
| Writing tests test-first | `~/.agents/skills/tdd/SKILL.md` |
| Stress-testing an uncertain plan | `~/.agents/skills/grilling/SKILL.md` |
| Attacking a just-implemented change with adversarial tests | `~/.agents/skills/chaos-engineering/SKILL.md` |

Audit existing code as it stands and return a ranked list of real problems with minimal fixes, never a rewrite proposal or style report. For branch or PR diff review, use `~/.agents/skills/code-review/SKILL.md` instead.

## Scope first

Before judging code, answer in one line each:

- What this code owns and what it does not own
- Who calls it and what invariant they rely on
- The hot path or primary reason it exists
- Whether it holds or computes state, and where that state lives

For a whole service, map the entry points and the three most-called functions first.

## Six dimensions in order

Work down this list in priority order and stop when the task budget is spent:

1. **Correctness.** Bounds, nulls, empties, error paths, partial failures, retries/idempotency, cleanup, swallowed exceptions (`references/bugs-and-failure-modes.md`).
2. **Data structures and performance.** Access-pattern fit, hot-path complexity, N+1 round trips, allocations in loops. Measure or prove complexity; mark estimates unmeasured (`references/data-structures-and-performance.md`).
3. **Decomposition.** Single responsibility, seam placement, pure steps vs hidden state, caller reuse (`references/decomposition.md`).
4. **System design.** Dependency direction, coupling, failure isolation, behavior when dependencies fail, observability (`~/.agents/skills/system-design/references/system-design-patterns.md`).
5. **Anti-patterns.** Name a smell (god object, feature envy, shotgun surgery, leaky abstraction, primitive obsession, hidden temporal coupling) only alongside its concrete cost here.
6. **Explicit configuration.** Edge validation, visible defaults, single source of truth, clear split between config, constants, and secrets (`references/configuration.md`).

## Finding bar

Report only defects you can verify directly in the code:

- State the failure or cost, trigger condition, and `file:line`.
- Propose the smallest fix that removes the problem (extract, rename, hoist, invert, or delete).
- Skip formatting and naming taste owned by repo linters.
- Keep abstractions out until two real callers exist.
- Mention unrelated pre-existing problems once briefly without expanding scope.

## Rank and report

Order findings by impact times likelihood:

    [blocker] path/file.py:214 - <what fails>, triggers when <condition>.
      Fix: <minimal change>.

    [major] path/file.py:88 - <structure/perf/design flaw>, costs <what and how much>.
      Fix: <minimal change>.

Close with two short lines: what you left unassessed, and the single highest impact-to-effort fix.

## Delegation

- Under 500 lines: audit inline.
- Larger scope or independent pass needed: dispatch a read-only `delegate_task` (`role: "review"`, fresh context, `You are a subagent. Don't run memo. Read ~/.agents/worker.md first.`) on a different model family with the closed file list, then merge and verify its findings before reporting. Outside T3 Code, use the harness's own read-only subagent with the same kickoff line and scope (per-harness table in `~/.agents/skills/delegate/SKILL.md`).
- Whole-architecture questions ("should this split into two services") belong in a design conversation, not a code audit; say so and stop.
