from datetime import datetime

from sqlalchemy import ForeignKey
from sqlalchemy import Boolean
from sqlalchemy import String
from sqlalchemy import DateTime
from sqlalchemy import Enum

from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column

from app.database.base import Base
from app.database.base_model import BaseModel

from app.core.enums import AlertType
from app.core.enums import AlertSeverity


class KioskAlert(Base, BaseModel):
    __tablename__ = "kiosk_alerts"

    kiosk_id: Mapped[str] = mapped_column(
        ForeignKey("kiosks.id"),
        nullable=False
    )

    alert_type: Mapped[AlertType] = mapped_column(
        Enum(AlertType),
        nullable=False
    )

    severity: Mapped[AlertSeverity] = mapped_column(
        Enum(AlertSeverity),
        nullable=False
    )

    message: Mapped[str] = mapped_column(
        String(500),
        nullable=False
    )

    is_resolved: Mapped[bool] = mapped_column(
        Boolean,
        default=False
    )

    resolved_by: Mapped[str | None] = mapped_column(
        ForeignKey("users.id"),
        nullable=True
    )

    resolved_at: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True
    )
