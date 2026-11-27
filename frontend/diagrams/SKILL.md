---
name: frontend-diagrams
description: Hand-written isometric SVG scenes, scripted screens, spatial maps, canvas textures, and stepped course panels without animation libraries.
cluster: frontend
tier: leaf
disable-model-invocation: true
---

# Diagram sections

Six drawing archetypes plus one brand-mark canvas texture and interactive stepped course panels. Build them with plain SVG, DOM, CSS keyframes, and ~300-line plain JS engines rather than GSAP, Three.js, Lottie, or video.

Measured in November 2026 on **loopconsult.com.br** (PT/EN), which splits engine code from declarative scene data:

| File | Lines | Purpose |
|---|---|---|
| `ascii.js` | 307 | Brand mark as live ASCII on canvas 2D |
| `iso.js` | 520 | Isometric system drawings in SVG |
| `campo.js` | 355 | Spatial signal map on canvas 2D with HTML labels |
| `infinito.js` | 243 | Particle morph (symbol, graph, symbol) at 30 fps |
| `main.js` | 601 | Section shells, tabs, playlets, count-ups, text scramble |

Keep each engine driven by declarative scene data so adding the next diagram takes markup and data rather than new engine code. Measured CSS timings (such as `1.90 s` and `450 ms`) come from 60 fps frame inspection.

## Archetypes

| # | Archetype | What it shows | Runtime | Start at |
|---|---|---|---|---|
| 1 | Isometric scene | System modules wired to a core, addressable by name | SVG `<figure data-iso="name">` | `references/iso-scene.md` |
| 2 | Scripted screen | Product performing a 6-beat sequence | DOM + CSS keyframes | `references/playlet-screen.md` |
| 3 | Storyboard | Process in 3 or 4 steps, one drawing per step | 4 figures + grid + 1 px rule | `references/iso-scene.md` |
| 4 | Layers | Funnel or stack lighting one layer at a time | Isometric engine + `:has()` | `references/iso-scene.md` |
| 5 | Static isometric | Product illustration without ducts or pulses | Isometric engine | `references/iso-scene.md` |
| 6 | Spatial map | Dense field highlighting key labeled nodes | Canvas + HTML labels | `references/spatial-map.md` |
| 7 | Canvas texture | Brand mark as living hero texture (at most one per page) | Canvas 2D | `references/ascii-texture.md` |
| 8 | Course panel | Interactive stepped lesson, switcher, or pipeline failure mode | DOM + `steps[]` + CSS states | `references/course-panels.md` |

Starter files live in `examples/index.html` (six diagram archetypes + canvas texture), `examples/stepper.html` (simulated-clock stepper), and `examples/panels.html` (five interactive course panels).

## Implementation rules

1. **Keep all readable text in HTML.** Draw geometry on canvas/SVG, and keep labels, titles, and panels in the DOM so they stay sharp, accessible, searchable, and translatable via `<html lang>`.
2. **Pause off-screen animations.** Attach one `IntersectionObserver` per section to toggle `is-visible` and halt ambient loops outside the viewport.
3. **Render the first frame synchronously at mount.** Paint initial state before the first `requestAnimationFrame` runs.
4. **Support real progressive enhancement.** Without JS, figures keep an `aria-label`, playlets render their final state, and maps show their panel copy. Gate animated styles on a root `.js` class added early.
5. **Respect `prefers-reduced-motion` as an explicit branch.** Jump straight to final state and disable ambient loops and autoplay.
6. **Seed all randomness.** Use a deterministic PRNG such as xorshift (`(s * 16807) % 2147483647`) so reloads and screenshot checks stay identical.
7. **Animate one thing at a time.** Run entry draw-in first, ambient loops at 2.4 to 3.7 s, and hover/click responses under 100 ms.
8. **Address every piece by name.** Tag modules with `data-module`, `data-vista`, or `data-rotulo` and expose one highlight method (`LoopIso.acender(fig, 'automacao')`).
9. **Replay via CSS class toggle.** Remove the active class, read `void el.offsetWidth` for reflow, and add the class back rather than building a JS timeline machine.
10. **Cap canvas DPR at 2 and throttle cell textures to ~24 fps.** Reserve 60 fps for structural motion.

## Section shell choreography

- Auto-rotate tabs every 7 s using `animation: tempo var(--dur) linear` on the active progress bar.
- Pause rotation on hover or focus inside the group, and stop autoplay permanently once the visitor clicks a tab manually.
- Replay a scripted screen on viewport re-entry, and on hover after a 3.4 s cooldown so reading is never interrupted.
- Implement full tablist ARIA (`role="tablist"`, `role="tab"`, `role="tabpanel"`, `aria-selected`, roving `tabindex`, arrow/Home/End keys) and hover activation only under `matchMedia('(hover: hover) and (min-width: 961px)')`.
- Animate numeric count-ups on entry over 900 ms with `1 - (1 - p)^3` easing and `tabular-nums`.
- Self-tour isometric modules every 2.6 s until pointer enters a label, then yield control to the visitor.

See `references/section-shell.md` for complete shell patterns.

## Choosing the archetype

| Content | Archetype |
|---|---|
| Named parts wired into a system | Isometric scene (1) |
| Process with 3 or 4 stages | Storyboard (3) |
| Funnel, stack, or clickable hierarchy | Layers + linked list (4) |
| Static product schematic | Static isometric (5) |
| Sequential "this triggers that" flow | Scripted screen (2) |
| Signal cluster with selective labels | Spatial map (6) |
| Living hero mark | Canvas texture (7) |
| Interactive learner walkthrough or comparison | Course panel (8) |
| Key metric supported by simple diagram | Count-up + static drawing |

When two archetypes fit, choose the cheaper runtime (a DOM/CSS scripted screen ships faster than custom SVG). Skip scroll-jacking, multi-layer parallax, hero videos, Lottie, and WebGL for 2D problems.

## Build order

1. Pick the archetype and design the declarative scene data (modules, beats, points, labels) before drawing pixels.
2. Write semantic HTML markup with real copy first and verify it reads cleanly without JS.
3. Add the drawing engine, paint frame 1 synchronously, and gate loops with `IntersectionObserver`.
4. Wire drivers (tabs, hover, autoplay) strictly through the named API.
5. Implement `prefers-reduced-motion` and no-JS states.
6. Verify in a real browser at 1280 and 375 px with `~/.agents/skills/frontend-verify/SKILL.md`: clean console, zero horizontal overflow, labels inside bounds, paused loops off-screen, and final state visible under reduced motion.

## References

| Topic | File |
|---|---|
| System and architecture SVG scenes | `references/iso-scene.md` |
| Scripted product screens | `references/playlet-screen.md` |
| Spatial maps and HTML label anchoring | `references/spatial-map.md` |
| Canvas 2D ASCII textures | `references/ascii-texture.md` |
| Tabs, autoplay, replay, keyboard, reduced motion | `references/section-shell.md` |
| Measured animation timings | `references/motion-craft.md` |
| Interactive course panels and steppers | `references/course-panels.md` |
