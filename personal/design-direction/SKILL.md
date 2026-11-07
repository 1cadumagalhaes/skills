---
name: design-direction
description: Decide a visual direction with the user before any UI is built, then record it and hand off. Use when a page, screen, product surface or component needs a look — when starting new UI, redesigning, restyling, or when the output feels generic and someone says it looks templated, AI-made or off-brand. Asks for a choice between two or three subject-grounded directions, writes the decision to DESIGN.md, then routes execution to design-taste-frontend for public pages and frontend-workflow/ui-craft for app UI.
---

# Design direction

One job: turn "make it look good" into a named direction the user chose, on the record, before code exists.

This is the *decide* phase. Building is `frontend-workflow`; rules are `ui-craft`; durable decisions are `design-contract`; a gallery-grade public page is `design-taste-frontend`.

## 0. Do not ask when the answer is given

Ask only when the direction is genuinely free. Skip the questions when:

- the brief names a direction ("brutalist", "editorial", "like Linear")
- an existing `DESIGN.md` already decides it — then follow it and say so
- the work is a fix inside an established surface (align, space, contrast) — that is `ui-craft`, not a direction decision

The brief's own words always win, including when it asks for something that reads as a default.

## 1. Ground it in the subject

A direction invented from taste alone reads as generic. Before proposing anything, name:

- **subject** — what the product actually is, its material, industry, vernacular
- **audience** — who uses it and in what state of mind
- **job** — the one thing this surface must accomplish

If the brief makes these unknowable, propose one concrete reading of each and confirm it in one line rather than asking an open question.

## 2. Propose two or three directions

Not a menu of styles — each option derived from the subject, then given a familiar **name as a handle for talking about it**. One line each:

> **Editorial/print** — the register of a printed catalogue: high-contrast serif display, wide margins, hairline rules. Risk: needs excellent photography or it reads empty.

Rules for the proposal:

- 2–3 options, never 5+. A long list is the same failure as a style menu.
- Each cites the concrete thing in the subject it comes from.
- Each names its own **risk** — what would make it fail here.
- Always include a "you choose" escape; then pick the one with the best subject fit and say why.
- One dominant idea per option. Not a palette plus a layout plus a motion system plus a motif.

## 3. Commit

Choose, and state it in one sentence. Then write it down **in the same change** as the work — a direction that lives only in chat is lost by the next session:

- into `DESIGN.md` via `design-contract` (foundations: type roles, palette roles, spacing, motion)
- if the repo has no `DESIGN.md`, create the minimal one

Do not silently blend the chosen direction with the layout you would have made anyway. If you deviate, say so and why.

## 4. Refuse the tells

These are the current generated-page defaults. They are legitimate for *some* briefs, but they must be a choice, never a reflex — and never a package deal:

- warm cream ground (~`#F4F1EA`) + high-contrast serif + terracotta accent (~`#D97757`)
- near-black ground + a single acid-green or vermilion accent
- broadsheet: hairline rules, zero radius, dense newspaper columns
- the SaaS card kit: identical rounded cards, one radius for everything, the same soft grey shadow, gradient washes as decoration
- template chrome regardless of subject: all-caps eyebrow above every heading, `A · B · C` meta strings, `WORD — fragment` labels, `#0B0B0B` standing in for black, monospace micro-labels, `→` appended to every button

Where the brief pins one of these, follow it. Where an axis is free, do not spend the freedom on a default. Full registry of tells: `design-taste-frontend` → `references/tells.md`.

## 5. Route execution

| surface | use |
|---|---|
| public/marketing page needing gallery-grade output | `design-taste-frontend` — its direction sheet, browser gate and screenshot loop |
| app UI, dashboard, admin, settings | `frontend-workflow` + `ui-craft` (+ `design-taste-frontend/references/app-screens.md` for app-specific rules) |
| one component inside an established surface | `frontend-workflow` + `ui-craft`; no new direction |
| copy for the chosen direction | the direction's own voice rules, recorded in `DESIGN.md` |

## 6. Report

Before handing off, state:

1. the direction chosen, in one line, and the subject detail it came from
2. the options rejected and why
3. anything you deviated from, and the reason
4. where it was recorded (`DESIGN.md` path)

Keep it to the four lines. This is the whole output of the decide phase.

---

Informed by `anthropics/skills` `frontend-design` (Apache-2.0) and `design-taste-frontend`'s tells registry.
