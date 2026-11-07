# Authentication and authorization

Broken access control is the top of every list because it is the easiest thing to leave half-done: the login works, so nobody looks at what happens after it.

## Sessions and tokens

- `[req]` Session cookies: `HttpOnly`, `Secure`, `SameSite=Lax` (or `Strict` where it does not break flows). A session token readable by JavaScript is an XSS-to-account-takeover pipeline.
- `[req]` Tokens are compared in constant time and stored hashed where possible; a token in a database dump is a credential.
- `[conv]` Short-lived access tokens + refresh rotation, or server sessions — pick one model and be strict about it. Access tokens in `localStorage` are the weak default; prefer cookies or in-memory with refresh.
- `[conv]` Invalidate server-side on logout and on password change. A logout that only clears the client is theatre.
- `[conv]` Absolute and idle timeouts, and a session list a user can revoke.

## Passwords and login

- `[conv]` Delegate to an identity provider (OIDC) where you can; don't build password auth you did not have to.
- `[req]` If you store passwords: argon2id (or bcrypt with a sane cost), never SHA-256, never unsalted.
- `[req]` Rate-limit and lock out on repeated failures, per account **and** per IP; log the attempts without logging the password.
- `[conv]` Generic error messages ("invalid credentials"), no user enumeration, and identical timing for "unknown user" and "wrong password" (hash a dummy).
- `[conv]` Offer MFA/TOTP for anything with money, admin or personal data; support recovery codes.

## Authorization

- `[req]` **Authorize against the object, in the query.** `WHERE tenant_id = $1 AND id = $2`, or database row-level security. Fetch-then-check is a bug generator: the check gets skipped on the next handler.
- `[req]` Tenancy comes from the authenticated principal (session, token claim), **never from the request body or a query parameter**.
- `[conv]` Deny by default: a new endpoint with no explicit permission is unreachable, not public.
- `[conv]` Centralise the check (middleware or a policy module) with per-endpoint rules, rather than scattering `if user.is_admin` through handlers.
- `[conv]` Distinguish authentication (401) from authorization (403), and return 404 when revealing existence is itself the leak.
- `[conv]` Admin is a **separate identity**, not a boolean on the user row that someone can flip via mass assignment.

## The IDOR checklist

For every endpoint that takes an identifier:

1. Where did the id come from — the principal, or the request?
2. Does the query filter by owner/tenant, and does that filter come from the principal?
3. What does the response reveal for something the caller cannot see — 403 (exists), 404 (doesn't), or a list count?
4. Are bulk endpoints looping the same check per item, or assuming the first one covered them?

## Object-level and function-level

- `[conv]` Object-level (can I touch *this row*) and function-level (can I use *this endpoint*) are separate checks. Most breaches are the first.
- `[conv]` Writes need the same check as reads. "Only the owner can edit" is often enforced only on the read path.
- `[conv]` GraphQL and bulk APIs: every resolver and every filter needs the scope; a parent-level check does not cover nested fetches.

## Delegated and machine access

- `[conv]` Service-to-service calls carry their own identity (`backend`/`infra` → identity, not a shared API key).
- `[conv]` Webhooks: verify the signature and the timestamp, reject replays; assume anyone can post to the URL.
- `[conv]` API keys are per-consumer, scoped, rotatable, and hashed at rest. One global key shared by three services cannot be revoked safely.

## Review questions

1. Can a user of tenant A reach tenant B's data by editing one id? (Try it — on a staging env, with two real accounts.)
2. What happens when the permission service errors: deny or allow?
3. Which endpoints skip the policy middleware, and why?
4. Does the admin path share the customer path's code, and if so, what stops a customer from using it?
