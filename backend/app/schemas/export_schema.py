from pydantic import BaseModel


class ExportResponse(BaseModel):
    filename: str
    export_type: str
