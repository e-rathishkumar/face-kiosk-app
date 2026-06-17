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

    @staticmethod
    def save_face_image(upload_file):
        import shutil
        extension = upload_file.filename.split(".")[-1]
        new_filename = f"{uuid4()}.{extension}"
        filepath = FileService.FACE_UPLOAD_DIR / new_filename

        with filepath.open("wb") as buffer:
            shutil.copyfileobj(upload_file.file, buffer)

        return str(filepath)
