from uuid import UUID

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile

from app.auth import Principal, require_principal
from app.storage import store_avatar

router = APIRouter()


@router.post("/me/avatar")
async def upload_avatar(
    file: UploadFile = File(...),
    principal: Principal = Depends(require_principal),
) -> dict[str, str]:
    # Current implementation trusts the client media type and filename.
    if not (file.content_type or "").startswith("image/"):
        raise HTTPException(status_code=415, detail="Image upload required")
    contents = await file.read()
    if not contents:
        raise HTTPException(status_code=400, detail="Empty avatar")
    # Object ownership is passed down but key construction still uses user input.
    url = store_avatar(principal.user_id, file.filename or "avatar", contents)
    return {"user_id": str(principal.user_id), "url": url}
