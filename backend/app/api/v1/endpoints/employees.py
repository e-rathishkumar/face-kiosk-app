from typing import List

from fastapi import APIRouter
from fastapi import Depends
from fastapi import HTTPException

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.employee_schema import (
    EmployeeCreate,
    EmployeeUpdate,
    EmployeeResponse
)

from app.services.employee_service import (
    EmployeeService
)

router = APIRouter(
    prefix="/employees",
    tags=["Employees"]
)


@router.post(
    "",
    response_model=EmployeeResponse
)
def create_employee(
    request: EmployeeCreate,
    db: Session = Depends(get_db)
):
    return EmployeeService.create_employee(
        db,
        request
    )


@router.get(
    "",
    response_model=List[EmployeeResponse]
)
def get_employees(
    db: Session = Depends(get_db)
):
    return EmployeeService.get_all_employees(
        db
    )


@router.get(
    "/{employee_id}",
    response_model=EmployeeResponse
)
def get_employee(
    employee_id: str,
    db: Session = Depends(get_db)
):
    employee = (
        EmployeeService.get_employee(
            db,
            employee_id
        )
    )

    if not employee:
        raise HTTPException(
            status_code=404,
            detail="Employee not found"
        )

    return employee


@router.put(
    "/{employee_id}",
    response_model=EmployeeResponse
)
def update_employee(
    employee_id: str,
    request: EmployeeUpdate,
    db: Session = Depends(get_db)
):
    employee = (
        EmployeeService.update_employee(
            db,
            employee_id,
            request
        )
    )

    if not employee:
        raise HTTPException(
            status_code=404,
            detail="Employee not found"
        )

    return employee


@router.patch(
    "/{employee_id}/deactivate",
    response_model=EmployeeResponse
)
def deactivate_employee(
    employee_id: str,
    db: Session = Depends(get_db)
):
    employee = (
        EmployeeService.deactivate_employee(
            db,
            employee_id
        )
    )

    if not employee:
        raise HTTPException(
            status_code=404,
            detail="Employee not found"
        )

    return employee


@router.delete(
    "/{employee_id}"
)
def delete_employee(
    employee_id: str,
    db: Session = Depends(get_db)
):
    success = EmployeeService.delete_employee(
        db,
        employee_id
    )

    if not success:
        raise HTTPException(
            status_code=404,
            detail="Employee not found"
        )

    return {"message": "Employee deleted successfully"}
