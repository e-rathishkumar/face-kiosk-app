from datetime import datetime

from sqlalchemy.orm import Session

from app.repositories.user_repository import (
    UserRepository
)

from app.services.audit_service import (
    AuditService
)

from app.utils.password_helper import (
    verify_password
)

from app.utils.jwt_helper import (
    create_access_token,
    create_refresh_token
)


class AuthService:

    @staticmethod
    def login(
        db: Session,
        username: str,
        password: str
    ):
        user = (
            UserRepository.get_by_username(
                db,
                username
            )
        )

        if not user:
            return None

        if not verify_password(
            password,
            user.password_hash
        ):
            return None

        user.last_login = (
            datetime.utcnow()
        )

        UserRepository.update(
            db,
            user
        )

        AuditService.log(
            db=db,
            action="LOGIN",
            entity_type="USER",
            entity_id=str(user.id)
        )

        access_token = (
            create_access_token(
                str(user.id),
                user.role.value
            )
        )

        refresh_token = (
            create_refresh_token(
                str(user.id)
            )
        )

        return {
            "id": str(user.id),
            "access_token":
                access_token,
            "refresh_token":
                refresh_token,
            "role":
                user.role.value,
            "must_reset_password":
                user.must_reset_password
        }
