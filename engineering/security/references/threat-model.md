# Threat model

You cannot review what you have not named. Ten minutes of this beats a week of checklist scanning.

## Four questions

1. **What are we protecting?** Data (personal, financial, credentials), money, availability, reputation, and access to anything downstream (a token that can deploy belongs on the list).
2. **From whom?** Anonymous internet, an authenticated user of another tenant, a compromised dependency, a malicious insider, a scraper, an agent given tools.
3. **What crosses a trust boundary?** Every arrow where data or a command passes between parties with different privilege: browser → API, API → DB, service → service, CI → cloud, page → agent.
4. **What happens if it fails?** Silent wrong answer, data loss, data exposure, outage, or a foothold. Name the worst plausible one; that's what sets the severity.

## Boundaries worth drawing explicitly

- **tenant ↔ tenant**: the most common real breach in multi-tenant SaaS, and the least often modelled.
- **internet ↔ authenticated** and authenticated user ↔ admin.
- **service ↔ service**: "internal network" is not an authorization model.
- **CI ↔ production**: the pipeline has production rights; treat it as a production system.
- **untrusted content ↔ model**: anything a model reads (a page, a file, a tool result) is an input to an interpreter with tool access. See `agent-security.md`.
- **human ↔ automation**: who can override, and is that override audited.

## Naming what you are protecting

For each asset, write one line: *what it is, where it lives, who may read, who may write, how long it is kept*. If a line cannot be written for personal data, that is the finding.

## Abuse cases, not just use cases

For each flow, ask what an adversary does with it: replay the request, change the id by one, supply a second tenant's id, upload a 4 GB file, send a webhook twice, pass an array where a string is expected, call the endpoint without the UI. The UI is not a control. Every request can be made directly.

## When to do this

- before a new externally reachable surface exists
- when data classification changes (new PII, new money movement)
- when a new party can reach the system (partner API, public webhook, MCP server, crawler)
- when a tenant boundary is introduced or moved

## Output

A short table, not a document: asset · boundary · threat · existing control · gap · severity. Two pages is already too long for anything smaller than a company.
