from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db import get_session
from app.models import Invoice
from app.tenant import current_tenant_id

router = APIRouter()


@router.get("/invoices/{invoice_id}")
def get_invoice(
    invoice_id: UUID,
    tenant_id: UUID = Depends(current_tenant_id),
    session: Session = Depends(get_session),
) -> dict[str, str]:
    statement = select(Invoice).where(
        Invoice.id == invoice_id, Invoice.tenant_id == tenant_id
    )
    invoice = session.scalar(statement)
    if invoice is None:
        raise HTTPException(status_code=404, detail="Invoice not found")
    return {"id": str(invoice.id), "status": invoice.status}
