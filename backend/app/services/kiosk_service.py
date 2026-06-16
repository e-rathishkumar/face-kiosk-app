from sqlalchemy.orm import Session

from app.models.kiosk import Kiosk

from app.repositories.kiosk_repository import (
    KioskRepository
)

from app.services.audit_service import (
    AuditService
)


class KioskService:

    @staticmethod
    def create_kiosk(
        db: Session,
        data
    ):
        kiosk = Kiosk(
            kiosk_code=data.kiosk_code,
            name=data.name,
            location=data.location,
            secret_key=data.secret_key,
            is_active=True
        )

        kiosk = (
            KioskRepository.create(
                db,
                kiosk
            )
        )

        AuditService.log(
            db=db,
            action="CREATE",
            entity_type="KIOSK",
            entity_id=str(kiosk.id)
        )

        return kiosk

    @staticmethod
    def get_all_kiosks(
        db: Session
    ):
        return (
            KioskRepository.get_all(
                db
            )
        )

    @staticmethod
    def get_kiosk(
        db: Session,
        kiosk_id
    ):
        return (
            KioskRepository.get_by_id(
                db,
                kiosk_id
            )
        )

    @staticmethod
    def update_kiosk(
        db: Session,
        kiosk_id,
        data
    ):
        kiosk = (
            KioskRepository.get_by_id(
                db,
                kiosk_id
            )
        )

        if not kiosk:
            return None

        kiosk.name = data.name
        kiosk.location = data.location
        kiosk.is_active = data.is_active

        kiosk = (
            KioskRepository.update(
                db,
                kiosk
            )
        )

        AuditService.log(
            db=db,
            action="UPDATE",
            entity_type="KIOSK",
            entity_id=str(kiosk.id)
        )

        return kiosk

    @staticmethod
    def deactivate_kiosk(
        db: Session,
        kiosk_id
    ):
        kiosk = (
            KioskRepository.get_by_id(
                db,
                kiosk_id
            )
        )

        if not kiosk:
            return None

        kiosk.is_active = False

        kiosk = (
            KioskRepository.update(
                db,
                kiosk
            )
        )

        AuditService.log(
            db=db,
            action="DEACTIVATE",
            entity_type="KIOSK",
            entity_id=str(kiosk.id)
        )

        return kiosk
