from datetime import datetime
from datetime import timedelta

from sqlalchemy.orm import Session

from app.models.report_schedule import (
    ReportSchedule
)

from app.repositories.report_schedule_repository import (
    ReportScheduleRepository
)


class ReportScheduleService:

    @staticmethod
    def calculate_next_run(
        frequency: str
    ):
        now = datetime.utcnow()

        frequency = frequency.upper()

        if frequency == "DAILY":
            return now + timedelta(days=1)

        if frequency == "WEEKLY":
            return now + timedelta(days=7)

        if frequency == "MONTHLY":
            return now + timedelta(days=30)

        return now + timedelta(days=1)

    @staticmethod
    def create(
        db: Session,
        report_type: str,
        frequency: str,
        email: str
    ):
        schedule = ReportSchedule(
            report_name=report_type,
            frequency=frequency,
            email_recipients=email,
            is_active=True,
            next_run=(
                ReportScheduleService
                .calculate_next_run(
                    frequency
                )
            )
        )

        return (
            ReportScheduleRepository.create(
                db,
                schedule
            )
        )

    @staticmethod
    def get_all(
        db: Session
    ):
        return (
            ReportScheduleRepository.get_all(
                db
            )
        )

    @staticmethod
    def deactivate(
        db: Session,
        schedule_id
    ):
        schedule = (
            ReportScheduleRepository.get_by_id(
                db,
                schedule_id
            )
        )

        if not schedule:
            return None

        schedule.is_active = False

        return (
            ReportScheduleRepository.update(
                db,
                schedule
            )
        )

    @staticmethod
    def activate(
        db: Session,
        schedule_id
    ):
        schedule = (
            ReportScheduleRepository.get_by_id(
                db,
                schedule_id
            )
        )

        if not schedule:
            return None

        schedule.is_active = True

        return (
            ReportScheduleRepository.update(
                db,
                schedule
            )
        )
