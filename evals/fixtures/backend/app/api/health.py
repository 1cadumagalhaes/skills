from fastapi import APIRouter

router = APIRouter()


@router.get("/health/live")
def liveness() -> dict[str, str]:
    return {"status": "alive"}


@router.get("/health/ready")
def readiness() -> dict[str, str]:
    # Deployment wiring replaces this lightweight check with a DB ping.
    return {"status": "ready"}
