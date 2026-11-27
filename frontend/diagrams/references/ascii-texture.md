# Canvas textures: ASCII and glyph fields

A brand mark or photo rendered as characters, lit like a relief, with a band of
light travelling through it and the pointer tilting the light. It is the most
"expensive-looking" per line of code of the four archetypes, and it never goes out
of date because the output is text.

Working code: `examples/index.html`, the `ascii()` block.

## The pipeline

1. **Rasterise the shape once** onto an offscreen canvas at a small fixed size
   (240 × 120 is plenty) and read it back with `getImageData`.
2. **Take alpha as the shape**, 0–1.
3. **Blur it three times** (box blur, radius ~6). Three passes approximate a
   Gaussian well enough that the gradient is smooth.
4. **Height = blurred × alpha.** This is the trick: the blurred copy is high in the
   middle of a stroke and low at its edge, multiplied by the shape so nothing
   spills outside it. The result is a rounded ridge, not a flat silhouette.
5. **Gradient → normal.** `n = normalize(-dh/dx, -dh/dy, 1)` with the gradient
   scaled by ~50 to exaggerate the relief (26 is soft, 55 is glossy).
6. **Luminance = normal · light** (plus the height itself, for ambient), then map
   that to two things at once: which character from the ramp, and which colour from
   the palette.

```js
const lum = dotNormals * .78 + Math.min(1, height * 1.5) * .34;   // tune these two
const ch  = RAMP[Math.round(lum * (RAMP.length - 1))];            // ' .:;=+*x#%@'
const tone= PAL[Math.round(lum * (PAL.length - 1))];              // 5 blues → white
```

Two weights, and they are the whole art direction: raise the first for crisper
edges, raise the second for a fatter, glossier body.

## Shapes with flat faces (icons, cubes, diagrams)

A stroke has a ridge everywhere, so the normal carries the light. A **flat filled
face has a constant normal**, so the normal term is identical on all of it — the only
thing that can separate one face from another is the **height**. Two consequences,
learned by getting them wrong:

1. Give each face its own alpha (`1.0 / 0.86 / 0.74` for top / right / left) and let
   the luminance be driven by `height * .85 + (dot - .6) * .30`. If you weight the
   normal instead, the cube renders as one flat blob with a bright rim.
2. **Isometric projection halves one axis** (`S = 0.5`), so a 16 px sticker becomes
   8 px tall. A blur radius of 4 (a 9 px window) erases it — the height never reaches
   its alpha, and the whole image comes out 2–3 ramp steps too dark. Measure the
   thinnest feature before choosing the blur radius: `r ≈ feature / 4`.

The cell grid is the other limit: at 8 × 11 px cells a 3 × 3 face gives each sticker
about 1.5 rows of glyphs. Below ~1.5 rows per feature, the character grid is coarser
than the shape and no tuning helps — make the shape bigger or the cells smaller.

## Draw it from an atlas, not with fillText

`fillText` per cell is ~10× slower than `drawImage` per cell. Pre-render every
character in every tone into one bitmap at startup:

```js
atlas.width  = cellW * RAMP.length;
atlas.height = cellH * TONES;
// for each tone: fillStyle = palette(tone); for each char: fillText at its cell
```

Then the frame is one `drawImage` per non-empty cell:

```js
ctx.drawImage(atlas, rampIndex * aCW, toneIndex * aCH, aCW, aCH, x, y, CW, CH);
```

That is what makes 1 500 cells at 24 fps comfortable on a laptop.

## Sizes and rates

| | desktop | narrow |
|---|---|---|
| cell | 8–9 × 13–14 px | 6 × 10 px |
| grid | canvas / cell | canvas / cell |
| rate | 24 fps (42 ms) | 24 fps |

The comment in the original source is the design decision worth keeping: *"at 60 fps
the shuffle becomes a blur"*. The character swap is supposed to look like text
settling, so it must be slower than the display.

Set the canvas **aspect ratio close to the mark's own** (`aspect-ratio: 2.5 / 1`).
The grid stretches whatever you draw into the full box, so a 2:1 mark in a 3:1
canvas comes out squat, and no amount of tuning fixes it.

## Ambient motion

- **A band of light** travelling horizontally: add
  `max(0, 1 - |u - band| * 7) * .5` to luminance, where `band` is
  `(t * .22) % 1.6 - .3`. Cheap, and it makes the surface look like it is being
  scanned by data.
- **Pointer tilt**: the light direction lerps toward the pointer (`* .08` per
  frame), so it follows with weight instead of sticking to the cursor.
- **A percentage of characters re-rolling** each frame adds life; keep it under 2 %
  or it reads as noise.

## The text variant: scramble-in

The same aesthetic applied to a heading — every letter cycles through glyphs and
settles into place, in a cascade, in under a second:

```js
const at = c * 34 + Math.random() * 170;             // per-character settle time
if (t - painted >= 42) { /* repaint all unsettled chars with random glyphs */ }
```

Repaint at 24 fps, not 60: at 60 the scramble is unreadable. Use it on a hero
headline, a location that changes ("São Paulo" → "Campinas"), or a status line —
never on body copy, and never when the same text must be selectable while it runs
(the reference site swaps `textContent`, so it is not).

## Gotchas

- `getImageData` needs a same-origin image; a cross-origin mark taints the canvas and throws. Draw the mark with paths, inline it as data-URI, or serve it from your own origin.
- Skip cells whose alpha is below ~0.16, and skip the space character entirely.
- `Math.min(2, devicePixelRatio)` — on a 3× phone the grid is the same and the
  extra pixels buy nothing.
- Do not animate a CSS filter or a stack of layers over the canvas to fake glow; it
  costs more than drawing the right tones.
- The canvas is decoration. `aria-hidden="true"`, no text alternative needed beyond
  the section heading — but the mark's meaning must already be in the HTML.

## When to use it

When the brand mark *is* the message and the section has nothing else to say: a
hero, a divider, a footer. One per page. Two competes with itself and neither reads
as an accent.

## Reduced motion

Draw a single frame with the light at rest and no band (`paint(now, still = true)`),
then never start the loop. The image stays — which is the point, since it costs one
frame.
