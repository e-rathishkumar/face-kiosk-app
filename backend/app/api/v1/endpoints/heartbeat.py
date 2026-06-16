from typing import List
from uuid import UUID

from fastapi import APIRouter
from fastapi import Depends

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.heartbeat_schema import (
    HeartbeatCreate,
    HeartbeatResponse
)

from app.services.heartbeat_service import (
    HeartbeatService
)

router = APIRouter(
    prefix="/heartbeat",
    tags=["Heartbeat"]
)


@router.post(
    "",
    response_model=HeartbeatResponse
)
def create_heartbeat(
    request: HeartbeatCreate,
    db: Session = Depends(get_db)
):
    return HeartbeatService.create_heartbeat(
        db,
        request
    )


@router.get(
    "",
    response_model=List[HeartbeatResponse]
)
def get_heartbeats(
    db: Session = Depends(get_db)
):
    return HeartbeatService.get_all(db)


@router.get(
    "/{kiosk_id}",
    response_model=List[HeartbeatResponse]
)
def get_kiosk_heartbeats(
    kiosk_id: UUID,
    db: Session = Depends(get_db)
):
    return HeartbeatService.get_kiosk_heartbeats(
        db,
        kiosk_id
    )
