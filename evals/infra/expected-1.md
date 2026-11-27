# infra / prompt-1

## Must decide
- Image: multi-stage build, base pinned by digest, non-root user, no secrets in layers (`.dockerignore`, no `ENV` keys), no build toolchain in the runtime stage.
- Workload: real `requests`, protective `limits`, and a `startupProbe` because boot is 40s. Liveness must not kill startup.
- Rollout: maxSurge/maxUnavailable that absorbs the boot time, an owner label, and a rollback path that was checked once.

## Must show
- `Dockerfile` with `FROM python:3.14-slim@sha256:... AS runtime`, `USER app`, and cache-friendly layer order.
- `Deployment` with `resources.requests/limits`, `startupProbe` where `failureThreshold * periodSeconds > 40`, a readiness probe, and `labels.owner`.
- A per-replica cost line at the chosen replica count.
- chained: `references/containers.md` and `references/kubernetes.md`.
- `kubectl apply --dry-run=server -f ...` or `helm template` output before claiming it works.

## Miss if
- `FROM python:latest` or a floating tag, root user, or a secret baked into a layer.
- No `startupProbe` while liveness fires inside the 40s boot window.
- Limits equal to requests with no cost math, or a rollout strategy that cannot absorb boot time.
