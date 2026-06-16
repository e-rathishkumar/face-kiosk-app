from sqlalchemy.orm import Session

from app.models.employee_face import EmployeeFace


class EmployeeFaceRepository:

    @staticmethod
    def create(
        db: Session,
        employee_face: EmployeeFace
    ):
        db.add(employee_face)
        db.commit()
        db.refresh(employee_face)

        return employee_face

    @staticmethod
    def get_by_employee(
        db: Session,
        employee_id
    ):
        return (
            db.query(EmployeeFace)
            .filter(
                EmployeeFace.employee_id ==
                employee_id
            )
            .all()
        )

    @staticmethod
    def count_by_employee(
        db: Session,
        employee_id
    ):
        return (
            db.query(EmployeeFace)
            .filter(
                EmployeeFace.employee_id ==
                employee_id
            )
            .count()
        )
