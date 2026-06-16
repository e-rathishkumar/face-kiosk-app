from sqlalchemy.orm import Session

from app.models.audit_log import AuditLog

from app.repositories.audit_repository import (
    AuditRepository
)


class AuditService:

    @staticmethod
    def log(
        db: Session,
        action: str,
        entity_type: str,
        entity_id: str,
        old_value=None,
        new_value=None,
        user_id=None,
        ip_address=None
    ):
        log = AuditLog(
            user_id=user_id,
            action=action,
            entity_type=entity_type,
            entity_id=str(entity_id),
            old_value=str(old_value)
            if old_value else None,
            new_value=str(new_value)
            if new_value else None,
            ip_address=ip_address
        )

        return AuditRepository.create(
            db,
            log
        )

    @staticmethod
    def get_all(
        db: Session
    ):
        return AuditRepository.get_all(
            db
        )

    @staticmethod
    def get_entity_logs(
        db: Session,
        entity_type: str
    ):
        return AuditRepository.get_by_entity(
            db,
            entity_type
        )
