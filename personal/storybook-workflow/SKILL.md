---
name: storybook-workflow
description: Isolated component development in Storybook — stories as the component's spec, states first, composition later. Use when the repo has Storybook and I am building or changing components.
---

# Storybook workflow

Stories are the component's specification, not marketing screenshots. A component without stories documenting its states is not done.

## How I build with it

1. **Skeleton story first**: render the component with minimal props before any styling work. This catches prop design problems early — redesign the API at this stage, it is cheap.
2. **One story per meaningful state**, named from the checklist: `Default`, `Empty`, `Loading`, `Error`, `Disabled`, `LongContent`, `ManyItems` (when relevant). Stories may use props or MSW-mocked data; state matrix per component follows `frontend-workflow`.
3. **Controls are part of the contract**: args set up so a reviewer can drag and probe. Args should not encourage invalid combinations — model state machines in argTypes/argTypes mapping where possible.
4. **Mock at the boundary the component touches**: fetches come as props or via MSW handlers scoped to the component, never live network.
5. **Compose only after isolation holds**: the page consumes the same stories' props; if composing forces prop changes, go back and fix the component — do not shape components around the page.

## House conventions

- Story files sit beside the component (`button.tsx` / `button.stories.tsx`).
- Story titles mirror the shared-library hierarchy (`Components/Inputs/Button`), promoted components get the promoted title.
- Interaction tests (`play`) only for behavioral contracts that regress (focus traps, form submission); visual states are the stories themselves — no redundant per-state snapshots.
- Deleting a state story = removing a documented behavior: needs a reason in the commit.