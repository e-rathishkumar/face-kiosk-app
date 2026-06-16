from typing import List

from fastapi import APIRouter
from fastapi import Depends
from fastapi import HTTPException

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.attendance_schema import (
    CheckInRequest,
    CheckOutRequest,
    AttendanceResponse
)

from app.services.attendance_service import (
    AttendanceService
)

router = APIRouter(
    prefix="/attendance",
    tags=["Attendance"]
)


@router.post(
    "/check-in",
    response_model=AttendanceResponse
)
def check_in(
    request: CheckInRequest,
    db: Session = Depends(get_db)
):
    return AttendanceService.check_in(
        db,
        request.employee_id,
        request.kiosk_id
    )


@router.post(
    "/check-out",
    response_model=AttendanceResponse
)
def check_out(
    request: CheckOutRequest,
    db: Session = Depends(get_db)
):
    session = (
        AttendanceService.check_out(
            db,
            request.employee_id
        )
    )

    if not session:
        raise HTTPException(
            status_code=404,
            detail="Active session not found"
        )

    return session


@router.get(
    "",
    response_model=List[
        AttendanceResponse
    ]
)
def get_attendance(
    db: Session = Depends(get_db)
):
    return AttendanceService.get_all(
        db
    )


@router.get(
    "/active",
    response_model=List[
        AttendanceResponse
    ]
)
def get_active_attendance(
    db: Session = Depends(get_db)
):
    return AttendanceService.get_active(
        db
    )


@router.get(
    "/employee/{employee_id}",
    response_model=List[
        AttendanceResponse
    ]
)
def get_employee_attendance(
    employee_id: str,
    db: Session = Depends(get_db)
):
    return (
        AttendanceService
        .get_employee_sessions(
            db,
            employee_id
        )
    )
