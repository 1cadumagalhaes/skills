---
name: game-production-gates
description: Phase gates for game projects — decide whether a game is ready to advance (concept, vertical slice, production, content-complete, release), whether the slice actually proves the loop, and whether the scope is survivable. Use when asked "is this ready", "can we move to production", "what's left before release", "is this scoped", when a milestone or demo is near, or before committing weeks of content work to an unproven loop.
---

# Game Production Gates

Five gates, one question each, and a verdict that is allowed to be bad news. Nothing here is Agile ceremony: no sprints, no story points, no team roster. It exists because the expensive mistake in games is not a bug — it is building content for a loop nobody wanted to play.

Engine and craft knowledge live in `router` and the gamedev skill pack; this skill only decides whether to keep going and what must exist first.

## The gates

| gate | question | evidence required | exit |
|---|---|---|---|
| **G1 Concept** | is there a loop, and is it different? | one-sentence loop, the verb the player repeats, 2 comparable games and what this does differently | a loop you can describe without adjectives |
| **G2 Slice** | does the loop survive contact with the build? | playable vertical slice, measured frame times, recorded playtest notes | someone else plays the loop unassisted for 5 minutes |
| **G3 Production** | can the remaining work be enumerated? | asset list with counts, content budget math, cut list, riskiest system identified | every remaining item has an owner-sized estimate and a cut alternative |
| **G4 Content-complete** | is the game finished except for polish? | all content in, no placeholders, full loop from menu to credits | a stranger can finish it |
| **G5 Release** | does it run where it will ship? | store build on target hardware, save/load across a restart, crash-free session, known-bugs list | store pages, build, and rollback plan exist |

## Verdicts

- **PASS** — the gate's evidence exists and you read it. Never on vibes.
- **CONCERNS** — the evidence exists but the risk is named and dated. State what would flip it to FAIL.
- **NOT ASSESSED** — the evidence does not exist yet. This is the honest default, and it is not the same as PASS.
- **FAIL** — the evidence contradicts the claim. Say which artifact and what it shows.

A gate is not a checklist that is "mostly fine". Anything unmeasured is `NOT ASSESSED`, and `CONCERNS` is not a way to avoid saying `FAIL`.

## The slice (G2) is the gate that matters

A vertical slice is the full loop, end to end, at final quality for a narrow path: input → core mechanic → success and fail → result screen → back in. One representative level, one real asset, target platform, measured frame times on that platform.

Not a trailer. Not a grey-box with all the systems half-built. If the slice is fun only in your head, you have G1, not G2.

Kill criteria, decided before you build it: if the loop is not clear to a fresh player in five minutes, or the slice misses frame budget on target hardware by more than 2×, stop and re-cut the design rather than optimising or adding content.

## Scope, at any gate

Ask for three lists: **must exist for the loop to work**, **tests a risky assumption**, **everything else**. Cut the third immediately. Then do the arithmetic out loud: assets × minutes each × remaining weeks against actual availability. A number that only works with 40-hour weeks is a `FAIL`.

## Running it

1. Ask which gate is in question, and for the artifacts named in that gate's row. Do not accept prose descriptions of artifacts.
2. Read them. Produce the verdict table: gate, verdict, evidence you actually inspected, blockers.
3. Name the next gate and the single artifact that would unblock it.
4. State explicitly what you could **not** verify — hardware, save files, other players. Those stay `NOT ASSESSED`.
