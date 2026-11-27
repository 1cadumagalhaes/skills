# Kubernetes

Most cluster pain is three decisions made once and never revisited: how much a workload asks for, how it is probed, and how it is rolled out.

## Requests and limits

- `[req]` **`requests` on every container.** Without them the scheduler is guessing, and the QoS class is `BestEffort`, first to be evicted under pressure.
- `[req]` **`limits` on memory, always.** A container without a memory limit can consume the node and get *other* pods OOM-killed; with one, only the offender dies.
- `[conv]` CPU limits: set them when you need predictability, leave them off when you need burst. A CPU limit throttles hard and often shows up as inexplicable latency.
- `[conv]` The QoS ladder is decided entirely by these numbers: `Guaranteed` = requests == limits for every container (predictable, expensive), `Burstable` = requests < limits (normal), `BestEffort` = none (evicted first).
- `[conv]` Size from measurement (`kubectl top`, historical p95), not from a guess. Over-requesting is the single largest quiet cost in most clusters: the scheduler reserves what you asked for, not what you use.

## Probes

- `[req]` `readinessProbe` = "can this pod take traffic right now". Failing it removes the pod from the Service without restarting it. That is how you gate on a dependency being reachable.
- `[req]` `livenessProbe` = "is this process wedged". **Never point liveness at a dependency**: a slow database then restarts the entire fleet, turning a degradation into an outage.
- `[req]` `startupProbe` for anything slow to boot (JVM, models, migrations). Without it a slow start is read as a dead process and the pod restart-loops forever.
- `[conv]` Readiness endpoints must not be expensive. They are polled every few seconds per pod. A health check that queries the database is a load generator.
- `[conv]` `initialDelaySeconds`/`failureThreshold` sized to the real boot time; defaults are not.

## Rollouts and availability

- `[req]` `minReadySeconds` so a flapping pod is not counted ready.
- `[conv]` `maxSurge`/`maxUnavailable`: surge for capacity headroom, unavailable zero for anything user-facing.
- `[conv]` PodDisruptionBudget on every workload with more than one replica (`minAvailable: 1` or `maxUnavailable: 25%`). It constrains *voluntary* disruptions, node drains and upgrades, not crashes.
- `[conv]` `topologySpreadConstraints` across zones/nodes; two replicas that land on the same node are one replica.
- `[conv]` Anti-affinity for the pieces that must not share a failure domain; affinity only when there is a real locality benefit.

## Autoscaling

- `[conv]` HPA scales on a metric **relative to requests**. No requests, no HPA. CPU is a proxy; queue depth or RPS is better where available.
- `[conv]` VPA and HPA fight over the same signal. Use VPA in recommendation mode unless you mean it, and never both on CPU.
- `[conv]` Cluster autoscaling reacts in minutes: a traffic spike faster than that needs headroom (`minReplicas`, buffer nodes), not a bigger HPA range.
- `[conv]` Scale-down stabilisation windows exist for a reason; a pod that scales to zero and back every minute loses caches and pays cold starts.

## Workload hygiene

- `[conv]` Labels: `app.kubernetes.io/name`, `instance`, `version`, plus an **owner** label. Cost reports and incident triage both key on them; without an owner, an expensive workload belongs to nobody.
- `[conv]` `resources` and probes are part of the manifest, not a Helm value someone remembers to set.
- `[conv]` Namespaces per environment or team, with `ResourceQuota` and `LimitRange` so one team cannot starve the cluster.
- `[conv]` `securityContext`: `runAsNonRoot`, `readOnlyRootFilesystem`, drop Linux capabilities, `allowPrivilegeEscalation: false`. This is the cheapest blast-radius reduction available.
- `[conv]` Jobs and CronJobs: `backoffLimit`, `activeDeadlineSeconds`, `ttlSecondsAfterFinished`, and a `concurrencyPolicy` that is not "let them pile up".

## Debugging order

When something is broken: `kubectl get pods` (status/reason) → `kubectl describe pod` (events: scheduling, probe failures, OOMKilled) → logs of the *previous* container (`--previous`) → node conditions. Pod `Pending` is a scheduling problem, not an application one; `OOMKilled` is a limit, not a leak, until proven otherwise.
