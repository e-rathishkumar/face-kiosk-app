from sqlalchemy.orm import Session

from app.models.employee import Employee
from app.models.user import User
from app.core.enums import UserRole
from app.repositories.employee_repository import EmployeeRepository
from app.utils.password_helper import hash_password

DEFAULT_EMPLOYEE_PASSWORD = "staff@123"


class EmployeeService:

    @staticmethod
    def create_employee(db: Session, data):
        # Check if employee code exists first
        existing_employee = db.query(Employee).filter(Employee.employee_code == data.employee_code).first()
        if existing_employee:
            from fastapi import HTTPException
            raise HTTPException(status_code=400, detail="Employee code already exists")

        employee = Employee(
            employee_code=data.employee_code,
            first_name=data.first_name,
            last_name=data.last_name,
            email=data.email,
            phone=data.phone,
            department=data.department,
            designation=data.designation,
            joining_date=data.joining_date,
            is_active=True
        )

        try:
            created_employee = EmployeeRepository.create(db, employee)
        except Exception as e:
            db.rollback()
            from fastapi import HTTPException
            raise HTTPException(status_code=400, detail="Failed to create employee (Possible duplicate)")

        # Auto-create a user account for the employee with default password
        username = data.employee_code.lower()
        email = data.email or f"{username}@employee.local"

        existing_user = (
            db.query(User)
            .filter(User.username == username)
            .first()
        )

        if not existing_user:
            user = User(
                username=username,
                email=email,
                password_hash=hash_password(DEFAULT_EMPLOYEE_PASSWORD),
                role=UserRole.EMPLOYEE,
                is_active=True,
                must_reset_password=True
            )
            db.add(user)
            db.commit()

        return created_employee

    @staticmethod
    def get_all_employees(db: Session):
        return EmployeeRepository.get_all(db)

    @staticmethod
    def get_employee(db: Session, employee_id):
        return EmployeeRepository.get_by_id(
            db,
            employee_id
        )

    @staticmethod
    def deactivate_employee(
        db: Session,
        employee_id
    ):
        employee = EmployeeRepository.get_by_id(
            db,
            employee_id
        )

        employee.is_active = False

        return EmployeeRepository.update(
            db,
            employee
        )

    @staticmethod
    def update_employee(
        db: Session,
        employee_id,
        data
    ):
        employee = EmployeeRepository.get_by_id(
            db,
            employee_id
        )

        employee.first_name = data.first_name
        employee.last_name = data.last_name
        employee.email = data.email
        employee.phone = data.phone
        employee.department = data.department
        employee.designation = data.designation

        return EmployeeRepository.update(
            db,
            employee
        )

    @staticmethod
    def delete_employee(
        db: Session,
        employee_id
    ):
        employee = EmployeeRepository.get_by_id(
            db,
            employee_id
        )

        if employee:
            # Also delete associated user if it exists
            username = employee.employee_code.lower()
            existing_user = (
                db.query(User)
                .filter(User.username == username)
                .first()
            )
            if existing_user:
                db.delete(existing_user)
            
            # Import models here to avoid circular imports if any
            from app.models.attendance_session import AttendanceSession
            from app.models.employee_face import EmployeeFace
            from app.models.recognition_log import RecognitionLog

            # Delete related records to prevent foreign key violations
            db.query(AttendanceSession).filter(AttendanceSession.employee_id == employee_id).delete()
            db.query(EmployeeFace).filter(EmployeeFace.employee_id == employee_id).delete()
            db.query(RecognitionLog).filter(RecognitionLog.employee_id == employee_id).delete()
            
            EmployeeRepository.delete(db, employee)
            return True
        return False

