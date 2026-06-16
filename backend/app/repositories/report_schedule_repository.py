from sqlalchemy.orm import Session

from app.models.report_schedule import (
    ReportSchedule
)


class ReportScheduleRepository:

    @staticmethod
    def create(
        db: Session,
        schedule: ReportSchedule
    ):
        db.add(schedule)
        db.commit()
        db.refresh(schedule)

        return schedule

    @staticmethod
    def get_all(
        db: Session
    ):
        return (
            db.query(
                ReportSchedule
            )
            .order_by(
                ReportSchedule.created_at.desc()
            )
            .all()
        )

    @staticmethod
    def get_by_id(
        db: Session,
        schedule_id
    ):
        return (
            db.query(
                ReportSchedule
            )
            .filter(
                ReportSchedule.id == schedule_id
            )
            .first()
        )

    @staticmethod
    def update(
        db: Session,
        schedule: ReportSchedule
    ):
        db.commit()
        db.refresh(schedule)

        return schedule
