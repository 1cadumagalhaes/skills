from fastapi import FastAPI

from app.routes.avatar import router as avatar_router
from app.routes.signup import router as signup_router

app = FastAPI(title="Member API fixture")
app.include_router(avatar_router, prefix="/v1")
app.include_router(signup_router, prefix="/v1")


@app.get("/health/live")
def live() -> dict[str, str]:
    return {"status": "alive"}
