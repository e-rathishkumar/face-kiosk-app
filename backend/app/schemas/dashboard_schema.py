from pydantic import BaseModel


class DashboardSummaryResponse(BaseModel):
    total_employees: int
    active_attendance: int
    total_kiosks: int
    recognition_logs: int
    pending_unrecognized: int
