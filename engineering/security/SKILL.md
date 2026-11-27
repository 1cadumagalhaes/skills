---
name: security
description: Security policy and review for authn/z, tenancy, PII/secrets, untrusted input, supply chain, and agent safety. Use when touching auth, personal data, secrets, dependencies, or MCP servers.
cluster: engineering
tier: root
---

# Security

Policy and verification layer. Implementation mechanics live in `backend` (query scoping, API boundaries), `infra` (IAM, image provenance), and `data-engineering` (warehouse PII handling).

Use OWASP **Top 10:2025** as the risk awareness map and OWASP **ASVS 5.0.0** as the verification standard (cite concrete requirements such as `v5.0.0-8.2.2` rather than vague labels).

| Question | Read |
|---|---|
| What assets are exposed and to whom | `references/threat-model.md` |
| Authentication, sessions, roles, and tenant isolation | `references/authn-authz.md` |
| Personal data, secrets, logging, and retention | `references/data-protection.md` |
| Untrusted input, injection, SSRF, uploads, output encoding | `references/input-and-injection.md` |
| Dependencies, containers, CI, and provenance | `references/supply-chain.md` |
| What an agent or LLM may read and execute | `references/agent-security.md` |

## Non-negotiables

1. **Enforce authorization inside the data query.** Scope every tenant query in the same statement that fetches rows rather than relying on route checks alone.
2. **Keep secrets out of code, image layers, logs, and prompts.** Treat test credentials with the same secrecy as production keys.
3. **Treat every external input as untrusted.** Validate request bodies, query params, filenames, webhooks, scraped pages, tool outputs, and model responses.
4. **Inventory personal data before storing it.** Enforce retention, deletion, and LGPD compliance from day one.
5. **Fail closed on authorization or policy errors.** An unreachable policy check denies access.
6. **Audit every dependency, skill, and MCP server as code execution.** Pin versions and inspect updates before trusting them.

## Review method

Trace from sensitive data outward: what data this touches, who can trigger it, and what happens when a check fails. Report each finding with the asset, crossed trust boundary, concrete attack path, impact, `file:line`, and smallest fix. Rank severity by real impact rather than category name.

## Sources

OWASP ASVS 5.0.0 (May 2025), OWASP Top 10:2025, OWASP Cheat Sheet Series, OWASP DevSecOps Guideline, OWASP Agentic Skills Top 10, OWASP secure-agent-playbook.
