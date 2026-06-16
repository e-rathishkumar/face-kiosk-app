from uuid import UUID
from datetime import datetime

from pydantic import BaseModel


class RecognitionLogResponse(BaseModel):
    id: UUID
    employee_id: UUID
    kiosk_id: UUID
    confidence_score: float
    event_time: datetime
    image_url: str | None = None

    class Config:
        from_attributes = True
