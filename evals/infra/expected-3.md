# infra / prompt-3

## Must decide
- Cost is a design constraint: answer with per-replica, per-node, and request-multiplier math, not a hunch.
- Separate the candidate causes before recommending: replica count, requests inflated above usage (Autopilot bills requests), missing HPA, idle node pool, egress or storage.
- No change until the measurement exists, and any scale-down keeps the rollback.

## Must show
- Actual requests vs usage per workload (`kubectl get pods -A -o custom-columns=...` or `kubectl top`), compared against the 12 replicas.
- The monthly math: replicas x (requests.cpu x Autopilot price) versus the old 4-replica number, with the delta.
- Three concrete actions in order: right-size requests, add HPA on a real load signal, re-measure after 24h.
- The owner-label check, with a missing `labels.owner` reported as a finding.
- chained: `references/cost-and-observability.md` and `references/kubernetes.md`.

## Miss if
- Answers scale down to 4 with no cost math or usage numbers.
- Ignores requests vs usage, the usual Autopilot multiplier.
- Changes requests/limits without a rollback and a re-measure step.
