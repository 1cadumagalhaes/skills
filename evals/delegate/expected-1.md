# delegate / prompt-1

## Must decide
- Route by difficulty: exploration and read-only audit go to `pi` with `opencode-go/deepseek-v4.1-flash` (or `antigravity` with `gemini-4-hydrogen`), not the strong tier.
- Split by repo (three independent slices) and run them in parallel; the coordinator stays on the migration and does not edit audit files.
- Each child gets the kickoff contract and a closed file list; the coordinator reads each returned diff/findings before accepting.

## Must show
- The exact first line of every prompt: `You are a subagent. Don't run memo. Read ~/.agents/worker.md first.`
- An explicit `role` per call (`research` or `review`), allowed paths, forbidden paths, and shell stdout capped below 12 KB per command.
- A verifiable completion command per child (for example the file count the child must reach) with its expected output.
- The acceptance step: top findings re-checked against the files, merged into one ranked report.
- chained: `~/.agents/policy.md` and `~/.agents/worker.md`.

## Miss if
- Sends the audit to the strong tier because it matters, or runs the three repos sequentially.
- Any child prompt missing the first line or the role, or carrying unbounded scope/output.
- Accepts child output unread, or lets a worker write outside its allowed paths.
