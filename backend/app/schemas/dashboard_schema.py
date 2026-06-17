from typing import List
from datetime import datetime
from pydantic import BaseModel


class DashboardSummaryResponse(BaseModel):
    total_employees: int
    active_attendance: int
    total_kiosks: int
    recognition_logs: int
    pending_unrecognized: int


class EmployeeDashboardSummaryResponse(BaseModel):
    present_today: int
    absent_today: int
    late_today: int
    present_dates: List[str]
    absent_dates: List[str]
    late_dates: List[str]
    total_hours_today: float


class ActivityResponse(BaseModel):
    id: str
    type: str
    timestamp: datetime
    status: str | None = None
