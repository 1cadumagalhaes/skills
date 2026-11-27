# debug / prompt-2

## Must decide
- Refuse to guess: a ranked theory without a measurement is noise. Answer the question with the loop that will decide it.
- Establish access first: can this environment reach metrics, traces, or a repro? If not, say what is blocked and which artifact is needed.
- With access, the performance branch skips log scatter: baseline with a profiler or `EXPLAIN (ANALYZE, BUFFERS)` and compare yesterday against today.

## Must show
- The baseline command and the numbers it must produce (p50/p99, buffer reads, plan nodes) before any hypothesis.
- The differential setup: same input, old commit vs new (`git bisect run`, or two deploys), because after-yesterday-deploy is a differential claim.
- Vetted numbers before acting: chain `~/.agents/skills/benchmark-check/SKILL.md` if the 2x came from a dashboard or benchmark rather than a measured request.
- For each candidate cause, the observation that would falsify it, in the loop terms.

## Miss if
- Answers with a list of likely causes and no measurement plan.
- Adds logs before a baseline exists.
- Treats the dashboard 2x as proven without checking the query that produced it.
