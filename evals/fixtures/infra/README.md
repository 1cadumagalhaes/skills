# Ledgerline ingest worker eval fixture

This compact eval fixture is not production infrastructure. It models a fictional FastAPI worker on GKE Autopilot, deployed via GitHub Actions and Workload Identity Federation. No Dockerfile exists yet; the Deployment uses a fictional image and the eval asks for a hardened build. Project, registry and organization names are fake.

The workload starts at 4 replicas. A prior proposal raised this to 12; no live cluster data is included, so costs and actual usage must be measured.