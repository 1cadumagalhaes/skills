---
name: infra
description: Containers, Kubernetes workloads, cloud IAM, CI/CD pipelines, Terraform/Argo IaC, and cloud cost (GCP-first with AWS/Azure equivalents). Use for Dockerfiles, GKE tuning, OIDC, pipelines, or infra drift.
cluster: engineering
tier: root
---

# Infra

Six places infrastructure becomes expensive or fragile, ordered by operational impact.

| Area | Read |
|---|---|
| Writing or reviewing a Dockerfile | `references/containers.md` |
| Sizing, probing, autoscaling, or rolling out Kubernetes / GKE workloads | `references/kubernetes.md` |
| Granting cluster, pipeline, or service cloud access | `references/cloud-iam.md` |
| Building or fixing a CI/CD pipeline | `references/ci-cd.md` |
| Changing Helm/ArgoCD manifests or Terraform/OpenTofu | `references/iac-and-gitops.md` |
| Cutting cloud spend or fixing observability gaps | `references/cost-and-observability.md` |
| Degrading or disabling a behaviour under load | `~/.agents/skills/feature-flags/SKILL.md` |

`cloud-iam.md` maps GCP first with AWS and Azure equivalents so every identity rule transfers across clouds.

## Non-negotiables

1. **Eliminate static cloud credentials.** Use OIDC or Workload Identity Federation for CI and workload identity at runtime instead of exported service-account JSON keys.
2. **Run containers non-root from pinned digests.** Keep secrets out of image layers and pin base images by SHA digest rather than mutable tags.
3. **Set real Kubernetes `requests` and protective `limits`.** Add a `startupProbe` for slow-booting workloads so probes do not kill startup under load.
4. **Apply production changes through reviewed CI/GitOps.** Keep state in locked remote backends and avoid manual click-ops changes that create unrecorded drift.
5. **Ensure every workload has an owner label and tested rollback path.** Verify rollbacks before relying on them during an incident.
6. **Treat cost as a design constraint.** Calculate per-replica, per-node, GKE Autopilot request multipliers, and DB/storage costs before scaling.

## Sources

Docker build and cache best practices, Kubernetes probes/requests/disruption docs, GKE cost optimization docs, AKS scheduler and workload identity docs, OWASP Workload Identity Federation and CI/CD Security guidelines, GitHub OIDC deployment hardening, HashiCorp Terraform automation, Argo CD docs.
