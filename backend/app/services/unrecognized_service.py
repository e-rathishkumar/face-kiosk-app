from sqlalchemy.orm import Session

from app.models.unrecognized_entry import (
    UnrecognizedEntry
)

from app.repositories.unrecognized_repository import (
    UnrecognizedRepository
)

from app.core.enums import (
    UnrecognizedStatus
)


class UnrecognizedService:

    @staticmethod
    def create_entry(
        db: Session,
        kiosk_id,
        image_url,
        confidence_score
    ):
        entry = UnrecognizedEntry(
            kiosk_id=kiosk_id,
            image_url=image_url,
            face_crop_url=image_url,
            confidence_score=confidence_score,
            status=UnrecognizedStatus.PENDING
        )

        return UnrecognizedRepository.create(
            db,
            entry
        )

    @staticmethod
    def get_all_entries(
        db: Session
    ):
        return UnrecognizedRepository.get_all(
            db
        )

    @staticmethod
    def update_status(
        db: Session,
        entry_id,
        status
    ):
        entry = (
            UnrecognizedRepository.get_by_id(
                db,
                entry_id
            )
        )

        if not entry:
            return None

        entry.status = status

        return (
            UnrecognizedRepository.update(
                db,
                entry
            )
        )
