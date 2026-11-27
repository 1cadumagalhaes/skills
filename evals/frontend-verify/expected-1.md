# frontend-verify / prompt-1

## Must decide
- Browser, not build: run the checker against the local server at both widths (375 and 1280), then inspect both screenshots.
- Report fields that must be read: console/page errors, horizontal overflow, unnamed or duplicate controls, inputs without `<label>` or outside a form, images missing `alt`/`width`/`height`, pointer cursor on non-interactive elements, `<h1>` count, Tab walk with focus visibility, axe-core AA when it resolves.
- Unhappy paths are manual and required: error state, empty search, deleting the last item, invalid submit, keyboard-only navigation.

## Must show
- The exact command `node ~/.agents/skills/frontend-verify/scripts/check_ui.mjs "http://localhost:5173/team" --out .ui-check`, plus URL and exit code.
- The JSON summary quoted (counts per category, offending selectors), not no issues found.
- Both screenshots inspected, and the Tab walk focus stops plus visibility reported.
- Unverified items stated explicitly (for example axe-core not installed), and `.ui-check` removed or kept out of git.

## Miss if
- Claims verification from `npm run build` or typecheck, or from a single width.
- Reports looks good with no console/overflow/a11y numbers.
- Silently skips the checker on exit `2`, or leaves `.ui-check` tracked.
