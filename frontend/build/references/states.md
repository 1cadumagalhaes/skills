# States acceptance criteria

A component that displays data or accepts input has more states than the happy path. List them before coding, build each state, and inspect it visually.

| State | Requirement |
|---|---|
| Loading | Placeholder or "Loading..." with `aria-busy` or `role="status"` and skeleton geometry matching real content to prevent layout shift. |
| Empty | Clear headline plus cause and recovery action ("No members match 'zz'. Clear the search."), never a blank panel. |
| Error | Plain explanation of what failed plus a concrete recovery path (Retry button or link), never a blank area or `console.error` alone. |
| Success / done | Visible updated state and screen-reader announcement (`role="status"`). |
| Pending action | Triggering control shows progress and disables only while its own request runs, preventing double submit while keeping the rest of the page responsive. |
| Long and odd content | Very long names, emails, URLs, and unbroken tokens wrap (`overflow-wrap: anywhere`) or truncate with full value accessible; 0, 1, and 500 items render cleanly. |
| Partial failure | One failing row attaches its error to that row without breaking the surrounding list. |
| After removal | Focus moves cleanly to the next row, previous row, or list heading rather than dropping to `<body>`. |

## Habits

1. **Force the error path.** Trigger failures using the repo's dev toggle, mock flag, or query param and inspect the error view directly.
2. **Name verified states in your summary.** List exact verified states ("states checked: loading, empty, error, pending, long strings") instead of assuming completion.

## State design rules

- Model async state as a discriminated union (`loading`, `error`, `ready`) so impossible combinations cannot happen. See `vue-astro-patterns.md` or `react-patterns.md`.
- Scope pending spinners to the button or row being mutated rather than locking the entire screen.
- Design the empty state as a real screen with title, cause, and action.

Adapted from `senior-frontend` in `davila7/claude-code-templates` (MIT, commit 30f72e1); see `ATTRIBUTION.md`.
