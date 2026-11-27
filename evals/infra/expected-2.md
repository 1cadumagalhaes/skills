# infra / prompt-2

## Must decide
- Refuse the static key: GitHub OIDC to Workload Identity Federation, short-lived tokens, no exported service-account key anywhere.
- Narrow the grant: attribute condition on `repo:<org>/<repo>:ref:refs/heads/main`, a dedicated deployer SA with minimum roles, never `roles/owner` or `editor`.
- Production changes land through reviewed CI/GitOps with locked remote state; `terraform apply` from a laptop is out.

## Must show
- The WIF setup concretely: workload identity pool plus provider, `attribute_condition`, the `roles/iam.workloadIdentityUser` binding, and `permissions: id-token: write` in the workflow.
- Remote state with locking (GCS backend and lock) plus a plan artifact reviewed before apply.
- The migration for the existing key: delete it, then prove no consumer remains (`gcloud iam service-accounts keys list`).
- chained: `references/cloud-iam.md` and `references/ci-cd.md`.

## Miss if
- Creates or endorses the JSON key as temporary.
- Grants a broad role or an unconditional provider.
- Applies from a developer machine, or without locked remote state.
