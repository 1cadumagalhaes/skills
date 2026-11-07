# Containers

The image is the deployment unit: every megabyte is pulled on every cold start, and every extra tool is an extra attack surface.

## Dockerfile shape

- `[req]` **Multi-stage**: build in one stage, copy artifacts into a minimal runtime stage. Build tools, compilers and dev dependencies never reach the final image.
- `[req]` **Order by change frequency** — base image, then dependency manifests, then `install`, then source code, then build. `COPY . .` before the dependency install throws away the cache on every code change.
- `[conv]` Order dependencies before source; use BuildKit cache mounts for package managers (`--mount=type=cache,target=/root/.cache/pip`) so a rebuild is seconds.
- `[conv]` One process per container. No supervisord, no cron inside the image; scheduling is the orchestrator's job.
- `[conv]` `ENTRYPOINT` as a JSON array (exec form) so PID 1 receives signals; `CMD` for defaults. Without that, `SIGTERM` never reaches your app and shutdown becomes a 30-second kill.
- `[conv]` OCI labels (`org.opencontainers.image.source`, `.revision`, `.version`); they make an image traceable to a commit.

## Base images

- `[req]` Pin by **digest**, not by tag: `FROM python:3.13-slim@sha256:…`. `latest` is not a version, and even `3.13-slim` moves under you.
- `[conv]` Smallest base that works: `-slim`, `alpine` only if you have no musl problems, distroless where you do not need a shell. Smaller base = smaller CVE surface and faster pulls.
- `[conv]` Rebuild on a schedule even when nothing changed — base-image CVEs arrive without commits.

## Runtime

- `[req]` `USER` a non-root UID (and a numeric one, because Kubernetes `runAsNonRoot` needs a number). Root in the container is root on the node's kernel if anything escapes.
- `[req]` **No secrets in the image**: not in `ENV`, not `COPY`d, not in build args (they persist in history). Secrets are mounted at runtime.
- `[conv]` `.dockerignore` excludes `.git`, `node_modules`, tests, local env files, build output — both for speed and to avoid copying a `.env` that was never meant to ship.
- `[conv]` Read-only root filesystem in production where the app allows it; write to a mounted `emptyDir` or a volume.
- `[conv]` `HEALTHCHECK` only for local/docker-compose use; Kubernetes ignores it and uses its own probes.

## Size and audit

- `[conv]` Measure the actual size (`docker image ls`, `docker history`), and find the fat layer before optimising blind. A 1.2 GB Python image is usually a compiler and a wheel cache.
- `[conv]` Scan images in CI (Trivy/Grype) and fail on fixable criticals; a scan nobody gates on is decoration.
- `[conv]` Generate an SBOM per build. It is what lets you answer "am I affected" in a minute instead of a day.
- `[conv]` Rebuild is not optional: a base image with a CVE requires a new image, not a restart.

## Multi-arch and reproducibility

- `[conv]` Build for the architectures you deploy to (`linux/amd64`, sometimes `linux/arm64`) in one manifest; a laptop-built arm64 image that "works locally" fails on the node.
- `[conv]` Builds should be reproducible from a commit: pinned base digests, pinned dependency lockfile, no network fetch of `latest` anything.
- `[conv]` Never build on the production host. Build in CI, push to a registry (Artifact Registry / ECR / ACR), deploy by digest.
