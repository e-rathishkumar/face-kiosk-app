from pydantic import BaseModel
from uuid import UUID


class KioskCreate(BaseModel):
    kiosk_code: str
    name: str
    location: str | None = None
    secret_key: str


class KioskUpdate(BaseModel):
    name: str
    location: str | None = None
    is_active: bool


class KioskResponse(BaseModel):
    id: UUID

    kiosk_code: str
    name: str
    location: str | None = None

    secret_key: str
    is_active: bool

    class Config:
        from_attributes = True
