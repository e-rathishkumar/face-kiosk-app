from sqlalchemy.orm import Session

from app.models.report_history import (
    ReportHistory
)


class ReportHistoryRepository:

    @staticmethod
    def create(
        db: Session,
        report: ReportHistory
    ):
        db.add(report)
        db.commit()
        db.refresh(report)

        return report

    @staticmethod
    def get_all(
        db: Session
    ):
        return (
            db.query(
                ReportHistory
            )
            .order_by(
                ReportHistory.generated_at.desc()
            )
            .all()
        )
