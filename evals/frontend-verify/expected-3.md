# frontend-verify / prompt-3

## Must decide
- The script reports, the rules judge: chain `~/.agents/skills/frontend-rules/SKILL.md` to decide whether each hit is a defect.
- An h1 count of 0 is a semantics problem (no native heading structure); three unnamed icon buttons violate `[req]` #1 and #2, and are verifiable defects, not taste.
- Check whether a name exists but is hidden from the accessibility tree (`aria-label` vs `sr-only` text vs `title`), because that changes the fix.

## Must show
- Per hit: verdict, rule id, `file:line` in the component, and the minimal fix (`aria-label` on the icon button, one real `<h1>` in the page shell).
- The verification loop: re-run the checker and show the counts moving 3 to 0 and 0 to 1, not just the code change.
- The severity difference stated: unlabeled interactive controls block screen-reader users; a missing h1 weakens navigation.
- chained: `~/.agents/skills/frontend-rules/SKILL.md`, specifically `references/semantics-and-a11y.md`.

## Miss if
- Answers the script is right, fix them without judging, or dismisses both as cosmetic.
- Fixes with `aria-label="button"` or `role="heading"` on a div.
- Changes code without re-running the checker to prove the counts moved.
