from sqlalchemy.orm import Session

from app.repositories.kiosk_repository import (
    KioskRepository
)

from app.repositories.heartbeat_repository import (
    HeartbeatRepository
)

from app.repositories.alert_repository import (
    AlertRepository
)

from app.core.enums import AlertSeverity


class HealthService:

    @staticmethod
    def get_kiosk_health(
        db: Session
    ):
        kiosks = KioskRepository.get_all(db)

        response = []

        for kiosk in kiosks:

            latest_heartbeat = (
                HeartbeatRepository
                .get_latest_by_kiosk(
                    db,
                    kiosk.id
                )
            )

            active_alerts = (
                AlertRepository
                .get_active_by_kiosk(
                    db,
                    kiosk.id
                )
            )

            status = "HEALTHY"

            if active_alerts:
                status = "WARNING"

            for alert in active_alerts:
                if (
                    alert.severity
                    == AlertSeverity.CRITICAL
                ):
                    status = "CRITICAL"
                    break

            response.append(
                {
                    "kiosk_id": kiosk.id,
                    "kiosk_name": kiosk.name,

                    "status": status,

                    "battery_level":
                        latest_heartbeat.battery_level
                        if latest_heartbeat else None,

                    "cpu_usage":
                        latest_heartbeat.cpu_usage
                        if latest_heartbeat else None,

                    "memory_usage":
                        latest_heartbeat.memory_usage
                        if latest_heartbeat else None,

                    "temperature":
                        latest_heartbeat.temperature
                        if latest_heartbeat else None,

                    "active_alerts":
                        len(active_alerts),

                    "last_heartbeat":
                        latest_heartbeat.heartbeat_time
                        if latest_heartbeat else None
                }
            )

        return response
