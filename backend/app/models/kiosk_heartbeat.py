from datetime import datetime

from sqlalchemy import ForeignKey
from sqlalchemy import Integer
from sqlalchemy import Float
from sqlalchemy import String
from sqlalchemy import DateTime

from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column

from app.database.base import Base
from app.database.base_model import BaseModel


class KioskHeartbeat(Base, BaseModel):
    __tablename__ = "kiosk_heartbeats"

    kiosk_id: Mapped[str] = mapped_column(
        ForeignKey("kiosks.id"),
        nullable=False
    )

    battery_level: Mapped[int | None] = mapped_column(Integer)
    cpu_usage: Mapped[float | None] = mapped_column(Float)
    memory_usage: Mapped[float | None] = mapped_column(Float)
    temperature: Mapped[float | None] = mapped_column(Float)

    storage_total: Mapped[float | None] = mapped_column(Float)
    storage_available: Mapped[float | None] = mapped_column(Float)

    network_strength: Mapped[int | None] = mapped_column(Integer)

    device_model: Mapped[str | None] = mapped_column(
        String(255)
    )

    app_version: Mapped[str | None] = mapped_column(
        String(50)
    )

    heartbeat_time: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False
    )
