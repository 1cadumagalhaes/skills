---
name: design-contract
description: Maintain and follow a repo DESIGN.md holding durable design decisions. Use when doing frontend/UI work in any repo — read DESIGN.md first; when a design decision should outlive the task, write it there.
---

# Design contract

Every frontend repo under my ownership keeps a `DESIGN.md` at its root. It is the durable, cross-task agreement on what the product looks like and how it behaves — so no task re-litigates settled decisions, and no one guesses.

`DESIGN.md` contents (keep terse, decision-per-entry):

- **Foundations**: typography, spacing scale, color tokens, iconography, motion/duration values.
- **Component decisions**: the canonical way we render buttons, tables, modals, forms, empty/loading/error states.
- **Layout & navigation**: grid, page shells, breakpoints.
- **Voice**: writing style for UI copy (labels, empty states, errors).
- **Non-goals**: what we deliberately do not do (e.g., no animations on lists), so it is not re-proposed.

## Rules

1. **Frontend work reads `DESIGN.md` before designing anything.** If it exists, decisions there are law; propose an amendment instead of silently deviating.
2. **A decision that should outlive the task lands in `DESIGN.md` in the same PR** as the change that introduced it. One line per decision: what, why, and what it replaced, when relevant.
3. **Design discussion is not code review.** Amend the contract first, then implement; otherwise the code encodes a decision nobody agreed to.
4. If the repo has no `DESIGN.md` and the work touches UI consistently, create a minimal one rather than leaving choices distributed in commits.
5. `DESIGN.md` never holds implementation details (which component library file renders the button) — those live in code; `DESIGN.md` holds intent and constraints.