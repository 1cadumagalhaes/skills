# security / prompt-3

## Must decide
- Treat the MCP server as code execution with the agent credentials: inventory what it can read (tickets, attachments, PII) and what it can act on.
- Pin it, inspect tools and source, and scope the blast radius with a dedicated credential and a tool allowlist, not the agent broad token.
- Model-facing output is an injection surface: ticket bodies and attachments re-enter the context, so prompt injection is in scope.

## Must show
- The inventory: tool list, each tool side effects, required scopes, and where it runs (vendor-hosted vs local process).
- Concrete controls: pinned version or commit, read-only Jira scope, write tools disabled, egress allowlist, per-call logging.
- The injection test: a ticket body carrying instructions, and the expected refusal or containment.
- chained: `references/agent-security.md` and `references/supply-chain.md`.

## Miss if
- Approves on vendor reputation with no tool/scope inventory.
- Reuses the agent broad token, or leaves write tools enabled by default.
- Ignores the returned ticket text as an injection surface.
