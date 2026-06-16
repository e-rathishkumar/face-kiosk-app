from fastapi import APIRouter
from fastapi import Depends
from fastapi import HTTPException
from fastapi import Request

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.auth_schema import (
    LoginRequest,
    LoginResponse,
    ResetPasswordRequest
)

from app.services.auth_service import AuthService

from app.repositories.user_repository import UserRepository
from app.utils.password_helper import verify_password, hash_password
from app.utils.jwt_helper import decode_token


router = APIRouter(
    prefix="/auth",
    tags=["Authentication"]
)


@router.post(
    "/login",
    response_model=LoginResponse
)
def login(
    request: LoginRequest,
    db: Session = Depends(get_db)
):
    result = AuthService.login(
        db,
        request.username,
        request.password
    )

    if not result:
        raise HTTPException(
            status_code=401,
            detail="Invalid credentials"
        )

    return result


@router.post("/reset-password")
def reset_password(
    request: ResetPasswordRequest,
    req: Request,
    db: Session = Depends(get_db)
):
    # Extract user from Authorization header
    auth_header = req.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Not authenticated")

    token = auth_header.split(" ")[1]
    payload = decode_token(token)
    if not payload:
        raise HTTPException(status_code=401, detail="Invalid token")

    user_id = payload.get("sub")
    user = db.query(
        __import__('app.models.user', fromlist=['User']).User
    ).filter_by(id=user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if not verify_password(request.old_password, user.password_hash):
        raise HTTPException(
            status_code=400,
            detail="Current password is incorrect"
        )

    user.password_hash = hash_password(request.new_password)
    user.must_reset_password = False
    db.commit()

    return {"message": "Password updated successfully"}
