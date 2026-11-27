# frontend-build / prompt-2

## Must decide
- Narrow the fastest path: the page may stay one file only while it is still composition. Once it owns table, filters, rows, and states, those are components.
- Ask before adding `date-fns`: check `package.json` for an existing date utility (dayjs, date-fns already, `Intl.DateTimeFormat`) and prefer the repo choice.
- Ship the smallest thing that is still verifiable: the page plus state coverage, not a dependency change and a page rewrite in one patch.

## Must show
- A yes/no on `date-fns` with the evidence from the dependency list, and the install only after permission.
- The component boundary actually chosen, with the reason it cannot be a page-only blob (state coverage, second consumer).
- State coverage still complete, and the composed page checked in the browser at 375 and 1280 px.
- chained: `references/states.md` and `references/vue-astro-patterns.md`.

## Miss if
- Installs a new dependency without checking or asking.
- Accepts an unreadable single-file page and drops state coverage to go faster.
- Ends with build passes as the only evidence.
