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


class DashboardService:

    @staticmethod
    def get_summary(
        db: Session
    ):
        return {
            "total_employees":
                EmployeeRepository.count(db),

            "active_attendance":
                AttendanceRepository.count_active(
                    db
                ),

            "total_kiosks":
                KioskRepository.count(db),

            "recognition_logs":
                RecognitionLogRepository.count(
                    db
                ),

            "pending_unrecognized":
                UnrecognizedRepository
                .count_pending(db)
        }
