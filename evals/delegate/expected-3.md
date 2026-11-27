# delegate / prompt-3

## Must decide
- Harness mechanics switch outside T3 Code: Claude Code uses `Agent` with `~/.claude/agents/`, not `delegate_task`, which is T3-only.
- The contract does not switch: first line, explicit role, closed scope, stdout below 12 KB, verifiable done command.
- Review goes to a model family different from the author, and the coordinator still validates before accepting.

## Must show
- The concrete mechanism (`Agent` with an agent profile under `~/.claude/agents/`, background or foreground with the returned result) and what it cannot do compared with `delegate_task`.
- A ready-to-paste kickoff for that harness, starting with `You are a subagent. Don't run memo. Read ~/.agents/worker.md first.` and ending with the completion command.
- chained: `~/.agents/policy.md` (harness table) and `~/.agents/worker.md` (worker bounds).
- The validation step: findings re-checked against the diff, with the family difference stated.

## Miss if
- Tells the user to call `delegate_task` from Claude Code.
- Sends a review to the same model family as the author.
- Drops the kickoff contract because Claude Code is different.
