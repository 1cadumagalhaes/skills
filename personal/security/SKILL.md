---
name: security
description: Security decisions for code, data, infrastructure and agents — access control and tenancy, PII and secrets, injection and untrusted input, supply chain, and what an agent may safely do with scraped or third-party content. Use when handling authentication, permissions or personal data, when reviewing code that touches secrets or user input, when adding a dependency or MCP server, or when deciding how much to trust tool output.
---

# Security

The policy layer. The mechanics live where they belong: query scoping and authorization placement in `backend`, IAM and pipeline credentials in `infra`, PII in a warehouse in `data-engineering`. This skill decides *what matters* and *how to verify it*.

Use the two OWASP artefacts for what each is good at: **Top 10:2025 is an awareness list** (which risks deserve attention), **ASVS 5.0.0 is a verification standard** (345 testable requirements in 17 chapters, cited as `v5.0.0-8.2.2`). Do not quote the Top 10 as if it were a control set.

| the question | read |
|---|---|
| what are we actually protecting, and from whom | `references/threat-model.md` |
| who may do what — login, sessions, roles, tenancy | `references/authn-authz.md` |
| personal data, secrets, logging, retention | `references/data-protection.md` |
| untrusted input, injection, SSRF, uploads, output | `references/input-and-injection.md` |
| dependencies, images, CI, provenance | `references/supply-chain.md` |
| what an agent or LLM may be handed | `references/agent-security.md` |

## Non-negotiables

1. **Authorization is checked against the data, not the route.** Every query on tenant data is scoped in the same statement that fetches it (A01:2025 has been #1 for years because people check the route).
2. **No secret in code, in an image layer, in a log line, or in a prompt.** Not even a test one; test keys leak into public repos at the same rate as real ones.
3. **Untrusted input is every input**: request bodies, query params, filenames, webhooks, scraped pages, tool output, model output, another service's response.
4. **Personal data is inventoried before it is stored.** You cannot delete, migrate or protect what you did not know you had — and under LGPD you must be able to.
5. **Fail closed.** If the authorization service is down, the answer is "no", not "allow and log".
6. **Every dependency, action and MCP server is a code execution decision**, pinned and reviewed like one.

## How to review

Work from the data outwards: what does this touch, who may touch it, what happens when a check fails. Then pick the ASVS chapter that matches and cite requirements rather than adjectives. A finding is: the asset, the trust boundary crossed, the concrete attack, the impact, `file:line`, and the smallest fix.

Severity by consequence, not by category name: *data of other tenants readable* is a blocker even if the category sounds mundane; a missing `X-Frame-Options` on a JSON API is not.

## Sources

OWASP **ASVS 5.0.0** (May 2025) · OWASP **Top 10:2025** · OWASP **Cheat Sheet Series** (incl. Supply Chain Security, Workload Identity Federation) · OWASP **DevSecOps Guideline** · OWASP **Agentic Skills Top 10** + skill assessment checklist · OWASP **secure-agent-playbook**, *Security Code Review*.
