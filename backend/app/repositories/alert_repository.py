from sqlalchemy.orm import Session

from app.models.kiosk_alert import (
    KioskAlert
)


class AlertRepository:

    @staticmethod
    def create(
        db: Session,
        alert: KioskAlert
    ):
        db.add(alert)
        db.commit()
        db.refresh(alert)

        return alert

    @staticmethod
    def get_all(
        db: Session
    ):
        return (
            db.query(
                KioskAlert
            )
            .order_by(
                KioskAlert.created_at.desc()
            )
            .all()
        )

    @staticmethod
    def get_active(
        db: Session
    ):
        return (
            db.query(
                KioskAlert
            )
            .filter(
                KioskAlert.is_resolved == False
            )
            .order_by(
                KioskAlert.created_at.desc()
            )
            .all()
        )

    @staticmethod
    def get_active_by_type(
        db: Session,
        kiosk_id,
        alert_type
    ):
        return (
            db.query(
                KioskAlert
            )
            .filter(
                KioskAlert.kiosk_id == kiosk_id,
                KioskAlert.alert_type == alert_type,
                KioskAlert.is_resolved == False
            )
            .first()
        )

    @staticmethod
    def get_active_by_kiosk(
        db: Session,
        kiosk_id
    ):
        return (
            db.query(
                KioskAlert
            )
            .filter(
                KioskAlert.kiosk_id == kiosk_id,
                KioskAlert.is_resolved == False
            )
            .all()
        )

    @staticmethod
    def get_by_id(
        db: Session,
        alert_id
    ):
        return (
            db.query(
                KioskAlert
            )
            .filter(
                KioskAlert.id == alert_id
            )
            .first()
        )

    @staticmethod
    def update(
        db: Session,
        alert: KioskAlert
    ):
        db.commit()
        db.refresh(alert)

        return alert
