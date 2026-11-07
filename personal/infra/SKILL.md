---
name: infra
description: Container images, Kubernetes workloads, cloud identity, CI/CD pipelines, infrastructure as code and cost — GCP-first with the AWS and Azure equivalent given for each rule. Use when writing a Dockerfile, setting requests/limits or probes, wiring OIDC instead of keys, reviewing a pipeline, structuring Terraform/Argo, or when a cluster is expensive, unstable or unrollbackable.
---

# Infra

Six places infrastructure gets expensive or fragile, in the order they tend to hurt.

| you are | read |
|---|---|
| writing or reviewing a Dockerfile | `references/containers.md` |
| sizing, probing, autoscaling or rolling out a workload | `references/kubernetes.md` |
| granting a cluster, pipeline or person cloud access | `references/cloud-iam.md` |
| building or fixing a pipeline | `references/ci-cd.md` |
| changing Terraform/OpenTofu or Argo | `references/iac-and-gitops.md` |
| the bill, or nobody can tell if it is healthy | `references/cost-and-observability.md` |

**Cloud coverage**: `cloud-iam.md` is written as a mapping table — GCP first, then the AWS and Azure equivalent. Rules are phrased so they read correctly in all three.

## Non-negotiables

1. **No static cloud credentials, anywhere.** OIDC/Workload Identity Federation from CI, instance or pod identity at runtime. A long-lived service-account JSON key or an access key is an incident waiting for a leak.
2. **Containers run as non-root, from a digest, with no secrets in layers.** Tags move; a digest does not.
3. **`requests` set so scheduling is real, `limits` set so a leak kills the pod and not the node.** Anything slow to boot gets a `startupProbe` or it will restart-loop under load.
4. **Nothing applied to production by hand.** Plan in the PR, apply in CI, state in a locked remote backend. Click-ops is drift with no history.
5. **Every workload has an owner label and a rollback that has been exercised.** An untested rollback is a rumour.
6. **Cost is a design input.** Know what one replica, one extra node and one full-table scan cost before scaling them.

## Sources

Docker *Building best practices* and *Optimize cache usage* · kubernetes.io *Disruptions*, resource management, probes · GKE *Best practices for running cost-optimized applications* · AKS resource-management and scheduler best practices (Microsoft Learn) · *Workload Identity and Access in EKS and AKS* (Microsoft Learn) · OWASP *Workload Identity Federation* cheat sheet · GitHub *Security hardening your deployments* (OIDC) · OWASP DevSecOps *CI/CD Pipeline Security* · HashiCorp *Running Terraform in automation* · Argo CD docs.
