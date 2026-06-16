from typing import List

from fastapi import (
    APIRouter,
    Depends
)

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.unrecognized_schema import (
    UnrecognizedResponse,
    UnrecognizedStatusUpdate
)

from app.services.unrecognized_service import (
    UnrecognizedService
)

router = APIRouter(
    prefix="/unrecognized",
    tags=["Unrecognized"]
)


@router.get(
    "",
    response_model=List[UnrecognizedResponse]
)
def get_unrecognized_entries(
    db: Session = Depends(get_db)
):
    return UnrecognizedService.get_all_entries(
        db
    )


@router.patch(
    "/{entry_id}/status",
    response_model=UnrecognizedResponse
)
def update_status(
    entry_id: str,
    request: UnrecognizedStatusUpdate,
    db: Session = Depends(get_db)
):
    return UnrecognizedService.update_status(
        db,
        entry_id,
        request.status
    )
