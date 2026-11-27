from fastapi import FastAPI

from app.api.health import router as health_router
from app.api.invoices import router as invoice_router
from internal.http.invoices.handlers import router as internal_invoice_router

app = FastAPI(title="Ledgerline Billing API", version="1.0")
app.include_router(health_router)
app.include_router(invoice_router, prefix="/v1")
app.include_router(internal_invoice_router)
