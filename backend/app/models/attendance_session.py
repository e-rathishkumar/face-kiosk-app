from datetime import datetime

from sqlalchemy import ForeignKey, DateTime, Enum

from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base
from app.database.base_model import BaseModel

from app.core.enums import AttendanceStatus
from app.core.enums import CheckoutType


class AttendanceSession(Base, BaseModel):
    __tablename__ = "attendance_sessions"

    employee_id: Mapped[str] = mapped_column(
        ForeignKey("employees.id"),
        nullable=False
    )

    kiosk_id: Mapped[str] = mapped_column(
        ForeignKey("kiosks.id"),
        nullable=False
    )

    check_in_time: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False
    )

    check_out_time: Mapped[datetime | None] = mapped_column(
        DateTime,
        nullable=True
    )

    checkout_type: Mapped[CheckoutType | None] = mapped_column(
        Enum(CheckoutType),
        nullable=True
    )

    status: Mapped[AttendanceStatus] = mapped_column(
        Enum(AttendanceStatus),
        nullable=False
    )
