---
name: frontend-rules
description: "Checkable UI correctness and accessibility rules: semantics, focus, hit targets, contrast, tabular numbers, transitions, and modern CSS. Use when building or reviewing web interfaces."
cluster: frontend
tier: root
---

# UI craft

| When | Read |
|---|---|
| Building and reviewing interface motion | `~/.agents/skills/motion-build/SKILL.md` |

Checkable rules with concrete values for accessible, resilient interfaces. Visual direction lives in `frontend-direction` and `DESIGN.md`.

## Tag legend

- `[req]` Hard requirement (WCAG or browser behavior). Violating it is a defect.
- `[conv]` Strong convention with a clear technical reason. Follow unless the repo decides otherwise.
- `[taste]` Default starting point a designer may override with an explicit reason.

## Always apply

1. `[req]` Use native HTML elements first: `<button>` for actions, `<a>` for navigation, `<table>` for tabular data, `<label for>` for every input.
2. `[req]` Keep focus visible on keyboard navigation: style `:focus-visible` and always provide a clear focus ring when customizing outlines.
3. `[req]` Keep pointer targets at least 24x24 CSS px (WCAG 2.5.8), aiming for 40x40 on desktop and 44x44 on touch with zero target overlap.
4. `[req]` Verify contrast against the actual painted background: 4.5:1 for body text and 3:1 for large text and UI boundaries (WCAG 1.4.3 / 1.4.11).
5. `[req]` Pair state colors with text, icon, or shape; never rely on color alone.
6. `[req]` Give every input a visible label, matching `type`/`inputmode`, `aria-invalid="true"`, and `aria-describedby` error wiring; focus the first invalid field on failed submit.
7. `[conv]` Apply `font-variant-numeric: tabular-nums` to live counters, timers, tables, and numeric columns, and verify the loaded font includes `tnum`.
8. `[conv]` Name explicit CSS properties in transitions (avoid `transition: all`) and prefer transitions over keyframes for interruptible user interactions.
9. `[conv]` Gate hover rules inside `@media (hover: hover)` so touch taps do not leave sticky hover states.
10. `[conv]` Use semantic color tokens (`--color-text-secondary`) rather than raw palette names (`--blue-500`), with separate palettes per color scheme.
11. `[taste]` Keep nested corner radii concentric: `inner = max(0, outer - padding - border)`.
12. `[taste]` Adjust optical alignment (icons, curve overshoots, type baselines) by eye when geometric centering reads off.

## References

| Read when | File |
|---|---|
| Nesting rounded surfaces, borders vs shadows, pills, focus rings | `references/radii-and-depth.md` |
| Tables, live values, timers, prices, aligned columns | `references/numbers-and-tables.md` |
| Measure, wrapping, type scales, spacing rhythm, punctuation, fonts | `references/type-and-rhythm.md` |
| Forms, focus, hit targets, contrast, screen readers, reduced motion | `references/semantics-and-a11y.md` |
| Layout queries, color primitives, browser support floors | `references/modern-css.md` |
| Text entry, motion limits, media loading, long lists, touch, hydration | `references/platform-polish.md` |
| Animation choreography and spring recipes | `~/.agents/skills/motion-build/RECIPES.md` |

Sources: WCAG 2.2 (W3C Recommendation, 2024-12-12), `interfaces.dev` cheat sheet, Can I use, local `fontTools` checks.
