from datetime import datetime

from sqlalchemy import String
from sqlalchemy import DateTime

from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column

from app.database.base import Base
from app.database.base_model import BaseModel


class ReportHistory(Base, BaseModel):
    __tablename__ = "report_history"

    report_name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )

    generated_by: Mapped[str | None] = mapped_column(
        String(100)
    )

    file_url: Mapped[str] = mapped_column(
        String(500),
        nullable=False
    )

    generated_at: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False
    )
