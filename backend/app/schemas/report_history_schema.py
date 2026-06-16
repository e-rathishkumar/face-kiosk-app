from uuid import UUID
from datetime import datetime

from pydantic import BaseModel


class ReportHistoryResponse(BaseModel):

    id: UUID

    report_name: str

    generated_by: str | None = None

    file_url: str

    generated_at: datetime

    class Config:
        from_attributes = True
