from uuid import UUID
from datetime import datetime

from pydantic import BaseModel

from app.core.enums import (
    UnrecognizedStatus
)


class UnrecognizedStatusUpdate(BaseModel):
    status: UnrecognizedStatus


class UnrecognizedResponse(BaseModel):
    id: UUID
    kiosk_id: UUID
    image_url: str
    face_crop_url: str
    confidence_score: float | None = None
    status: UnrecognizedStatus
    reviewed_by: UUID | None = None
    reviewed_at: datetime | None = None
    remarks: str | None = None

    class Config:
        from_attributes = True
