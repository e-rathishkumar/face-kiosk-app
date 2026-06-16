from typing import List
from uuid import UUID

from fastapi import APIRouter
from fastapi import Depends
from fastapi import HTTPException

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.report_schedule_schema import (
    ReportScheduleCreate,
    ReportScheduleResponse
)

from app.services.report_schedule_service import (
    ReportScheduleService
)

router = APIRouter(
    prefix="/report-schedules",
    tags=["Report Schedules"]
)


@router.post(
    "",
    response_model=ReportScheduleResponse
)
def create_schedule(
    request: ReportScheduleCreate,
    db: Session = Depends(get_db)
):
    return ReportScheduleService.create(
        db,
        report_type=request.report_type,
        frequency=request.frequency,
        email=request.email
    )


@router.get(
    "",
    response_model=List[ReportScheduleResponse]
)
def get_schedules(
    db: Session = Depends(get_db)
):
    return ReportScheduleService.get_all(
        db
    )


@router.patch(
    "/{schedule_id}/deactivate",
    response_model=ReportScheduleResponse
)
def deactivate_schedule(
    schedule_id: UUID,
    db: Session = Depends(get_db)
):
    schedule = (
        ReportScheduleService.deactivate(
            db,
            schedule_id
        )
    )

    if not schedule:
        raise HTTPException(
            status_code=404,
            detail="Schedule not found"
        )

    return schedule


@router.patch(
    "/{schedule_id}/activate",
    response_model=ReportScheduleResponse
)
def activate_schedule(
    schedule_id: UUID,
    db: Session = Depends(get_db)
):
    schedule = (
        ReportScheduleService.activate(
            db,
            schedule_id
        )
    )

    if not schedule:
        raise HTTPException(
            status_code=404,
            detail="Schedule not found"
        )

    return schedule
