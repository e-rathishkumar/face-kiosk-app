from datetime import datetime

from sqlalchemy import String
from sqlalchemy import Boolean
from sqlalchemy import DateTime

from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column

from app.database.base import Base
from app.database.base_model import BaseModel


class ReportSchedule(Base, BaseModel):
    __tablename__ = "report_schedules"

    report_name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )

    frequency: Mapped[str] = mapped_column(
        String(50),
        nullable=False
    )

    email_recipients: Mapped[str] = mapped_column(
        String(1000),
        nullable=False
    )

    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True
    )

    last_run: Mapped[datetime | None] = mapped_column(
        DateTime
    )

    next_run: Mapped[datetime | None] = mapped_column(
        DateTime
    )
