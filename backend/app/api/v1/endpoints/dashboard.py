from fastapi import APIRouter
from fastapi import Depends

from sqlalchemy.orm import Session

from app.database.session import get_db

from typing import List
from app.schemas.dashboard_schema import (
    DashboardSummaryResponse,
    EmployeeDashboardSummaryResponse,
    ActivityResponse
)

from app.services.dashboard_service import (
    DashboardService
)

router = APIRouter(
    prefix="/dashboard",
    tags=["Dashboard"]
)


@router.get(
    "/summary",
    response_model=DashboardSummaryResponse
)
def get_dashboard_summary(
    db: Session = Depends(get_db)
):
    return DashboardService.get_summary(
        db
    )


@router.get(
    "/employee/{employee_id}",
    response_model=EmployeeDashboardSummaryResponse
)
def get_employee_dashboard(
    employee_id: str,
    db: Session = Depends(get_db)
):
    return DashboardService.get_employee_summary(
        db, employee_id
    )


@router.get(
    "/employee/{employee_id}/activities",
    response_model=List[ActivityResponse]
)
def get_employee_activities(
    employee_id: str,
    db: Session = Depends(get_db)
):
    return DashboardService.get_employee_activities(
        db, employee_id
    )
