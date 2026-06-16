from typing import List

from fastapi import (
    APIRouter,
    Depends,
    UploadFile,
    File,
    Form
)

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.schemas.employee_face_schema import (
    FaceRegistrationResponse
)

from app.services.employee_face_service import (
    EmployeeFaceService
)

from app.core.enums import FacePose


router = APIRouter(
    prefix="/employee-faces",
    tags=["Employee Faces"]
)


@router.post(
    "/upload",
    response_model=FaceRegistrationResponse
)
def upload_face(
    employee_id: str = Form(...),
    pose: FacePose = Form(...),
    image: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    return EmployeeFaceService.upload_face(
        db,
        employee_id,
        pose,
        image
    )


@router.get(
    "/{employee_id}",
    response_model=List[
        FaceRegistrationResponse
    ]
)
def get_faces(
    employee_id: str,
    db: Session = Depends(get_db)
):
    return EmployeeFaceService.get_faces(
        db,
        employee_id
    )
