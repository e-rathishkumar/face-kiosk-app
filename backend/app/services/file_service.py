from pathlib import Path
from uuid import uuid4


class FileService:

    FACE_UPLOAD_DIR = Path(
        "uploads/faces"
    )

    FACE_UPLOAD_DIR.mkdir(
        parents=True,
        exist_ok=True
    )

    @staticmethod
    def save_face_image_bytes(filename: str, image_bytes: bytes):
        extension = filename.split(".")[-1]
        new_filename = f"{uuid4()}.{extension}"
        filepath = FileService.FACE_UPLOAD_DIR / new_filename

        with open(filepath, "wb") as buffer:
            buffer.write(image_bytes)

        return str(filepath)
