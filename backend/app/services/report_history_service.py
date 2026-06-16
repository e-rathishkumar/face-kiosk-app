from datetime import datetime
from sqlalchemy.orm import Session

from app.models.report_history import (
    ReportHistory
)

from app.repositories.report_history_repository import (
    ReportHistoryRepository
)


class ReportHistoryService:

    @staticmethod
    def create(
        db: Session,
        report_name: str,
        file_url: str,
        generated_by: str | None = None
    ):
        report = ReportHistory(
            report_name=report_name,
            generated_by=generated_by,
            file_url=file_url,
            generated_at=datetime.utcnow()
        )

        return (
            ReportHistoryRepository.create(
                db,
                report
            )
        )

    @staticmethod
    def get_all(
        db: Session
    ):
        return (
            ReportHistoryRepository.get_all(
                db
            )
        )
