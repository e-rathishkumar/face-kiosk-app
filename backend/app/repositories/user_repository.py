from sqlalchemy.orm import Session
from sqlalchemy import or_

from app.models.user import User


class UserRepository:

    @staticmethod
    def get_by_username(
        db: Session,
        identifier: str
    ):
        identifier = identifier.lower().strip()
        from sqlalchemy import func
        return (
            db.query(User)
            .filter(
                or_(
                    User.username == identifier,
                    func.lower(User.email) == identifier
                )
            )
            .first()
        )

    @staticmethod
    def update(
        db: Session,
        user: User
    ):
        db.commit()
        db.refresh(user)

        return user
