from sqlalchemy.orm import Session

from app.models.kiosk_heartbeat import KioskHeartbeat


class HeartbeatRepository:

    @staticmethod
    def create(
        db: Session,
        heartbeat: KioskHeartbeat
    ):
        db.add(heartbeat)
        db.commit()
        db.refresh(heartbeat)

        return heartbeat

    @staticmethod
    def get_all(
        db: Session
    ):
        return (
            db.query(KioskHeartbeat)
            .order_by(
                KioskHeartbeat.heartbeat_time.desc()
            )
            .all()
        )

    @staticmethod
    def get_by_kiosk(
        db: Session,
        kiosk_id
    ):
        return (
            db.query(KioskHeartbeat)
            .filter(
                KioskHeartbeat.kiosk_id == kiosk_id
            )
            .order_by(
                KioskHeartbeat.heartbeat_time.desc()
            )
            .all()
        )

    @staticmethod
    def get_latest_by_kiosk(
        db: Session,
        kiosk_id
    ):
        return (
            db.query(KioskHeartbeat)
            .filter(
                KioskHeartbeat.kiosk_id == kiosk_id
            )
            .order_by(
                KioskHeartbeat.heartbeat_time.desc()
            )
            .first()
        )
