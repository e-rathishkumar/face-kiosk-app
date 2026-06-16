from typing import List

from fastapi import APIRouter
from fastapi import Depends

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.audit_schema import (
    AuditLogResponse
)

from app.services.audit_service import (
    AuditService
)

router = APIRouter(
    prefix="/audit-logs",
    tags=["Audit Logs"]
)


@router.get(
    "",
    response_model=List[AuditLogResponse]
)
def get_audit_logs(
    db: Session = Depends(get_db)
):
    return AuditService.get_all(
        db
    )


@router.get(
    "/{entity_type}",
    response_model=List[AuditLogResponse]
)
def get_entity_logs(
    entity_type: str,
    db: Session = Depends(get_db)
):
    return AuditService.get_entity_logs(
        db,
        entity_type
    )
