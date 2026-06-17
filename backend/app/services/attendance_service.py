from datetime import datetime

from sqlalchemy.orm import Session

from app.repositories.attendance_repository import (
    AttendanceRepository
)

from app.models.attendance_session import (
    AttendanceSession
)

from app.core.enums import (
    AttendanceStatus,
    CheckoutType
)

from app.services.audit_service import (
    AuditService
)


class AttendanceService:

    @staticmethod
    def has_active_session(
        db: Session,
        employee_id
    ):
        return (
            AttendanceRepository
            .get_active_session(
                db,
                employee_id
            )
            is not None
        )

    @staticmethod
    def has_checked_out_today(
        db: Session,
        employee_id: str
    ):
        return AttendanceRepository.has_checked_out_today(db, employee_id)

    @staticmethod
    def check_in(
        db: Session,
        employee_id,
        kiosk_id
    ):
        existing = (
            AttendanceRepository
            .get_active_session(
                db,
                employee_id
            )
        )

        if existing:
            return existing

        session = AttendanceSession(
            employee_id=employee_id,
            kiosk_id=kiosk_id,
            check_in_time=
            datetime.utcnow(),
            status=
            AttendanceStatus.ACTIVE
        )

        session = (
            AttendanceRepository.create(
                db,
                session
            )
        )

        AuditService.log(
            db=db,
            action="CHECK_IN",
            entity_type="ATTENDANCE",
            entity_id=str(session.id)
        )

        return session

    @staticmethod
    def check_out(
        db: Session,
        employee_id
    ):
        session = (
            AttendanceRepository
            .get_active_session(
                db,
                employee_id
            )
        )

        if not session:
            return None

        session.status = (
            AttendanceStatus.COMPLETED
        )

        session.check_out_time = (
            datetime.utcnow()
        )

        session.checkout_type = (
            CheckoutType.MANUAL
        )

        session = (
            AttendanceRepository.update(
                db,
                session
            )
        )

        AuditService.log(
            db=db,
            action="CHECK_OUT",
            entity_type="ATTENDANCE",
            entity_id=str(session.id)
        )

        return session

    @staticmethod
    def get_all(
        db: Session
    ):
        return (
            AttendanceRepository.get_all(
                db
            )
        )

    @staticmethod
    def get_active(
        db: Session
    ):
        return (
            AttendanceRepository
            .get_active_sessions(
                db
            )
        )

    @staticmethod
    def get_employee_sessions(
        db: Session,
        employee_id
    ):
        return (
            AttendanceRepository
            .get_employee_sessions(
                db,
                employee_id
            )
        )
