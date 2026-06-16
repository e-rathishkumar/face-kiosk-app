from datetime import datetime
from uuid import UUID

from pydantic import BaseModel


class KioskHealthResponse(BaseModel):
    kiosk_id: UUID
    kiosk_name: str

    status: str

    battery_level: int | None = None
    cpu_usage: float | None = None
    memory_usage: float | None = None
    temperature: float | None = None

    active_alerts: int

    last_heartbeat: datetime | None = None

    class Config:
        from_attributes = True
