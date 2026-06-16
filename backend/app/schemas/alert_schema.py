from uuid import UUID
from datetime import datetime

from pydantic import BaseModel

from app.core.enums import (
    AlertType,
    AlertSeverity
)


class AlertCreate(BaseModel):
    kiosk_id: UUID
    alert_type: AlertType
    severity: AlertSeverity
    message: str


class AlertResolveRequest(BaseModel):
    resolved_by: UUID | None = None


class AlertResponse(BaseModel):
    id: UUID
    kiosk_id: UUID
    alert_type: AlertType
    severity: AlertSeverity
    message: str
    is_resolved: bool
    resolved_by: UUID | None = None
    resolved_at: datetime | None = None

    class Config:
        from_attributes = True
