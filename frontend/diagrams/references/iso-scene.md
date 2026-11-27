# Isometric scenes

The section that says "our product is a system": boxes, cylinders and plates on an
isometric grid, ducts between them, labels riding the projection, the whole thing
stroking itself in when it scrolls into view, and a public function to light one
piece by name.

Cost: ~200 lines of engine, ~30 lines per figure. Runs on SVG, so it stays crisp at
any size and needs no WebGL.

Working code: `examples/index.html`, the `iso()` block.

## The projection

Two constants do all the work:

```js
const C = Math.cos(Math.PI / 6);   // 0.866 — how much x leans right
const S = 0.5;                     // classic 2:1 isometric
const p = (x, y, z, u) => [
  (x - y) * C * u,                 // screen x
  ((x + y) * S - z) * u            // screen y
];
```

`u` is the unit in pixels (`data-u` on the figure). Everything else — boxes,
cylinders, ducts, label anchors — is expressed in grid units and multiplied by `u`
at projection time, so one scene scales by changing a single attribute.

Track the bounding box while projecting (min/max of both screen coordinates). The
`viewBox` is that box plus ~10 px of padding, which is what lets one figure be
squeezed into a 300 px column and a 600 px one without touching the drawing.

## Depth: paint order, not a depth buffer

Two rules, and they are enough:

1. **Objects are painted far to near.** With the viewer at `+x +y`, depth is
   `x + y`; sort objects ascending and append in that order.
2. **Every face is filled with the page background colour.** An opaque fill hides
   whatever is behind it, so hidden edges disappear for free.

```js
const parts = [];                               // {d, node}
const put = (node, d) => { parts.push({ d, node }); return node; };
// ...
parts.sort((a, b) => a.d - b.d).forEach(p => g.appendChild(p.n));
```

The fill must be *exactly* the background (`var(--iso-fill)` = `var(--bg)`), or the
back edges show through as ghosts. On a gradient or image background, this
technique does not work — use a matching solid panel behind the figure.

A box draws only the three faces a viewer can see: `right` (x+w), `front` (y+d),
`top` (z+h). Three polygons each; there is no reason to draw the hidden ones.

## Primitives worth having

| primitive | notes |
|---|---|
| `box(x,y,z,w,d,h,{module, anchor, top, front})` | 3 faces + optional detail brushes + a named label anchor |
| `cylinder(cx,cy,z,r,h,{rings})` | ellipse radii are `r * SQRT2 * C * u` and `r * SQRT2 * S * u` — that is what makes a circle look like a circle on the floor plane |
| `ring(cx,cy,z,r)` | a flat ellipse: floor markings, signal rings |
| `duct(points[],{module,delay,duration})` | a polyline plus a travelling pulse |
| `wire(x,y,z,w,d,h)` | dashed 12-edge cuboid: the thing that does not exist yet |

Detail brushes are callbacks that receive a mapper from face-local `(u,v)` to screen
space, so a screen's content is written in the face's own coordinates:

```js
box(-.4, 4.4, 0, 3, 2.2, 1.8, {
  module: 'dashboard',
  front: (map, w, h) => {                        // map(u,v) -> [sx, sy]
    poly([map(.4,.4), map(w-.4,.4), map(w-.4,h-.4), map(.4,h-.4)], 'f screen', 1e7);
  }
});
```

**Gotcha:** a detail drawn into a face must be keyed with that face's depth, or it
floats above closer boxes. In the example, details are pushed at `1e7` because no
box is ever in front of the module they belong to — fine for a flat scene, wrong for
nested ones. When in doubt, give the detail the depth of the box that owns it plus a
fraction.

## Draw-in

The trick that makes this look hand-drawn rather than assembled:

```css
.js .iso-fig.is-mounted .iso-svg :is(.f,.l,.d):not(.dash) {
  stroke-dasharray: 1 1;
  stroke-dashoffset: 1;
  transition: stroke-dashoffset 1.1s var(--ease) var(--d, 0s);
}
.js .iso-fig.is-drawn .iso-svg :is(.f,.l,.d) { stroke-dashoffset: 0; }
```

```js
el.setAttribute('pathLength', '1');                       // normalise every path
el.style.setProperty('--d', (i / n * tempo).toFixed(3) + 's');
```

`pathLength="1"` makes one dash equal to the whole outline, whatever its real
length, so a single `stroke-dashoffset: 1 → 0` animation works for every element.
The stagger is just the element index over the total count times `data-tempo`
(0.9–1.8 s on the reference site). Add `is-ready` ~`tempo + 0.4 s` later to switch
the ambient loops on.

## Pulses along the ducts

A short dash travelling a path, with no JS at all:

```css
.pulse { stroke-dasharray: .06 .94; opacity: 0; }
.is-ready .pulse { opacity: 1; animation: pulse var(--pv, 3.2s) linear infinite var(--pd, 0s); }
@keyframes pulse { from { stroke-dashoffset: 1 } to { stroke-dashoffset: 0 } }
.iso-fig:not(.is-visible) .pulse { animation-play-state: paused; }
```

Per-duct `--pd` (delay) and `--pv` (duration) keep several ducts from marching in
lockstep — 3.1/3.4/3.7 s with 0.4–0.9 s offsets reads as data flowing, one shared
duration reads as a loading animation.

## Labels: HTML over the drawing

Do not use `<text>`. Labels as absolutely positioned spans inside the `<figure>`:

- they inherit the page font, translate with the page, and are readable by the
  site's i18n pass;
- they can be buttons, or carry `title`/`aria-label`;
- they stay sharp when the SVG is scaled.

Position them with the same projection, after mounting (the figure must have a
width), and clamp horizontally so a label near the edge does not leave the frame:

```js
const fw = fig.clientWidth, lw = el.offsetWidth || 60;
const px = (s[0] - (x0 - pad)) / w * fw;
el.style.left = Math.max(4, Math.min(fw - lw - 4, px)) + 'px';
el.style.top  = ((s[1] - (y0 - pad)) / h * 100).toFixed(2) + '%';
```

The `figure` gets `role="img"` and a sentence-long `aria-label` describing the scene;
the spans inside it are `aria-hidden`.

## Addressability

Give every element that can be highlighted `data-module="name"`, and expose one
function:

```js
function lit(name) {
  fig.querySelectorAll('[data-module]').forEach(el =>
    el.classList.toggle('is-lit', !!name && el.getAttribute('data-module') === name));
  fig.querySelectorAll('[data-label]').forEach(el =>
    el.classList.toggle('is-lit', !!name && el.getAttribute('data-label') === name));
  fig.classList.toggle('has-lit', !!name);
}
window.LoopIso = { light: (fig, name) => api(fig).lit(name) };
```

```css
.iso-fig.has-lit [data-module]:not(.is-lit) { opacity: .35; }   /* the rest recedes */
[data-module].is-lit.f, [data-module].is-lit.l { stroke: var(--accent); stroke-width: 1.5; }
.iso-fig.has-lit .pulse { opacity: .25; }
.iso-fig.has-lit .pulse.is-lit { opacity: 1; animation-duration: 1.7s; }
```

That one API is why the same drawing can be driven by a tab list ("which situation
are you in?"), a button row ("what do you need?"), or a self-tour. On the reference
site the identical `planta` scene appears twice, once touring itself and once
answering tabs.

Self-tour: light `nomes[i]` every 2.6 s while visible, stop when a pointer or focus
enters a label, resume on leave.

## Linked list ↔ drawing (the `:has()` pattern)

The most convincing interaction on the reference site is not an animation at all: a
list of three topics on the right, a stacked drawing on the left, and hovering or
focusing any topic lights its floor, dims the others, lifts the chosen one, and
dims the sibling rows — and hovering the floors or the labels does the same in
reverse. One function drives all six element groups.

**JS sets three classes and one flag; CSS derives everything else.**

```js
function mostrar(n) {                       // n = index, or -1 for none
  fig.classList.toggle('tem-andar', n >= 0);                        // a flag on the figure
  andares.forEach((g, i) => g.classList.toggle('is-aceso', i === n));  // the floors
  rotulos.forEach((r, i) => r.classList.toggle('is-escolhido', i === n));
  linhas.forEach((li, i) => {                                        // the list rows
    li.classList.toggle('is-ativo', i === n);
    if (i === n) li.setAttribute('aria-current', 'true'); else li.removeAttribute('aria-current');
  });
}
```

```css
/* the drawing: the chosen floor rises, the rest recede */
.iso__andar { transition: opacity .35s var(--ease-soft), transform .5s var(--ease); }
.iso.tem-andar .iso__andar:not(.is-aceso) { opacity: .26; }
.iso__andar.is-aceso { transform: translateY(-7px); }
.iso__andar.is-aceso :is(.iso__face, .iso__linha) { stroke: var(--iso-azul); stroke-width: 1.5; }

/* the list dims itself — the parent reacts to the child, JS never picks "the others" */
.escada li { transition: background-color .3s var(--ease-soft), opacity .3s var(--ease-soft); }
.escada:has(li.is-ativo) li:not(.is-ativo) { opacity: .5; }
.escada li.is-ativo { background: var(--bg); }
```

Four things make it work, and they are worth copying exactly:

1. **`:has()` on the container.** `.escada:has(li.is-ativo) li:not(.is-ativo)` is the
   whole "everything else recedes" rule. No JS loop over the siblings, no
   `data-state` on the parent, and it degrades to "nothing dims" in a browser
   without `:has()`.
2. **Two speeds in one component.** Opacity at 350 ms, the 7 px lift at 500 ms. The
   lift is the gesture; the dim is the consequence. Same instinct as the measured
   state fades (450–550 ms) elsewhere on the site.
3. **Hover is bidirectional and reversible.** Rows, floors and side labels all call
   the same `mostrar(n)`; `pointerleave` returns to the *pinned* index, not to none;
   `click` pins or unpins. Six groups, one function, one source of truth.
4. **A persistent emphasis coexists.** The third row carries `is-alta` in the markup
   ("prioritized") and its floor is drawn already lit, so the diagram has a bias
   before anyone touches it. Hover is elaboration, not the only way to read it.

Accessibility rides along: rows get `tabindex`, `focus` calls the same `mostrar`,
`aria-current` marks the chosen one, and Enter/Space pins it. And on narrow screens
the stack moves **below** the list (`order: 2`), so the control comes first.

## Three scenes, three jobs (all the same engine)

| the section is | scene | motion |
|---|---|---|
| a system with named parts | boxes + ducts from a core | draw-in + pulses + addressable modules |
| a process in 3–4 steps (storyboard) | one tiny scene per step: two boxes talking, a stack of plates, three blocks, a plate with a ring above | draw-in only, no ducts; the hover is the card's own |
| a funnel or a hierarchy (layers) | cylinders stacked at rising `z`, radii shrinking | draw-in + one lit layer at a time |
| a product mockup (static) | a window and a phone as boxes with a `screen` face | draw-in only; it stops when it is finished |

Two practical notes from building the set:

- **Storyboard figures need a fixed height box.** Different scenes have different
  aspects, so with `width: 100%` the captions land at different heights across the
  four cards. Give the figure a `height` and let the SVG letterbox inside it — that
  is safe *only* because those figures carry no HTML labels.
- **Cylinders need a lit top to read as plates.** The occlusion trick fills faces
  with the page background, which is right for boxes and makes a stack of discs look
  like a wireframe. One rule fixes it: `[data-iso="pilha"] .f.top { fill:
  color-mix(in srgb, var(--accent) 12%, var(--fill)) }`.

## Picking the scene

Keep it under ~25 boxes. Isometric is legible exactly while everything has a
distinct silhouette; past that it turns into a plate of spaghetti and a canvas point
cloud tells the same story better (`references/spatial-map.md`).

## Checklist

- [ ] fill = page background, or the back edges ghost through
- [ ] objects sorted by `x + y`; details keyed to their owner's depth
- [ ] `viewBox` from the tracked bounding box + padding
- [ ] first frame drawn synchronously; loops gated on `is-visible`
- [ ] labels clamped inside the figure, `aria-hidden`, scene has an `aria-label`
- [ ] reduced motion: `is-drawn is-ready` added immediately, no pulses
- [ ] no-JS: the figure is decorative (`aria-hidden`), nothing else depends on it
