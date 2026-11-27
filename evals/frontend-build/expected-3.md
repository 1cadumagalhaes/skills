# frontend-build / prompt-3

## Must decide
- Storybook repo means the isolated-component step runs through the leaf `~/.agents/skills/frontend-storybook/SKILL.md`: stories are the component spec, not a demo gallery.
- One story per state that matters (default, empty, loading, error, long content, disabled), with fixture/mock data, no live fetch.
- Props and emitted events are settled against the stories before the page consumes the component.

## Must show
- chained: `~/.agents/skills/frontend-storybook/SKILL.md`, plus `references/states.md` for the state list.
- Story files with explicit fixtures, an arg per prop variation, and an interaction/play case for the pending-action state.
- The repo typecheck/lint run over the story files, and Storybook build (or dev) output showing the stories compile.
- ContractCard promoted to the shared component folder if a second page will use it.

## Miss if
- Writes a single Default story and calls it state coverage.
- Stories fetch real data or need a running backend.
- Skips page composition once the component exists, or never verifies the composed page.
