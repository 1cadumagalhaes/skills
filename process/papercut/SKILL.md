---
name: papercut
description: "Record friction the agent hits while using a skill, tool or doc: a rejected flag, an exit 0 on error, an empty result that should have rows, a pointer to a file that does not exist. Write the report, keep working. Use whenever something almost worked or wasted a turn."
cluster: process
tier: root
---

# Papercut

When something you were told to do does not work the way the skill, tool or doc said it would, that is a papercut. File it, work around it, keep going. Do not stop to ask, and do not silently swallow it.

This exists because friction found in a session is the cheapest evidence about where the skills lie, and it dies with the session unless someone writes it down.

## When to file

File one report when any of these happens while following a skill or a reference:

- A command or flag the doc gave you is rejected, or does not exist.
- A command exits 0 on an error, or succeeds with an empty result where rows were expected.
- A pointer leads to a file or skill that is not there.
- The skill's step cannot be completed as written, and you had to invent the missing part.
- You spent more than two turns on something the skill should have answered.

Do not file for: a bug in the user's own code, a missing dependency you can install, a one-off typo in a prompt, or anything already recorded in `papercuts/` for the same skill and cause. Check by filename before writing a duplicate.

## Format

One file, `papercuts/YYYY-MM-DD-<skill>.md`, named for the skill that misled you. A second report for the same skill the same day gets `-2`.

```markdown
# <skill>: <one line>

- Tried: the exact command, path or step, and where the instruction came from (`file:line`).
- Expected: what the skill or doc promised.
- Happened: the exact error, exit code or output, quoted.
- Workaround: what you did instead, so the session could continue.
- Fix: the smallest change that would have avoided this.
```

Five lines, no preamble. Quote the real output, do not summarize it. If the cause is a renamed skill or a moved file, say which name or path is stale and which one is current.

## Then continue

Resume the task with the workaround. Do not edit the skill you are following unless the user asked for that: a papercut is a report to the owner, not a license to refactor mid-task. At the end of the work, mention in one line how many reports you filed.

Owners read `papercuts/` by skill. A fix lands in the skill or in the check that would have caught it, and the report stays as the record.
