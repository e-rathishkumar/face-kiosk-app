from sqlalchemy.orm import Session

from app.models.kiosk_metrics import (
    KioskMetrics
)


class KioskMetricsRepository:

    @staticmethod
    def create(
        db: Session,
        metrics: KioskMetrics
    ):
        db.add(metrics)
        db.commit()
        db.refresh(metrics)

        return metrics

    @staticmethod
    def get_by_kiosk(
        db: Session,
        kiosk_id
    ):
        return (
            db.query(
                KioskMetrics
            )
            .filter(
                KioskMetrics.kiosk_id == kiosk_id
            )
            .order_by(
                KioskMetrics.recorded_at.desc()
            )
            .all()
        )

    @staticmethod
    def get_latest(
        db: Session,
        kiosk_id
    ):
        return (
            db.query(
                KioskMetrics
            )
            .filter(
                KioskMetrics.kiosk_id == kiosk_id
            )
            .order_by(
                KioskMetrics.recorded_at.desc()
            )
            .first()
        )
