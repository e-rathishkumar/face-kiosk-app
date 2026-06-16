from fastapi import APIRouter
from fastapi import Depends

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.report_schema import (
    AttendanceReportResponse,
    RecognitionReportResponse,
    UnrecognizedReportResponse,
    DashboardReportResponse
)

from app.services.report_service import (
    ReportService
)

router = APIRouter(
    prefix="/reports",
    tags=["Reports"]
)


@router.get(
    "/attendance",
    response_model=AttendanceReportResponse
)
def attendance_report(
    db: Session = Depends(get_db)
):
    return ReportService.attendance_report(
        db
    )


@router.get(
    "/recognition",
    response_model=RecognitionReportResponse
)
def recognition_report(
    db: Session = Depends(get_db)
):
    return ReportService.recognition_report(
        db
    )


@router.get(
    "/unrecognized",
    response_model=UnrecognizedReportResponse
)
def unrecognized_report(
    db: Session = Depends(get_db)
):
    return ReportService.unrecognized_report(
        db
    )


@router.get(
    "/dashboard",
    response_model=DashboardReportResponse
)
def dashboard_report(
    db: Session = Depends(get_db)
):
    return ReportService.dashboard_report(
        db
    )
