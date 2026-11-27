---
name: frontend-design-doc
description: Maintain and follow a repo DESIGN.md holding durable visual and UX decisions. Use at the start of frontend work or when recording design choices that must outlive the task.
cluster: frontend
tier: leaf
disable-model-invocation: true
---

# Design contract

Every owned frontend repository keeps a `DESIGN.md` at its root so tasks preserve settled decisions instead of re-inventing typography, tokens, or component conventions.

## Contents of DESIGN.md

Keep entries terse, one clear decision per item:

- **Foundations.** Typography, spacing scale, color tokens, iconography, motion durations.
- **Component decisions.** Canonical rendering for buttons, tables, modals, forms, and empty/loading/error states.
- **Layout and navigation.** Grid, page shells, breakpoints.
- **Voice.** Rules for UI copy, labels, empty states, and errors.
- **Non-goals.** Deliberate exclusions (for example, no animations on data lists) so agents do not propose them repeatedly.

## Rules

1. **Read `DESIGN.md` before changing any frontend UI.** Follow existing rules as law; propose an amendment instead of deviating silently.
2. **Record durable decisions in `DESIGN.md` in the same change.** Include what changed, why, and what it replaced.
3. **Settle contract changes before coding.** Amend `DESIGN.md` first when introducing new surface rules.
4. **Create a minimal `DESIGN.md` if none exists** on an owned UI repo rather than leaving choices scattered across commits.
5. **Keep implementation paths out of `DESIGN.md`.** Store visual intent and constraints in `DESIGN.md` while code owns component files.
