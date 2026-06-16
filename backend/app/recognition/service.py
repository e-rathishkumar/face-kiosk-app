from fastapi import HTTPException

from app.recognition.face_detector import (
    FaceDetector
)


class RecognitionService:

    @staticmethod
    def validate_face(
        image_path: str
    ):
        faces = FaceDetector.detect_faces(
            image_path
        )

        print("DEBUG FACES:", len(faces))
        print("DEBUG COORDS:", faces)

        count = len(faces)

        if count == 0:
            raise HTTPException(
                status_code=400,
                detail="FACE_001: No Face Detected"
            )

        if count > 1:
            raise HTTPException(
                status_code=400,
                detail="FACE_002: Multiple Faces Detected"
            )

        return True
