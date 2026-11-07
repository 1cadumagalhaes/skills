---
name: code-quality
description: Judge existing code on its own terms — bugs, anti-patterns, decomposition, data structures, performance, system design, explicit configuration — and propose the smallest change that fixes each. Use when auditing a module, when code feels messy or slow, before extending something, or when asked whether code is good.
---

# Code quality

An audit of code **as it is**, not of a diff. The output is a ranked list of real problems with minimal fixes — not a rewrite proposal, not a style report.

Diff review is a different job (thermo-nuclear agents); this one is about state.

## Scope first

Before judging anything, answer in one line each:

- what this code owns and what it is not responsible for
- who calls it, and what they expect to stay true (the implied contract)
- the hot path or the reason it exists at all
- whether it stores or computes state, and where that state lives

If the scope is a whole service, map the entry points and the three most-called functions first. Do not read everything.

## The six dimensions, in order

Work in this order. Stop when the budget for the task is spent — a shallow pass over all six beats a deep pass over the first one.

1. **Correctness** — bounds, nulls, empties, error paths, partial failure, retries/idempotency, resource cleanup, swallowed exceptions. → `references/bugs-and-failure-modes.md`
2. **Data structures and performance** — does the structure match the access pattern; complexity in the hot path; N+1 round trips; allocation in loops. Measured or reasoned, never guessed. → `references/data-structures-and-performance.md`
3. **Decomposition** — is this one job; where the seam is; pure step vs hidden state; would a second caller reuse it. → `references/decomposition.md`
4. **System design** — dependency direction, coupling, failure isolation, what happens when a dependency is down, what is observable. → `~/.agents/skills/dsa-system-design-optimizer/references/system-design-patterns.md`
5. **Anti-patterns** — name the smell when it is genuinely there (god object, feature envy, shotgun surgery, leaky abstraction, primitive obsession, hidden temporal coupling), and say what it costs here. A smell named without a cost is noise.
6. **Explicit configuration** — no magic values; parsed and validated at the edge; defaults visible; one source of truth; config vs constant vs secret told apart. → `references/configuration.md`

## Finding bar

Report only what you can defend from the code:

- every finding names the failure or cost, the condition that triggers it, and `file:line`
- the fix is the **smallest change that removes the problem** — extract, rename, hoist, invert, delete. Not "refactor the module"
- style, formatting and naming-for-taste are out of scope; the project's linters own them
- no abstraction before there are two callers; no pattern for its own sake
- if a concern needs a measurement to be honest, say "unmeasured" or measure it
- pre-existing issues in code you were not asked about: mention once, briefly, do not investigate

## Rank and report

Order by **impact × likelihood**, not by file or by dimension. Format:

    [blocker] path/file.py:214 — <what is wrong>, breaks when <condition>.
      Fix: <the minimal change>.

    [major] path/file.py:88 — <structure/perf/design problem>, costs <what, how much>.
      Fix: <minimal change>.

    [minor] ...

Close with two short lines: what you deliberately did not assess, and the one change with the best impact-to-effort ratio if they only do one thing.

## Delegation

- Under ~500 lines: audit inline.
- Larger, or when an independent model should look: hand the file list to the `auditor` agent (read-only, strong model, high thinking) and aggregate its findings with yours.
- Architectural questions ("should this be two services", "what is the right boundary") are a design conversation, not an audit — say so and stop.
