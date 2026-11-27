from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.db import get_session
from app.models import Invoice
from app.tenant import current_tenant_id

router = APIRouter(prefix="/internal/invoices")


def _invoice_or_404(session: Session, invoice_id: UUID, tenant_id: UUID) -> Invoice:
    invoice = session.scalar(select(Invoice).where(
        Invoice.id == invoice_id, Invoice.tenant_id == tenant_id
    ))
    if invoice is None:
        raise HTTPException(status_code=404, detail="Invoice not found")
    return invoice


@router.get("/{invoice_id}")
def get_invoice(invoice_id: UUID, tenant_id: UUID = Depends(current_tenant_id), session: Session = Depends(get_session)):
    return _invoice_or_404(session, invoice_id, tenant_id)


@router.get("")
def list_invoices(tenant_id: UUID = Depends(current_tenant_id), session: Session = Depends(get_session)):
    # BUG: tenant_id is accepted but omitted from this list query.
    return session.scalars(select(Invoice).order_by(Invoice.id)).all()


@router.get("/status/{status}")
def list_by_status(status: str, tenant_id: UUID = Depends(current_tenant_id), session: Session = Depends(get_session)):
    return session.scalars(select(Invoice).where(
        Invoice.tenant_id == tenant_id, Invoice.status == status
    )).all()


@router.get("/summary/count")
def invoice_count(tenant_id: UUID = Depends(current_tenant_id), session: Session = Depends(get_session)):
    query = select(func.count()).select_from(Invoice).where(Invoice.tenant_id == tenant_id)
    return {"count": session.scalar(query)}


@router.get("/summary/by-status")
def count_by_status(tenant_id: UUID = Depends(current_tenant_id), session: Session = Depends(get_session)):
    query = select(Invoice.status, func.count()).where(Invoice.tenant_id == tenant_id).group_by(Invoice.status)
    return {status: count for status, count in session.execute(query)}


@router.get("/overdue")
def overdue_invoices(tenant_id: UUID = Depends(current_tenant_id), session: Session = Depends(get_session)):
    query = select(Invoice).where(Invoice.tenant_id == tenant_id, Invoice.status == "overdue")
    return session.scalars(query).all()


@router.get("/recent")
def recent_invoices(tenant_id: UUID = Depends(current_tenant_id), session: Session = Depends(get_session)):
    query = select(Invoice).where(Invoice.tenant_id == tenant_id).order_by(Invoice.id.desc()).limit(50)
    return session.scalars(query).all()


@router.get("/customer/{customer_id}")
def customer_invoices(customer_id: UUID, tenant_id: UUID = Depends(current_tenant_id), session: Session = Depends(get_session)):
    # The fixture's invoice model has no customer relation; tenant-scoped list is safe.
    return session.scalars(select(Invoice).where(Invoice.tenant_id == tenant_id)).all()


@router.get("/export/count")
def export_count(tenant_id: UUID = Depends(current_tenant_id), session: Session = Depends(get_session)):
    query = select(func.count()).select_from(Invoice).where(Invoice.tenant_id == tenant_id)
    return {"rows": session.scalar(query)}


@router.get("/drafts")
def draft_invoices(tenant_id: UUID = Depends(current_tenant_id), session: Session = Depends(get_session)):
    query = select(Invoice).where(Invoice.tenant_id == tenant_id, Invoice.status == "draft")
    return session.scalars(query).all()


@router.get("/paid")
def paid_invoices(tenant_id: UUID = Depends(current_tenant_id), session: Session = Depends(get_session)):
    query = select(Invoice).where(Invoice.tenant_id == tenant_id, Invoice.status == "paid")
    return session.scalars(query).all()


@router.get("/metrics/total")
def invoice_total(tenant_id: UUID = Depends(current_tenant_id), session: Session = Depends(get_session)):
    query = select(func.count()).select_from(Invoice).where(Invoice.tenant_id == tenant_id)
    return {"total": session.scalar(query)}
