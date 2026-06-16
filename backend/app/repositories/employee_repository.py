from sqlalchemy.orm import Session

from app.models.employee import Employee


class EmployeeRepository:

    @staticmethod
    def create(
        db: Session,
        employee: Employee
    ):
        db.add(employee)
        db.commit()
        db.refresh(employee)
        return employee

    @staticmethod
    def get_all(
        db: Session
    ):
        return db.query(Employee).all()

    @staticmethod
    def get_by_id(
        db: Session,
        employee_id
    ):
        return (
            db.query(Employee)
            .filter(Employee.id == employee_id)
            .first()
        )

    @staticmethod
    def update(
        db,
        employee
    ):
        db.commit()
        db.refresh(employee)
        return employee

    @staticmethod
    def delete(
        db: Session,
        employee: Employee
    ):
        db.delete(employee)
        db.commit()

    @staticmethod
    def count(
        db: Session
    ):
        return db.query(Employee).count()
