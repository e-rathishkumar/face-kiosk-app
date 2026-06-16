from uuid import UUID
from datetime import datetime

from pydantic import BaseModel


class HeartbeatCreate(BaseModel):
    kiosk_id: UUID

    battery_level: int | None = None
    cpu_usage: float | None = None
    memory_usage: float | None = None
    temperature: float | None = None

    storage_total: float | None = None
    storage_available: float | None = None

    network_strength: int | None = None

    device_model: str | None = None
    app_version: str | None = None


class HeartbeatResponse(BaseModel):
    id: UUID

    kiosk_id: UUID

    battery_level: int | None = None
    cpu_usage: float | None = None
    memory_usage: float | None = None
    temperature: float | None = None

    storage_total: float | None = None
    storage_available: float | None = None

    network_strength: int | None = None

    device_model: str | None = None
    app_version: str | None = None

    heartbeat_time: datetime

    class Config:
        from_attributes = True
