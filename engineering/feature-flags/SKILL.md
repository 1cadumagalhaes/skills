---
name: feature-flags
description: "Decide, build and retire feature flags: which of the four categories, mechanism from env var to flag service, rollout versus rollback, kill switches, A/B cohorts, and what changes on the client. Use when adding a flag, choosing a flag tool, or cleaning one up."
cluster: engineering
tier: leaf
disable-model-invocation: true
---

# Feature flags

A flag decouples behaviour from the artifact. The category decides who owns it, how long it lives and how it is configured, so pick the category before writing the flag.

| When | Read |
|---|---|
| Deciding whether the change can be undone by redeploying | `~/.agents/skills/backend/SKILL.md` |
| The flag hides UI rather than server behaviour | `~/.agents/skills/frontend-build/SKILL.md` |
| The flag degrades the system under load | `~/.agents/skills/infra/SKILL.md` |

## Four categories, four lifetimes

| Category | Job | Lives | Decided how |
|---|---|---|---|
| Release | keep unfinished work out of users' view, ship trunk continuously | days to a couple of weeks | static, one value per release |
| Experiment | multivariate or A/B comparison of cohorts | long enough for significance | dynamic, per user |
| Ops | degrade or disable a behaviour fast, under load or under incident | short, or permanent as a kill switch | dynamic, by an operator |
| Permissioning | who gets a feature: premium, alpha, beta, internal | years | dynamic, per user |

Treating these alike is the original mistake. A release flag that outlives its rollout is debt; a permissioning flag that expires breaks paying customers.

## Off means old, On means new

Hold one convention everywhere: **Off enables existing or legacy behaviour, On enables the new behaviour**. Testing becomes tractable, and every reader of the flag knows what the default protects.

## Mechanism: climb only when a requirement forces it

| Rung | Serves | Costs |
|---|---|---|
| Constant in code | a flag that ships with the next release | a build per change |
| Environment variable | per-environment differences | restart or redeploy |
| Configuration file | change without build, reviewed in git | no targeting |
| Table in the app database | runtime admin and history | one more dependency on the hot path |
| Distributed flag service | targeting by context, audit of who flipped what, environments, kill switch in incident, experiments with exposure | a vendor, evaluation latency, one more failure mode |

Prefer static configuration. A flag service is an operations decision, not an elegance decision: admin, audit trail and environment management are software, and a file cannot audit itself.

## Rollout and rollback are different questions

- Rollout is how the new thing arrives: canary cohort, percentage, targeting.
- Rollback of the **artifact** takes the previous deploy, minutes, and requires knowing what is wrong.
- Rollback of the **behaviour** takes the flag, seconds, and requires no diagnosis at all.

That last difference is the reason ops flags exist. The feature was built, tested and validated, and a user found a situation nobody planned: the code is right for everything that was tested, and the behaviour does not serve that user. Turn it off first, understand later. A hotfix needs the cause; a flag does not.

Every ops flag states, in writing: who flips it, how fast, what degrades, and what the user sees. A flag with no owner is a button nobody presses during an incident.

## Experiments measure, they do not guard deploys

- Assignment is **stable per user**, derived from a stable identity, never a per-request random draw.
- The configuration stays frozen for the window; a concurrent change to the same path invalidates the result, and staying longer is not better.
- Canary is not an experiment: canary asks "is it safe", experiment asks "which variant is better".
- Multivariate needs traffic most internal services do not have. Without volume the test concludes nothing.
- The window ends with a decision written down: ship, iterate, drop. A flag that outlives the decision is debt.
- A claimed lift is a measurement, so vet it before believing it.

## The client surface

| Concern | Rule |
|---|---|
| Default value | Mandatory, and it is what users see when the provider fails or is absent, so the default is the safe, legacy behaviour |
| Provider readiness | The first render happens before the provider answers. Block the render or accept a switch, but decide it explicitly instead of letting the screen flicker |
| Security | A client flag is in the bundle. It never authorises anything; the server decides |
| Server rendering | Server and client evaluate with the same context, or hydration diverges |
| Exposure | Counted once per exposure, not once per render |
| Payload | Flag keys and defaults ship to the browser, so nothing secret rides in a flag value |

## Test three configurations, not all of them

Production configuration, fallback (the flags about to be released flipped Off), and all-on to catch a future regression. Combinatorial testing of every permutation is not the goal and is not feasible.

## Retire it as part of the delivery

A flag is debt from the moment it is created. The work is not done when the flag is on for everyone; it is done when the flag and the dead branch are gone. Put the expiry in the same change that introduces the flag, and treat a flag past its date as a defect.
