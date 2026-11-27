# Easing, duration, and property reference

Use the existing project tokens first. These values are the canonical motion-cluster defaults; do not approximate or create a parallel token set.

## Easing choice

| Situation | Easing |
| --- | --- |
| Entering or exiting | `ease-out` |
| Moving or morphing on screen | `ease-in-out` |
| Hover or color change | `ease` |
| Constant motion, such as a marquee or progress indicator | `linear` |
| Default | `ease-out` |

Never use `ease-in` on UI: it starts slowly and delays the moment the user is watching. Built-in CSS easings are too weak for deliberate UI motion; use these strong curves:

```css
--ease-out: cubic-bezier(0.23, 1, 0.32, 1);        /* strong ease-out for UI */
--ease-in-out: cubic-bezier(0.77, 0, 0.175, 1);    /* strong ease-in-out for on-screen movement */
--ease-drawer: cubic-bezier(0.32, 0.72, 0, 1);     /* iOS-like drawer curve (Ionic) */
```

For another curve, use [easing.dev](https://easing.dev/) or [easings.co](https://easings.co/); do not hand-roll one.

## Duration budgets

| Element | Duration |
| --- | --- |
| Button press feedback | 100-160ms |
| Tooltips, small popovers | 125-200ms |
| Dropdowns, selects | 150-250ms |
| Modals, drawers | 200-500ms |
| Marketing or explanatory motion | Can be longer |

UI animations generally stay under 300ms. A longer duration needs a reason, such as a deliberate hold or explanatory motion. The source skills all give modals/drawers a 200-500ms range while separately setting the general UI ceiling below 300ms; retain both statements, and apply the exception with an explicit reason.

## Property and implementation rules

- Prefer `transform` and `opacity`; they avoid layout and paint and can be composited. Do not animate `width`, `margin`, `padding`, `top`, or `left` for ordinary UI motion. `height` is tolerated for accordions when no transform equivalent works; `clip-path` is a sanctioned additional property for purposeful reveals.
- Never enter with `scale(0)`. Start around `scale(0.9-0.97)` plus `opacity: 0`.
- Anchor popovers, dropdowns, menus, and tooltips at their trigger with `transform-origin` (Base UI: `var(--transform-origin)`). Modals are exempt and may stay centered.
- Use `translate()` percentages for offsets relative to the element's own size. Set a moving element's transform directly; do not drive every child's transform through a parent CSS variable.
- CSS transitions retarget during interruption; keyframes restart. Prefer transitions for rapidly triggered or reversible UI. Use springs for momentum, gestures, and interruptible movement; keep bounce at 0.1-0.3 and reserve visible bounce for playful interactions or drag-to-dismiss.
- CSS animations are preferable for predetermined motion under load; use JS for dynamic or interruptible motion. Motion `x`/`y`/`scale` shorthands are hardware-accelerated on HTML elements from Motion 14.2; older versions should use a full `transform` string. Layout animations remain main-thread work.
- Ship reduced-motion handling and gate hover motion with `(hover: hover) and (pointer: fine)`.
