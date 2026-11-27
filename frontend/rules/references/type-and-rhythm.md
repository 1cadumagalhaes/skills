# Type and rhythm

## Measure and wrapping

- `[conv]` Long text: 60–75 characters per line. UI copy: shorter. Full-width text over ~90ch is unreadable regardless of font size.
- `[conv]` `text-wrap: balance` on headings (2–4 lines max); `text-wrap: pretty` on descriptions to avoid orphans. Neither on long-form body text.
  Support: `balance` widely supported; `pretty` is Chrome/Edge 117+, Safari 26+, **Firefox none** — treat as progressive enhancement, never as a layout dependency.
- `[conv]` `overflow-wrap: break-word` (or `anywhere`) for long words, IDs and URLs; `white-space: nowrap` for labels and badges that must not wrap.
- `[conv]` Slightly longer measure and more line-height for serif body text than for sans.
- `[conv]` Never truncate with an ellipsis without a way to read the whole value (title/expanded view).

## Scales

- `[conv]` One type scale, 5–7 steps, ratio between ~1.15 (dense UI) and ~1.33 (editorial). Every size in the UI comes from the scale.
- `[conv]` Fluid sizing with `clamp()` instead of a breakpoint per size: `font-size: clamp(1rem, 0.95rem + 0.3vw, 1.25rem)`.
- `[conv]` Line-height: ~1.5 for body, 1.1–1.25 for display sizes, 1 for single-line labels.
- `[conv]` Two families maximum; if two, make them clearly distinct in role. One family with weight/size contrast is usually better.
- `[taste]` Use `font-size-adjust` or a size-adjusted fallback stack so a font swap does not shift layout (the classic 0.02 CLS).

## Fonts

- `[conv]` `woff2` only; `woff` only as a legacy fallback if a browser floor demands it. Never ship `ttf`/`otf` to the web.
- `[conv]` `font-display: swap` for body, `optional` for decorative display faces (avoids the late-swap flash).
- `[conv]` Subset what you ship; a full CJK font costs megabytes for one label.
- `[taste]` `-webkit-font-smoothing: antialiased` is a preference, not a fix — it thins text on macOS; decide per project instead of copying it everywhere.
- `[conv]` Match icon stroke weight to the adjacent text weight; a 1.5px icon next to 400-weight text reads as broken.

## Spacing rhythm

- `[conv]` One spacing scale (4px or 8px steps). No arbitrary `13px`. If a value is not on the scale, either it is wrong or the scale is missing a step.
- `[conv]` Space between groups ≥ 2× the space between items inside a group (e.g. 8px within, 16–24px between). This single ratio does more for perceived order than any colour choice.
- `[conv]` Use `gap` for flex/grid spacing rather than margins on children — margins collapse, gap does not, and gap keeps the component's own box honest.
- `[conv]` Padding inside a control scales with its size class; a small button and a large button should not share the same inner padding.

## Punctuation and casing

- `[conv]` Smart punctuation in visible copy: curly quotes, en dash for ranges (1–3), em dash for asides, one ellipsis character (…).
- `[conv]` Apply uppercase with `text-transform`, never by typing it — screen readers and search see the underlying text.
- `[conv]` Sentence case for buttons, labels and headings is the safer default; pick one convention and hold it across the product.
- `[conv]` Underlines: `text-underline-position: from-font` + `text-decoration-skip-ink: auto` so the line does not cut through g and y.
- `[conv]` Button labels start with a verb ("Save draft", "Delete project"); a confirmation button names the consequence, not "OK".

## Empty and loading states

- `[conv]` An empty state explains what belongs there and offers one action to start — never a blank panel.
- `[conv]` Skeletons match the final layout's dimensions, or the page shifts when data lands.
- `[conv]` Loading indicators under ~300 ms do not need one; a flash of spinner is worse than a short wait.
