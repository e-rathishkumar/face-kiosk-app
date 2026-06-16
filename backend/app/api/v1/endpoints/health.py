from fastapi import APIRouter
from fastapi import Depends

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.health_schema import (
    KioskHealthResponse
)

from app.services.health_service import (
    HealthService
)


router = APIRouter(
    prefix="/health",
    tags=["Health"]
)


@router.get(
    "/kiosks",
    response_model=list[KioskHealthResponse]
)
def get_kiosk_health(
    db: Session = Depends(get_db)
):
    return HealthService.get_kiosk_health(
        db
    )
