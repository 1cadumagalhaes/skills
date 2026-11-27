---
name: debug
description: Diagnosis loop for hard bugs and performance regressions. Build a tight red feedback loop before theorizing. Use when debugging failing or slow behavior.
cluster: engineering
tier: root
derived_from: {repo: mattpocock/skills, commit: abeeaf95660b, license: MIT}
---

# Diagnosing bugs

| When | Read |
|---|---|
| Measuring a performance change reliably | `~/.agents/skills/benchmark-check/SKILL.md` |

A six-phase discipline for hard bugs and regressions. Skip a phase only when the evidence already proves it.

When exploring the codebase, query `graphify` first if `graphify-out/graph.json` exists, and read `AGENTS.md` and `DESIGN.md` if present.

## Redact secrets first

Replace any secret or credential in pasted commands, payloads, or captured artifacts with `<REDACTED>`. Run loops against environment variables or `~/.pgpass`, never inline credentials, and never print database passwords or tokens.

## Phase 1: Build a tight feedback loop

Build a **tight** pass/fail signal that goes **red** on this exact bug before reading deeply or forming theories. Every minute invested here prevents guessing.

Choose the cheapest reproducible seam in this order:

1. **Failing test.** `uv run pytest tests/... -k <case>`, Cargo test, or Vitest/Playwright unit or integration test.
2. **Data or pipeline dry run.** Isolated fixture over SQL/BigQuery/Postgres, `dlt` extract check on a single slice, or Airflow task test command. Always keep prod untouched and verify read-only safety first.
3. **CLI or HTTP script.** Command with a pinned fixture input diffing stdout against expected output, or `curl` against a local dev server.
4. **Browser check.** Playwright script asserting DOM, console errors, or network responses.
5. **Captured trace replay.** Save a failing payload or event log inside a project-local scratch directory, never `/tmp`, and replay it in isolation.
6. **Property or stress loop.** Run 100 iterations or parallel workers to turn an intermittent flake into a frequent failure.
7. **Bisect or differential loop.** Run old vs new commits (`git bisect run`) or two configs on the same input.
8. **Human-in-the-loop script.** Last resort when only a human can click through the UI. Copy `scripts/hitl-loop.template.sh` into a project-local temporary path and capture structured output.

Tighten the loop once it exists: narrow input scope to run in seconds, assert the exact user symptom rather than "no crash", and pin RNG seeds, time, and fixtures so it is deterministic.

If you genuinely cannot build a loop, stop and state what you tried. Ask the user for environment access, a redacted artifact, or permission to add temporary instrumentation.

**Phase 1 completion criterion.** Name one red-capable command you ran at least once, show its redacted output, and verify it is deterministic, fast, and directly asserts the reported symptom. Do not advance to Phase 2 without a red loop.

## Phase 2: Reproduce and minimize

Run the command and confirm it produces the user's exact failure mode rather than an unrelated error.

Then cut inputs, data rows, callers, and configuration one piece at a time, re-running after each cut, until every remaining element is load-bearing. Removing any remaining piece makes the loop go green.

## Phase 3: Hypothesize

Write 3 to 5 ranked hypotheses before testing any of them. Each hypothesis must state a falsifiable prediction:

`If <cause X> holds, then changing <Y> changes the output to <Z>.`

Show the ranked list to the user when they are active in the loop; otherwise proceed directly in priority order.

## Phase 4: Instrument

Test one variable per probe against a specific Phase 3 prediction:

1. Inspect state with a debugger or focused REPL call when possible.
2. Place targeted logs at the boundary that separates the top hypotheses.
3. Tag every temporary debug log with a unique prefix such as `[DEBUG-a4f2]` so cleanup is a single grep.

For performance regressions or BigQuery/Postgres query slowness, skip log scatter and establish a baseline with a profiler or `EXPLAIN (ANALYZE, BUFFERS)`, then vet numbers with `~/.agents/skills/benchmark-check/SKILL.md`.

## Phase 5: Fix and lock down with a regression test

Write the regression test at the real seam where the failure occurs before applying the fix. A shallow test that mocks away the failing interaction gives false confidence. If no clean seam exists, state that architectural gap explicitly as a finding.

1. Turn the minimized repro into a failing test at the real seam.
2. Watch it fail. When testing a forced mutation on a fixture or code copy, `git diff` against pristine code to verify the mutation actually landed and can fail.
3. Apply the smallest fix for the root cause.
4. Watch the new test and the full Phase 1 loop pass.

## Phase 6: Cleanup and report

Verify every item before declaring done:

- Original un-minimized Phase 1 loop passes.
- Regression test and project checks (`make check` or stack equivalent) pass with counts reported.
- Zero remaining `[DEBUG-*]` markers (`grep` check) and zero stray debug files left in the workspace or `/tmp`.
- Root-cause hypothesis recorded in the closing summary or commit message.

Adapted from `mattpocock/skills` `debug` (MIT, Matt Pocock).
