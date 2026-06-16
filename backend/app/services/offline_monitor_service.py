from datetime import datetime
from datetime import timedelta

from sqlalchemy.orm import Session

from app.models.kiosk_alert import (
    KioskAlert
)

from app.repositories.kiosk_repository import (
    KioskRepository
)

from app.repositories.heartbeat_repository import (
    HeartbeatRepository
)

from app.repositories.alert_repository import (
    AlertRepository
)

from app.services.audit_service import (
    AuditService
)

from app.core.enums import AlertType
from app.core.enums import AlertSeverity


class OfflineMonitorService:

    OFFLINE_MINUTES = 5

    @staticmethod
    def run(
        db: Session
    ):
        kiosks = KioskRepository.get_all(db)

        alerts_created = 0

        for kiosk in kiosks:

            latest = (
                HeartbeatRepository
                .get_latest_by_kiosk(
                    db,
                    kiosk.id
                )
            )

            if not latest:
                continue

            threshold = (
                datetime.utcnow()
                - timedelta(
                    minutes=
                    OfflineMonitorService
                    .OFFLINE_MINUTES
                )
            )

            if latest.heartbeat_time > threshold:
                continue

            existing = (
                AlertRepository
                .get_active_by_type(
                    db,
                    kiosk.id,
                    AlertType.OFFLINE
                )
            )

            if existing:
                continue

            alert = KioskAlert(
                kiosk_id=kiosk.id,
                alert_type=AlertType.OFFLINE,
                severity=AlertSeverity.CRITICAL,
                message="Kiosk heartbeat timeout (offline)"
            )

            alert = AlertRepository.create(
                db,
                alert
            )

            AuditService.log(
                db=db,
                action="OFFLINE_ALERT_CREATED",
                entity_type="ALERT",
                entity_id=str(alert.id)
            )

            alerts_created += 1

        return {
            "kiosks_checked":
                len(kiosks),
            "offline_alerts_created":
                alerts_created
        }
