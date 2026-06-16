from datetime import datetime

from sqlalchemy.orm import Session

from app.services.export_service import (
    ExportService
)

from app.services.report_schedule_service import (
    ReportScheduleService
)


class ReportSchedulerService:

    @staticmethod
    def run_pending(
        db: Session
    ):
        schedules = (
            ReportScheduleService.get_all(
                db
            )
        )

        schedules_checked = 0
        executed = 0

        now = datetime.utcnow()

        for schedule in schedules:

            schedules_checked += 1

            if not schedule.is_active:
                continue

            if (
                schedule.next_run and
                schedule.next_run > now
            ):
                continue

            file_path = None

            if schedule.report_name == "attendance":
                file_path = (
                    ExportService
                    .export_attendance_csv(db)
                )

            elif schedule.report_name == "recognition":
                file_path = (
                    ExportService
                    .export_recognition_csv(db)
                )

            elif schedule.report_name == "unrecognized":
                file_path = (
                    ExportService
                    .export_unrecognized_csv(db)
                )

            if file_path:

                schedule.last_run = now

                schedule.next_run = (
                    ReportScheduleService
                    .calculate_next_run(
                        schedule.frequency
                    )
                )

                db.commit()

                executed += 1

        return {
            "schedules_checked":
                schedules_checked,
            "executed":
                executed
        }
