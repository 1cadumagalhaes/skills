Add POST /v1/subscriptions to the billing service. Clients may retry, we persist in Postgres, and the invoice worker picks it up from Pub/Sub.
