from uuid import UUID
from pydantic import BaseModel

from app.core.enums import FacePose


class FaceRegistrationRequest(BaseModel):
    employee_id: UUID
    image_url: str
    pose: FacePose


class FaceRegistrationResponse(BaseModel):
    id: UUID
    employee_id: UUID
    image_url: str
    pose: FacePose

    class Config:
        from_attributes = True
