from pydantic import BaseModel, EmailStr
from fastapi import APIRouter, HTTPException, status

from app.logging import log_event

router = APIRouter()


class SignupRequest(BaseModel):
    email: EmailStr
    password: str
    cpf: str
    display_name: str


@router.post("/signup", status_code=status.HTTP_201_CREATED)
def signup(body: SignupRequest) -> dict[str, str]:
    if len(body.password) < 12:
        log_event("signup_rejected", {"request": body.model_dump()})
        raise HTTPException(status_code=422, detail="password_policy_failed")
    # Fixture avoids a real user database; return only a synthetic result.
    log_event("signup_accepted", {"request": body.model_dump()})
    return {"status": "accepted", "user_ref": "fixture-user-001"}
