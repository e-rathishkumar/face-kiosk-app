from uuid import UUID

from pydantic import BaseModel


class AuditLogResponse(BaseModel):

    id: UUID

    user_id: UUID | None = None

    action: str

    entity_type: str

    entity_id: str

    old_value: str | None = None

    new_value: str | None = None

    ip_address: str | None = None

    class Config:
        from_attributes = True
