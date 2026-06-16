from fastapi import (
    APIRouter,
    UploadFile,
    File,
    Depends,
    Form
)

from sqlalchemy.orm import Session

from app.database.session import get_db

from app.services.recognition_service import (
    FaceRecognitionService
)

router = APIRouter(
    prefix="/recognition",
    tags=["Recognition"]
)


@router.post("")
def recognize_face(
    kiosk_id: str = Form(...),
    image: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    return FaceRecognitionService.recognize(
        db,
        kiosk_id,
        image
    )
