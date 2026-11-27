---
name: agent-docs
description: Writing documents for agents. Use when creating or editing skills, AGENTS.md, CLAUDE.md, or agent definitions.
cluster: process
tier: root
disable-model-invocation: true
derived_from: {repo: mattpocock/skills, commit: abeeaf95660b, license: MIT}
---

# Writing for agents

| When | Read |
|---|---|
| Removing vague or padded agent prose | `~/.agents/skills/unslop/SKILL.md` |

Reference for any document an agent reads: a skill, an `AGENTS.md`, an agent definition, or a doc reached by a pointer. The packaging differs; the writing rules stay constant because the goal is the same process every run rather than identical prose.

When writing or editing a skill, also read `SKILL-MECHANICS.md` in this directory for repository layout, frontmatter, invocation choices, and subagent requirements. Apply `~/.agents/skills/unslop/SKILL.md` to every finished agent document.

## Context pointers

A context pointer is a reference held in the agent's window that names out-of-context material and gives the condition for opening it. A skill description and an `AGENTS.md` line naming a doc are both context pointers. The pointer's wording, not its target, decides whether the agent reaches the material. A required doc behind weak wording causes variance. Sharpen the wording first, and inline the material only if sharpening fails.

A pointer does two jobs: state what the material is, and list the distinct branches that trigger opening it. Because always-loaded pointers cost tokens on every turn, prune them harder than the body:

- Front-load the leading trigger words.
- Keep one trigger per branch. Collapse synonyms that rename the same branch.
- Omit identity or caveats the body already carries.

## Two loads

Every document and pointer spends one of two budgets:

- **Context load.** Material always loaded in the agent's window (`AGENTS.md` lines, auto skill descriptions). It spends tokens and attention on every turn whether or not it fires.
- **Cognitive load.** Material the human must remember exists and ask for by name. The human acts as the index. Spend cognitive load where human judgement matters, and remove it where the agent should act autonomously.

Material behind a pointer trades the full document's context load for the pointer's single line. Material with no pointer relies only on cognitive load.

## Information hierarchy

Documents mix **steps** (ordered actions) and **reference** (definitions, rules, facts consulted on demand). Place each piece on the lowest rung where it still triggers reliably:

1. **In-file step.** Primary actions the agent runs in order.
2. **In-file reference.** Rules or tables consulted during the work. A flat peer set of rules on one rung is valid when every run needs them.
3. **Disclosed reference.** Sibling file (`references/*.md`) or external file reached by a context pointer only when its branch applies.

Branching is the disclosure test. Inline what every branch needs, and move behind a pointer what only some branches reach. When a document has ordered steps, burying long in-file reference between steps makes attention a coin flip.

Keep each concept's definition, rules, and caveats under one heading rather than scattered across sections. When a single document grows too long even with live unique lines, disclose reference files or split by branch or sequence.

## Steps and completion criteria

Every step ends on a **completion criterion**, the verifiable condition that defines done. Two properties control execution quality:

- **Clarity.** Can the agent distinguish done from not-done? Vague bounds such as "understanding reached" invite **premature completion**, rushing toward later visible steps. Defend by sharpening the bound first (for example, naming the exact check command or required count). Hide later steps across a real context boundary, such as a subagent dispatch or handoff, only when an irreducibly fuzzy step still triggers rushing.
- **Demand.** How much work the bound requires. "Every modified skill checked" forces legwork that "summarize changes" does not. Exhaustive demand ("every rule applied") binds flat reference just as a completion bound binds a sequence.

## When to split

Splitting one document into two spends one of the two loads, so split only when the cut earns it:

- **By sequence.** Split ordered steps when visible later steps tempt the agent to rush the current step.
- **By invocation.** Split out a model-invoked skill when it has a distinct trigger word you use directly or when other skills call it. See `SKILL-MECHANICS.md`.

## Leading words and positive phrasing

A **leading word** is a compact concept already present in model pretraining (`tight`, `red`, `fail-closed`, `tracer bullet`, `slice`). Repeated as a token rather than restated as a sentence, it anchors behavior in fewer tokens. Choose an existing pretrained word before coining a new term.

State the target behavior in the positive. Negations drag the forbidden behavior into active attention. Use a prohibition only for a hard boundary you cannot phrase positively, and pair it immediately with the required action.

## Pruning

- **Single source of truth.** Keep each rule in one authoritative file. Duplicating the same rule across `AGENTS.md`, skills, and agent files inflates maintenance cost and distorts attention.
- **Environment as source of truth.** Do not cache repo layouts, `package.json` scripts, or `--help` flags in prose when a single fast command reads them live. Cache only unwritten conventions, rationale, and gotchas.
- **Relevance and sediment.** Remove prose that does not change behavior or belongs to an unused stack.
- **No-Op test.** Inspect sentence by sentence: does this change model behavior compared to its default? Settle doubts by running the document, not by guessing. Delete failing sentences whole rather than trimming words, and replace weak leading words (`be thorough`) with concrete verifiable bars.

Done when the edited document has no redundant context pointers, no unmeasured no-ops, clear completion criteria on every phase, and passes `unslop`.

Adapted from `mattpocock/skills` `agent-docs` (MIT, Matt Pocock).
