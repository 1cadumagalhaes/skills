---
name: observability
description: "Instrument a service so production questions are answerable without shipping code: signals, log hygiene, metric naming and cardinality, trace context, SLO and error budget, burn-rate alerts. Use when adding logs, metrics or traces."
cluster: engineering
tier: root
---

# Observability

Done means someone can answer "why is this happening" in production without adding instrumentation or deploying first. If investigating requires a new log line, the service was not instrumented.

| When | Read |
|---|---|
| The number in the alert or the panel needs vetting | `~/.agents/skills/frontend-dashboard/SKILL.md` for panels; `~/.agents/skills/infra/references/cost-and-observability.md` for the cost of telemetry |
| The question is why a behaviour breaks rather than how to see it | `~/.agents/skills/debug/SKILL.md` |

## Four signals, and what each answers

| Signal | Answers |
|---|---|
| Trace | where did this request go, and which hop spent the time |
| Metric | how much, how often, how fast, over time |
| Log | what exactly happened in this one case |
| Baggage | which context must travel with all of the above |

Profiles are not a signal you can rely on yet. Logs are not second class: they carry the specific case that metrics only count.

## Start from the question, not from the instrument

Write the question the system must answer from the user's side ("the checkout page loads"), then the measurement that answers it, then the number that is unacceptable. That order gives an SLI, an SLO and an error budget. Instrumentation without a question produces dashboards nobody reads.

## Logs

- Structured, one event per line, stable field names.
- Never log: password, token, API key, full request body of an auth endpoint, personal identifiers (CPF, card, address), or an entire third-party payload.
- Level means severity, not importance: `info` for state changes an operator would want in a timeline, `warn` for something survived, `error` for something a human must act on.
- Always the identifiers that join it to a trace and to a user request: request id, trace id, tenant, job id.
- A log line without a consumer is noise. If nothing reads it, delete it.

## Metrics

- One unit and one quantity per metric. Never mix milliseconds with seconds or request size with request duration.
- Name: application prefix, base unit, unit suffix in plural (`request_duration_seconds`), `_total` for an accumulating counter.
- Labels describe the thing measured. Every unique combination is a new series, so label values must be bounded: status, route template, queue name, tenant tier. Never user id, email, URL with ids, or free text.
- Cardinality has a budget. Before adding a label, say how many values it can take and who pays for it.
- If `sum()` or `avg()` across the dimensions is meaningless, that is two metrics pretending to be one.

## Traces

- Propagate context across every outbound call, and put the trace id in logs so the two signals join.
- One span per meaningful operation, named by the operation rather than the function.
- Attributes are for search, so they must be bounded and free of personal data.

## Alerts

- Page on the symptom the user feels, ticket on the cause. An alert that pages without a runbook is a bug in the alert.
- Alert on the SLO with a burn rate over two windows: a short window detects, a long window prevents noise. A duration threshold (`for: 1h`) is not a window: it does not scale with severity, so a total outage and a small one alert at the same speed.
- Every alert states its four properties: how often it is right (precision), what it misses (recall), how fast it fires (detection), how long it keeps firing after the fix (reset).
- Dashboards follow questions that someone actually asks. A dashboard with no reader is a screenshot with a cost.
