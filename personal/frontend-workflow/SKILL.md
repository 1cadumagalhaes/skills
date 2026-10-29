---
name: frontend-workflow
description: My component-first frontend workflow — plan the page, extract reusable components, build them in isolation with states, then compose. Use when building or changing any page/screen/component in a frontend codebase.
---

# Frontend workflow (component-first)

Never build a page top-down. Components first, page last.

## The sequence

1. **Plan the page**: purpose, data needs, states (empty/loading/error/success), and which parts already exist. Read the repo's `DESIGN.md` if present (`design-contract` skill) and the shared component library. For visual quality gates, `design-taste-frontend` governs.
2. **Extract components**: list candidate components and mark each as `existing` / `reuse + extend` / `new`. Maximize reuse **across pages**, not just within this one — check sibling pages before inventing anything.
3. **Build new components independently**, outside the page: develop each with mock/fixed data, in Storybook when the repo has it (`storybook-workflow` skill) or a scratch route otherwise.
4. **Validate states** per component: default, empty, loading, error, overloaded data (long strings/many items), interactive states (hover/focus/disabled), and accessibility (focus order, labels, contrast).
5. **Compose the page** only after components hold individually. Data fetching and layout live in the page; components stay presentational and predictable via props.
6. **Review pass**: did anything built for this page belong to more than one page? If yes, promote it to the shared library before finishing.

## Hard rules

- A component gets data via props; no component fetches on its own unless it is explicitly a data component.
- No new styling system; follow the repo's existing tokens/theme (`design-contract` decides what's durable).
- Page files are thin: layout + composition + data wiring. If a page file grows past composition, extract components.
- Preserve unrelated components/pages: no drive-by edits.