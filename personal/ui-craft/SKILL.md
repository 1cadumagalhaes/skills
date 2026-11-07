---
name: ui-craft
description: >-
  Concrete rules for building or reviewing UI that is correct, accessible and modern — concentric
  radii, tabular numbers, focus rings, spacing rhythm, semantic HTML, form errors, hover on touch,
  contrast, hit targets, and modern CSS instead of workarounds. Use when styling, restyling,
  reviewing or fixing any web interface, when a layout or component looks wrong, shifts, or is
  misaligned, when auditing accessibility, or when a typography, colour or spacing decision needs a
  concrete value rather than an opinion. Rules, not process — pair with frontend-workflow for build
  order and design-direction for the look.
---

# UI craft

Checkable rules with concrete values. Nothing here is taste — the look lives in `design-direction`.

## Tag legend

- `[req]` hard requirement (WCAG, or how browsers actually behave). Violating it is a defect.
- `[conv]` convention with a reason. Follow unless the project says otherwise.
- `[taste]` strong default a designer may overrule. Say which trade you took when you do.

## Always apply

1. `[req]` Native element first: `<button>` for actions, `<a>` for navigation, `<table>` for tabular data, `<label for>` for every input. An ARIA role is not a substitute for the element.
2. `[req]` Focus is always visible: style `:focus-visible`; never `outline: none` without a replacement ring.
3. `[req]` Pointer targets ≥ 24×24 CSS px (WCAG 2.5.8); aim 40×40 desktop, 44×44 touch. Targets must not overlap.
4. `[req]` Contrast measured against the surface actually behind the element: 4.5:1 body text, 3:1 large text and UI boundaries (WCAG 1.4.3 / 1.4.11).
5. `[req]` Never colour alone for state — add icon, label or shape.
6. `[req]` Every input has a visible label, a matching `type`/`inputmode`, and errors wired with `aria-invalid="true"` + `aria-describedby`; on submit, focus moves to the first invalid field.
7. `[conv]` Numbers that update or line up in columns get `font-variant-numeric: tabular-nums` — and confirm the font ships `tnum`, because several common ones do not.
8. `[conv]` Name the properties in a transition (never `transition: all`); use transitions, not keyframes, for anything a person can interrupt.
9. `[conv]` Hover styles inside `@media (hover: hover)` — on touch `:hover` sticks after a tap and reads as selected.
10. `[conv]` Semantic colour tokens, never primitives: `--color-text-secondary`, not `--blue-500`. One theme-switch mechanism, a separate palette per scheme.
11. `[taste]` Concentric radii when nesting: inner = outer − padding − border, floored at 0.
12. `[taste]` Optical beats geometric — adjust the icon side, curve overshoots and descenders by eye.

## References — read the one that matches the task

| read when | file |
|---|---|
| nesting rounded surfaces, borders vs shadows, pills, focus rings | `references/radii-and-depth.md` |
| tables, live values, timers, prices, aligned columns | `references/numbers-and-tables.md` |
| measure, wrapping, type scales, spacing rhythm, punctuation, fonts | `references/type-and-rhythm.md` |
| forms, focus, hit targets, contrast, screen readers, reduced motion | `references/semantics-and-a11y.md` |
| choosing layout/query/colour primitives, browser support floors | `references/modern-css.md` |

Sources: WCAG 2.2 (W3C Recommendation, 2024-12-12); <https://interfaces.dev/cheat-sheet>; Can I use for support floors; font feature checks run locally with fontTools.
