from typing import List

from fastapi import APIRouter
from fastapi import Depends

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.recognition_log_schema import (
    RecognitionLogResponse
)

from app.services.recognition_log_service import (
    RecognitionLogService
)

router = APIRouter(
    prefix="/recognition-logs",
    tags=["Recognition Logs"]
)


@router.get(
    "",
    response_model=List[RecognitionLogResponse]
)
def get_logs(
    db: Session = Depends(get_db)
):
    return RecognitionLogService.get_all_logs(
        db
    )


@router.get(
    "/{employee_id}",
    response_model=List[RecognitionLogResponse]
)
def get_employee_logs(
    employee_id: str,
    db: Session = Depends(get_db)
):
    return RecognitionLogService.get_employee_logs(
        db,
        employee_id
    )
