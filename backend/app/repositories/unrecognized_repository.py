from sqlalchemy.orm import Session

from app.models.unrecognized_entry import (
    UnrecognizedEntry
)

from app.core.enums import (
    UnrecognizedStatus
)


class UnrecognizedRepository:

    @staticmethod
    def create(
        db: Session,
        entry: UnrecognizedEntry
    ):
        db.add(entry)
        db.commit()
        db.refresh(entry)

        return entry

    @staticmethod
    def get_all(
        db: Session
    ):
        return (
            db.query(
                UnrecognizedEntry
            )
            .order_by(
                UnrecognizedEntry.created_at.desc()
            )
            .all()
        )

    @staticmethod
    def get_by_id(
        db: Session,
        entry_id
    ):
        return (
            db.query(
                UnrecognizedEntry
            )
            .filter(
                UnrecognizedEntry.id == entry_id
            )
            .first()
        )

    @staticmethod
    def update(
        db: Session,
        entry: UnrecognizedEntry
    ):
        db.commit()
        db.refresh(entry)

        return entry

    @staticmethod
    def count_pending(
        db: Session
    ):
        return (
            db.query(
                UnrecognizedEntry
            )
            .filter(
                UnrecognizedEntry.status ==
                UnrecognizedStatus.PENDING
            )
            .count()
        )
