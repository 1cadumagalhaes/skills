# Input and injection

Everything is untrusted until it is validated at the boundary: request bodies, query params, headers, filenames, uploads, webhooks, scraped pages, tool output, and model output.

## The injection families

- `[req]` **SQL**: parameterised queries only. String interpolation, even with quoting or an ORM's raw fragment, is the bug. Watch `ORDER BY`/column names, which parameters cannot bind. Allowlist them.
- `[req]` **Command**: no shell with interpolated input. Argument arrays, never `shell=True`/`exec`, never `os.system`, never a filename concatenated into a command.
- `[req]` **Template**: user content is data, not template. Never `render(user_input)`, never `eval`/`Function`/`exec` on anything reaching from outside.
- `[req]` **Path**: resolve and confirm the result stays inside the intended root (`realpath` then prefix check); treat `..`, absolute paths, symlinks and null bytes as hostile.
- `[conv]` **Header/log injection**: strip newlines from anything written to a header or a log line.
- `[conv]` **Deserialisation**: no pickle/YAML-unsafe-load/Java serialisation of untrusted data. JSON with a schema.
- `[conv]` **XML/XXE**: disable external entity resolution.

## Output and browsers

- `[req]` Context-aware escaping in templates (HTML, attribute, JS, URL are different contexts). Auto-escaping on, `innerHTML` off for user content.
- `[conv]` CSP as a second line, not the first: `default-src 'self'`, no `unsafe-inline` where avoidable, and a report-only rollout first.
- `[conv]` `Content-Type` set explicitly, plus `X-Content-Type-Options: nosniff`. An uploaded file served as `text/html` is stored XSS.
- `[conv]` CORS: explicit origins, no `*` with credentials, no reflecting the `Origin` header.

## SSRF and outbound requests

- `[req]` Any URL that comes from a user (webhook target, image proxy, scraper seed, "import from URL") is an SSRF risk: resolve the host and block private ranges (`127/8`, `10/8`, `172.16/12`, `192.168/16`, `169.254/16`, the metadata endpoint), plus IPv6 equivalents.
- `[conv]` Prefer an allowlist of hosts for integrations; a proxy that fetches anything is an open port into your network.
- `[conv]` Redirects re-checked at each hop; DNS rebinding is why the check happens after resolution.

## Uploads

- `[req]` Validate type by content, not by extension or `Content-Type`; cap size before reading the body; store outside the webroot; serve with `Content-Disposition: attachment` and a generated name.
- `[conv]` Image/document processing is the risky part: decode in a sandbox, with a timeout and a memory cap (an image bomb is a DoS).
- `[conv]` Never trust the client's filename. Path traversal and header injection both arrive there.

## Rate limits and resource abuse

- `[conv]` Limits per identity and per IP on expensive endpoints (search, export, login, password reset, LLM calls); a login endpoint without a limit is a credential-stuffing gateway.
- `[conv]` Cap what a single request can ask for: page size, date range, array length, file count, query complexity.
- `[conv]` Expensive work is asynchronous with a quota, not a request that can be opened in parallel indefinitely.

## Validation

- `[conv]` Validate at the boundary, once, into a typed structure (see `backend` → `api-design.md`), and let the interior trust it.
- `[conv]` Allowlist what is acceptable rather than blocklisting what is bad; blocklists miss encodings.
- `[conv]` Reject, do not sanitise silently: a cleaned-up email address that silently differs from what the user typed is a support ticket and often a bug.

## Review pattern

For each endpoint: where does each input come from, what is it used for (query, path, header, template, shell), and what happens with a 10 MB string, an array where a scalar is expected, a null, a negative number, a Unicode RTL override, or a URL pointing at `169.254.169.254`.
