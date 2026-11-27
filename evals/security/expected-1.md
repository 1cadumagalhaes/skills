# security / prompt-1

## Must decide
- Trace from the asset outward: the file, its bucket/URL, who can trigger the upload, and what happens when a check fails (must deny).
- Untrusted input is the whole surface: content sniffing, size cap, SVG/HTML stored then served, filename traversal, and any fetch-from-URL path (SSRF).
- Personal data: avatars are user content tied to a person, so storage location, public/private URL, retention, and deletion on account close are in scope.

## Must show
- Findings in the review format: asset, crossed trust boundary, concrete attack path, impact, `file:line`, smallest fix; severity by real impact.
- ASVS 5.0.0 requirement ids cited concretely (`v5.0.0-...`) plus the Top 10:2025 category, not a vague label.
- Authorization stated inside the object lookup/query, not only in middleware.
- chained: `references/threat-model.md`, `references/input-and-injection.md`, `references/data-protection.md`.

## Miss if
- Generic checklist with no `file:line` and no attack path.
- Accepts the client `Content-Type` as validation, or stores the file under the user-supplied filename.
- Ignores the serving side (public bucket, inline SVG, no `Content-Disposition`, no CSP).
