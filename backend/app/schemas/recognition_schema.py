from pydantic import BaseModel


class RecognitionResponse(
    BaseModel
):
    recognized: bool
    employee_id: str | None = None
    pose: str | None = None
    distance: float | None = None
