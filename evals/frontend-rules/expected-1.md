# frontend-rules / prompt-1

## Must decide
- Map each item to a rule id: divs with onClick violate `[req]` #1 (native `<button>`), `outline: none` violates `[req]` #2 (visible focus), 16px targets violate `[req]` #3 (24x24 minimum, 40 desktop / 44 touch, no overlap).
- Contrast is checked against the painted background: 4.5:1 body, 3:1 large text and UI boundaries.
- Labels and error wiring are part of the form, not polish: `<label for>`, `aria-invalid`, `aria-describedby`, and focus the first invalid field on failed submit.

## Must show
- Findings grouped by rule, each tagged `[req]`/`[conv]`/`[taste]` with the concrete value (px, ratio) and `file:line`.
- Replacement markup: `<button type="button">`, a `:focus-visible` ring that survives the custom outline, and `min-block-size`/`min-inline-size` for the hit target.
- State colors paired with text, icon, or shape, never color alone (`[req]` #5).
- chained: `references/semantics-and-a11y.md` for focus, hit-target, and contrast detail.

## Miss if
- Accepts `outline: none` because a hover style exists.
- Lists semantics problems with no rule id and no expected value.
- Reviews only the happy path and never submits the form invalid.
