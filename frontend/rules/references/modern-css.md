# Modern CSS

Reach for the platform before adding a dependency, a JS measurement, or a hack. Every item below is a *replacement* for something people still hand-roll, with its practical floor.

Floors verified against Can I use where marked; the rest are stable since ~2021-2023 and should still be confirmed against the project's own browser floor before relying on them at the edge.

## Layout

- `[conv]` Logical properties (`padding-inline`, `margin-block`, `inset-inline-start`) instead of `left`/`right`. RTL comes free instead of needing a second stylesheet.
- `[conv]` `display: grid` / `flex` instead of floats, clearfixes or table-cell tricks.
- `[conv]` `gap` in flex and grid instead of margins on children.
- `[conv]` `grid-template-columns: auto-fit minmax(min(250px, 100%), 1fr)` instead of a media-query ladder for card grids.
- `[conv]` Container queries (`@container`) when a component's layout depends on its own width, not the viewport. A card in a sidebar and the same card in a wide column want different layouts; media queries cannot express that.
- `[conv]` `aspect-ratio` instead of padding-top percentage hacks.
- `[conv]` `min()/max()/clamp()` for fluid type and spacing instead of many breakpoints.
- `[conv]` `dvh`/`svh`/`lvh` instead of `100vh` on mobile, where `vh` ignores the browser chrome.
- `[conv]` `position: sticky` + `scroll-margin-top` for anchor targets under a sticky header; `scroll-padding-top` on the scrolling container does the same job for in-page jumps.
- `[conv]` `:has()` for parent-state selection (`body:has(dialog[open])`) instead of JS adding classes. Floor: Chrome/Edge 105, Safari 15.4, Firefox 121.

## Colour

- `[conv]` `color-mix()` instead of precomputed hover/disabled shades: `color-mix(in oklab, var(--color-accent) 85%, black)`.
- `[conv]` `oklch()` for palettes where perceived lightness must be even across hues; sRGB lightness is not perceptually uniform and is why hand-picked palettes look patchy.
- `[conv]` Gradient interpolation space matters: `in oklab` for even brightness, `in oklch` for more vivid midpoints, `in srgb` for muted ones.
- `[conv]` `currentColor` for icon strokes and borders that should follow text colour.
- `[conv]` One theme mechanism only: `prefers-color-scheme` **or** a class on `<html>`. Mixing them produces pages that fight themselves.

## Forms and interaction

- `[conv]` `accent-color` to theme checkboxes/radios without rebuilding them.
- `[conv]` `:user-invalid` / `:user-valid` so a field is not marked invalid before the person finishes. Floor: Chrome 119, Safari 16.5, Firefox 88.
- `[conv]` `field-sizing: content` for auto-growing inputs/textarea instead of a JS height hack. Floor: Chrome/Edge 123, Firefox 152, Safari 26.2. Use with a fallback.
- `[conv]` `<dialog>` + `showModal()` instead of a hand-built focus trap; it handles Escape, inertness and the top layer. Style with `::backdrop`.
- `[conv]` `@starting-style` for enter transitions on elements that were just added to the DOM (dialogs, popovers). Floor: Chrome 117, Safari 17.5, Firefox 129.
- `[conv]` `popover` + `anchor-name` for tooltips/menus where support allows; **anchor positioning is still partial** (Chrome 125+, Safari 26+, Firefox none). Treat it as an enhancement, not the only path.
- `[conv]` `inert` instead of `aria-hidden` + `tabindex="-1"` on background content.
- `[conv]` `scroll-behavior: smooth` only inside `@media (prefers-reduced-motion: no-preference)`.

## Type and content

- `[conv]` `text-wrap: balance` for headings; `pretty` is progressive (Firefox lacks it). Never depend on it for layout.
- `[conv]` `font-variant-numeric` for figures (see `numbers-and-tables.md`), `font-feature-settings` only when a feature has no property.
- `[conv]` `content-visibility: auto` with `contain-intrinsic-size` for long lists, but measure first; it can break find-in-page and scroll anchoring.
- `[conv]` `::selection` styled to match the palette instead of the browser default, which often fails contrast against brand colours.

## What not to do

- `[conv]` No `transition: all`, no `will-change` sprinkled everywhere (it costs compositor memory), no `!important` to win a specificity fight you can restructure away.
- `[conv]` No JS measurement for things CSS can express: element height, sticky offsets, equal columns, text truncation with a tooltip.
- `[conv]` No viewport-unit type scaling without `clamp()`. It produces unreadable text at both extremes.
- `[conv]` Don't polyfill what the browser floor already supports; check the floor first.
