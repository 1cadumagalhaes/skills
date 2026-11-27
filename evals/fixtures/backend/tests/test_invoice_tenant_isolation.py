from uuid import uuid4

from sqlalchemy import create_engine
from sqlalchemy.orm import Session

from app.models import Base, Invoice
from internal.http.invoices.handlers import list_invoices


def test_list_invoices_does_not_return_another_tenants_rows():
    """Known failing regression case: tenant B must not see tenant A's invoice."""
    engine = create_engine("sqlite://")
    Base.metadata.create_all(engine)
    tenant_a, tenant_b = uuid4(), uuid4()
    with Session(engine) as session:
        invoice_a = Invoice(tenant_id=tenant_a, status="draft")
        session.add(invoice_a)
        session.commit()
        result = list_invoices(tenant_id=tenant_b, session=session)
        assert all(row.tenant_id == tenant_b for row in result)
