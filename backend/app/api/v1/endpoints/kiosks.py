from typing import List

from fastapi import APIRouter
from fastapi import Depends
from fastapi import HTTPException

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.kiosk_schema import (
    KioskCreate,
    KioskUpdate,
    KioskResponse
)

from app.services.kiosk_service import (
    KioskService
)

router = APIRouter(
    prefix="/kiosks",
    tags=["Kiosks"]
)


@router.post(
    "",
    response_model=KioskResponse
)
def create_kiosk(
    request: KioskCreate,
    db: Session = Depends(get_db)
):
    return KioskService.create_kiosk(
        db,
        request
    )


@router.get(
    "",
    response_model=List[KioskResponse]
)
def get_kiosks(
    db: Session = Depends(get_db)
):
    return KioskService.get_all_kiosks(
        db
    )


@router.get(
    "/{kiosk_id}",
    response_model=KioskResponse
)
def get_kiosk(
    kiosk_id: str,
    db: Session = Depends(get_db)
):
    kiosk = (
        KioskService.get_kiosk(
            db,
            kiosk_id
        )
    )

    if not kiosk:
        raise HTTPException(
            status_code=404,
            detail="Kiosk not found"
        )

    return kiosk


@router.put(
    "/{kiosk_id}",
    response_model=KioskResponse
)
def update_kiosk(
    kiosk_id: str,
    request: KioskUpdate,
    db: Session = Depends(get_db)
):
    kiosk = (
        KioskService.update_kiosk(
            db,
            kiosk_id,
            request
        )
    )

    if not kiosk:
        raise HTTPException(
            status_code=404,
            detail="Kiosk not found"
        )

    return kiosk


@router.patch(
    "/{kiosk_id}/deactivate",
    response_model=KioskResponse
)
def deactivate_kiosk(
    kiosk_id: str,
    db: Session = Depends(get_db)
):
    kiosk = (
        KioskService.deactivate_kiosk(
            db,
            kiosk_id
        )
    )

    if not kiosk:
        raise HTTPException(
            status_code=404,
            detail="Kiosk not found"
        )

    return kiosk
