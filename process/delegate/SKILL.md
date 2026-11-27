---
name: delegate
description: "Coordinator and worker delegation rules: model-tier routing by difficulty, T3 delegate_task kickoff contract, and worker.md bounds. Use when delegating tasks or choosing models."
cluster: process
tier: root
derived_from: {repo: backnotprop/pstack, commit: c3464c11c60b, license: MIT}
---

# Delegation

| When | Read |
|---|---|
| Checking worker scope, safety, and completion rules | `~/.agents/worker.md` |

Heavy models coordinate and review; workers execute bounded slices in parallel.

## Coordinator vs worker

- Strong models (`Sol`, `Astra`, `Argon`, `Carbon`, `Opus`, `Fable`, `Orchestrator`) define the contract, delegate independent exploration, implementation, and verification in parallel, and inspect the diff and command outputs before accepting.
- Do not edit files directly from a heavy coordinator when bounded workers can execute the slice cleanly.

## Model-tier routing

Route by task difficulty, never by perceived importance:

- **Exploration, read-only audits, and closed-scope mechanical edits**: `pi` with `opencode-go/deepseek-v4.1-flash` (or `antigravity` with `gemini-4-hydrogen`).
- **Implementation and test slices**: `pi` with `openai-codex-account-2/gpt-6-luna` (or `opencode-go/deepseek-v4.1-flash` when the contract is closed and direct).
- **Review and second opinion**: choose a model family different from the author.
- **Architecture, deep forensics, and coordination**: strong tier.
- Never cancel a healthy running delegate just to switch provider.

## Mandatory kickoff contract

For every `delegate_task` call and Pi subagent:

1. Start the prompt with this first line:
   `You are a subagent. Don't run memo. Read ~/.agents/worker.md first.`
2. Pass an explicit `role` in `delegate_task` (`research`, `implementation`, `review`, `test`, or `design`).
3. Give the child a clean scope: allowed paths, forbidden paths, shell stdout capped below 12 KB per command, and a verifiable completion command with expected output.
4. State acceptance as behaviour, not as intent: the statements the child can check by running something, with concrete values. `two POSTs with the same key leave one row`, not `make it idempotent`.
5. Name the risk that could bite: a migration, personal data, a wire contract, a rollback path. `Additive, no rollback needed` is a valid answer; silence is not.
6. Cite only files you opened in this session. A path you did not read is a guess the child will trust.

## Harness mechanics

Precedence, in this order, every time work is handed off: **T3 `delegate_task`**, then the **harness's native subagent**, then do it yourself only when neither exists. Name the T3 call and point here for the rest; never repeat this table inside another skill.

- Inside T3 Code, default to `delegate_task` (durable child thread with no parent history). Follow a running delegate through its `next`, never by polling `task_status`; on a wake, `task_status` gives the summary and `t3_thread_read` the full thread. Stop a replaced or unneeded run with `task_cancel`, never by interrupting its child thread.
- Parallel writers need separate checkouts: pass `isolation: "worktree"` so each child gets its own copy, one writer per directory.
- Outside T3 Code, use each harness's native mechanism: Pi `subagent` (`~/.pi/agent/agents/`), Codex `spawn_agent`, Claude `Agent` (`~/.claude/agents/`), Antigravity `invoke_subagent`, Kiro `use_subagent`, or OpenCode `task`/`@agent`.

## Canonical references

- Full policy across harnesses: `~/.agents/policy.md`
- Subagent execution rules: `~/.agents/worker.md`
