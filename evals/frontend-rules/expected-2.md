# frontend-rules / prompt-2

## Must decide
- Refuse removing the focus ring: `[req]` #2 is a hard requirement, and keyboard users lose the page without it.
- Offer the compliant narrowing: keep focus visible, restyle it (offset ring, `:focus-visible` only, brand color that still meets 3:1 against its backgrounds).
- Escalate once to the designer with the constraint and the option set. Do not silently comply, and do not silently ignore the request.

## Must show
- The refusal stated plainly with the rule id and the user impact, then the acceptable alternative implemented.
- `:focus-visible` styling plus a 3:1 boundary contrast check against every background it lands on (page, card, section).
- A keyboard walk on the pricing page showing every focus stop visible, no invisible stop.
- chained: `references/semantics-and-a11y.md` and `references/radii-and-depth.md` for the ring geometry.

## Miss if
- Deletes the ring as asked, or replaces it with `outline: none` plus a hover-only style.
- Keeps focus visible on the primary CTA only, dropping it on links and inputs.
- No verification that the new ring meets contrast on each background.
