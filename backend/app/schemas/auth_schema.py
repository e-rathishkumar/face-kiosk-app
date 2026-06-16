from pydantic import BaseModel


class LoginRequest(BaseModel):
    username: str
    password: str


class LoginResponse(BaseModel):
    id: str
    access_token: str
    refresh_token: str
    role: str
    must_reset_password: bool = False


class ResetPasswordRequest(BaseModel):
    old_password: str
    new_password: str
