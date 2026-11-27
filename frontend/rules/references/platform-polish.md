# Platform polish

Rules that make a working interface feel finished on real devices. Tag meaning
matches the rest of `frontend-rules` (`[req]` requirement, `[conv]` convention with a
reason).

## Text entry

- `[conv]` `spellCheck={false}` on emails, codes, usernames and search-as-you-type.
- `[conv]` A checkbox or radio and its label share one hit target (wrap, or
  `label[for]`); never a tiny box next to a large dead label.
- `[req]` Allow password managers and paste everywhere — no `onPaste` with
  `preventDefault`, no `autocomplete="off"` on credentials.
- `[conv]` Never ask for the same information twice in one flow (WCAG 3.3.7);
  prefill what you already know.
- `[conv]` Warn before leaving a form with unsaved changes.

## Motion

- `[req]` Any auto-playing motion longer than 5 s needs pause/stop (WCAG 2.2.2).
- `[conv]` Carousels and marquees keep controls visible; no hover-only pause.

## Media

- `[conv]` Below-the-fold images `loading="lazy"`; the LCP/hero image
  `fetchpriority="high"` — do not lazy-load the hero.
- `[conv]` Prefer `<video autoplay muted loop playsinline>` over an animated GIF:
  far smaller, and it honours `prefers-reduced-motion` through your own logic.
- `[conv]` Every `<img>` has `width` and `height` (or an aspect-ratio box) so it
  cannot shift layout.
- `[conv]` `preconnect` to asset/CDN origins; preload critical fonts with
  `font-display: swap`.

## Long lists and rendering cost

- `[conv]` A few hundred rows or more: virtualize, or put `content-visibility: auto`
  on off-screen sections.
- `[conv]` No layout reads during render (`getBoundingClientRect`, `offsetHeight`).
- `[conv]` Keep controlled inputs cheap per keystroke; no heavy work in `onChange`.

## Touch and viewport

- `[conv]` `touch-action: manipulation` on interactive elements to kill the
  300 ms double-tap delay.
- `[conv]` `overscroll-behavior: contain` inside modals and drawers so scrolling
  them does not scroll the page behind.
- `[conv]` Full-bleed layouts respect `env(safe-area-inset-*)`.
- `[conv]` `autoFocus` sparingly, and never on mobile without a reason — it
  summons the keyboard and jumps the page.

## Theming and browser chrome

- `[conv]` `color-scheme: dark` (or `light dark`) on `<html>`; it themes
  scrollbars, form controls and the canvas before CSS loads.
- `[conv]` `<meta name="theme-color">` matches the page background, and updates
  with the scheme.
- `[conv]` A native `<select>` needs explicit `background-color` and `color` on a
  dark theme, or the popup stays white or renders white-on-white.

## Locale and language

- `[req]` `<html lang>` is set; content in another language carries `lang` on its
  own element.
- `[conv]` Dates and numbers through `Intl.DateTimeFormat` / `Intl.NumberFormat`,
  never hardcoded formats.
- `[conv]` `translate="no"` on brand names and code tokens, so browser
  translation does not mangle them.

## Server-rendered frameworks

- `[conv]` An input with `value` needs `onChange`, or use `defaultValue`; otherwise
  it is read-only and React warns.
- `[conv]` Guard `Date.now()`, `Math.random()` and locale-dependent formatting
  against server/client mismatch.
- `[conv]` `suppressHydrationWarning` only where genuinely needed, never as a
  blanket fix.

## Keyboard

- `[conv]` A skip link to main content on any page with a nav before it.
- `[req]` Anything drag-only (reorder, sliders, swipe) has a click or keyboard
  alternative (WCAG 2.5.7).

## Stop and fix

- The API error reaches only `console.error`.
- An icon button has no accessible name, or every row's button says the same
  word.
- “Done” was said without opening the page.

Adapted from the `senior-frontend` skill in claude-code-templates (MIT, commit
30f72e1) — itself adapted from Vercel's Web Interface Guidelines and Addy
Osmani's web-quality-skills — deduplicated against `semantics-and-a11y.md` and
`type-and-rhythm.md`. Attribution in the skills repo's `ATTRIBUTION.md`.
