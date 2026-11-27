# Motion craft, measured

Structure tells you what a panel *is*; this file is what makes it *feel* right.
Everything below was measured frame by frame (60 fps) on seven clips of a real
course platform. Frame differencing measures *when*; region tracking measures *how long*.
The method is at the end so any new reference can be measured the same way.

Two levels of measurement, and you need both:

- **frame differencing** (whole frame, 0.15 % threshold) finds the **beats**, marking
  when something happens. It stops seeing a change as soon as it becomes gradual.
- **region tracking** (one property: a bar's edge, a box's mean colour, a panel's ink)
  gives the **ramp**, showing how long the change actually takes.

Coarse diff alone will report "80 ms" for a transition that really runs 500 ms.

## Per panel

| clip | what it is | rhythm | what a single beat costs |
|---|---|---|---|
| stepper (autoplay) | 6 steps of a request | **1.90 s**, metronomic (1.9 × 5, 1.93) | clock bar **217-250 ms**; node turning amber **450-550 ms**; ~7 % of the screen |
| pipeline (manual) | 5 stages, clicked | **1.2-2.1 s**, irregular because a human clicks | 80-170 ms, spread across the stage cards and the detail pane |
| robot copying | 8 gestures, one per card | **~1.0 s per item** | cursor travel **~470 ms**, the action **130-380 ms**, the new table row **~450 ms** |
| representations | 3 tabs, clicked | on demand | **cut out in one frame**, new content fades in over **~200 ms** |
| architectures | 3 variants, clicked | **2.7 s** between clicks | two waves of ~130 ms, **~230 ms apart** (opacity first, detail text second) |
| request walkthrough | typed URL, then stages | continuous text + one **800 ms** burst | terminal streams continuously; stage bars land in ~100 ms each |
| notes / highlight | select → save → card | manual | 0.35 s + 0.25 s, two waves ~100 ms apart, ~1 s end to end |

## The behaviours behind those numbers

1. **Two speeds, by meaning.** What carries *data* moves fast (200-250 ms: a bar, a
   number, a bar landing). What carries *state* moves slowly (450-550 ms: a box
   turning amber, a row of text dimming). One duration for both is what makes a panel
   feel either twitchy or sluggish, never right.
2. **Two speeds in one component, declared in CSS.** The same author's linked list ↔
   drawing uses `opacity .35s` for the dimming and `transform .5s` for the 7 px lift.
   The consequence is slow and soft; the gesture is slower and physical. The video
   measurement of the node fade (450-550 ms) is the same instinct in another component.
3. **Derive "the others", do not compute them.** A single class on the matching item
   plus `:has()` on the container (`.escada:has(li.is-ativo) li:not(.is-ativo)`) gives
   "everything else recedes" with no JS loop over siblings and no parent data-attribute.
4. **Autoplay is metronomic; manual is not.** The stepper's intervals were 1.90 s six
   times in a row. The clicked panels ran 1.2, 1.9, 2.1, and 1.9 s. They varied because
   a person was deciding. If a panel advances itself, the beat must be exact; if a
   person drives it, do not fake regularity with a timer.
5. **Cut out, fade in.** Switching tab content: the old panel disappears **in a single
   frame**, then the new one fades and rises over ~200 ms. No crossfade. A crossfade
   makes two texts overlap for 300 ms, and in a teaching panel that is unreadable.
6. **Two waves beat one long animation.** The architecture switch and the highlight
   save both run as two waves ~100-230 ms apart: first the container changes (opacity,
   outline), then the text inside it. The eye reads it as one gesture with a beginning
   and an end, instead of a 600 ms smear.
7. **Tempo is per-item, not per-panel.** The robot demo sets the pace of the *thing it
   is showing*: one card per second, cursor ~470 ms, action on arrival. A demo of a
   repeated process should feel like the process, not like a UI demo.
8. **Continuous and discrete can coexist.** The request walkthrough streams terminal
   text every frame while the stage bars land discretely. Continuous motion for
   "something is happening", discrete beats for "this is now true".
9. **Quiet by default.** The stepper's clip measures **97 % of frames** under the
   motion threshold. A teaching panel is something you read that occasionally moves.
   (A marketing page does the opposite: it keeps an ambient loop alive. Do not mix
   the two registers on one screen.)
10. **One change per beat, and a small share of the screen**: ~7 % for the stepper,
   17-21 % for the card + row. The artifact never re-lays-out; a step that moves
   everything reads as a different panel.
11. **State is redundant, in four channels**: border colour, background wash, a status
   word (`rodando` / `pronto`), and an icon. Any one alone fails for someone.
12. **Accumulate, never reset.** Clock and bar only grow, the pager fills behind you,
    the checks stay. Progress that resets makes the learner re-orient.
13. **The dot rides the wire.** One 4-5 px dot at the midpoint of the active hop is
    the only continuously moving element on the whole stepper. That makes it read
    as energy, not decoration.
14. **The pointer is authored.** In the robot demo the card highlight lands *before*
    the row appears in the table; the order of cause and effect is the lesson.

## The shell, from the same clips

- **Keyboard first, and it says so**: "Aperte Enter na barra de endereço" sits next
  to the input; each panel's own instruction bar says what to press. The panel teaches
  its operation.
- **One hint, once**: a small black tooltip (`clique aqui`) floats over the control the
  first time, then goes away. Never a modal, never an overlay tour.
- **Prose → panel → a paragraph that names what you just saw.** The panel is never
  sticky and never takes over the scroll.
- **Progress in three places**: the tab's progress line, the lesson's position in the
  sidebar (with durations), and `passo 4 de 7` inside the panel. They never contradict.
- **The way back is always visible** ("Voltar para a aula").
- **Interaction is optional**: every panel is complete at step 1; the rest is
  elaboration, nothing is hidden behind an action.

## Reading a new reference

### What a reference is built with

`scripts/fingerprint.sh <url>` fetches the HTML, lists the files it loads, counts
library signatures (GSAP, Three, framer-motion, Lenis, Locomotive, Barba, Swiper,
Lottie) and counts technique signatures (`<canvas>`, `stroke-dashoffset`,
`@keyframes`, `animation-timeline`, `IntersectionObserver`, `requestAnimationFrame`,
`prefers-reduced-motion`). It ends with a verdict: a library is driving the motion,
or it is hand-written.

```bash
./scripts/fingerprint.sh https://loopconsult.com.br/en/
# → no libraries; canvas 2, stroke-dash 8, css-keyframes 4, raf 5, reduced-motion 2
```

The most informative part is the **file list**. A site that ships `ascii.js`,
`iso.js`, `campo.js`, `infinito.js` is hand-built engine by engine; a site that ships
`vendor-8f2a.js` is hiding a framework in a bundle and the craft is in the timeline,
not the maths. When the file names are promising, read those files. The comments in
the Loop Consulting ones are a masterclass in explaining an engine in eight lines.

Caveat: a bundle can hide anything. "No library in the HTML" means *hand-written or
bundled*, not proof of either.

### Where the beats are, from a still or a clip

When the reference is a clip, pull frames instead of guessing. Every detail that
matters (labels, colours, state chips, counters) is readable in stills:

```bash
yt-dlp -f 'best[ext=mp4]/best' --write-info-json -o 'v1.%(ext)s' '<url>'   # the post text is often the best description
ffmpeg -ss 4 -i v1.mp4 -frames:v 1 -vf scale=1200:-2 -y v1_a.png           # 3–4 frames per clip
```

The `description` field of the info JSON usually states what the thing is
("visualização simplificada pra explicar o que é webscraping"), and three frames
spread over a 10 s clip are enough to reconstruct the state machine.

The tell is in the *edges*:

| what you see | archetype | tell |
|---|---|---|
| thin 1 px lines forming a 3D-ish structure, appearing progressively | isometric / line drawing | uniform stroke width at every zoom → SVG; faces filled with the background colour → painter's algorithm |
| characters or dots forming a shape, shimmering | canvas texture | the grid never resolves to smooth curves; density is constant regardless of shape |
| a cloud of dots that turns, with labels that stay crisp | spatial map | labels stay sharp while dots blur → canvas under HTML |
| a small app UI that types, ticks and confirms | playlet | the "screenshot" has font rendering identical to the page → real DOM |
| cards reordering, panels sliding under the cursor | layout/FLIP or tabs | content is selectable text; no canvas |
| a page that pins and scrolls sideways | scroll-driven | the scrollbar moves while the content does not |
| a diagram with `passo 3 de 7`, a pager and a "próximo passo" button | course panel | the artifact never moves; only state, colour and one sentence change |

Then build the *mechanic*, not the picture: the reference files in this skill are
implementations of the mechanics. Never copy a site's source. The maths here
(projection, dashed strokes, luminance ramps) is textbook and safe to rewrite; the
scene data, copy and imagery are theirs.

## How to measure a new reference

```bash
# beats + quiet share (whole frame, 0.15% threshold)
ffmpeg -v error -i clip.mp4 -vf "fps=60,scale=320:180" -f rawvideo -pix_fmt gray - \
| python3 -c "
import sys, numpy as np
w, h = 320, 180; n = w * h; prev = None; act = []
while True:
    b = sys.stdin.buffer.read(n)
    if len(b) < n: break
    f = np.frombuffer(b, np.uint8).reshape(h, w).astype(np.int16)
    act.append(0.0 if prev is None else float((abs(f - prev) > 12).mean()))
    prev = f
a = np.array(act)
on = np.where(a > 0.0015)[0]
beats, last = [], -99
for k in on:
    if k - last > 6: beats.append(k)
    last = k
print('beats (s):', [round(k / 60, 2) for k in beats])
print('quiet  : %d%% of the clip' % (100 * (a < 0.0015).mean()))
"
```

Then split the frame into a grid (6 × 4) and report which cells moved per beat. That
locates the change without knowing the layout. Finally, for each beat you care about,
crop one region and track **one** property per frame (mean luminance, ink share, the
right edge of a coloured bar, a coloured area's percentage) and read the 10 %→90 %
ramp. That last step is the one that yields a duration you can put in a CSS file.

## Applying it

- One property, one duration, chosen by meaning: **data 200-250 ms, state 450-550 ms**.
- Content switches: **cut out, then ~200 ms fade in**. Never crossfade text.
- Multi-part changes: **two waves ~100-230 ms apart**, container first, content second.
- Autoplay: a metronomic beat (1.9 s for reading, 1.0 s for a repeated action), always
  pausable, stopped for good at the first manual action.
- Keep under ~10 % of the panel changing per beat, and exactly one continuously moving
  element at most.
- Reduced motion: same final states, zero transitions. This is guaranteed if every pixel is
  derived from the step index.
