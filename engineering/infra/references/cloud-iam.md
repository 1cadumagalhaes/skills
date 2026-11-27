# Cloud identity

One rule with three dialects: **workloads and pipelines assume an identity; they never carry a key.**

## The mapping

| need | GCP (primary) | AWS | Azure |
|---|---|---|---|
| identity for a workload on k8s | Workload Identity Federation for GKE (GSA bound to a KSA) | IRSA, or EKS Pod Identity (prefer Pod Identity on new clusters) | Microsoft Entra Workload ID (federated credential on a managed identity) |
| identity for a VM / container off-k8s | service account attached to the instance | IAM role via instance profile | managed identity on the resource |
| identity for CI (no stored secret) | Workload Identity Federation pool, provider trusts GitHub's OIDC | IAM OIDC provider + role with a trust policy on `sub` | federated credential on an app/managed identity |
| secrets store | Secret Manager | Secrets Manager / SSM Parameter Store | Key Vault |
| policy guardrails | Organization Policy Service | Service Control Policies (Organizations) | Azure Policy |
| audit of who did what | Cloud Audit Logs | CloudTrail | Activity Log / Entra sign-in logs |

## Rules that hold in all three

- `[req]` **No long-lived keys.** No service-account JSON key, no IAM access key, no client secret in a repo, a CI variable or an image. If a doc tells you to download a key, the doc is older than the feature that replaced it.
- `[req]` **Trust is asserted on the identity of the caller, not on a shared secret.** For OIDC federation, condition the trust policy on the `sub` claim (repository, branch, environment) and `aud`, so a fork or another branch cannot assume the role.
- `[req]` **Least privilege, scoped to the resource.** A role that can write one bucket is not a role that can administer storage. Start from deny and add the specific verbs.
- `[conv]` Separate identities per environment and per purpose (build vs deploy vs runtime). One identity shared by CI and prod is a blast radius, not a convenience.
- `[conv]` Humans impersonate, they do not hold keys either: short-lived tokens via `gcloud auth login`/`aws sso login`/`az login`, and impersonation for cross-account work.
- `[conv]` Rotate what cannot be federated, and inventory it. If a static credential must exist, it is an exception with an owner and a review date.

## GCP specifics

- `[conv]` Prefer **Workload Identity Federation** over keys for everything off-GCP (GitHub Actions included); for GKE, bind a Kubernetes service account to a Google service account rather than mounting a key.
- `[conv]` Service accounts are resources with IAM policies: grant at the resource or folder, not at project level "for simplicity".
- `[conv]` `gcloud iam service-accounts keys list` and the org policy `iam.disableServiceAccountKeyCreation` are the two controls that keep key sprawl from coming back.

## AWS specifics

- `[conv]` Pod Identity over IRSA on new clusters (no OIDC provider per cluster to maintain), IRSA where Pod Identity is unavailable.
- `[conv]` Trust policies are the security boundary: an assume-role policy without a `sub`/`aud` condition is open to any workflow in the org.
- `[conv]` Permission boundaries for anything that can create IAM.

## Azure specifics

- `[conv]` Managed identity over service principals with secrets; federated credentials for CI.
- `[conv]` Role assignments at resource-group or resource scope; subscription-level Owner is an administrative role, not a deployment one.

## Review questions

1. Can this pipeline deploy to production without a stored secret? If not, why not.
2. If this credential leaked, what is the blast radius, one bucket, one project, or the org?
3. Who is the owner of this identity, and when was it last used? Unused identities are deleted identities.
