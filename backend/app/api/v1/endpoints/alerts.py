from typing import List

from fastapi import APIRouter
from fastapi import Depends

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.alert_schema import (
    AlertCreate,
    AlertResolveRequest,
    AlertResponse
)

from app.services.alert_service import (
    AlertService
)

router = APIRouter(
    prefix="/alerts",
    tags=["Alerts"]
)


@router.post(
    "",
    response_model=AlertResponse
)
def create_alert(
    request: AlertCreate,
    db: Session = Depends(get_db)
):
    return AlertService.create_alert(
        db,
        request
    )


@router.get(
    "",
    response_model=List[AlertResponse]
)
def get_alerts(
    db: Session = Depends(get_db)
):
    return AlertService.get_all_alerts(
        db
    )


@router.get(
    "/active",
    response_model=List[AlertResponse]
)
def get_active_alerts(
    db: Session = Depends(get_db)
):
    return AlertService.get_active_alerts(
        db
    )


@router.patch(
    "/{alert_id}/resolve",
    response_model=AlertResponse
)
def resolve_alert(
    alert_id: str,
    request: AlertResolveRequest,
    db: Session = Depends(get_db)
):
    return AlertService.resolve_alert(
        db,
        alert_id,
        request.resolved_by
    )
