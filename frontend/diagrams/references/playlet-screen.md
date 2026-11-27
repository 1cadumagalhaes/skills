# Scripted screens

A small mock UI — a chat, a dashboard, a code editor, an agent console — that
performs a six-beat story when it comes into view: the client message arrives, the
bot types, the bot answers, the order is created. It is the cheapest of the four
archetypes (HTML plus CSS, no canvas, no engine) and the one that most reliably
reads as "this product works".

Working code: `examples/index.html`, the `playlet()` block and its `.playlet` CSS.

## Anatomy

```html
<div class="playlet" data-playlet>
  <div class="playlet-tilt" data-tilt>
    <div class="screen">                                  <!-- the mock -->
      <div class="screen-top">…avatar, name, status…</div>
      <p class="bubble in beat b1">Hi! Do you deliver to Campinas?</p>
      <div class="bubble-pair">
        <p class="bubble out typing beat"><i></i><i></i><i></i></p>
        <p class="bubble out beat b2">We do. Want me to hold your order…?</p>
      </div>
      <p class="bubble in beat b3">Yes, please</p>
      <p class="done beat b4">Order created and link sent</p>
    </div>
  </div>
</div>
```

One class on the wrapper starts everything. Each beat is one keyframe with its own
delay; there is no timeline, no sequence runner, no state.

```css
.js .playlet .beat { opacity: 0; }
.is-playing .beat   { animation: enter .5s var(--ease) both; }
.is-playing .b1     { animation-delay: .15s; }
.is-playing .b2     { animation-delay: 1.5s; }
.is-playing .b3     { animation-delay: 2.25s; }
.is-playing .b4     { animation-delay: 2.85s; }
@keyframes enter { from { opacity: 0; translate: 0 8px; } to { opacity: 1; translate: 0 0; } }
```

The `.js` prefix is what keeps the no-JS page readable: without the script nothing
is hidden, so the mock shows its final state.

## Timing

Aim for 3–4 s total, six beats maximum. The reference chat runs 3.4 s:

| t | beat |
|---|---|
| 0.15 s | client message in (0.5 s) |
| 0.6 s | typing dots, 0.95 s, visible for the middle 70 % |
| 1.5 s | bot message in |
| 2.25 s | client confirms |
| 2.85 s | success line + a check mark popping (0.45 s) |

A typing indicator is a 0.95 s animation whose opacity is 0 for the first 12 % and
last 18 % — it reads as "typing then sent" instead of "three dots forever":

```css
@keyframes says { 0% { opacity: 0 } 12% { opacity: 1 } 82% { opacity: 1 } 100% { opacity: 0 } }
```

## Replay

Remove, reflow, re-add. That is the whole mechanism, and it is why there is no
state to get out of sync:

```js
function replay() {
  box.classList.remove('is-playing');
  void box.offsetWidth;          // forces the reflow that re-triggers the animation
  box.classList.add('is-playing');
}
```

When to replay:

- on entering the viewport (`IntersectionObserver`, threshold ~0.35) — but not if it
  played less than ~500 ms ago, or a fast scroll flickers it;
- on hover over the screen, only after 3.4 s of stillness (the visitor has finished
  reading and is asking for it again);
- never on every mouse move.

## The tilt

A 6–8 degree tilt is enough to make the mock feel like an object. Perspective on
the parent, transform on the screen, reset on leave:

```js
screen.addEventListener('pointermove', e => {
  if (e.pointerType !== 'mouse') return;        // touch scrolling would fight it
  const r = screen.getBoundingClientRect();
  const x = (e.clientX - r.left) / r.width - .5;
  const y = (e.clientY - r.top) / r.height - .5;
  screen.style.transform = `rotateX(${-y * 6}deg) rotateY(${x * 8}deg)`;
});
```

`.playlet-tilt { perspective: 900px }` and `transition: transform .35s` on the
screen. Throttle with a `requestAnimationFrame` latch if the DOM is heavy; do not
wrap it in `setTimeout`.

## What to build inside

The mock must be **real DOM with real text**, not an image, or it cannot be
translated, read, or restyled. Good subjects:

| subject | beats |
|---|---|
| chat / support bot | question → typing → answer → order created |
| dashboard | rows appear → one row highlights → a number counts up → a badge appears |
| code editor | lines type in with `steps()` → a caret → a result line appears |
| agent console | a document is scanned (a sweep line) → two hits highlight → three steps check off → output |
| integration | cards scroll in a marquee → a connector line draws between two of them |

Keep 4–7 beats. The last one is the payoff and should be a *state change*, not
another sentence: a check mark, a badge, a created record.

## Gotchas

- `animation-fill-mode: both`, always. Without it the beat flashes visible for one
  frame before its delay starts.
- Animate `opacity` and `translate` only. Height, margin and `top` will jitter and
  cost layout on every frame.
- No real `<input>`, `<select>` or focusable mock controls: they steal focus, get
  tabbed into, and are a lie. If it must look interactive, make it `disabled` or a
  `div`.
- Fixed typography: the mock is a picture made of type. Pin font sizes, line
  heights and widths in px, or it will reflow differently at every breakpoint.
- Legible at 300 px wide. If the mock needs 500 px to read, it is the wrong mock
  for a two-column section; put it full-width or drop the copy column.
- Do not put it inside `overflow: hidden` with `transform` on the same element —
  Safari clips the tilted plane.

## Reduced motion

Add `is-playing` immediately so the beats are laid out, and let the CSS media query
kill the animation; the final state is then simply the end state. That is why the
delays live in CSS and not in a JS timeline: one `animation: none !important` fixes
the whole section.
