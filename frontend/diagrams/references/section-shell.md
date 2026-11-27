# The section shell

The engines draw. The shell decides *when*, and it is most of what a visitor
experiences as "interactive". Everything here is small and boring on purpose: one
observer, one class, one timer.

## The `.js` gate

First line of the script, before anything else:

```js
document.documentElement.classList.add('js');
```

Then CSS hides only what the script is responsible for:

```css
.js .playlet .beat { opacity: 0 }        /* no JS → the final state is simply visible */
.js .iso-fig.is-mounted … { stroke-dashoffset: 1 }
```

This is the whole progressive-enhancement contract in two lines, and it is why the
no-JS page is readable rather than empty.

## Observers

Three different jobs; do not reuse one observer for all of them.

```js
// 1. enter once — the drawing/animating starts when it is worth starting
const enter = new IntersectionObserver(es => es.forEach(e => {
  if (e.isIntersecting) { start(e.target); enter.unobserve(e.target); }
}), { rootMargin: '0px 0px -12% 0px', threshold: .15 });

// 2. visibility, toggled — pause ambient loops while off-screen
const vis = new IntersectionObserver(es => es.forEach(e => {
  e.target.classList.toggle('is-visible', e.isIntersecting);
}), { threshold: .1 });

// 3. near, for lazy third-party embeds (cal.com, video, maps)
new IntersectionObserver(es => es.forEach(e => {
  if (e.isIntersecting) { loadEmbed(e.target); obs.disconnect(); }
}), { rootMargin: '600px 0px' });
```

Rules of thumb: `threshold` 0.1-0.15 and a negative bottom `rootMargin` so a section
starts animating when it is properly on screen, not when one pixel appears;
`rootMargin: '600px 0px'` (not threshold) for anything that needs a network request.

`animation-play-state: paused` on the off-screen loops is worth more than any
micro-optimisation: it lets the browser drop an entire section to zero cost.

## Auto-rotating tabs

The reference site's "what we build" panel: four tabs, 7 s each, a progress line on
the active tab, pause on hover and focus, stop for good when the visitor chooses.

```js
const DURACAO = 7000;
caixa.style.setProperty('--dur', DURACAO + 'ms');   // the progress bar reads this

function agendar() {
  clearTimeout(relogio);
  abas.forEach(a => a.classList.remove('is-correndo'));
  if (!sozinho || !emTela || pausado) return;
  void abas[atual].offsetWidth;                     // restart the progress animation
  abas[atual].classList.add('is-correndo');
  relogio = setTimeout(() => ativar((atual + 1) % abas.length), DURACAO);
}
```

```css
.is-correndo::after { animation: tempo var(--dur) linear both; }
@keyframes tempo { to { transform: scaleX(1) } }
```

`sozinho` goes false on the first click or keypress. Autoplay must never fight a
visitor who has taken control. `emTela` comes from an observer at ~0.35; `pausado`
from `mouseenter`/`focusin`.

Do not use `setInterval`. A timeout re-scheduled after every activation keeps the
clock honest after a pause, and it is the same amount of code.

## Tablist semantics

```js
abas.forEach((a, i) => a.addEventListener('keydown', e => {
  const n = abas.length; let alvo = -1;
  if (e.key === 'ArrowRight' || (vertical && e.key === 'ArrowDown')) alvo = (i + 1) % n;
  else if (e.key === 'ArrowLeft' || (vertical && e.key === 'ArrowUp')) alvo = (i - 1 + n) % n;
  else if (e.key === 'Home') alvo = 0;
  else if (e.key === 'End') alvo = n - 1;
  if (alvo < 0) return;
  e.preventDefault();
  ativar(alvo, true);          // true → move focus with the selection
}));
```

`roving tabindex` (selected tab `0`, the rest `-1`), `aria-selected`,
`aria-controls` → panel id, and the panel gets `role="tabpanel"`
`aria-labelledby`. On wide screens with a real pointer, `mouseenter` selects too
(`matchMedia('(hover: hover) and (min-width: 961px)')`). The "para quem é" section
on the reference site uses this behavior: hovering a situation lights the module it
maps to.

## Replay guard

```js
let last = 0;
function touch() { last = performance.now(); replay(); }
// on enter:
if (performance.now() - last > 500) touch();
// on hover of the screen:
if (performance.now() - last > 3400) touch();
```

500 ms keeps a fast scroll from strobing it; 3 400 ms means "the visitor has finished
reading and asked for it again". Both thresholds matter.

## Hover-linked list ↔ drawing

When a section pairs a list with a drawing (topics on the right, diagram on the
left), do not animate each side separately: one function sets a class on the matching
piece of both, and CSS `:has()` on the container dims the siblings. The full pattern,
with the exact CSS and the reasons, is in `references/iso-scene.md` under
"Linked list ↔ drawing".

The invariants: hover and focus run the same function, `pointerleave` returns to the
*pinned* item rather than to nothing, and nothing is only reachable by hovering (the
pinned default is visible at rest).

## Count-ups

```js
function contar(el) {
  const alvo = parseInt(el.dataset.alvo, 10), t0 = performance.now();
  (function passo(now) {
    const p = Math.min(1, (now - t0) / 900);
    el.textContent = String(Math.round(alvo * (1 - Math.pow(1 - p, 3))));
    if (p < 1) requestAnimationFrame(passo);
  })(t0);
}
```

900 ms, ease-out cubic, `font-variant-numeric: tabular-nums` so the line does not
twitch. Never count up a number the visitor is trying to read twice.

## Reduced motion, per engine

| engine | reduced-motion behaviour |
|---|---|
| isometric scene | add `is-drawn is-ready` immediately: full drawing, no pulses, no tour |
| playlet | add `is-playing` so it lays out; the global `animation: none` leaves the end state |
| spatial map | one static frame, no spin, no autoplay |
| ASCII texture | one frame with the light at rest |
| tabs | no autoplay; the first tab stays selected |
| count-up | print the final number |

One media query handles the CSS half:

```css
@media (prefers-reduced-motion: reduce) {
  * { animation: none !important; transition: none !important; }
}
```

The JS half is a branch in each initialiser. Do not try to express it as a CSS-only
concern: `animation-duration: 0.01ms` still fires `animationend` handlers you may
not have written.

## Performance checklist

- [ ] no loop runs in a section that is not on screen
- [ ] one rAF per engine, cancelled on `pagehide`
- [ ] nothing measures layout inside a frame (`getBoundingClientRect` in a pointer
      handler is fine; in the draw loop it is not)
- [ ] `will-change: transform` on at most one element per section, removed when idle
- [ ] no `filter: blur()` over an animating element
- [ ] third-party embeds behind an observer and behind consent
- [ ] the page reaches a first paint before any loop starts
