# Evals

Skill batteries: three prompts per port, run by `scripts/eval.sh`. The point is to
catch a skill that costs context without changing behavior, and to fix the skill
file (never the eval) when it fails.

## Layout

```
evals/<port>/
  prompt-1.md       input, verbatim, in the shape a user would send
  expected-1.md     rubric: must decide / must show / miss if
  prompt-2.md       edge case: the skill must refuse, narrow or ask
  prompt-3.md       case that should chain to a leaf skill
  results/          created by --run: prompt-<n>-with.txt (and -without with --arms)
evals/fixtures/<port>/   the workspace the run happens in
```

`<port>` is the skill's frontmatter `name` (`frontend-verify`, `tdd`, `motion-review`), so
the ablation flag lines up with `scripts/link.sh --without <port>`.

Every expected file is a **rubric, not an expected output**: reading it against the model's
answer is the judgement. Nothing is diffed literally.

## The battery

Three prompts per port:

1. **Golden case** with `expected-1.md` written by hand. It encodes the behavior the skill
exists to produce.
2. **Edge case**: a request the skill must refuse, narrow, or ask about.
3. **Chain case**: a request that should reach a leaf skill.

Keep prompts short and single-intent.

## Commands

```bash
scripts/eval.sh --list                       # ports that have prompts
scripts/eval.sh frontend-verify              # print the command, runs nothing
scripts/eval.sh frontend-verify --run        # one arm, with the skill, in the fixture
scripts/eval.sh frontend-verify --run --arms # ablation: with and without
```

Default is **one arm**: mount the farm, copy `evals/fixtures/<port>/` to a temp directory,
run `pi --no-session </dev/null -p "$(cat evals/<port>/prompt-<n>.md)" --mode text` there,
write `results/prompt-<n>-with.txt`. `--arms` adds the without-arm and restores the farm
through a trap. `--cwd <dir>` overrides the fixture.

The run must never happen with this repo as the working directory. With the cwd here the
model reads `evals/<port>/expected-*.md` and reads the skill directory even when the farm
link is removed, which voids the measurement. The first battery run proved both.

`--run` spends quota. Print-only is the default on purpose.

## Pass bar

A port passes when **2 of 3 prompts** satisfy their rubric, judged by reading the answer
against `expected-<n>.md`:

- the decision the rubric says the skill must force is visible in the answer
- the command, artifact or `file:line` the rubric requires actually appears
- none of the rubric's "miss if" conditions happen

With `--arms`, an identical pair on a real prompt is a null result: no evidence the skill
pays for its context.

## Findings fix the skill, not the eval

When a battery fails, change the skill:

- wrong or missing instruction: edit `SKILL.md`
- missing detail: add a `references/` file and point to it
- skill fired but added nothing: tighten `description`, or set
  `disable-model-invocation: true` so it stops costing permanent context
- prompt too easy or too ambiguous: only then revisit the prompt, and record why

Never edit `expected-<n>.md` to match whatever the model produced. A rubric that drifts
to the current output tests nothing.

After changing a skill, re-run `scripts/link.sh` then the port. Usage evidence for
which ports are worth having at all comes from `scripts/usage.sh`.
