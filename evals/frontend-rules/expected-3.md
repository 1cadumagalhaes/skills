# frontend-rules / prompt-3

## Must decide
- This is `[conv]` #7: `font-variant-numeric: tabular-nums` on live counters, timers, tables, and numeric columns, and the loaded font must actually ship `tnum` or the property is a no-op.
- Alignment is a table concern: numeric columns right or decimal aligned, headers matched to their column format.
- Color is not the signal: up/down deltas need a label or glyph, not green and red alone (`[req]` #5).

## Must show
- The CSS applied plus the font check proving `tnum` exists (fontTools/`ttx -l` on the woff2, or `font-feature-settings: "tnum"` availability).
- Table semantics with `<table>`, `<th scope>`, and per-column alignment; tabular figures on every numeric cell including the totals row.
- Before/after evidence: two screenshots or a measured column width with changing values, so the jumping is demonstrably gone.
- chained: `references/numbers-and-tables.md`, and `~/.agents/skills/frontend-direction/SKILL.md` if the visual treatment changes.

## Miss if
- Adds `tabular-nums` with no font support check, so nothing changes.
- Fixes alignment with padding hacks while numbers stay proportional.
- Uses color alone for up/down deltas.
