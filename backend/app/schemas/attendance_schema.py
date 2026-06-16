from uuid import UUID
from datetime import datetime

from pydantic import BaseModel


class CheckInRequest(BaseModel):
    employee_id: UUID
    kiosk_id: UUID


class CheckOutRequest(BaseModel):
    employee_id: UUID


class AttendanceResponse(BaseModel):
    id: UUID
    employee_id: UUID
    kiosk_id: UUID

    check_in_time: datetime
    check_out_time: datetime | None = None

    status: str

    class Config:
        from_attributes = True
