from pydantic import BaseModel


class AttendanceReportResponse(BaseModel):
    total_sessions: int
    active_sessions: int
    completed_sessions: int


class RecognitionReportResponse(BaseModel):
    total_recognitions: int


class UnrecognizedReportResponse(BaseModel):
    total_unrecognized: int
    pending_unrecognized: int


class DashboardReportResponse(BaseModel):
    total_employees: int
    active_attendance: int
    total_kiosks: int
    recognition_logs: int
    pending_unrecognized: int
