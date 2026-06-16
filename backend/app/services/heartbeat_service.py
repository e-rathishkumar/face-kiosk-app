from datetime import datetime

from sqlalchemy.orm import Session

from app.models.kiosk_heartbeat import (
    KioskHeartbeat
)

from app.models.kiosk_alert import (
    KioskAlert
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

from app.services.kiosk_metrics_service import (
    KioskMetricsService
)

from app.core.enums import AlertType
from app.core.enums import AlertSeverity


class HeartbeatService:

    @staticmethod
    def _create_alert_if_needed(
        db: Session,
        kiosk_id,
        alert_type,
        severity,
        message
    ):
        existing_alert = (
            AlertRepository.get_active_by_type(
                db,
                kiosk_id,
                alert_type
            )
        )

        if existing_alert:
            return

        alert = KioskAlert(
            kiosk_id=kiosk_id,
            alert_type=alert_type,
            severity=severity,
            message=message
        )

        alert = AlertRepository.create(
            db,
            alert
        )

        AuditService.log(
            db=db,
            action="ALERT_CREATED",
            entity_type="ALERT",
            entity_id=str(alert.id)
        )

    @staticmethod
    def create_heartbeat(
        db: Session,
        data
    ):
        heartbeat = KioskHeartbeat(
            kiosk_id=data.kiosk_id,
            battery_level=data.battery_level,
            cpu_usage=data.cpu_usage,
            memory_usage=data.memory_usage,
            temperature=data.temperature,
            storage_total=data.storage_total,
            storage_available=data.storage_available,
            network_strength=data.network_strength,
            device_model=data.device_model,
            app_version=data.app_version,
            heartbeat_time=datetime.utcnow()
        )

        heartbeat = HeartbeatRepository.create(
            db,
            heartbeat
        )

        KioskMetricsService.create(
            db,
            heartbeat
        )

        if (
            data.battery_level is not None
            and data.battery_level < 10
        ):
            HeartbeatService._create_alert_if_needed(
                db,
                data.kiosk_id,
                AlertType.CRITICAL_BATTERY,
                AlertSeverity.CRITICAL,
                "Battery level below 10%"
            )

        elif (
            data.battery_level is not None
            and data.battery_level < 20
        ):
            HeartbeatService._create_alert_if_needed(
                db,
                data.kiosk_id,
                AlertType.LOW_BATTERY,
                AlertSeverity.HIGH,
                "Battery level below 20%"
            )

        if (
            data.cpu_usage is not None
            and data.cpu_usage > 90
        ):
            HeartbeatService._create_alert_if_needed(
                db,
                data.kiosk_id,
                AlertType.HIGH_CPU,
                AlertSeverity.HIGH,
                "CPU usage above 90%"
            )

        if (
            data.temperature is not None
            and data.temperature > 65
        ):
            HeartbeatService._create_alert_if_needed(
                db,
                data.kiosk_id,
                AlertType.HIGH_TEMPERATURE,
                AlertSeverity.CRITICAL,
                "Temperature above 65°C"
            )

        if (
            data.storage_available is not None
            and data.storage_available < 10
        ):
            HeartbeatService._create_alert_if_needed(
                db,
                data.kiosk_id,
                AlertType.LOW_STORAGE,
                AlertSeverity.HIGH,
                "Available storage below 10 GB"
            )

        return heartbeat

    @staticmethod
    def get_all(
        db: Session
    ):
        return HeartbeatRepository.get_all(
            db
        )

    @staticmethod
    def get_kiosk_heartbeats(
        db: Session,
        kiosk_id
    ):
        return HeartbeatRepository.get_by_kiosk(
            db,
            kiosk_id
        )

    @staticmethod
    def get_latest(
        db: Session,
        kiosk_id
    ):
        return HeartbeatRepository.get_latest_by_kiosk(
            db,
            kiosk_id
        )
