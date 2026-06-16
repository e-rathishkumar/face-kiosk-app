from datetime import datetime

from fastapi import HTTPException
from sqlalchemy.orm import Session

from app.models.kiosk_alert import (
    KioskAlert
)

from app.repositories.alert_repository import (
    AlertRepository
)


class AlertService:

    @staticmethod
    def create_alert(
        db: Session,
        request
    ):
        alert = KioskAlert(
            kiosk_id=request.kiosk_id,
            alert_type=request.alert_type,
            severity=request.severity,
            message=request.message
        )

        return AlertRepository.create(
            db,
            alert
        )

    @staticmethod
    def get_all_alerts(
        db: Session
    ):
        return AlertRepository.get_all(
            db
        )

    @staticmethod
    def get_active_alerts(
        db: Session
    ):
        return AlertRepository.get_active(
            db
        )

    @staticmethod
    def resolve_alert(
        db: Session,
        alert_id,
        resolved_by=None
    ):
        alert = AlertRepository.get_by_id(
            db,
            alert_id
        )

        if not alert:
            raise HTTPException(
                status_code=404,
                detail="Alert not found"
            )

        alert.is_resolved = True
        alert.resolved_by = resolved_by
        alert.resolved_at = datetime.utcnow()

        return AlertRepository.update(
            db,
            alert
        )
