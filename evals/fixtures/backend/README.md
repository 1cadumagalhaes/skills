# Billing service eval fixture

This repository is a deliberately small eval fixture, not production code. It models a FastAPI billing service backed by PostgreSQL. The requested subscription-creation endpoint is not implemented yet; the schema has no added subscription column, and callers must design retry safety and transactional delivery before adding it.

The current database schema includes subscriptions and orders. Invoice work is published through an existing publisher call site to illustrate the current delivery boundary.