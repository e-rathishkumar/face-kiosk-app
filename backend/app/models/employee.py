from datetime import date

from sqlalchemy import String, Boolean, Date
from sqlalchemy.orm import Mapped, mapped_column

from app.database.base import Base
from app.database.base_model import BaseModel


class Employee(Base, BaseModel):
    __tablename__ = "employees"

    employee_code: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        nullable=False
    )

    first_name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )

    last_name: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )

    email: Mapped[str | None] = mapped_column(
        String(255),
        nullable=True
    )

    phone: Mapped[str | None] = mapped_column(
        String(30),
        nullable=True
    )

    department: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True
    )

    designation: Mapped[str | None] = mapped_column(
        String(100),
        nullable=True
    )

    joining_date: Mapped[date | None] = mapped_column(
        Date,
        nullable=True
    )

    is_active: Mapped[bool] = mapped_column(
        Boolean,
        default=True
    )
