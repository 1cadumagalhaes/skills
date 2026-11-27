from uuid import uuid4

from sqlalchemy import create_engine, select
from sqlalchemy.orm import Session

from app.models import Base, Subscription


def test_subscription_natural_key_is_tenant_scoped():
    engine = create_engine("sqlite://")
    Base.metadata.create_all(engine)
    tenant_a, tenant_b = uuid4(), uuid4()
    with Session(engine) as session:
        session.add(Subscription(tenant_id=tenant_a, external_ref="customer-42", plan_code="basic"))
        session.commit()
        assert session.scalar(select(Subscription).where(
            Subscription.tenant_id == tenant_a, Subscription.external_ref == "customer-42"
        )) is not None
        assert session.scalar(select(Subscription).where(
            Subscription.tenant_id == tenant_b, Subscription.external_ref == "customer-42"
        )) is None
