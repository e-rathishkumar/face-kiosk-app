from datetime import datetime

from sqlalchemy import ForeignKey, Float, String, DateTime

from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base
from app.database.base_model import BaseModel


class RecognitionLog(Base, BaseModel):
    __tablename__ = "recognition_logs"

    employee_id: Mapped[str] = mapped_column(
        ForeignKey("employees.id"),
        nullable=False
    )

    kiosk_id: Mapped[str] = mapped_column(
        ForeignKey("kiosks.id"),
        nullable=False
    )

    confidence_score: Mapped[float] = mapped_column(
        Float,
        nullable=False
    )

    event_time: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False
    )

    image_url: Mapped[str | None] = mapped_column(
        String(500),
        nullable=True
    )
