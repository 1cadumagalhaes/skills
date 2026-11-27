---
name: chaos-engineering
description: "Attack a just-implemented change with adversarial tests that try to break it: boundaries, nulls, money, hostile dependencies, concurrency, hostile payloads, impossible states. Report what held and what ceded. Use when asked to chaos-test, stress, or adversarially test a diff."
cluster: engineering
tier: leaf
disable-model-invocation: true
---

# Chaos engineering

Where the code was built, this tries to break it. The target is a change, not a repository: take the diff, write tests whose only goal is to prove it fails, run them, and report where the code holds and where it cedes.

An attack that survives is a result. The point is not to find bugs at any cost, but to map the boundary and leave the useful tests behind as regression.

| When | Read |
|---|---|
| Reviewing the diff as a reviewer rather than an attacker | `~/.agents/skills/code-audit/SKILL.md` (its review modes) |

## Phase 1: Resolve the target and the baseline

Attack the first that exists: a pull request diff, a local diff against the base branch, or the working tree when nothing is committed yet. Resolve the base explicitly rather than assuming the remote default.

**Done when:** the diff command returns a non-empty diff, and the base branch is named.

Then run the change's own tests. A red baseline means you cannot tell a real finding from a broken environment, so stop and say which test is red.

**Done when:** the existing tests for the touched area pass, or the run stops with the failing test named.

## Phase 2: Map the attack surface

Read the diff, not the repository. List what changed: production files, contracts (schema, DTO, external payload, queue message), and the acceptance criteria the change claims. What the author already tested is done; what they forgot is where the chaos lives.

**Done when:** every changed file is classified as surface or noise, and each contract has at least one named way to violate it.

## Phase 3: Choose the vectors

Select from this catalog only the vectors the diff can actually suffer, ordered by impact times likelihood:

- boundaries: zero, negative, maximum, empty, one, N plus one, leap day, timezone
- nulls and absence: omitted optional, null versus missing, empty object, absent remote field
- money: rounding, installments that do not sum, discount over 100%, float drift
- hostile dependencies: 500, 429, timeout, truncated JSON, cache down, lock contention, process dies mid-flight
- concurrency and idempotency: same request twice, duplicate webhook, reprocessed job, race with a cron
- hostile payloads: emoji, encoding, 10k characters, injection strings, HTML in free text, number as string
- impossible state: enum outside its domain, orphaned reference, expired session
- contract violation: type flip, unknown enum, extra field, empty second page

**Done when:** the chosen vectors are written as hypotheses, one line each, with the ones you rejected and why.

## Phase 4: Build the arsenal

Write the attacks as tests in the project's own framework and conventions, one test per hypothesis, named by the hypothesis rather than the implementation. Simulate hostility with mocks and fixtures: the test describes the hostile world, never depends on a real one. Synthetic data only, no production rows, no real personal data.

Each attack asserts the correct behavior under chaos. A failing attack is therefore a real finding, and the same test becomes the regression once the fix lands.

For a wide surface, split the vector families across parallel workers, one writer per checkout: `delegate_task` with `isolation: "worktree"` inside T3, the harness's own subagent outside it.

**Done when:** every hypothesis in the plan has a test, and the whole arsenal runs in one command.

## Phase 5: Run and classify

Run the arsenal. Classify every attack, with no inflation:

- **KILLED**: the code cedes. Quote the failure.
- **SURVIVED**: the code holds. That is a result, record it.
- **INCONCLUSIVE**: the test itself is wrong (bad mock, flaky, environment limit). Fix and rerun; still inconclusive after two attempts, record it as such.

**Done when:** every attack carries one of the three labels, and each KILLED carries the failing assertion and its stack line.

## Phase 6: Report and hand back

Report in this shape, short:

- Target: the diff command and the base.
- Coverage: vectors attacked, and the ones deliberately skipped with a reason.
- Findings: each KILLED in one line with the file and the failing assertion.
- Held: the SURVIVED list, one line per vector.
- Handoff: which attacks stay as regression tests, and the fix each KILLED needs.

**Done when:** the report names every attack exactly once, and the regression tests are either committed with the fix or listed as the fix's test plan.

Keep the attacks out of the production path: a chaos test never ships to a user, never touches production data, and never runs against a live remote. If an attack needs a live dependency to be meaningful, that is an INCONCLUSIVE with the reason, not a live run.
