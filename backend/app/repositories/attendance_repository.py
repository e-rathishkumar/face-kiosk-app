from sqlalchemy.orm import Session

from app.models.attendance_session import (
    AttendanceSession
)

from app.core.enums import (
    AttendanceStatus
)


class AttendanceRepository:

    @staticmethod
    def create(
        db: Session,
        session: AttendanceSession
    ):
        db.add(session)
        db.commit()
        db.refresh(session)

        return session

    @staticmethod
    def get_active_session(
        db: Session,
        employee_id
    ):
        return (
            db.query(
                AttendanceSession
            )
            .filter(
                AttendanceSession.employee_id
                == employee_id,
                AttendanceSession.status
                == AttendanceStatus.ACTIVE
            )
            .first()
        )

    @staticmethod
    def update(
        db: Session,
        session: AttendanceSession
    ):
        db.commit()
        db.refresh(session)

        return session

    @staticmethod
    def get_all(
        db: Session
    ):
        return (
            db.query(
                AttendanceSession
            )
            .order_by(
                AttendanceSession.check_in_time.desc()
            )
            .all()
        )

    @staticmethod
    def get_active_sessions(
        db: Session
    ):
        return (
            db.query(
                AttendanceSession
            )
            .filter(
                AttendanceSession.status
                == AttendanceStatus.ACTIVE
            )
            .all()
        )

    @staticmethod
    def get_employee_sessions(
        db: Session,
        employee_id
    ):
        return (
            db.query(
                AttendanceSession
            )
            .filter(
                AttendanceSession.employee_id
                == employee_id
            )
            .order_by(
                AttendanceSession.check_in_time.desc()
            )
            .all()
        )

    @staticmethod
    def count(
        db: Session
    ):
        return (
            db.query(
                AttendanceSession
            )
            .count()
        )

    @staticmethod
    def count_active(
        db: Session
    ):
        return (
            db.query(
                AttendanceSession
            )
            .filter(
                AttendanceSession.status
                == AttendanceStatus.ACTIVE
            )
            .count()
        )

    @staticmethod
    def count_active(
        db: Session
    ):
        return (
            db.query(
                AttendanceSession
            )
            .filter(
                AttendanceSession.status ==
                AttendanceStatus.ACTIVE
            )
            .count()
        )
