from sqlalchemy.orm import Session

from app.repositories.employee_repository import (
    EmployeeRepository
)

from app.repositories.kiosk_repository import (
    KioskRepository
)

from app.repositories.attendance_repository import (
    AttendanceRepository
)

from app.repositories.recognition_log_repository import (
    RecognitionLogRepository
)

from app.repositories.unrecognized_repository import (
    UnrecognizedRepository
)

from app.core.enums import (
    AttendanceStatus
)


class ReportService:

    @staticmethod
    def attendance_report(
        db: Session
    ):
        sessions = AttendanceRepository.get_all(
            db
        )

        active = [
            s for s in sessions
            if s.status ==
            AttendanceStatus.ACTIVE
        ]

        completed = [
            s for s in sessions
            if s.status ==
            AttendanceStatus.COMPLETED
        ]

        return {
            "total_sessions": len(sessions),
            "active_sessions": len(active),
            "completed_sessions": len(completed)
        }

    @staticmethod
    def recognition_report(
        db: Session
    ):
        return {
            "total_recognitions":
                RecognitionLogRepository.count(db)
        }

    @staticmethod
    def unrecognized_report(
        db: Session
    ):
        return {
            "total_unrecognized":
                len(
                    UnrecognizedRepository.get_all(db)
                ),

            "pending_unrecognized":
                UnrecognizedRepository.count_pending(
                    db
                )
        }

    @staticmethod
    def dashboard_report(
        db: Session
    ):
        return {
            "total_employees":
                EmployeeRepository.count(db),

            "active_attendance":
                len(
                    AttendanceRepository
                    .get_active_sessions(db)
                ),

            "total_kiosks":
                KioskRepository.count(db),

            "recognition_logs":
                RecognitionLogRepository.count(db),

            "pending_unrecognized":
                UnrecognizedRepository.count_pending(
                    db
                )
        }
