from datetime import datetime

from sqlalchemy.orm import Session

from app.models.recognition_log import RecognitionLog

from app.repositories.recognition_log_repository import (
    RecognitionLogRepository
)


class RecognitionLogService:

    @staticmethod
    def create_log(
        db: Session,
        employee_id,
        kiosk_id,
        confidence_score,
        image_url
    ):
        recognition_log = RecognitionLog(
            employee_id=employee_id,
            kiosk_id=kiosk_id,
            confidence_score=confidence_score,
            event_time=datetime.utcnow(),
            image_url=image_url
        )

        return RecognitionLogRepository.create(
            db,
            recognition_log
        )

    @staticmethod
    def get_all_logs(
        db: Session
    ):
        return RecognitionLogRepository.get_all(
            db
        )

    @staticmethod
    def get_employee_logs(
        db: Session,
        employee_id
    ):
        return (
            RecognitionLogRepository.get_by_employee(
                db,
                employee_id
            )
        )
