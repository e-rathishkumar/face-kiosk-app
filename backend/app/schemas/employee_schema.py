from uuid import UUID
from datetime import date

from pydantic import BaseModel


class EmployeeCreate(BaseModel):
    employee_code: str
    first_name: str
    last_name: str
    email: str | None = None
    phone: str | None = None
    department: str | None = None
    designation: str | None = None
    joining_date: date | None = None


class EmployeeUpdate(BaseModel):
    first_name: str
    last_name: str
    email: str | None = None
    phone: str | None = None
    department: str | None = None
    designation: str | None = None


class EmployeeResponse(BaseModel):
    id: UUID
    employee_code: str
    first_name: str
    last_name: str
    email: str | None = None
    phone: str | None = None
    department: str | None = None
    designation: str | None = None
    is_active: bool

    class Config:
        from_attributes = True
