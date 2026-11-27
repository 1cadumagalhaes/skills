---
name: frontend-verify
description: Verify built UI in a real browser at 375 and 1280 px (console, overflow, labels, Tab focus walk, axe-core). Use after changing pages or UI components.
cluster: frontend
tier: root
---

# Frontend verify

Passing `typecheck` never proves a button is reachable by keyboard or that mobile layout stays inside the viewport. Inspect the rendered page in a real browser.

## Run the checker

```bash
node ~/.agents/skills/frontend-verify/scripts/check_ui.mjs "http://localhost:5173/#/team" --out .ui-check
```

Flags: `--widths 375,1280`, `--tabs 40`, `--wait 1500`, `--out DIR`.

It writes a full-page screenshot per width plus a JSON report covering:

- Console errors and uncaught page errors
- Horizontal overflow
- Controls without an accessible name or with duplicate names
- Inputs missing a `<label>` or placed outside a form
- Images missing `alt`, `width`, or `height`
- Non-interactive elements with pointer cursors
- `<h1>` element count
- Full Tab focus walk showing every focus stop and focus visibility
- Optional `axe-core` WCAG 2.2 AA violations when `axe-core` resolves in the project

Run only against your own local dev or preview server.

## When the checker fails

- Exit `1` means the URL is missing or is not HTTP(S); pass a valid local page URL.
- Exit `2` means Playwright is unavailable; install Playwright and Chromium before rerunning.

## Dependencies

Requires `playwright` and Chromium (`npm i -D playwright && npx playwright install chromium`). If unavailable, exit code `2` reports the gap; state that missing check explicitly instead of skipping silently. `axe-core` is optional.

## Inspect visually and interactively

In T3 Code, drive the page with the `preview_*` tools instead of the script when the browser is already open: `preview_open` with a `target` of the dev-server port, `preview_snapshot` for console errors, overflow and the accessibility tree, `preview_act` for the Tab walk and unhappy paths, `preview_evaluate` for anything the snapshot truncates. Keep the script below for a non-T3 harness, for CI, or when you need the JSON report as a file.

1. Open and inspect both the 375 px and 1280 px screenshots directly.
2. Exercise unhappy paths: trigger error states, empty search results, deleting the last item, invalid form submits, and keyboard-only navigation.
3. Catch semantic issues the script cannot judge (confusing empty state copy, weak visual hierarchy, misleading error messages).
4. Remove temporary `.ui-check` artifacts before finishing or keep them ignored outside git.

## Report

State the exact URL and command run, checker JSON summary, screenshots inspected, and anything you could not verify (missing Playwright, no running server, blocked network). "It builds" is not "it works".

Checker adapted from `senior-frontend` in `davila7/claude-code-templates` (MIT, commit 30f72e1); see `references/NOTICE.md`.
