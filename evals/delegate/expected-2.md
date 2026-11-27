# delegate / prompt-2

## Must decide
- Route by difficulty, never importance: name what makes the slice hard (architecture, cross-repo forensics), and only then the strong tier.
- Refuse cancelling a healthy running delegate to switch providers: let it finish and use its result, or start the strong-tier child alongside for the part that needs it.
- Prefer escalating scope over the model: if the slice is too big for luna, split it.

## Must show
- The difficulty justification in one line (what the task needs that a fast model cannot do), or the finding that it does not need the strong tier.
- The running delegate left alone, with what it will return and how its output is used.
- If a strong-tier child is still justified: role, closed scope, and the verification the coordinator performs on its output.
- chained: `~/.agents/policy.md` (tier routing) and `~/.agents/worker.md` (worker bounds).

## Miss if
- Upgrades the model because the user called it important.
- Cancels or kills the running delegate to switch provider.
- Neither splits the slice nor states why the strong tier is genuinely required.
