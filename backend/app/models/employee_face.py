from sqlalchemy import (
    String,
    ForeignKey,
    Integer,
    Enum
)

from sqlalchemy.orm import (
    Mapped,
    mapped_column
)

from pgvector.sqlalchemy import Vector

from app.database.base import Base
from app.database.base_model import BaseModel
from app.core.enums import FacePose


class EmployeeFace(Base, BaseModel):
    __tablename__ = "employee_faces"

    employee_id: Mapped[str] = mapped_column(
        ForeignKey("employees.id"),
        nullable=False
    )

    embedding: Mapped[list[float]] = mapped_column(
        Vector(512),
        nullable=False
    )

    image_url: Mapped[str] = mapped_column(
        String(500),
        nullable=False
    )

    pose: Mapped[FacePose] = mapped_column(
        Enum(FacePose),
        nullable=False
    )

    version: Mapped[int] = mapped_column(
        Integer,
        default=1
    )
