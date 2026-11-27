---
name: blast-radius
description: Analyze what a change can break outside the diff and prove the core safety fact by running code.
cluster: engineering
tier: leaf
disable-model-invocation: true
derived_from: {repo: backnotprop/pstack, commit: c3464c11c60b, license: MIT}
---

# Blast radius

Find what a change breaks outside its diff before it ships. Listing static grep callers is cheap and incomplete; the real risk lives where symbol search stops.

Run all output prose through `~/.agents/skills/unslop/SKILL.md`.

## Five-step certainty ladder

Drive the core safety assumption as far down this ladder as is cheap, and state explicitly where verification stopped:

1. **Claimed.** Stated in prose. Worthless alone.
2. **Cited.** Pinned to exact `file:line` or installed library source.
3. **Walked.** Traced the failure condition end to end and showed it cannot reach.
4. **Executed.** Wrote and ran a script or focused test calling the real code that fails loudly if the assumption breaks.
5. **Reproduced live.** Verified against a running local app, dev container, or dry-run pipeline.

## Workflow

1. **Read the whole diff.** Inspect modified symbols, config defaults, migrations, and commits on the branch against its base.
2. **State the single safety fact.** Identify the one condition the change relies on to stay safe, such as "this backfill only inserts missing dates and leaves existing partition rows intact". Focus proof effort here first.
3. **Trace past grep.** Inspect the areas static search misses in Cadu's stack:
   - **Data and schemas:** Postgres/AlloyDB migrations, lock behavior, BigQuery partition filters, downstream dbt/dlt marts, Airflow DAG schedules and retries.
   - **Contracts:** JSON wire fields, FastAPI response shapes, environment variables, container entrypoints, Helm values.
   - **UI and build:** Astro/Vue hydration timing, shared CSS tokens, `DESIGN.md` constraints, client bundle boundaries.
   - **Dependencies and infra:** pinned library source code, cloud IAM permissions, GKE resource requests/limits and cost multipliers.
4. **Separate confirmed risks from cleared paths.** Cite exact `file:line` paths and observed behavior. A search returning zero callers is still evidence when named explicitly. Never invent a caller or API.
5. **Prove the safety fact.** Run real code (step 4 or 5 above) and record the command and output. Keep any temporary test script inside the repo only if promoted to a real test; otherwise clean it up before finishing.
6. **Second opinion for high-risk diffs.** For risky migrations, auth changes, or broad refactors, dispatch an independent `delegate_task` (`role: "review"`) on a different model family with `You are a subagent. Don't run memo. Read ~/.agents/worker.md first.`, fresh context, and the same scope. Outside T3 Code, send the same brief to the harness's own read-only subagent (per-harness table in `~/.agents/skills/delegate/SKILL.md`).

## Report format

- **What changed.** Concrete behavior change, including implicit side effects.
- **Core safety fact.** The statement, ladder step reached (1 to 5), and command proof, or `unproven` with reason.
- **Confirmed risks.** Failure mode, `file:line`, likelihood, impact, and repro output.
- **Cleared paths.** Checked boundaries and why they hold.
- **Before merge.** Cheapest test or dry-run command that guards the riskiest seam.

Adapted from `backnotprop/pstack` `blast-radius` (MIT, Lauren Tan).
