# CI/CD

The pipeline holds production credentials, runs third-party code on every push, and publishes what everything downstream trusts. It is the most valuable target in the repo.

## Authentication

- `[req]` **OIDC federation to the cloud, not stored secrets.** GitHub Actions: `permissions: id-token: write`, then assume a role/service account through Workload Identity Federation. AWS and Azure have identical mechanics.
- `[req]` Constrain the trust to this repository, this branch/environment. A federated role that accepts any workflow in the org is a shared password with better branding.
- `[req]` Least-privilege `permissions:` at the top of every workflow (`contents: read` by default), widened per job only where needed.
- `[conv]` Secrets that cannot be federated live in the platform's store (Secret Manager / Secrets Manager / Key Vault), injected at deploy time, never echoed, never written to the workspace.

## Supply chain

- `[req]` **Pin third-party actions by full commit SHA**, with the version in a comment. A tag is mutable; a compromised action runs with your token.
- `[req]` Never use `pull_request_target` with a checkout of the PR head — that combination hands write tokens and secrets to fork code.
- `[conv]` Pin the base images, the toolchain and the lockfiles the build uses; a build that resolves `latest` is not reproducible.
- `[conv]` Produce provenance (SLSA) and an SBOM per build; deploy by digest, not tag, so what is running is what was built.
- `[conv]` Scan dependencies and images in the pipeline and fail on the thresholds you actually care about.

## Speed and feedback

- `[conv]` Tier the tests: fast checks (lint, types, unit) on every push; slow suites on PR; full matrix and end-to-end before merge or on main. A pipeline that takes 40 minutes for a typo gets bypassed.
- `[conv]` Cache what is expensive (package manager, build layers, test fixtures) keyed on the lockfile hash — and make a cache miss slow, not wrong.
- `[conv]` `concurrency` with `cancel-in-progress` per branch: pushing twice should not run the suite twice.
- `[conv]` Fail fast: order jobs so the cheapest failure happens first, and do not run the matrix until the single-version build passes.

## Deploy discipline

- `[req]` One pipeline path to production, the same one used for every change. A hotfix that skips the gates is a different system nobody has tested.
- `[conv]` Environment protection rules for prod: required reviewer, restricted branches, deploy windows if the business has them.
- `[conv]` Deploy by immutable digest, with the commit SHA in the image label and the deploy annotation — the link from "what is running" to "which change" must be one lookup.
- `[conv]` Migrations run as an explicit step before the new code, with the old code still able to run against the new schema (`backend` → `data-modelling.md`).
- `[conv]` Rollback is a pipeline operation, not a person with `kubectl`. Test it on the first deploy of every new service.

## Reproducibility

- `[conv]` The build is a function of the commit: pinned tool versions (including the CI runner image and the toolchain), no ambient credentials, no network fetch of unpinned things.
- `[conv]` Artifacts are content-addressed and retained long enough to redeploy an old commit during an incident.
- `[conv]` Anything a human runs by hand to make a deploy work belongs in the pipeline by the end of the week.

## What to alert on

- `[conv]` Failed deploys and rollbacks, not every failed job (a lint failure is not an incident).
- `[conv]` Deployment frequency, lead time, change-failure rate, time to restore — the four that tell you whether the pipeline is healthy.
- `[conv]` Drift between what Git says should be deployed and what is running (see `iac-and-gitops.md`).
