# Frequency and motion gate

Use this gate to decide whether motion is worth adding or keeping. Judge the interaction in context, not by frequency alone.

## Frequency of use

| Frequency | Guidance |
| --- | --- |
| 100+ times/day, including keyboard shortcuts, command palettes, or core navigation | No animation. Keyboard-initiated actions are a disqualifier. |
| Tens of times/day, including hover effects, list navigation, and frequent toggles | Remove it or keep it near-imperceptible: fast and subtle. |
| Occasional, including modals, drawers, toasts, and settings | Standard motion is eligible. |
| Rare or first-time, including onboarding, empty states, success, and celebration | The delight budget is available, when the motion has a purpose. |

**Wording retained from the source skills:** build says "near-imperceptible only" for tens/day and instructs stopping at 100+/day; find says reject or suggest near-imperceptible motion and calls occasional/rare "eligible"; improve and review say "remove or drastically reduce" at tens/day and "standard animation" occasionally. These are compatible guidance, not different frequency thresholds.

## Purpose

Name a purpose before adding motion: **feedback**, **spatial consistency**, **state indication**, **preventing a jarring change**, or **explanation** (marketing/onboarding only). **Delight** is reserved for rare or first-time moments. "It looks cool" is not enough. If the motion has no purpose, omit it.

## Distance and scale

Prefer the smallest movement that makes the relationship legible. Keep frequent interactions especially subtle; avoid moving information the user is reading or acting on. Use the element's own dimensions for spatial offsets (for example, `translateY(100%)`), not arbitrary hard-coded distances. Large travel is justified only when it communicates a real spatial relationship; decorative travel does not pass the gate.

## Platform and input

Respect the actual input and platform: never animate keyboard-initiated actions; gate hover-only motion behind `(hover: hover) and (pointer: fine)` so touch does not trigger false hover states. Respect `prefers-reduced-motion` with fewer and gentler movements while retaining useful feedback. Do not assume web hover behavior applies to touch or native interfaces; inspect the platform's existing motion conventions before recommending an implementation.
