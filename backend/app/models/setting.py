from sqlalchemy import String
from sqlalchemy.orm import Mapped
from sqlalchemy.orm import mapped_column

from app.database.base import Base
from app.database.base_model import BaseModel


class Setting(Base, BaseModel):
    __tablename__ = "settings"

    setting_key: Mapped[str] = mapped_column(
        String(100),
        unique=True,
        nullable=False
    )

    setting_value: Mapped[str] = mapped_column(
        String(500),
        nullable=False
    )

    updated_by: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True
    )
