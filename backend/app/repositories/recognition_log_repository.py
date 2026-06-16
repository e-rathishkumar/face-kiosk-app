from sqlalchemy.orm import Session

from app.models.recognition_log import RecognitionLog


class RecognitionLogRepository:

    @staticmethod
    def create(
        db: Session,
        recognition_log: RecognitionLog
    ):
        db.add(recognition_log)
        db.commit()
        db.refresh(recognition_log)

        return recognition_log

    @staticmethod
    def get_all(
        db: Session
    ):
        return (
            db.query(
                RecognitionLog
            )
            .order_by(
                RecognitionLog.event_time.desc()
            )
            .all()
        )

    @staticmethod
    def get_by_employee(
        db: Session,
        employee_id
    ):
        return (
            db.query(
                RecognitionLog
            )
            .filter(
                RecognitionLog.employee_id == employee_id
            )
            .order_by(
                RecognitionLog.event_time.desc()
            )
            .all()
        )

    @staticmethod
    def count(
        db: Session
    ):
        return db.query(
            RecognitionLog
        ).count()
