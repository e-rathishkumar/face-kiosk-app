import cv2
from fastapi import HTTPException

from app.recognition.insightface_service import (
    InsightFaceService
)


class FaceEmbedder:

    @staticmethod
    def generate_embedding(
        image_bytes: bytes
    ):
        import numpy as np
        image_array = np.frombuffer(image_bytes, np.uint8)
        image = cv2.imdecode(image_array, cv2.IMREAD_COLOR)

        faces = (
            InsightFaceService.app.get(
                image
            )
        )

        if len(faces) == 0:
            raise HTTPException(
                status_code=400,
                detail="FACE_001: No Face Detected"
            )

        if len(faces) > 1:
            raise HTTPException(
                status_code=400,
                detail="FACE_002: Multiple Faces Detected"
            )

        return (
            faces[0]
            .embedding
            .tolist()
        )
