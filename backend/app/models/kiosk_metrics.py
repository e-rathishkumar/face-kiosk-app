from datetime import datetime

from sqlalchemy import (
    ForeignKey,
    Float,
    Integer,
    DateTime
)

from sqlalchemy.orm import (
    Mapped,
    mapped_column
)

from app.database.base import Base
from app.database.base_model import BaseModel


class KioskMetrics(Base, BaseModel):
    __tablename__ = "kiosk_metrics"

    kiosk_id: Mapped[str] = mapped_column(
        ForeignKey("kiosks.id"),
        nullable=False
    )

    battery_level: Mapped[int | None] = mapped_column(
        Integer
    )

    cpu_usage: Mapped[float | None] = mapped_column(
        Float
    )

    memory_usage: Mapped[float | None] = mapped_column(
        Float
    )

    temperature: Mapped[float | None] = mapped_column(
        Float
    )

    storage_available: Mapped[float | None] = mapped_column(
        Float
    )

    network_strength: Mapped[int | None] = mapped_column(
        Integer
    )

    recorded_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False
    )
