from datetime import datetime

from sqlalchemy import ForeignKey
from sqlalchemy import String
from sqlalchemy import Float
from sqlalchemy import DateTime
from sqlalchemy import Enum

from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column

from app.database.base import Base
from app.database.base_model import BaseModel

from app.core.enums import UnrecognizedStatus


class UnrecognizedEntry(Base, BaseModel):
    __tablename__ = "unrecognized_entries"

    kiosk_id: Mapped[str] = mapped_column(
        ForeignKey("kiosks.id"),
        nullable=False
    )

    image_url: Mapped[str] = mapped_column(
        String(500),
        nullable=False
    )

    face_crop_url: Mapped[str] = mapped_column(
        String(500),
        nullable=False
    )

    confidence_score: Mapped[float | None] = mapped_column(
        Float,
        nullable=True
    )

    status: Mapped[UnrecognizedStatus] = mapped_column(
        Enum(UnrecognizedStatus),
        nullable=False
    )

    reviewed_by: Mapped[str | None] = mapped_column(
        ForeignKey("users.id"),
        nullable=True
    )

    reviewed_at: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True
    )

    remarks: Mapped[str | None] = mapped_column(
        String(500),
        nullable=True
    )
