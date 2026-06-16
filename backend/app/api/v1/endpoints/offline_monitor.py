from fastapi import APIRouter
from fastapi import Depends

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.offline_monitor_schema import (
    OfflineMonitorResponse
)

from app.services.offline_monitor_service import (
    OfflineMonitorService
)


router = APIRouter(
    prefix="/offline-monitor",
    tags=["Offline Monitor"]
)


@router.post(
    "/run",
    response_model=OfflineMonitorResponse
)
def run_monitor(
    db: Session = Depends(get_db)
):
    return OfflineMonitorService.run(
        db
    )
