from sqlalchemy.orm import Session

from app.models.audit_log import AuditLog


class AuditRepository:

    @staticmethod
    def create(
        db: Session,
        audit_log: AuditLog
    ):
        db.add(audit_log)
        db.commit()
        db.refresh(audit_log)

        return audit_log

    @staticmethod
    def get_all(
        db: Session
    ):
        return (
            db.query(AuditLog)
            .order_by(
                AuditLog.created_at.desc()
            )
            .all()
        )

    @staticmethod
    def get_by_entity(
        db: Session,
        entity_type: str
    ):
        return (
            db.query(AuditLog)
            .filter(
                AuditLog.entity_type ==
                entity_type
            )
            .order_by(
                AuditLog.created_at.desc()
            )
            .all()
        )

    @staticmethod
    def count(
        db: Session
    ):
        return (
            db.query(
                AuditLog
            )
            .count()
        )
