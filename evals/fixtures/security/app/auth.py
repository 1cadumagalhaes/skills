from dataclasses import dataclass
from uuid import UUID

from fastapi import Header, HTTPException


@dataclass(frozen=True)
class Principal:
    user_id: UUID
    token_id: str


# Local eval tokens are explicitly synthetic and must never be used outside fixtures.
_FIXTURE_TOKENS = {
    "fixture-token-user-a": Principal(UUID("aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa"), "token-a"),
    "fixture-token-user-b": Principal(UUID("bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb"), "token-b"),
}


def require_principal(authorization: str = Header(...)) -> Principal:
    scheme, _, token = authorization.partition(" ")
    principal = _FIXTURE_TOKENS.get(token) if scheme.lower() == "bearer" else None
    if principal is None:
        raise HTTPException(status_code=401, detail="Invalid bearer token")
    return principal
