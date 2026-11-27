# Spatial maps

Clusters of points in space, each cluster a named source, a few points bright enough
to ask for attention, a side panel that explains whichever one you touch. It is the
archetype for "there is a lot under the surface" — and the one that most often gets
faked with a static image, badly.

Working code: `examples/index.html`, the `map()` block.

## Structure

```html
<div class="map" data-map>
  <div class="map-stage">
    <canvas class="map-canvas" aria-hidden="true"></canvas>   <!-- drawing only -->
    <div class="map-labels"></div>                            <!-- real buttons -->
  </div>
  <aside class="map-panel" aria-live="polite">                <!-- real text -->
    <div data-view="intro">…</div>
    <div data-view="0" hidden>…</div>
  </aside>
</div>
```

The canvas draws dots and lines. **Everything with a word in it is DOM**, positioned
each frame from the same projection: the cluster names, the signal buttons, the
panel. That is what makes the thing keyboard-operable and readable — the reference
site's 3D map is a canvas with `<button>`s floating over it.

## The data

A cluster is a centre, three radii, a tilt, a spin speed and a point count:

```js
{ cx: .27, cy: .48, rx: .13, ry: .26, rz: .12, n: 46, tilt: .34, spin: .22 }
```

Points on the shell of an ellipsoid, denser in the middle (`r = acaso() ** .55`):

```js
const th = rnd() * 6.283, ph = Math.acos(2 * rnd() - 1), r = Math.pow(rnd(), .55);
pts.push({ x: sin(ph) * cos(th) * r, y: cos(ph) * r, z: sin(ph) * sin(th) * r });
```

Edges: for each point, link to its 3 nearest neighbours **in 3D**, not on screen.
Computing neighbours on screen and then rotating would make the graph tear apart;
3D neighbours rotate with the cloud.

Seed the random (`(s * 16807) % 2147483647`) so the map is identical on every visit
and every screenshot.

## Projection

Rotate around the cluster's own vertical axis, tilt the whole thing, then a cheap
perspective divide:

```js
const c = cos(ang), s = sin(ang);
const x = p.x * c + p.z * s, z = -p.x * s + p.z * c;
const ci = cos(tilt), si = sin(tilt);
const y = p.y * ci - z * si, z2 = p.y * si + z * ci;
const k = 700 / (700 + z2 * 260);                 // perspective
return { x: cx * W + x * rx * W * k, y: cy * H + y * ry * H * k, k, z: z2 };
```

`k` is both the perspective scale and the depth cue: radius `1.5 * k`, alpha from
`k`. Sort the projected points by `z` before drawing so nearer dots sit on top; at
this size, sorting 50 points per cluster per frame is free.

Focal length 700 with a 260 depth multiplier gives a mild perspective — enough that
the cluster turns, not so much that it distorts. Change the 260, not the 700, when
you want more depth.

## Interaction

| trigger | effect |
|---|---|
| `pointerenter` / `focus` on a signal button | panel switches to that view, cluster name lights |
| `click` | same, plus it stops the autoplay |
| pointer anywhere over the map | rotation stops (or slows to 20 %) |

The panel is plain DOM: swap `hidden` on the `[data-view]` blocks and set
`aria-pressed` on the buttons. No canvas text, so nothing to make accessible.

Autoplay: every ~4 s advance to the next signal while nobody is touching it, and
stop for good on the first click. Guard on `hovered` so it never advances under the
pointer.

## Performance

- 30 fps is right for this; `if (now - last < 33) return` costs one comparison and
  saves half the work. The eye reads it as smooth because the motion is slow.
- Do not create gradients, shadows or `Path2D` per frame. Set `fillStyle` to a
  string, `beginPath`/`arc`/`fill`, per point.
- Edges as `moveTo`/`lineTo` pairs in one loop, one `stroke` per alpha band at most;
  per-edge `stroke` calls are the usual bottleneck.
- `ctx.setTransform(dpr, 0, 0, dpr, 0, 0)` on every frame, `clearRect(0, 0, W, H)` in
  CSS pixels. Cap `dpr` at 2.
- Re-measure on `ResizeObserver`, redraw immediately after measuring, or the first
  frame after a resize is empty.

## The morph variant

`infinito.js` on the reference site is the same machinery with states: particles
sampled from the brand mark's alpha channel, morphing to a graph and back, on a 14 s
cycle at 30 fps. Three arrays (start, end, current), one eased interpolation
(`e = t < .5 ? 2t² : 1 - 2(1-t)²`), and a `Math.sin` wobble per state so the idle
state is not frozen. Only worth building when the section is a centrepiece and the
mark is the message; otherwise use the ASCII texture, which costs a fifth of it.

## When to use it

Use it when there are **many small things and a few that matter** and the relation
between them is the point: sources feeding a signal engine, integrations, sensors,
documents. Fewer than ~20 items or no relations → a list or a grid of cards tells it
better and loads instantly.

## Checklist

- [ ] labels and buttons are DOM, positioned from the projection
- [ ] seeded random; identical on every load
- [ ] edges computed in 3D
- [ ] depth sort before draw; radius and alpha from `k`
- [ ] autoplay stops on click; pause on hover/focus
- [ ] first frame drawn synchronously; 30 fps throttle
- [ ] reduced motion: one static frame, no spin, no autoplay
- [ ] no-JS: the panel's first view is visible and readable, canvas is decorative
