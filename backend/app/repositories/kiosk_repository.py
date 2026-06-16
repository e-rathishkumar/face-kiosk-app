from sqlalchemy.orm import Session

from app.models.kiosk import Kiosk


class KioskRepository:

    @staticmethod
    def create(
        db: Session,
        kiosk: Kiosk
    ):
        db.add(kiosk)
        db.commit()
        db.refresh(kiosk)
        return kiosk

    @staticmethod
    def get_all(
        db: Session
    ):
        return db.query(Kiosk).all()

    @staticmethod
    def get_by_id(
        db: Session,
        kiosk_id
    ):
        return (
            db.query(Kiosk)
            .filter(Kiosk.id == kiosk_id)
            .first()
        )

    @staticmethod
    def update(
        db: Session,
        kiosk
    ):
        db.commit()
        db.refresh(kiosk)
        return kiosk

    @staticmethod
    def count(
        db: Session
    ):
        return db.query(Kiosk).count()
