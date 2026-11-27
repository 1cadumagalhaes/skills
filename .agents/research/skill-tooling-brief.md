# Research brief: tooling around agent-skill distribution, validation and evaluation

## Context you must assume

I run a personal farm of 49 agent skills. Each skill is a directory with `SKILL.md` (YAML frontmatter:
name, description, cluster, tier root|leaf, optional `derived_from`) plus `references/` and `scripts/`.
One repo is symlinked into the skill directories of five harnesses: Pi, Claude Code, Codex, Antigravity
(via `~/.gemini/config/skills`) and Kiro. Auto-invocable roots cost index characters on every turn;
leaves are manual and cost nothing until read.

What I already run:

- a linker that reconciles one tree into the five harness dirs, with `--without <skill>` for ablation;
- a checker for frontmatter, tier, leaf reachability, name budget, body size, text hygiene, and one
  completion criterion per phase;
- usage and cost per skill, attributed from Pi session JSONL (`usage.cost.total` before and after the
  read);
- an eval runner with one fixture repo per port and three prompts each (golden, edge, chain), judged by
  reading against a rubric.

## Why I am asking

Uber published "How Uber Evals 1 Million Agent Skill Invocations a Month". It describes two things.
`aifx`, an internal CLI: starts any agent, merges configuration in layers (company, team, repo, cwd,
user, local), installs skills and plugins across Claude Code, Codex, OpenCode and Cursor, handles sign-in
and MCP, and acts as the tool gateway for code mode. And Skill Workshop, a plugin plus web app: a
`spec.md` compiles into `SKILL.md` and test prompts, with a linter, evals, ablations, and a per-skill
page showing usage, cost and quality fed by OpenTelemetry hooks.

I want to know what exists in public, and whether anything covers both halves.

## Questions, in priority order

1. Public or open-source tools for **skill and prompt distribution plus cross-harness configuration**
   (the aifx analog). Include `npx skills` / skills.sh, the Claude Code and Codex plugin marketplaces,
   and any installer-plus-`doctor` pattern you find.
2. Tools that **evaluate** agent skills or prompts with golden cases, ablations, blind judges or
   trajectory grading: promptfoo, Inspect AI, DeepEval, OpenAI Evals, LangSmith, Braintrust, Arize, and
   anything skill-specific rather than prompt-generic.
3. Anything that **compiles a spec into a skill** (one source of truth that regenerates SKILL.md and its
   test prompts when the model changes).
4. Anything that does **per-skill usage and cost attribution from agent session logs**, rather than
   per-request tracing.
5. **https://executor.sh** — what is it, exactly? MCP gateway, tool executor, something else? Does it
   overlap aifx's role as the tool gateway for code mode? Verify against the repository and docs.
6. Does anything open-source **combine 1 and 2**, which is what aifx plus Skill Workshop is?

## Constraints

- Primary sources only: repository, docs, release notes, source. No listicles, no vendor landing pages.
- For each tool: one line on what it actually does, license, last release date, and which question
  number it answers.
- Write "nothing found" where that is the answer. Do not pad with adjacent categories (observability
  platforms, generic prompt managers) unless the tool has a skill-specific feature.
- Flag anything that is announced but unshipped, and anything that only works inside one vendor's
  harness.

## Output

1. A table: tool | category | one line | license | last release | answers question #.
2. At most five findings, each stating what it means for someone running one repo across five harnesses.
3. "What I would try first": three bullets, each with the exact command or doc URL to start from.

Maximum 800 words.
