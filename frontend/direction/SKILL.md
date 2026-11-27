---
name: frontend-direction
description: Choose a subject-grounded visual direction with the user before writing UI code and record it in DESIGN.md. Use when starting a new surface or when existing UI looks generic.
cluster: frontend
tier: leaf
disable-model-invocation: true
---

# Design direction

Turn "make it look good" into one explicit, subject-grounded direction chosen on the record before writing UI code.

This is the decide phase. Component building lives in `frontend-build`, accessibility and CSS rules in `frontend-rules`, durable decisions in `frontend-design-doc`, and gallery-grade public-page art direction in `frontend-taste`.

## 0. Skip questions when the answer already exists

Proceed directly without asking when:

- The prompt already specifies a direction ("brutalist", "editorial", "like Linear").
- An existing `DESIGN.md` already sets the direction; follow it and say so.
- The task is a fix inside an established surface (alignment, spacing, contrast); use `frontend-rules` directly.

Honor the brief's stated terms first whenever they resolve an axis.

## 1. Ground the surface in its subject

Name three facts before proposing directions:

- **Subject.** What the product actually is, its domain, material, and vernacular.
- **Audience.** Who opens it and in what working context.
- **Job.** The single primary action or understanding this surface delivers.

If the brief leaves these ambiguous, propose one concrete reading of each and confirm in one line rather than asking an open-ended question.

## 2. Propose two or three directions

Derive 2 to 3 distinct options from the subject, each with a familiar handle name, its subject origin, and its concrete failure risk:

> **Editorial print.** Register of a technical manual with serif display, wide margins, and hairline rules. Risk: requires strong photography or reads bare.

Rules for proposals:

- Offer 2 to 3 options, never a large style catalog.
- State the concrete subject anchor and primary risk for each option.
- Include a "you pick" option, recommend the strongest fit, and explain why.
- Keep one dominant idea per option rather than bundling unrelated palettes, layouts, and motifs.

## 3. Commit the decision

State the chosen direction in one sentence and write it into `DESIGN.md` via `frontend-design-doc` in the same change (create a minimal `DESIGN.md` if absent). Follow the committed direction throughout implementation; name and justify any explicit deviation.

## 4. Refuse generic AI tells

Avoid unchosen template defaults (cream plus terracotta serif, black plus acid-green, cookie-cutter SaaS icon cards, repetitive uppercase eyebrows, `A . B . C` metadata dividers, trailing button arrows) unless the brief explicitly calls for them. Read the full tells registry at `~/.agents/skills/frontend-taste/references/tells.md` before styling public pages.

## 5. Route execution

| Surface | Next skill or reference |
|---|---|
| Public or marketing page needing gallery-grade craft | `frontend-build` (its table routes to `frontend-taste`) |
| App UI, dashboard, admin, or settings | `frontend-build` + `frontend-rules` (+ `~/.agents/skills/frontend-taste/references/app-screens.md`) |
| Single component inside an existing surface | `frontend-build` + `frontend-rules` |
| Interactive diagrams, system maps, course steppers | `frontend-build` routes to `frontend-diagrams` |
| UI copy voice | Direction voice rules in `DESIGN.md` |

## 6. Report

Close the decide phase in four concise lines:

1. Chosen direction and its subject anchor.
2. Rejected options and why.
3. Any deliberate deviations and reasons.
4. Path where the decision is recorded (`DESIGN.md`).

Informed by `anthropics/skills` `frontend-design` (Apache-2.0) and `frontend-taste` tells registry.
