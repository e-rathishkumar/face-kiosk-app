from uuid import UUID
from datetime import datetime

from pydantic import BaseModel


class ReportScheduleCreate(BaseModel):
    report_type: str
    frequency: str
    email: str


class ReportScheduleResponse(BaseModel):
    id: UUID

    report_name: str
    frequency: str

    email_recipients: str

    is_active: bool

    last_run: datetime | None = None
    next_run: datetime | None = None

    class Config:
        from_attributes = True
