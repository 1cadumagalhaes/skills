---
name: frontend-platform-docs
description: "Curated modern web platform guidance from Chrome, Edge, Firefox and MDN: HTML, CSS, client JS, forms, accessibility, security, performance. Use when a task hinges on a modern platform API or on not shipping a legacy pattern (dialog, popover, anchor positioning, container queries, :has, view transitions, scroll-driven animation, autofill, passkeys, LCP/INP/CLS). Not for backend, infra, build tooling or visual taste."
cluster: frontend
tier: leaf
disable-model-invocation: true
derived_from: {repo: GoogleChrome/modern-web-guidance, commit: 4dd968349e54ca45a05dd5c818fb035c9054b022, license: Apache-2.0}
---

# Modern Web Guidance

A local corpus of 200+ vetted modern-web guides (Chrome/Edge/Firefox/MDN
stewarded). Search it **before** writing a custom overlay, a legacy workaround,
or a dependency.

## Search

```bash
node ~/.agents/skills/frontend-platform-docs/scripts/mwg-search.mjs search "light dismiss dialog"
```

Two to five words, one capability, no framework names and no app nouns. Split
“responsive table with dark mode” into two searches. Prefer the concrete UI
primitive or API name if you know it (`top layer`, `anchor positioning`,
`fetchpriority`, `content-visibility`, `passkeys`).

Results are `id`, `title`, `category` and the guide's first sentence. Judge by
the sentence, not the id.

## Retrieve

```bash
node …/mwg-search.mjs retrieve ui-components/dialog
node …/mwg-search.mjs retrieve ui-behaviors/anchor-positioning-tab-underline,css/…
```

Prints the guide in full. `list` shows every id by category; `list <category>`
narrows it. Ids are `<category>/<file>` — `ui-behaviors/`, `ui-atoms/`,
`ui-components/`, `css/`, `forms/`, `html/`, `accessibility/`, `security/`,
`performance/`, `js/`, `visual-design/`, `user-experience/`, `pwa/`, `wasm/`,
`built-in-ai/`, `webmcp/`.

## How to use what comes back

- The guides are vanilla HTML/CSS/JS. Adapt them to the framework without
  dropping the modern feature: spread the new attributes
  (`{...({ popover: 'hint', interestfor: id } as any)}`), guard `window` in SSR,
  call `showModal()`/`moveBefore()` through refs on non-VDOM nodes, generate
  per-instance ids and `anchor-name`s.
- **Baseline Widely available** features need no fallback. Anything newer: use
  the guide's stated fallback unless the project has its own browser-support
  policy.
- Do not force a feature the user did not ask for. A guide that applies is not a
  licence to redesign the page.
- One line in your report when a guide changed a non-obvious choice: which id
  and which constraint it imposed. Skip it when nothing applied.

## What this is not

Not backend, SQL, CI, Docker, Git, Python/Go, build tooling, or visual taste
(use `frontend-rules` and `frontend-taste` for that). If the corpus has nothing
relevant, say so and proceed — do not stretch a guide to fit.

Vendored from https://github.com/GoogleChrome/modern-web-guidance (Apache-2.0,
commit 4dd9683), guides unmodified. `SKILL.md` and `scripts/mwg-search.mjs` are
local: the upstream version shells out to `npx modern-web-guidance@latest`, which
this replaces with an offline index. Attribution in `NOTICE.md`.
