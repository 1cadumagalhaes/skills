# IaC and GitOps

Two ownership records: Terraform (or OpenTofu) says what infrastructure exists, a GitOps controller says what workloads should run. Neither proves the service works. That is what monitoring is for.

## Terraform

- `[req]` **Remote state with locking** (GCS, S3+DynamoDB, Azure Blob, or HCP Terraform). Local state is a laptop-only single point of failure; no lock means two applies corrupt each other.
- `[req]` **One state per environment and per blast radius.** A state that contains dev and prod means a plan touching one can affect the other.
- `[req]` `plan` in the PR, `apply` in CI from the reviewed plan. `-detailed-exitcode` (0 = no changes, 2 = changes, 1 = error) is how the pipeline knows. Nothing applied by hand to production.
- `[conv]` Save the plan file and apply *that* plan (`-out`), so what was reviewed is what runs.
- `[conv]` Pin the Terraform version and every provider version; an unpinned provider silently changes resource semantics on the next run.
- `[conv]` Modules with narrow inputs and documented outputs; no module that reaches into account/project-wide scope.
- `[conv]` `prevent_destroy` and `lifecycle` on stateful resources (databases, buckets, DNS), the guardrail you appreciate at 3 a.m.
- `[conv]` Drift detection on a schedule; a `plan` that shows unexpected changes is an incident, not noise.

## What belongs where

- Terraform/OpenTofu: networks, clusters, databases, buckets, IAM, DNS, registries, long-lived and slow-changing.
- GitOps controller (Argo CD, Flux): workloads, deployments, services, config that changes per release.
- Overlap is where teams fight: do not manage the same object from both. Pick one owner per resource and write it down.

## Argo CD / GitOps

- `[conv]` The cluster reconciles from Git; nobody `kubectl apply`s to production. A manual change is reverted by the next sync, which is the point.
- `[conv]` Separate the app repo from the deploy repo (or use a rendered-manifests directory) so a deploy is a commit that can be reviewed and reverted.
- `[conv]` `syncPolicy` explicit: automated with `selfHeal` for stateless, manual for anything that would surprise you.
- `[conv]` Sync waves and hooks for ordering (migrations before rollout); health checks that mean something, not `Progressing` forever.
- `[conv]` Rollback = revert the commit (or `argocd app rollback` to a known revision), and it must be a rehearsed action.

## Helm

- `[conv]` Values layering: chart defaults → environment values → a small override file. Never fork a chart to change one value.
- `[conv]` Templates contain no secrets; they reference an existing Secret/ExternalSecret.
- `[conv]` `helm template` in CI and diff the rendered output. A values change that alters 40 resources should be visible before merge.
- `[conv]` Pin chart versions by semver and review the changelog on bump; charts change defaults between minors.

## The review questions

1. If this is applied twice, is it the same result? (Idempotent, or `plan` after `apply` is empty.)
2. What is the blast radius of this state/module? Can it delete a database?
3. Can a new engineer reproduce production from Git alone, no console, no `kubectl`, no memory?
4. What breaks if this apply fails halfway, and what would recovery look like?
