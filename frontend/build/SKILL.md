---
name: frontend-build
description: "Component-first frontend workflow: inspect stack, plan states, build and verify components in isolation, then compose pages. Use when building or changing UI pages or components."
cluster: frontend
tier: root
---

# Frontend workflow (component-first)

| When | Read |
|---|---|
| Recording a durable visual system | `~/.agents/skills/frontend-design-doc/SKILL.md` |
| Choosing a visual direction before coding | `~/.agents/skills/frontend-direction/SKILL.md` |
| Choosing diagrams for technical explanations | `~/.agents/skills/frontend-diagrams/SKILL.md` |
| Writing and reviewing isolated stories | `~/.agents/skills/frontend-storybook/SKILL.md` |
| Art-directing a public page | `~/.agents/skills/frontend-taste/SKILL.md` |
| Checking browser-platform guidance | `~/.agents/skills/frontend-platform-docs/SKILL.md` |
| Auditing existing components or structure | `~/.agents/skills/code-audit/SKILL.md` |
| Analytics dashboard, panel or Grafana | `~/.agents/skills/frontend-dashboard/SKILL.md` |
| Hiding a feature behind a flag, or varying the UI per cohort | `~/.agents/skills/feature-flags/SKILL.md` |
| Choosing a UI library | `~/.agents/skills/frontend-choose-library/SKILL.md` |
| Improving a revenue-critical flow | `~/.agents/skills/frontend-revenue-design/SKILL.md` |
| Stress-testing a UI with hostile input | `~/.agents/skills/frontend-stress/SKILL.md` |

Build components from the inside out and compose the page last.

## Sequence

1. **Inspect stack and plan the page.** Read `package.json` to identify the exact framework (`Vue 3`, `Nuxt`, `Astro`, `Svelte`, or `React`), styling/component library (`shadcn-vue`, `Reka UI`, Tailwind, etc.), data layer, and `typecheck`/`lint`/`test`/`build` commands. Read `DESIGN.md` (`frontend-design-doc`) if present; for gallery-grade public pages, follow `~/.agents/skills/frontend-taste/SKILL.md`. Ask before adding a dependency.
2. **Inventory reusable components.** List needed components and mark each `existing`, `reuse + extend`, or `new`. Check sibling pages first so shared patterns live once.
3. **Build new components in isolation.** Develop each component with fixture/mock data outside the page first, using Storybook (`~/.agents/skills/frontend-storybook/SKILL.md`) when the repo has Storybook or an isolated dev route otherwise.
4. **Build and check every state.** Verify default, empty, loading, error, pending action, partial failure, long/overflow content, interactive states (hover, focus, disabled), and accessibility (`references/states.md`). Trigger error states explicitly rather than assuming they render.
5. **Compose the page.** Keep layout, route wiring, and data fetching in the page while components stay presentational through props and typed events.
6. **Promote shared primitives.** Move any new component useful to two or more pages into the shared component folder before finishing.

## Hard rules

- Keep components presentational; pass data via props and emit events upward unless the component is an explicit data boundary.
- Reuse the repo's existing tokens and theme (`frontend-design-doc`); avoid introducing a parallel styling system.
- Keep page files thin (layout, composition, data wiring). Extract components when a page grows past composition.
- Leave unrelated pages and components untouched.
- Verify every component state in `references/states.md` is built and inspected.
- Open the built page in a real browser (`frontend-verify`) at 375 and 1280 px before calling UI work done. If no browser can run, state explicitly what went unverified.

## References

| Read when | File |
|---|---|
| Planning and verifying component states | `references/states.md` |
| Building in Vue 3, Nuxt, or Astro | `references/vue-astro-patterns.md` |
| Building in a React codebase | `references/react-patterns.md` |
| Developing isolated stories in a Storybook repo | `~/.agents/skills/frontend-storybook/SKILL.md` |
