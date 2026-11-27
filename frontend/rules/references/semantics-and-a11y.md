# Semantics and accessibility

Requirements marked `[req]` map to WCAG 2.2 (W3C Recommendation, 2024-12-12). Cite the criterion when you flag one in review.

## Structure

- `[req]` Native elements first: `<button>` for actions, `<a href>` for navigation, `<table>` for tabular data, `<ul>/<ol>` for lists, `<label for>` for inputs. ARIA cannot add keyboard behaviour, focus handling or form submission — it only renames what is there.
- `[req]` Heading order follows structure (`h1` → `h2`), not visual size. Style the level you need instead of skipping levels for looks.
- `[req]` Landmarks: one `<main>`, `<nav>`, `<header>`, `<footer>`. They are how screen reader users jump around a page.
- `[conv]` `tabindex` only `0` or `-1`. Positive values break the expected order.
- `[conv]` `aria-hidden="true"` never on anything focusable; hide decorative graphics, not controls.

## Focus

- `[req]` Focus is always visible (WCAG 2.4.7) and never entirely hidden behind sticky headers or overlays (WCAG 2.4.11). A sticky header needs `scroll-margin-top` on anchor targets.
- `[req]` Style `:focus-visible`, not bare `:focus` — the latter draws a ring on mouse clicks too, which is why people remove it, which is how focus gets lost.
- `[conv]` Focus rings sit outside the element and add to the radius (see `radii-and-depth.md`); 2px minimum width, 3:1 contrast against the adjacent background.
- `[conv]` A custom control must show focus *and* respond to Enter/Space (buttons) or arrows/Home/End (composites). If that is hard, the native element was the answer.
- `[conv]` Move focus deliberately: opening a dialog focuses its first meaningful element, closing returns focus to the trigger, submitting focuses the first invalid field.

## Targets and input

- `[req]` Target size ≥ 24×24 CSS px (WCAG 2.5.8); 44×44 on touch, 40×40 desktop is the comfortable aim. Targets must not overlap.
- `[conv]` Inline links inside text are exempt; still avoid 1-character click areas.
- `[conv]` `type` and `inputmode` must match the data: `type="email"`, `inputmode="numeric"` for codes, `autocomplete="one-time-code"` for OTP. This is what gives mobile users the right keyboard.
- `[req]` Never block paste — people paste passwords, codes and addresses.
- `[conv]` Keep the submit button enabled until submission starts; validate on submit, not on every keystroke, and never validate a field the person has not finished.

## Forms and errors

- `[req]` Every input has a visible label bound with `for`/`id`. A placeholder is not a label.
- `[req]` Errors: `aria-invalid="true"` on the field, the message linked with `aria-describedby`, focus moved to the first invalid field on submit.
- `[conv]` Error text says what to do, in the interface's voice ("Enter a date after today"), not what went wrong mechanically.
- `[conv]` Validate with `:user-invalid` where available so a field is not marked invalid before the person finishes typing.
- `[conv]` `required` + `aria-required` only when actually required; a field that is "required for this flow" is not the same as required by the form.
- `[conv]` Announce async results with `role="status"` (polite); reserve `role="alert"` (assertive) for errors that need interrupting.

## Colour and motion

- `[req]` Colour is never the only channel for state (WCAG 1.4.1). Add icon, label, underline or shape.
- `[req]` Contrast: 4.5:1 body text, 3:1 large text and UI boundaries/icons (WCAG 1.4.3, 1.4.11), measured against the surface actually behind the element.
- `[conv]` Dark mode is its own palette, not an inversion. Inverting breaks contrast relationships and shadows.
- `[req]` Respect `prefers-reduced-motion`: wrap non-essential animation in `@media (prefers-reduced-motion: no-preference)` or provide a still path.
- `[conv]` Hover styles inside `@media (hover: hover)`; hover is not a state touch users have.
- `[conv]` `pointer-events: none` on decorative glows/gradients so they never swallow a click.

## Review checklist

1. Keyboard-only pass: can everything be reached, activated and left? Is the ring visible at every stop?
2. Zoom to 200 % and 400 %: does content reflow without clipping or horizontal scroll (WCAG 1.4.10)?
3. Screen reader pass on one form and one data table: labels, errors, column headers (`scope="col"`), row headers.
4. Force `prefers-reduced-motion: reduce` and confirm nothing essential disappears.
5. Grep the diff for `outline: none`, `tabindex="1"`-style positives, `<div` with `onClick`, and `transition: all`.
