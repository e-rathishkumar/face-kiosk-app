from sqlalchemy.orm import Session

from app.models.recognition_log import (
    RecognitionLog
)


class RecognitionRepository:

    @staticmethod
    def get_latest_recognition(
        db: Session,
        employee_id
    ):
        return (
            db.query(
                RecognitionLog
            )
            .filter(
                RecognitionLog.employee_id
                == employee_id
            )
            .order_by(
                RecognitionLog.event_time.desc()
            )
            .first()
        )
