# repo-defaults / prompt-2

## Must decide
- Refuse the unlimited scope: clean the repo is not one logical unit. Propose a bounded first patch and name what stays untouched.
- Keep three traps out: mass file moves, dead-code deletion without a caller check, and a formatting pass bundled with behavior.
- Ask once only if the target structure is genuinely undefined; otherwise state the assumption and proceed with the smallest complete unit.

## Must show
- A short cut list: what moves, what deletes (with the caller/route check proving it is dead), what stays.
- One proposed first commit, Conventional Commits shape, small enough to review in one sitting.
- The verification command for that patch (`make check` or stack equivalent) named before any edit.
- Retize constraint restated if the repo is a Retize one: database access via ports and `~/.pgpass` only.

## Miss if
- Starts moving files repo-wide in one shot.
- Deletes supposedly unused code without proving no importer/route calls it.
- Proposes a rewrite or a long-lived branch instead of a bounded patch.
