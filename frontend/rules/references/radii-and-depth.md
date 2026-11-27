# Radii and depth

## Concentric radii

A rounded child inside a padded rounded parent looks wrong unless the radii are concentric:
`inner = outer − padding − border`. Compute it, don't eyeball it.

```css
.card {
  --radius: 12px;
  --pad: 8px;
  --border: 1px;
  border-radius: var(--radius);
  padding: var(--pad);
  border: var(--border) solid var(--color-border);
}
.card > .inner {
  /* floored at 0: CSS clamps negative radii to 0, but silent clamping reads as a mistake */
  border-radius: max(0px, calc(var(--radius) - var(--pad) - var(--border)));
}
```

Four places the naive formula breaks:

1. `[conv]` **Borders** sit between padding and the outer edge. Subtract the border width too, as above.
2. `[conv]` **Pills** are `height ÷ 2`, not `999px`. A huge value *renders* like `height/2` because CSS clamps a radius to half the box, but it breaks the concentric math for anything nested inside, and it lies to the next reader. Use `border-radius: 50%`/`calc(var(--h) / 2)` for a fixed-height pill; `calc(infinity * 1px)` is the semantic form where support is acceptable.
3. `[conv]` **Focus rings sit outside** the element, so their radius *adds*: `ring-radius = inner + offset + ring-width`. Subtracting here is the common bug. It makes the ring cut the corners.
   ```css
   :focus-visible {
     outline: 2px solid var(--color-focus);
     outline-offset: 2px;
     /* visually concentric with a 6px inner radius */
     border-radius: calc(6px + 2px + 2px);
   }
   ```
4. `[conv]` **Padding larger than the radius** yields a negative calc; CSS clamps it to 0. Wrap in `max(0px, …)` so the intent is explicit, and decide deliberately whether the inner corner should be square.

## Optical over geometric

`[taste]` Equal measured padding can still look unequal. Adjust by eye for:

- a button with text + icon: slightly less padding on the icon side
- curves overshooting straight edges (text next to a circle needs a hair more space)
- descenders (g, y, j) needing a touch more bottom padding than ascenders need at the top
- the optical centre of large type sitting above the geometric centre

## Depth

- `[taste]` Layered `box-shadow` reads as depth better than a border. Stack 2-3 shadows: a tight one for the edge, a wider soft one for the lift.
- `[taste]` Give images a `1px` outline offset by `-1px`, black at ~8 % in light mode and white at ~8 % in dark, so photos on white/dark grounds do not bleed.
- `[conv]` Do not use a shadow *and* a border to do the same job; pick which one carries the edge.
- `[conv]` Hairlines (1px) on hidpi: a `0.5px`-style hairline needs `box-shadow: 0 0 0 0.5px` or a transform trick; a plain `1px` border at 2× is visibly heavier than at 1×.

## Animation geometry

- `[conv]` Animate from the trigger: set `transform-origin` to the point that opened the surface, not `center`.
- `[conv]` Name the properties; `transition: all` animates layout and paint you never intended.
- `[conv]` Button press: `scale(0.95–0.98)`, ~200 ms, `ease-out`.
- `[conv]` Exit animations should be shorter and smaller than entrances (~4 px travel + `blur(4px)` fading out).
- `[conv]` Menus opened frequently: animate the close, not the open.
- `[conv]` If an element jitters 1-2 px mid-animation, `will-change: transform` (Safari/iOS especially).
- `[conv]` Stagger entrances in small groups rather than animating one large block; keep frequent interactions instant.
- `[conv]` No entrance animation on page load unless it is the point.
