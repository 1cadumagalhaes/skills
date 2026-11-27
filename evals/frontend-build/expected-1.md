# frontend-build / prompt-1

## Must decide
- Inspect first: `package.json` for the exact stack (Nuxt 3, shadcn-vue/Tailwind, data layer) and the typecheck/lint/test/build commands; read `DESIGN.md` if present.
- Component inventory before page code: each piece marked `existing`, `reuse + extend`, or `new`, after checking sibling pages for the shared table/filter patterns.
- Components built in isolation with fixture data (Storybook if the repo has it, else an isolated dev route); the page stays thin, owning only layout, route wiring, and data fetching.

## Must show
- Every state from `references/states.md`: default, empty, loading, error, pending action, partial failure, long/overflow content, hover/focus/disabled, a11y.
- Presentational components: props in, typed events out, no fetch inside a list row.
- Browser check: `node ~/.agents/skills/frontend-verify/scripts/check_ui.mjs "http://localhost:5173/contracts" --widths 375,1280`, with both screenshots inspected.
- Any new dependency asked about before install; a component used on two pages promoted to the shared folder.
- chained: `references/vue-astro-patterns.md`, `references/states.md`, `~/.agents/skills/frontend-verify/SKILL.md`.

## Miss if
- Everything inline in one page file, or only the happy path built.
- A parallel styling system or new tokens instead of the repo `DESIGN.md` tokens.
- Done declared from build/typecheck with no browser check, or no statement of what went unverified.
