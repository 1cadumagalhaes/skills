# Supply chain

Every dependency, lockfile, base image, CI action and MCP server is code that runs with your privileges. The question is never "do we trust this package", it is "what can it do to us, and would we notice".

## Dependencies

- `[req]` Lockfiles committed and used in CI (`npm ci`, `uv sync --frozen`, `poetry install --no-root`). A build that resolves fresh versions is not reproducible and not reviewable.
- `[conv]` Pin exact versions in the lock; pin ranges in the manifest only as wide as your update cadence.
- `[conv]` Adding a dependency is a decision: maintenance status, transitive tree size, what it does at install time (post-install scripts are code execution), and whether it has a licence that fits.
- `[conv]` Automated updates with tests as the gate. Stale is a risk, but so is an unreviewed major bump on a Friday.
- `[conv]` Scan for known CVEs in CI and fail on fixable criticals. A scan nobody gates on is decoration.

## Build and provenance

- `[conv]` **SBOM per build**, kept with the artifact. It is what answers "are we affected" in a minute instead of a day.
- `[conv]` **Provenance** (SLSA-style) so the artifact can be tied to the commit and the pipeline that built it; deploy by digest, not tag.
- `[conv]` Artifacts are immutable once published; a tag that can be repushed is a supply-chain hole.
- `[conv]` The build is hermetic where possible: no ambient credentials, no network fetch of unpinned things.

## CI as a supply-chain node

- `[req]` Third-party actions/plugins pinned by full SHA.
- `[req]` No `pull_request_target` with a checkout of the PR head; no secrets exposed to fork builds.
- `[conv]` Least-privilege `permissions:` per job; OIDC to the cloud rather than stored keys (`infra` → `ci-cd.md`, `cloud-iam.md`).
- `[conv]` Runner images and toolchains pinned by version; a build that changes because `ubuntu-latest` moved is not a build you can trust.

## Containers

- `[conv]` Base images digest-pinned and rebuilt on a schedule; scan the image, not only the source lockfile. The OS packages are part of the surface.
- `[conv]` Non-root, read-only root filesystem, dropped capabilities, no shell in production images where the app allows it (`infra` → `containers.md`).
- `[conv]` No secrets baked into layers; a secret in a deleted layer is still in the image.

## MCP servers and agent extensions

- `[req]` Every MCP server is arbitrary code with tool access: read its source before adding it, pin the version, and scope its credentials to the minimum it needs.
- `[conv]` Prefer a server that exposes read-only tools unless you need writes; prefer `deferred`/`codemode` exposure so its tool descriptions do not reshape your context by default.
- `[conv]` An MCP server that can execute commands, write files or reach the cloud is a shell. Treat it like one.

## Skills and prompts you import

- `[conv]` A SKILL.md is instructions the model will follow: it can tell an agent to exfiltrate, to `curl | sh`, or to ignore its rules. Vendor it like code, review the diff on update, and record the pin and the licence.
- `[conv]` Run imported skills against the **OWASP Agentic Skills Top 10** checklist (AST01 malicious skills, plus its categories) before they enter the farm. An unlicensed import from a stranger is exactly the case that checklist was written for.
- `[conv]` Nothing in a skill may instruct the agent to disable its own guardrails; if it does, that is the finding.

## Incident questions

1. If this package were malicious today, what would it reach, the filesystem, the network, the cloud credentials, production?
2. Can we list every artifact built from this repo in the last 90 days, and what was inside it?
3. Who can publish to our registry, and is that audited?
