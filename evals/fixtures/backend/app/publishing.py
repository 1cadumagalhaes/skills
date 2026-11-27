from concurrent.futures import TimeoutError as PublishTimeout
from uuid import UUID

from google.cloud import pubsub_v1

PROJECT_ID = "demo-billing-project"
INVOICE_TOPIC = "invoice-work"
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(PROJECT_ID, INVOICE_TOPIC)


def publish_invoice_created(invoice_id: UUID, tenant_id: UUID) -> str:
    """Publish an invoice event; callers currently wait synchronously."""
    future = publisher.publish(
        topic_path,
        event_type="invoice.created",
        invoice_id=str(invoice_id),
        tenant_id=str(tenant_id),
    )
    try:
        return future.result(timeout=5.0)
    except PublishTimeout as exc:
        raise RuntimeError("Invoice event publish timed out") from exc
