from fastapi import APIRouter
from fastapi import Depends

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.report_scheduler_schema import (
    ReportSchedulerResponse
)

from app.services.audit_service import (
    AuditService
)

from app.services.report_scheduler_service import (
    ReportSchedulerService
)

router = APIRouter(
    prefix="/report-scheduler",
    tags=["Report Scheduler"]
)


@router.post(
    "/run",
    summary="Run Scheduled Reports",
    response_model=ReportSchedulerResponse
)
def run_scheduler(
    db: Session = Depends(get_db)
):
    result = (
        ReportSchedulerService.run_pending(
            db
        )
    )

    AuditService.log(
        db=db,
        action="RUN",
        entity_type="REPORT_SCHEDULER",
        entity_id="manual",
        new_value=str(result)
    )

    return result
