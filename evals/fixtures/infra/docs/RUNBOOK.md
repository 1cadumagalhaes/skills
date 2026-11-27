# Ingest worker runbook

Fixture documentation, not production operational guidance.

## Deploy and rollback

1. Merge a reviewed change to main; the protected production workflow applies the reviewed plan with GitHub OIDC. No service-account JSON key is used.
2. Check kubectl -n analytics rollout status deployment/api-gateway and probe events.
3. Roll back with kubectl -n analytics rollout undo deployment/api-gateway, then verify the prior ReplicaSet becomes ready.

## Cost and capacity

The fixture starts at 4 replicas and requests 500m CPU / 512Mi. A 12-replica setting triples requested CPU and memory; this alone does not establish billed cost. In Autopilot, collect kubectl top pods -n analytics and compare usage to requests, then use the regional price sheet and billing export. Check owner labels.

## Health

Boot can take about 40 seconds. Startup probe budget is 12 x 5 seconds (60s); readiness gates traffic, and liveness begins only after startup succeeds.
