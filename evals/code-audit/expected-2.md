# code-audit / prompt-2

## Must decide
- Refuse the rewrite: this skill returns a ranked list of real problems with minimal fixes, and mess is not a finding.
- Establish scope first, then name the defects that would justify change (hidden state, N+1, god object) with `file:line` and cost.
- If restructuring is genuinely warranted, say so as a design conversation (`module-design` / `domain-modeling`), not as a rewrite performed inside the audit.

## Must show
- Scope line for the module, then ranked findings with minimal fixes; any rewrite-shaped item labeled out of scope with the reason.
- The two or three structural defects that would justify a redesign, with the cost of leaving them, measured where possible.
- The closing lines: unassessed areas and the highest impact-to-effort fix.
- chained: `references/decomposition.md` for the responsibility and seam findings.

## Miss if
- Starts producing a new architecture or a rewritten file.
- Substitutes naming or formatting taste for defects.
- No ranking, or no statement of what was skipped.
