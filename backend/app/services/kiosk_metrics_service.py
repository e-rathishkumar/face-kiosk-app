from datetime import datetime

from sqlalchemy.orm import Session

from app.models.kiosk_metrics import (
    KioskMetrics
)

from app.repositories.kiosk_metrics_repository import (
    KioskMetricsRepository
)


class KioskMetricsService:

    @staticmethod
    def create(
        db: Session,
        heartbeat
    ):
        metrics = KioskMetrics(
            kiosk_id=heartbeat.kiosk_id,
            battery_level=heartbeat.battery_level,
            cpu_usage=heartbeat.cpu_usage,
            memory_usage=heartbeat.memory_usage,
            temperature=heartbeat.temperature,
            storage_available=
                heartbeat.storage_available,
            network_strength=
                heartbeat.network_strength,
            recorded_at=datetime.utcnow()
        )

        return (
            KioskMetricsRepository.create(
                db,
                metrics
            )
        )
