# Cost and observability

Infrastructure cost is decided in the manifest, not in the invoice review. And a workload nobody can see is a workload nobody can fix.

## Where the money goes

- `[conv]` **Over-requested CPU/memory is the top quiet cost.** The scheduler reserves `requests`, not usage. A workload using 200 mCPU but requesting 1 CPU is paying for 800 mCPU of nothing, on every replica, forever.
- `[conv]` Right-size from data: p95 usage over two weeks, then add a headroom margin, not the reverse. VPA in recommendation mode (or GKE's recommender / `kubectl top` history) gives you the number.
- `[conv]` Idle environments are the second: dev/staging clusters running full replicas overnight. Scale to zero, or schedule off-hours scaling where the platform allows it.
- `[conv]` Storage is the third: unattached volumes, snapshots nobody expires, log retention measured in years, BigQuery tables never partitioned (see `data-engineering` → `bigquery.md`).
- `[conv]` Egress and inter-zone traffic are billed and usually invisible: two services chatting across zones pay for a design decision.

## Levers, in order of payoff

1. Requests down to measured usage (with a limit above it), immediate, no architecture change.
2. Autoscaling actually reaching zero or near-zero in low-traffic hours.
3. Bin-packing: bigger nodes with higher utilization beats many small nodes with idle capacity, unless availability demands spread.
4. Spot/preemptible for stateless and batch work (handle the interruption), committed-use/savings plans for steady state.
5. Deleting what nobody uses. The cheapest capacity is the one you stop paying for.

## Budgets and alerts

- `[conv]` A budget alert at 50/80/100 % of the expected monthly spend, per project, sent to someone who can act. A bill nobody watches is a discovery, not a control.
- `[conv]` Cost anomaly alerting where the platform supports it; a 300 % day-over-day jump is either a bug or an attack.
- `[conv]` Label everything with owner and environment, or cost reports are unattributable. Unlabelled spend belongs to "the platform team", which means nobody.

## Observability of the infrastructure itself

- `[conv]` Four signals per workload: rate, errors, duration (per endpoint), saturation (CPU/memory/queue). Anything else is optional.
- `[conv]` Node and cluster level: node pressure conditions, disk usage with a trend, certificate and token expiry, control-plane quota.
- `[conv]` Alert on symptoms users feel (error rate, latency, failed deploys), page on those only. Cause-based alerts go to a dashboard, not to a phone at 3 a.m.
- `[conv]` Every alert links to the dashboard or runbook that explains it; an alert without a next step is noise that trains people to ignore alerts.
- `[conv]` Logs: structured, with the request id, without secrets or personal data, with retention chosen deliberately. Log volume is a cost line and a privacy surface.

## Capacity questions to answer before an incident

- What is the traffic at peak, and what is the headroom at `maxReplicas`?
- What happens when the cluster cannot scale (quota, IP exhaustion, regional stockout)?
- Which dependency is single-region, and what is the plan if it fails?
- How long does a cold start take? That is the floor on your recovery time.

## Review checklist

1. Every workload has requests/limits derived from measurement, and an owner label.
2. Autoscaling is configured and has been observed working, not just defined.
3. A budget alert exists and someone has received one.
4. The dashboards answer "is it healthy" without opening a terminal.
5. Retention and log volume are chosen, not defaulted.
