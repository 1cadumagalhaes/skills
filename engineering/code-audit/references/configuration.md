# Explicit configuration

Implicit configuration is where codebases rot quietly: a default that differs between environments, a value duplicated in four places, a threshold nobody can find. The rule is: **every decision that could change between deployments is named, validated once, and visible.**

## Three kinds, never confused

| kind | changes | lives in | example |
|---|---|---|---|
| **constant** | when the code changes | the source, named, with units | `MAX_BATCH_SIZE = 500` |
| **config** | per deployment | env vars / config file, parsed at the edge | `DATABASE_URL`, `RETRY_LIMIT` |
| **secret** | per deployment, sensitive | secret store / env injected by the platform | API keys, passwords |

A secret is never a config default. A constant is never an env var "just in case". Mixing them is how a test accidentally points at production.

## Magic values

- `[check]` Bare numbers and strings in logic: `sleep(300)`, `if status == 3`, `timeout=30`. Name them, and put the unit in the name: `TIMEOUT_SECONDS = 30`.
- `[check]` The same literal in several places. One source of truth, or they will drift.
- `[check]` A boolean argument that switches behaviour: `run(dry=True)`. Two functions or an explicit enum reads better and cannot be passed positionally by accident.
- `[check]` Magic keys: `os.environ["FOO"]` scattered around; define the name once.
- `[check]` Environment-sniffing branches: `if settings.ENV == "prod": do_things_differently()`. Configuration decides; code paths should not fork on environment, with rare, named exceptions.

## Parse once, at the edge, validated

    # one place, typed, exhaustive, fails fast
    @dataclass(frozen=True)
    class Settings:
        database_url: str
        retry_limit: int = 3
        timeout_seconds: float = 30.0

    def load_settings(env=os.environ) -> Settings:  # called once at startup
        ...

- `[check]` Validation happens once, at startup, with a message that names the variable and what was expected, not on first use, three hours later, in a background job.
- `[check]` Types and ranges are enforced (`int`, `> 0`, one of a set), not assumed.
- `[check]` Required vs optional is explicit; an optional value has a visible default in code, not in documentation.
- `[check]` Invalid configuration fails at boot. A service that starts with a half-broken config and fails at 3 a.m. is a defect.
- `[check]` Nothing reads the environment deep inside business logic. Pass `Settings` down; do not let a helper call `os.getenv`.

## Visibility

- `[check]` The resolved configuration is logged once at startup, secrets redacted, defaults marked as defaults.
- `[check]` A `.env.example` (or schema) lists every key the code requires, kept in sync.
- `[check]` Defaults are documented where they are set, not in a wiki that drifts.

## Feature flags

- `[check]` Every flag has an owner, a default, and an intended removal date; a flag with no removal plan is dead configuration.
- `[check]` A flag is checked in one place, not sprinkled through every call site.
- `[check]` Flags do not compose into combinatorial behaviour nobody has tested (`if a and not b or c`).

## Reporting

    [major] svc/worker.py:41 - `sleep(300)` hardcoded; the 300 s is also a queue visibility timeout
      set in terraform, so changing one silently desynchronises the other. Fix: read
      `settings.queue_visibility_seconds` and assert it at startup.
