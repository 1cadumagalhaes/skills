---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when the user wants a topic researched, docs or API facts gathered, or reading legwork delegated to a background agent.
cluster: process
tier: root
disable-model-invocation: true
derived_from: {repo: mattpocock/skills, commit: abeeaf95660b, license: MIT}
---

Hand the reading to a background agent so you keep working. In T3 Code that is `delegate_task` with `mode: "async"`: it runs in its own child thread with no parent context, and the result arrives in this thread when it finishes. Outside T3 Code, use the harness's native background subagent (Pi `subagent` with `run_in_background`); per-harness table in `~/.agents/skills/delegate/SKILL.md`. Either way, start it with a fresh context window and begin its prompt with `You are a subagent. Don't run memo. Read ~/.agents/worker.md first.` Do not poll it: the completion wakes you.

Its job:

1. Investigate the question against **primary sources** (official docs, source code, specs, first-party APIs), not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where.
