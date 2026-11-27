# Data protection

Personal data is a liability with a legal schedule attached. In Brazil, **LGPD** (Lei 13.709/2018) applies to anything you collect about a person: purpose limitation, minimization, a lawful basis, deletion on request, and a record of processing. That is a product requirement, not a legal afterthought.

## Inventory first

- `[req]` A data inventory: field · table · classification (public / internal / personal / sensitive) · purpose · retention · who reads it. No inventory, no ability to answer "delete this person".
- `[conv]` Classify once and derive everything from it: masking, access reviews, retention, and what may be logged.
- `[conv]` Sensitive categories get extra care: CPF and other national ids, health, biometrics, financial, precise location, minors.

## Minimisation and purpose

- `[conv]` Collect what the feature needs, not what might be useful. Every extra field is future breach surface and future deletion work.
- `[conv]` Purpose is written down per field. Using checkout data for marketing is a new purpose, and usually a new lawful basis.
- `[conv]` Delete or anonymise on a schedule, not "eventually". Retention is a number in a config, and a job that enforces it.
- `[conv]` Deletion must reach the warehouse too: the mart, the backups' retention window, and any exported CSV someone emailed.

## At rest and in transit

- `[conv]` TLS everywhere, including service-to-service where the platform allows it; no plaintext fallback for internal traffic.
- `[conv]` Encryption at rest is table stakes (managed databases have it); it does not replace column-level protection for the fields that would hurt: hash or encrypt identifiers you do not need in clear.
- `[conv]` Hashing for matching (an id you must join on) is not the same as hashing for secrecy: use a keyed hash (HMAC) with a scoped key so the same CPF in a different context cannot be correlated. Salt/scope by purpose — `'62|cpf|'` style key separation is what makes the digest reusable without being a global registry.

## Secrets

- `[req]` Secrets live in a secret manager or the platform's injected env, never in code, images, CI logs or prompts.
- `[conv]` One secret per environment and purpose; rotation is a documented, exercised procedure.
- `[conv]` A secret that leaked is rotated, not deleted from history. Assume it was read within seconds.

## Logging hygiene

- `[req]` Never log: passwords, tokens, session ids, full card numbers, full CPF, request bodies of auth endpoints, or whole API payloads from third parties.
- `[conv]` Log identifiers (user id, request id), not the personal data behind them; redact at the logger, not at every call site.
- `[conv]` Log retention is chosen, and short for anything that could contain personal data. Logs are a second copy of your database that nobody classified.

## Access and audit

- `[conv]` Production data access is a role, reviewed, logged, and time-boxed; a shared analyst account with read access to everything is an audit finding.
- `[conv]` "Who saw this person's data" must be answerable from logs for sensitive tables.
- `[conv]` Test and staging data is synthetic or masked. Restoring production into dev is a breach with extra steps.

## The questions that catch most of it

1. Where does this person's data end up? (table, warehouse, logs, exports, backups, a prompt)
2. If they ask for deletion tomorrow, what exactly would we delete, and what would we miss?
3. Does the response return more fields than the screen shows — internally, or to an API consumer?
4. Is any of this in a log or a trace?
