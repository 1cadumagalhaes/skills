---
name: frontend-storybook
description: Isolated component development in Storybook using state stories as the component spec.
cluster: frontend
tier: leaf
disable-model-invocation: true
---

# Storybook workflow

Stories define the component specification rather than acting as static screenshots. A component in a Storybook repo is unfinished until stories cover its states.

## Sequence

1. **Write a skeleton story first.** Render the component with minimal props before styling so prop API flaws surface early while changes are cheap.
2. **Author one story per meaningful state.** Cover `Default`, `Empty`, `Loading`, `Error`, `Disabled`, `LongContent`, and `ManyItems` where applicable, matching the state matrix in `frontend-build` (`references/states.md`).
3. **Keep controls valid.** Configure args and `argTypes` so reviewers can explore valid states without triggering impossible combinations.
4. **Mock at the network boundary.** Supply data through props or scoped MSW handlers rather than live network requests.
5. **Compose pages only after isolated stories hold.** If page composition exposes an awkward prop API, fix the component and stories rather than adapting components to one page.

## Conventions

- Co-locate stories beside the component (`button.vue` and `button.stories.ts`, or `.tsx`/`.stories.tsx`).
- Mirror the shared UI hierarchy in story titles (`Components/Inputs/Button`).
- Write `play` interaction tests only for behavioral contracts that can regress (focus traps, validation, submission).
- Deleting a state story removes a documented requirement; explain why in the commit message.
