from datetime import datetime
from datetime import timedelta

from jose import jwt

SECRET_KEY = "face_recognition_kiosk_super_secret_key"
ALGORITHM = "HS256"


def create_access_token(
    user_id: str,
    role: str
):
    expire = datetime.utcnow() + timedelta(hours=24)

    payload = {
        "sub": user_id,
        "role": role,
        "exp": expire
    }

    return jwt.encode(
        payload,
        SECRET_KEY,
        algorithm=ALGORITHM
    )


def create_refresh_token(
    user_id: str
):
    expire = datetime.utcnow() + timedelta(days=7)

    payload = {
        "sub": user_id,
        "exp": expire
    }

    return jwt.encode(
        payload,
        SECRET_KEY,
        algorithm=ALGORITHM
    )


def decode_token(token: str):
    try:
        payload = jwt.decode(
            token,
            SECRET_KEY,
            algorithms=[ALGORITHM]
        )
        return payload
    except Exception:
        return None
