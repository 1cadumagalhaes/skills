# Skill mechanics

Cadu-specific rules for frontmatter, invocation, repository placement, and subagent dispatches inside skills.

## Repository layout and farms

All skills live in `~/Projects/skills`, one directory per skill, grouped by cluster:

- `base/` holds cross-cutting defaults (`repo-defaults`).
- `engineering/` holds backend, data, infra, security, python, audit and debugging.
- `frontend/` holds build, rules, verify, dashboard and their leaves.
- `motion/` holds animation build and its leaves.
- `process/` holds planning, delegation, writing and shipping playbooks.
- `parked/` holds off-farm packs (`marketing/`, `seo/`, `gamedev/`, `media-misc/`, `ml-legacy/`, `web/`) excluded from default linking.

The skill name is the frontmatter `name`, not the directory basename. Cluster and tier (`root` or `leaf`) are frontmatter fields; only roots may be model-invoked. After adding, renaming, or moving any skill, run `scripts/link.sh` to reconcile `~/.agents/skills` and mirror farms (`~/.claude/skills`, `~/.kiro/skills`, `~/.codex/skills`, `~/.gemini/config/skills`), then run `scripts/check.sh`.

## Invocation choice

Choose one mode per skill:

- **Model-invoked (auto).** Omit `disable-model-invocation`. Write a front-loaded `description` under 200 characters listing the distinct trigger branches. Use this only when the agent must reach the skill unasked on recurring daily work.
- **User-invoked (manual).** Set `disable-model-invocation: true` in frontmatter. Write a concise one-line `description` summarizing what the playbook does, without trigger synonyms. Reach manual skills by slash name or explicit path (`~/.agents/skills/<name>/SKILL.md`).

Keep shared reference needed by multiple manual skills either in an active manual target file pointed to by exact `~/.agents/skills/<name>/...` path, or inside `references/` of the owning skill. Do not cross-reference skills inside `parked/`.

## Native primitives

When an action has a native primitive in the harness, name it, with the fallback in the same line:

- Waiting on CI or review: `watch_pull_request`, never a sleep or poll loop. Fallback outside T3: one `gh pr checks --watch` read.
- Delegating work: `delegate_task` first, then the harness's native subagent (`subagent` in Pi, `invoke_subagent` in agy, `Agent` in Claude, `spawn_agent` in Codex, `task`/`@agent` in OpenCode, `use_subagent` in Kiro), and only if neither exists do it yourself. Each skill names the T3 call and points to `~/.agents/skills/delegate/SKILL.md`; no skill repeats the full table, because copies drift.
- Reading prior or parallel sessions: `t3_thread_read` and `t3_thread_search`, not transcript mining.
- Driving a browser: `preview_*` tools, with the Playwright script as the fallback or for CI.
- Scheduled or recurring work: `schedule_task`, not an agent that sleeps between runs.

A skill that tells an agent to poll, sleep, or babysit a PR without naming the watcher is wrong even when it works: it burns turns and context that the primitive does not. `scripts/check.sh` warns on that pattern.

## Subagent dispatches inside skills

Every skill or reference that instructs an agent to spawn a subagent or `delegate_task` must state all three rules:

1. Start the child in a **fresh context window**.
2. Begin the child prompt with: `You are a subagent. Don't run memo. Read ~/.agents/worker.md first.`
3. Specify a closed file scope, bounded command output, and a verifiable completion criterion.

## Quality gate

Before finishing any new or edited `SKILL.md`, run `~/.agents/skills/unslop/SKILL.md` over the full text and run `scripts/check.sh` to verify valid YAML frontmatter, cluster and tier, reachable leaves, and the auto-index budget.

Adapted from `mattpocock/skills` `SKILL-MECHANICS.md` (MIT, Matt Pocock) for Cadu's multi-harness setup.
