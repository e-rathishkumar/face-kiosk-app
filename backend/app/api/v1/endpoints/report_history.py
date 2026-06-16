from typing import List

from fastapi import APIRouter
from fastapi import Depends

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.report_history_schema import (
    ReportHistoryResponse
)

from app.services.report_history_service import (
    ReportHistoryService
)

router = APIRouter(
    prefix="/report-history",
    tags=["Report History"]
)


@router.get(
    "",
    response_model=List[
        ReportHistoryResponse
    ]
)
def get_report_history(
    db: Session = Depends(get_db)
):
    return (
        ReportHistoryService.get_all(
            db
        )
    )
